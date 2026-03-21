// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./interfaces/IPrismContext.sol";
import "./libraries/PrismErrors.sol";

/// @title PrismContext — Disposable smart wallet with caveats
/// @notice Each context is a compartmentalized wallet derived from a root identity.
///         If compromised, only this context is affected — not the root wallet.
contract PrismContext is IPrismContext {
    address private immutable _owner;       // root wallet
    address private immutable _delegate;    // agent or operator
    address private immutable _factory;     // PrismFactory
    uint256 private immutable _spendingLimit;  // max per tx
    uint256 private immutable _dailyLimit;     // max per 24h
    uint256 private immutable _expiresAt;      // 0 = never
    address[] private _allowlist;

    bool public revoked;
    uint256 public dailySpent;
    uint256 public currentWindowStart;

    modifier onlyAuthorized() {
        if (msg.sender != _owner && msg.sender != _delegate && msg.sender != _factory)
            revert PrismErrors.Unauthorized();
        _;
    }

    modifier onlyOwnerOrFactory() {
        if (msg.sender != _owner && msg.sender != _factory)
            revert PrismErrors.Unauthorized();
        _;
    }

    modifier whenActive() {
        if (revoked) revert PrismErrors.ContextRevoked();
        if (_expiresAt != 0 && block.timestamp > _expiresAt) revert PrismErrors.ContextExpired();
        _;
    }

    constructor(
        address owner_,
        address delegate_,
        uint256 spendingLimit_,
        uint256 dailyLimit_,
        uint256 ttl_,
        address[] memory allowlist_
    ) {
        _owner = owner_;
        _delegate = delegate_;
        _factory = msg.sender;
        _spendingLimit = spendingLimit_;
        _dailyLimit = dailyLimit_;
        _expiresAt = ttl_ > 0 ? block.timestamp + ttl_ : 0;
        _allowlist = allowlist_;
        currentWindowStart = block.timestamp;
    }

    /// @notice Execute a transaction within caveats
    function execute(address to, uint256 value, bytes calldata data)
        external
        onlyAuthorized
        whenActive
        returns (bytes memory)
    {
        // Check per-tx spending limit
        if (_spendingLimit > 0 && value > _spendingLimit)
            revert PrismErrors.SpendingLimitExceeded();

        // Check daily limit (reset window if 24h passed)
        if (_dailyLimit > 0) {
            if (block.timestamp >= currentWindowStart + 24 hours) {
                dailySpent = 0;
                currentWindowStart = block.timestamp;
            }
            if (dailySpent + value > _dailyLimit)
                revert PrismErrors.SpendingLimitExceeded();
            dailySpent += value;
        }

        // Check allowlist
        if (_allowlist.length > 0) {
            bool allowed = false;
            for (uint256 i = 0; i < _allowlist.length; i++) {
                if (_allowlist[i] == to) {
                    allowed = true;
                    break;
                }
            }
            if (!allowed) revert PrismErrors.ContractNotAllowed();
        }

        // Execute
        (bool success, bytes memory result) = to.call{value: value}(data);
        require(success, "PrismContext: execution failed");
        return result;
    }

    function isActive() external view returns (bool) {
        if (revoked) return false;
        if (_expiresAt != 0 && block.timestamp > _expiresAt) return false;
        return true;
    }

    function owner() external view returns (address) { return _owner; }
    function delegate() external view returns (address) { return _delegate; }

    function remainingDailyAllowance() external view returns (uint256) {
        if (_dailyLimit == 0) return type(uint256).max;
        if (block.timestamp >= currentWindowStart + 24 hours) return _dailyLimit;
        if (dailySpent >= _dailyLimit) return 0;
        return _dailyLimit - dailySpent;
    }

    function revoke() external onlyOwnerOrFactory {
        revoked = true;
    }

    /// @notice Accept ETH deposits
    receive() external payable {}
}
