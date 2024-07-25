// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {RaffleContract} from "src/Raffle.sol";
import {HelperConfigs} from "./HelperConfigs.s.sol";
import {CreateSubscription} from "./interactions.s.sol";

contract DeployRaffle is Script {
    function run() public {}

    function deployContract() external returns(RaffleContract, HelperConfigs) {
        HelperConfigs helperConfigs = new HelperConfigs();
        HelperConfigs.NetworkConfigs memory configs = helperConfigs.getConfigs();

        if(configs.subscriptionId == 0) {
            CreateSubscription createSubscription = new CreateSubscription();
            (configs.subscriptionId, configs.vrfCoordinator) = createSubscription.createSubscription(configs.vrfCoordinator);
        }

        vm.startBroadcast();
        RaffleContract raffle = new RaffleContract(
        //     uint _entranceFee,
        // uint interval,
        // address _vrfCoordinator,
        // uint subscriptionId,
        // uint32 callbackGasLimit,
        // bytes32 keyHash
        configs.entranceFee,
        configs.interval,
        configs.vrfCoordinator,
        configs.subscriptionId,
        configs.callbackGasLimit,
        configs.keyHash
        );
        vm.stopBroadcast();

        return (raffle, helperConfigs);
    }
}