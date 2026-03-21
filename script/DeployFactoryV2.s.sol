// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../contracts/PrismFactory.sol";

contract DeployFactoryV2 is Script {
    function run() external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerKey);

        // Official ERC-8004 registry on Celo mainnet (8004scan.io)
        address erc8004Registry = 0x8004A169FB4a3325136EB29fA0ceB6D2e539a432;

        PrismFactory factory = new PrismFactory(erc8004Registry);
        console.log("PrismFactory V2:", address(factory));
        console.log("Integrated with ERC-8004 Registry:", erc8004Registry);

        vm.stopBroadcast();
    }
}
