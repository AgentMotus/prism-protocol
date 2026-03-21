// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IPrismFactory {
    struct ContextConfig {
        string contextType;     // "defi", "social", "browsing", "agent", etc.
        uint256 spendingLimit;  // max wei per tx
        uint256 dailyLimit;     // max wei per 24h window
        address[] allowlist;    // allowed target contracts (empty = any)
        uint256 ttl;            // seconds until auto-expire (0 = no expiry)
        address delegate;       // address allowed to operate this context (agent)
    }

    event ContextCreated(
        address indexed owner,
        address indexed contextAddress,
        string contextType,
        address delegate,
        uint256 salt
    );

    event ContextRevoked(
        address indexed owner,
        address indexed contextAddress
    );

    /// @notice Create a new context wallet from root identity
    function createContext(ContextConfig calldata config, uint256 salt) external returns (address);

    /// @notice Predict context address before creation (CREATE2)
    function predictAddress(address owner, uint256 salt) external view returns (address);

    /// @notice Get all contexts for an owner
    function getContexts(address owner) external view returns (address[] memory);

    /// @notice Revoke a context
    function revokeContext(address contextAddress) external;
}
