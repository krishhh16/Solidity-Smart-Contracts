// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {DeployRaffle} from "script/DeployRaffle.s.sol";
import {RaffleContract} from "src/Raffle.sol";
import {HelperConfigs} from "script/HelperConfigs.s.sol";

contract RaffleTest is Test {
    RaffleContract public raffle;
    HelperConfigs public helperConfig;
    uint entranceFee;
    uint interval;
    address vrfCoordinator;
    uint subscriptionId;
    uint32 callbackGasLimit;
    bytes32 keyHash;

    address public User = makeAddr("person");
    uint public constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        DeployRaffle deployer = new DeployRaffle();
        (raffle, helperConfig) = deployer.deployContract();
        HelperConfigs.NetworkConfigs memory configs = helperConfig.getConfigs();

        entranceFee = configs.entranceFee;
        interval = configs.interval;
        vrfCoordinator = configs.vrfCoordinator;
        subscriptionId = configs.subscriptionId;
        callbackGasLimit = configs.callbackGasLimit;
        keyHash = configs.keyHash;
    }

    function testRaffleInitializesToOpen() external view {
        assert(raffle.getRaffleState() == RaffleContract.RaffleIsOpen.OPEN);
    }
}
