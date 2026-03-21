// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./interfaces/IPrismFactory.sol";
import "./PrismContext.sol";
import "./libraries/PrismErrors.sol";

/// @title PrismFactory — Derive context wallets from root identity
/// @notice Your wallet is your root identity. From it, you derive disposable
///         context wallets with granular permissions, delegated to agents.
///         If a context is compromised, only that context is affected.
///         Optionally auto-registers agents on the official ERC-8004 Identity Registry.
contract PrismFactory is IPrismFactory {
    mapping(address => address[]) private _ownerContexts;
    mapping(address => bool) public isContext;

    /// @notice Official ERC-8004 Identity Registry (8004scan.io)
    address public immutable erc8004Registry;

    /// @notice Events
    event AgentAutoRegistered(address indexed delegate, uint256 agentId, address registry);

    constructor(address _erc8004Registry) {
        erc8004Registry = _erc8004Registry;
    }

    /// @notice Create a new context wallet with CREATE2 deterministic address
    function createContext(ContextConfig calldata config, uint256 salt)
        external
        returns (address)
    {
        if (config.delegate == address(0)) revert PrismErrors.ZeroAddress();

        bytes32 create2Salt = keccak256(abi.encodePacked(msg.sender, salt));

        PrismContext context = new PrismContext{salt: create2Salt}(
            msg.sender,
            config.delegate,
            config.spendingLimit,
            config.dailyLimit,
            config.ttl,
            config.allowlist
        );

        address contextAddr = address(context);
        _ownerContexts[msg.sender].push(contextAddr);
        isContext[contextAddr] = true;

        emit ContextCreated(msg.sender, contextAddr, config.contextType, config.delegate, salt);
        return contextAddr;
    }

    /// @notice Create context + auto-register agent on official ERC-8004 registry
    /// @param config Context configuration with caveats
    /// @param salt Unique salt for CREATE2
    /// @param agentURI Registration file URI (IPFS, HTTPS, or data: URI)
    /// @return contextAddr The deployed context wallet address
    /// @return agentId The ERC-8004 agentId on the official registry
    function createContextAndRegister(
        ContextConfig calldata config,
        uint256 salt,
        string calldata agentURI
    ) external returns (address contextAddr, uint256 agentId) {
        if (config.delegate == address(0)) revert PrismErrors.ZeroAddress();

        bytes32 create2Salt = keccak256(abi.encodePacked(msg.sender, salt));

        PrismContext context = new PrismContext{salt: create2Salt}(
            msg.sender,
            config.delegate,
            config.spendingLimit,
            config.dailyLimit,
            config.ttl,
            config.allowlist
        );

        contextAddr = address(context);
        _ownerContexts[msg.sender].push(contextAddr);
        isContext[contextAddr] = true;

        emit ContextCreated(msg.sender, contextAddr, config.contextType, config.delegate, salt);

        // Auto-register on official ERC-8004 registry
        if (erc8004Registry != address(0)) {
            (bool success, bytes memory data) = erc8004Registry.call(
                abi.encodeWithSignature("register(string)", agentURI)
            );
            if (success && data.length >= 32) {
                agentId = abi.decode(data, (uint256));
                emit AgentAutoRegistered(config.delegate, agentId, erc8004Registry);
            }
        }
    }

    /// @notice Predict address before deployment
    function predictAddress(address owner_, uint256 salt) external view returns (address) {
        bytes32 create2Salt = keccak256(abi.encodePacked(owner_, salt));
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                create2Salt,
                keccak256(type(PrismContext).creationCode)
            )
        );
        return address(uint160(uint256(hash)));
    }

    /// @notice Get all contexts for a root wallet
    function getContexts(address owner_) external view returns (address[] memory) {
        return _ownerContexts[owner_];
    }

    /// @notice Revoke a context (owner only)
    function revokeContext(address contextAddress) external {
        PrismContext ctx = PrismContext(payable(contextAddress));
        if (ctx.owner() != msg.sender) revert PrismErrors.Unauthorized();
        ctx.revoke();
        emit ContextRevoked(msg.sender, contextAddress);
    }
}
