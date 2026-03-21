// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../contracts/PrismFactory.sol";
import "../contracts/PrismRegistry.sol";

contract Deploy is Script {
    function run() external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerKey);

        PrismFactory factory = new PrismFactory();
        PrismRegistry registry = new PrismRegistry();

        console.log("PrismFactory:", address(factory));
        console.log("PrismRegistry:", address(registry));

        vm.stopBroadcast();
    }
}
