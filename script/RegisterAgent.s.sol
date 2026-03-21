// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";

interface IPrismRegistry {
    function register(string calldata agentURI) external returns (uint256);
}

contract RegisterAgent is Script {
    function run() external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        address registry = vm.envAddress("REGISTRY");
        string memory agentURI = vm.envString("AGENT_URI");

        vm.startBroadcast(deployerKey);

        uint256 agentId = IPrismRegistry(registry).register(agentURI);
        console.log("AgentMotus registered with agentId:", agentId);

        vm.stopBroadcast();
    }
}
