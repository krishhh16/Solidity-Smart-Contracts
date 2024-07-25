// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
/**
 * @title Raffle Contract
 * @author Zeref
 * @notice This contract initializes the Raffle contract
 * @dev This contract utilizes the chainlink vrfv2.3
 */

contract RaffleContract is VRFConsumerBaseV2Plus {
    /*Error types*/
    error Raffle__NotEnoughCashStranger();
    error Raffle__TransactionFailed();
    error RaffleNotOpen();
    error RaffleHasNotEnded();

    /*Type Declaration*/
    enum RaffleIsOpen {
        OPEN,
        CALCULATING
    }


    /*State Variables */
    uint immutable s_entranceFee;
    address payable[] s_participants;
    // @dev duration of lottery in seconds
    uint immutable i_interval;
    uint immutable s_lastTimestamp;
    uint16 private constant REQUEST_CONFIRMATION = 3;
    uint32 private constant NUM_WORDS = 1;
    bytes32 private immutable i_keyHash;
    uint private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    address payable mostRecentWinner;
    RaffleIsOpen raffleOpen;

    event RaffleEntered();

    constructor(
        uint _entranceFee,
        uint interval, 
        address _vrfCoordinator,
        uint subscriptionId,
        uint32 callbackGasLimit,
        bytes32 keyHash
        ) VRFConsumerBaseV2Plus(_vrfCoordinator) {
        i_interval = interval;
        i_subscriptionId = subscriptionId;
        i_keyHash = keyHash;
        i_callbackGasLimit = callbackGasLimit;
        
        s_entranceFee = _entranceFee;
        s_lastTimestamp = block.timestamp;
        raffleOpen = RaffleIsOpen.OPEN;
    }

    function enterRaffle() external payable {
        if(msg.value < s_entranceFee) {
            revert Raffle__NotEnoughCashStranger();
        }
        s_participants.push(payable(msg.sender));

        emit RaffleEntered();
    }

    function prizeWinner() external {
        if((block.timestamp - s_lastTimestamp) < i_interval ){
            revert RaffleHasNotEnded();
        }
        if (raffleOpen != RaffleIsOpen.OPEN ){
            revert RaffleNotOpen();
        }

        uint requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: i_keyHash,
                subId: i_subscriptionId,
                requestConfirmations: REQUEST_CONFIRMATION,
                callbackGasLimit: i_callbackGasLimit,
                numWords: NUM_WORDS,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
        );
        raffleOpen = RaffleIsOpen.CALCULATING;

    }

     function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override{
        // Pick a random number between 0 and the length of the participants array
        address payable recentWinner = s_participants[randomWords[0] % s_participants.length];
        mostRecentWinner = recentWinner;

        raffleOpen = RaffleIsOpen.OPEN;
        (bool success,) = recentWinner.call{value: address(this).balance}("");

        if(!success) {
            revert Raffle__TransactionFailed();
        } 

     }
    /*
     * Getter functions are defined from this line forward
     */
    function getEntranceFee() external view returns (uint){
        return s_entranceFee;
    }


}
