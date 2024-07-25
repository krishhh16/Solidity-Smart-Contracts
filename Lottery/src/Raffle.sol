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
    error Raffle_NotEnoughCashStranger();

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

    event RaffleEntered();

    constructor(
        uint _entranceFee,
        uint interval, 
        address _vrfCoordinator,
        uint subscriptionId,
        uint32 callbackGasLimit,
        bytes32 keyHash
        ) VRFConsumerBaseV2Plus(_vrfCoordinator) {
        s_entranceFee = _entranceFee;
        i_interval = interval;
        s_lastTimestamp = block.timestamp;
        i_subscriptionId = subscriptionId;
        i_keyHash = keyHash;
        i_callbackGasLimit = callbackGasLimit;
    }

    function enterRaffle() external payable {
        if(msg.value < s_entranceFee) {
            revert Raffle_NotEnoughCashStranger();
        }
        s_participants.push(payable(msg.sender));

        emit RaffleEntered();
    }

    function prizeWinner() external {
        if((block.timestamp - s_lastTimestamp) < i_interval ){
            revert();
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

    }

     function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override{}
    /*
     * Getter functions are defined from this line forward
     */
    function getEntranceFee() external view returns (uint){
        return s_entranceFee;
    }


}