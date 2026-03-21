// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./libraries/PrismErrors.sol";

/// @title PrismPaymaster — Sponsor gas for Prism context wallets
/// @notice Root wallets deposit CELO into the paymaster. Context wallets
///         can claim gas refunds after executing transactions, enabling
///         agents to operate gasless. The paymaster only sponsors wallets
///         created by an authorized PrismFactory.
contract PrismPaymaster {
    /// @notice Factory authorized to create sponsored contexts
    address public immutable factory;

    /// @notice Owner (deployer) for admin functions
    address public immutable owner;

    /// @notice Gas allowance per context wallet per day
    uint256 public dailyGasAllowance;

    /// @notice Tracking: context → sponsor (root wallet that funds it)
    mapping(address => address) public contextSponsor;

    /// @notice Tracking: sponsor → deposited balance
    mapping(address => uint256) public sponsorBalance;

    /// @notice Tracking: context → gas spent today
    mapping(address => uint256) public dailyGasUsed;

    /// @notice Tracking: context → current window start
    mapping(address => uint256) public windowStart;

    /// @notice Events
    event Deposited(address indexed sponsor, uint256 amount);
    event Withdrawn(address indexed sponsor, uint256 amount);
    event ContextSponsored(address indexed sponsor, address indexed context);
    event GasRefunded(address indexed context, uint256 amount);
    event DailyAllowanceUpdated(uint256 newAllowance);

    modifier onlyOwner() {
        if (msg.sender != owner) revert PrismErrors.Unauthorized();
        _;
    }

    constructor(address _factory, uint256 _dailyGasAllowance) {
        factory = _factory;
        owner = msg.sender;
        dailyGasAllowance = _dailyGasAllowance;
    }

    /// @notice Root wallet deposits CELO to sponsor its agents' gas
    function deposit() external payable {
        require(msg.value > 0, "Must deposit > 0");
        sponsorBalance[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    /// @notice Register a context wallet for gas sponsorship
    /// @dev Called by the root wallet after creating a context via factory
    function sponsorContext(address context) external {
        // Verify it's a real context from our factory
        (bool ok, bytes memory data) = factory.staticcall(
            abi.encodeWithSignature("isContext(address)", context)
        );
        require(ok && abi.decode(data, (bool)), "Not a valid Prism context");
        require(sponsorBalance[msg.sender] > 0, "No sponsor balance");
        require(contextSponsor[context] == address(0), "Already sponsored");

        contextSponsor[context] = msg.sender;
        emit ContextSponsored(msg.sender, context);
    }

    /// @notice Context wallet (or its delegate) claims gas refund after executing a tx
    /// @param gasUsed Amount of gas used (in wei value)
    function claimGasRefund(uint256 gasUsed) external {
        address sponsor = contextSponsor[msg.sender];
        require(sponsor != address(0), "Context not sponsored");

        // Reset daily window if 24h passed
        if (block.timestamp >= windowStart[msg.sender] + 24 hours) {
            dailyGasUsed[msg.sender] = 0;
            windowStart[msg.sender] = block.timestamp;
        }

        // Check daily allowance
        require(
            dailyGasUsed[msg.sender] + gasUsed <= dailyGasAllowance,
            "Daily gas allowance exceeded"
        );

        // Check sponsor has funds
        require(sponsorBalance[sponsor] >= gasUsed, "Sponsor insufficient funds");

        // Update state
        dailyGasUsed[msg.sender] += gasUsed;
        sponsorBalance[sponsor] -= gasUsed;

        // Refund gas to context
        (bool success, ) = msg.sender.call{value: gasUsed}("");
        require(success, "Refund transfer failed");

        emit GasRefunded(msg.sender, gasUsed);
    }

    /// @notice Pre-fund a context wallet directly (simpler flow)
    /// @dev Sponsor sends gas directly to context. No claim needed.
    function prefundContext(address context) external {
        address sponsor = contextSponsor[context];
        require(sponsor == msg.sender, "Not the sponsor");
        
        uint256 amount = dailyGasAllowance;
        if (amount > sponsorBalance[msg.sender]) {
            amount = sponsorBalance[msg.sender];
        }
        require(amount > 0, "No funds");

        sponsorBalance[msg.sender] -= amount;
        (bool success, ) = context.call{value: amount}("");
        require(success, "Prefund failed");

        emit GasRefunded(context, amount);
    }

    /// @notice Sponsor withdraws unused balance
    function withdraw(uint256 amount) external {
        require(sponsorBalance[msg.sender] >= amount, "Insufficient balance");
        sponsorBalance[msg.sender] -= amount;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Withdraw failed");
        emit Withdrawn(msg.sender, amount);
    }

    /// @notice Owner updates daily gas allowance
    function setDailyAllowance(uint256 newAllowance) external onlyOwner {
        dailyGasAllowance = newAllowance;
        emit DailyAllowanceUpdated(newAllowance);
    }

    /// @notice Check remaining gas allowance for a context today
    function remainingGasAllowance(address context) external view returns (uint256) {
        if (block.timestamp >= windowStart[context] + 24 hours) {
            return dailyGasAllowance;
        }
        if (dailyGasUsed[context] >= dailyGasAllowance) return 0;
        return dailyGasAllowance - dailyGasUsed[context];
    }

    /// @notice Accept direct CELO deposits
    receive() external payable {
        sponsorBalance[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }
}
