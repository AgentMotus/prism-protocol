// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IPrismRegistry {
    event AgentRegistered(uint256 indexed agentId, address indexed owner, string agentURI);
    event AgentURIUpdated(uint256 indexed agentId, string newURI);
    event AgentDeactivated(uint256 indexed agentId);
    event AgentReactivated(uint256 indexed agentId);
    event FeedbackSubmitted(uint256 indexed agentId, address indexed reviewer, uint8 score, string comment);

    /// @notice Register a new agent (mints ERC-721)
    function register(string calldata agentURI) external returns (uint256 agentId);

    /// @notice Update agent registration file URI
    function setAgentURI(uint256 agentId, string calldata newURI) external;

    /// @notice Deactivate an agent
    function deactivate(uint256 agentId) external;

    /// @notice Reactivate an agent
    function reactivate(uint256 agentId) external;

    /// @notice Submit reputation feedback (1-5 score)
    function submitFeedback(uint256 agentId, uint8 score, string calldata comment) external;

    /// @notice Get aggregate reputation score
    function getReputation(uint256 agentId) external view returns (uint256 totalScore, uint256 reviewCount);

    /// @notice Check if agent is active
    function isActive(uint256 agentId) external view returns (bool);
}
