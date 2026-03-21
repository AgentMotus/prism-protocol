// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IPrismContext {
    /// @notice Execute a transaction from this context wallet
    function execute(address to, uint256 value, bytes calldata data) external returns (bytes memory);

    /// @notice Check if context is still active (not expired, not revoked)
    function isActive() external view returns (bool);

    /// @notice Get the root owner of this context
    function owner() external view returns (address);

    /// @notice Get the delegate (agent) authorized to operate
    function delegate() external view returns (address);

    /// @notice Get remaining daily spending allowance
    function remainingDailyAllowance() external view returns (uint256);

    /// @notice Revoke this context (owner or factory only)
    function revoke() external;
}
