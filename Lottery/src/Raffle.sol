// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;

/**
 * @title Raffle Contract
 * @author Zeref
 * @notice This contract initializes the Raffle contract
 * @dev This contract utilizes the chainlink vrfv2.3
 */

contract RaffleContract {
    error Raffle_NotEnoughCashStranger();

    uint immutable s_entranceFee;
    address payable[] s_participants;
    // @dev duration of lottery in seconds
    uint immutable i_interval;
    uint immutable s_lastTimestamp;

    event RaffleEntered();

    constructor(uint _entranceFee, uint interval) {
        s_entranceFee = _entranceFee;
        i_interval = interval;
        s_lastTimestamp = block.timestamp;
    }

    function enterRaffle() external payable {
        if(msg.value < s_entranceFee) {
            revert Raffle_NotEnoughCashStranger();
        }
        s_participants.push(payable(msg.sender));

        emit RaffleEntered();
    }

    function prizeWinner() external view {
        if((block.timestamp - s_lastTimestamp) < i_interval ){
            revert();
        }

    }

    /*
     * Getter functions are defined from this line forward
     */
    function getEntranceFee() external view returns (uint){
        return s_entranceFee;
    }


}