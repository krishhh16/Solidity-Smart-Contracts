// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfigs} from "./HelperConfigs.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract CreateSubscription is Script {
    function createSubscriptionUsingConfig() public returns (uint, address){
        HelperConfigs helperConfig = new HelperConfigs();
        address vrfCoordinator = helperConfig.getConfigs().vrfCoordinator;
        (uint subId, ) = createSubscription(vrfCoordinator);
        return (subId, vrfCoordinator);
    }

    function createSubscription(address vrfCoordinator) public 
    returns (uint, address) {
        console.log("Creating subscription on chain Id: ", block.chainid);
        vm.startBroadcast();
        uint subId = VRFCoordinatorV2_5Mock(vrfCoordinator)
            .createSubscription();
        vm.stopBroadcast();

        console.log("your subscription id is: ", subId);
        console.log(
            "Please update the subscription id in your HelperConfigs.s.sol"
        );
        return (subId, vrfCoordinator);
    }

    function run() public {
        createSubscriptionUsingConfig();
    }
}
