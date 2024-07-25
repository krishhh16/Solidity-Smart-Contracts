// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfigs, ConstantVariables} from "./HelperConfigs.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "test/mocks/LinkToken.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract CreateSubscription is Script, ConstantVariables {
    function createSubscriptionUsingConfig() public returns (uint, address) {
        HelperConfigs helperConfig = new HelperConfigs();
        address vrfCoordinator = helperConfig.getConfigs().vrfCoordinator;
        (uint subId, ) = createSubscription(vrfCoordinator);
        return (subId, vrfCoordinator);
    }

    function createSubscription(
        address vrfCoordinator
    ) public returns (uint, address) {
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

contract FundSubscription is Script {
    uint public constant FUND_AMOUNT = 3 ether;

    function fundSubscriptionUsingConfig() public {
        HelperConfigs helperConfig = new HelperConfigs();
        address vrfCoordinator = helperConfig.getConfigs().vrfCoordinator;
        uint subscriptionId = helperConfig.getConfigs().subscriptionId;
        address linkToken = helperConfig.getConfigs().link;
        fundSubscription(vrfCoordinator, subscriptionId, linkToken);
    }

    function fundSubscription(
        address vrfCoordinator,
        uint subscriptionId,
        address linkToken
    ) public {
        console.log("Funding subscription: ", subscriptionId);
        console.log("Using vrfCoordinator: ", vrfCoordinator);
        console.log("On ChainId", block.chainid);

        if(block.chainid == 31337){
            vm.startBroadcast();
            VRFCoordinatorV2_5Mock(vrfCoordinator).fundSubscription(subscriptionId, FUND_AMOUNT);
            vm.stopBroadcast();
        } else {
            vm.startBroadcast();
            LinkToken(linkToken).transferAndCall(vrfCoordinator, FUND_AMOUNT, abi.encode(subscriptionId));
            vm.stopBroadcast();

        }
    }

    function run() public {
        fundSubscriptionUsingConfig();
    }
}

contract AddConsumers is Script {
    function addConsumerUsingConfig(address mostRecentlyDeployed) public {
        HelperConfigs helperConfigs = new HelperConfigs();
        uint subId = helperConfigs.getConfigs().subscriptionId;
        address vrfCoordinator = helperConfigs.getConfigs().vrfCoordinator;
        addConsumer(mostRecentlyDeployed, vrfCoordinator, subId);
    }

    function addConsumer(address contractToAddtoVrf, address vrfCoordiator, uint subId) public {
            console.log("Adding consumer contract", contractToAddtoVrf);
            console.log("To vrfCoordinator: ", vrfCoordiator);
            console.log("ON chainid", block.chainid);

            vm.startBroadcast();
            VRFCoordinatorV2_5Mock(vrfCoordiator).addConsumer(subId, contractToAddtoVrf);
            vm.stopBroadcast(); 
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("Raffle",  block.chainid);
        addConsumerUsingConfig(mostRecentlyDeployed);
    }
}