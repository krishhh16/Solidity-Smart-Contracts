// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {RaffleContract} from "src/Raffle.sol";
import {HelperConfigs} from "./HelperConfigs.s.sol";
import {CreateSubscription, FundSubscription, AddConsumers} from "./interactions.s.sol";

contract DeployRaffle is Script {
    function run() public {}

    function deployContract() external returns(RaffleContract, HelperConfigs) {
        HelperConfigs helperConfigs = new HelperConfigs();
        HelperConfigs.NetworkConfigs memory configs = helperConfigs.getConfigs();

        if(configs.subscriptionId == 0) {
            CreateSubscription createSubscription = new CreateSubscription();
            (configs.subscriptionId, configs.vrfCoordinator) = createSubscription.createSubscription(configs.vrfCoordinator, configs.account);

            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(configs.vrfCoordinator, configs.subscriptionId, configs.link, configs.account);
        }

        vm.startBroadcast(configs.account);
        RaffleContract raffle = new RaffleContract(
        configs.entranceFee,
        configs.interval,
        configs.vrfCoordinator,
        configs.subscriptionId,
        configs.callbackGasLimit,
        configs.keyHash
        );
        vm.stopBroadcast();

        AddConsumers addconsumer = new AddConsumers();
        addconsumer.addConsumer(address(raffle), configs.vrfCoordinator, configs.subscriptionId,configs.account);
        return (raffle, helperConfigs);
    }
}