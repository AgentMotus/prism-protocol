// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./interfaces/IPrismRegistry.sol";
import "./libraries/PrismErrors.sol";

/// @title PrismRegistry — ERC-8004 Agent Identity & Reputation Registry
/// @notice Agents are registered as ERC-721 NFTs. Each token resolves to a
///         registration file (JSON on IPFS/HTTPS) describing the agent's
///         capabilities, services, and trust preferences.
///         Reputation feedback is stored onchain for composability.
contract PrismRegistry is ERC721URIStorage, IPrismRegistry {
    uint256 private _nextAgentId = 1;
    mapping(uint256 => bool) private _active;

    // Reputation
    struct Feedback {
        address reviewer;
        uint8 score;       // 1-5
        string comment;
        uint256 timestamp;
    }

    mapping(uint256 => Feedback[]) private _feedback;
    mapping(uint256 => uint256) private _totalScore;

    constructor() ERC721("Prism Agent Registry", "PRISM-AGENT") {}

    /// @notice Register a new agent — mints an NFT with agentURI
    function register(string calldata agentURI) external returns (uint256 agentId) {
        if (bytes(agentURI).length == 0) revert PrismErrors.InvalidURI();

        agentId = _nextAgentId++;
        _safeMint(msg.sender, agentId);
        _setTokenURI(agentId, agentURI);
        _active[agentId] = true;

        emit AgentRegistered(agentId, msg.sender, agentURI);
    }

    /// @notice Update the registration file URI
    function setAgentURI(uint256 agentId, string calldata newURI) external {
        if (ownerOf(agentId) != msg.sender) revert PrismErrors.Unauthorized();
        if (bytes(newURI).length == 0) revert PrismErrors.InvalidURI();
        _setTokenURI(agentId, newURI);
        emit AgentURIUpdated(agentId, newURI);
    }

    /// @notice Deactivate an agent
    function deactivate(uint256 agentId) external {
        if (ownerOf(agentId) != msg.sender) revert PrismErrors.Unauthorized();
        _active[agentId] = false;
        emit AgentDeactivated(agentId);
    }

    /// @notice Reactivate an agent
    function reactivate(uint256 agentId) external {
        if (ownerOf(agentId) != msg.sender) revert PrismErrors.Unauthorized();
        _active[agentId] = true;
        emit AgentReactivated(agentId);
    }

    /// @notice Submit reputation feedback (anyone can review)
    function submitFeedback(uint256 agentId, uint8 score, string calldata comment) external {
        if (!_exists(agentId)) revert PrismErrors.AgentNotFound();
        require(score >= 1 && score <= 5, "Score must be 1-5");

        _feedback[agentId].push(Feedback({
            reviewer: msg.sender,
            score: score,
            comment: comment,
            timestamp: block.timestamp
        }));
        _totalScore[agentId] += score;

        emit FeedbackSubmitted(agentId, msg.sender, score, comment);
    }

    /// @notice Get aggregate reputation
    function getReputation(uint256 agentId) external view returns (uint256 totalScore, uint256 reviewCount) {
        return (_totalScore[agentId], _feedback[agentId].length);
    }

    /// @notice Check if agent is active
    function isActive(uint256 agentId) external view returns (bool) {
        return _active[agentId];
    }

    /// @notice Check if token exists (internal helper exposed)
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }
}
