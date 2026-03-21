// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../contracts/PrismPaymaster.sol";

contract DeployPaymaster is Script {
    function run() external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerKey);

        // PrismFactory V2 on Celo mainnet
        // Support both V1 and V2 contexts
        address factory = 0xaC39210F2dBcD120D9bCDE7DEeF04f2c30F8E24F; // V1 (existing contexts)

        // Daily gas allowance: 0.05 CELO per context per day
        uint256 dailyAllowance = 0.05 ether;

        PrismPaymaster paymaster = new PrismPaymaster(factory, dailyAllowance);
        console.log("PrismPaymaster:", address(paymaster));

        vm.stopBroadcast();
    }
}
