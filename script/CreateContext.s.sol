// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";

interface IPrismFactory {
    struct ContextConfig {
        string contextType;
        uint256 spendingLimit;
        uint256 dailyLimit;
        address[] allowlist;
        uint256 ttl;
        address delegate;
    }
    function createContext(ContextConfig calldata config, uint256 salt) external returns (address);
}

contract CreateContext is Script {
    function run() external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        address factory = vm.envAddress("FACTORY");
        address delegate = vm.envAddress("DELEGATE");

        vm.startBroadcast(deployerKey);

        address[] memory allowlist = new address[](0); // no restrictions for demo

        IPrismFactory.ContextConfig memory config = IPrismFactory.ContextConfig({
            contextType: "agent",
            spendingLimit: 1 ether,        // max 1 CELO per tx
            dailyLimit: 5 ether,           // max 5 CELO per day
            allowlist: allowlist,
            ttl: 30 days,                  // expires in 30 days
            delegate: delegate
        });

        address context = IPrismFactory(factory).createContext(config, 1);
        console.log("Context wallet created:", context);
        console.log("Delegate (AgentMotus):", delegate);

        vm.stopBroadcast();
    }
}
