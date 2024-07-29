// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {DeployRaffle} from "script/DeployRaffle.s.sol";
import {RaffleContract} from "src/Raffle.sol";
import {HelperConfigs} from "script/HelperConfigs.s.sol";
import {Vm} from "forge-std/Vm.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

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

    event RaffleEntered(address indexed player);
    event WinnerPicked(address indexed winner);

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

        vm.deal(User, STARTING_BALANCE);
    }

    function testRaffleInitializesToOpen() external view {
        assert(raffle.getRaffleState() == RaffleContract.RaffleIsOpen.OPEN);
    }

    function testShouldRevertIfMoneyNotEnough() public {
        vm.prank(User);
        vm.expectRevert(RaffleContract.Raffle__NotEnoughCashStranger.selector);
        raffle.enterRaffle();
    }

    function testShouldIncrementTheParticipants() public {
        vm.prank(User);
        raffle.enterRaffle{value: entranceFee}();

        address participantAddress = raffle.getParticipantsFromIndex(0);

        assert(participantAddress == User);
    }

    function testEnteringRaffleEmitsEvent() public {
        vm.prank(User);
        vm.expectEmit(true, false, false, false, address(raffle));
        emit RaffleEntered(User);

        raffle.enterRaffle{value: entranceFee}();
    }

    modifier raffleEntered() {
        vm.prank(User);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        _;
    }
    
    function testDontAllowPlayersToEnterWhileRaffleCalculating() public raffleEntered {
        raffle.performUpkeep("");

        vm.expectRevert(RaffleContract.Raffle__RaffleNotOpen.selector);
        vm.prank(User);
        raffle.enterRaffle{value: entranceFee}();
    }

    function testCheckUpkeepReturnsFalseIfItHasNoBalance() public {
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        (bool upkeepNeeded, ) = raffle.checkUpkeep("");
        assert(!upkeepNeeded);
    }

    function testUpkeepReturnsFalseIfRaffleIsntOpen() public {
        vm.prank(User);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        raffle.performUpkeep("");

        (bool upkeepNeeded, ) = raffle.checkUpkeep("");
        assert(!upkeepNeeded);
    }

     function testCheckUpkeepReturnsTrueWhenParametersGood() public raffleEntered {
        (bool upkeepNeeded,) = raffle.checkUpkeep("");

        assert(upkeepNeeded);
    }
    
    function testPerformUpkeepRevertsIfCheckUpkeepIsFalse() public {
        uint currentBalance = 0;
        uint numPlayers = 0;
        RaffleContract.RaffleIsOpen rState = raffle.getRaffleState();

        vm.prank(User);
        raffle.enterRaffle{value: entranceFee}();
        currentBalance = currentBalance + entranceFee;
        numPlayers = 1;


        vm.expectRevert(
            abi.encodeWithSelector(RaffleContract.Raffle_UpkeepNotNeeded.selector, currentBalance, numPlayers, rState)
        );
        raffle.performUpkeep("");
    }

    function testPerformUpkeepUpdatesRaffleStateAndEmitsRequestId() public  raffleEntered{
        vm.recordLogs();
        raffle.performUpkeep("");

        Vm.Log[] memory entries = vm.getRecordedLogs();

        console.log(uint(entries[1].topics[1]));

        RaffleContract.RaffleIsOpen raffleState = raffle.getRaffleState();

        assert(uint(raffleState) > 0);
        assert(uint(raffleState) == 1);

    }

    function testFulfillrandomWordsPicksAWinnerResetsAndSendsMoney() public raffleEntered{
        uint additionalEntrants = 3;
        uint startingIndex = 1;
        address expectedWinner = address(1);

        for (uint i = startingIndex; i< startingIndex + additionalEntrants; i++ ){
            address newPlayer = address(uint160(i));
            hoax(newPlayer, 1 ether);
            raffle.enterRaffle{value: entranceFee}();
        }

        uint startingTimestamp = raffle.getLastTimestamp();
        uint winnerStartingBalance = expectedWinner.balance;

        vm.recordLogs();
        raffle.performUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requesId = entries[1].topics[1];
        console.log("REquest Id: " , uint(entries[1].topics[1]));
        VRFCoordinatorV2_5Mock(vrfCoordinator).fulfillRandomWords(uint256(requesId), address(raffle));

        address recentWinner = raffle.getRecentWinner();
        RaffleContract.RaffleIsOpen raffleState = raffle.getRaffleState();
        uint winnerBalance = recentWinner.balance;
        uint endingTimestamp = raffle.getLastTimestamp();
        uint prize = entranceFee * (additionalEntrants + 1);


        assert(recentWinner == expectedWinner);
        assert(uint(raffleState) == 0);
        assert(winnerBalance == winnerStartingBalance + prize);
        assert(endingTimestamp > startingTimestamp);

    }

}
