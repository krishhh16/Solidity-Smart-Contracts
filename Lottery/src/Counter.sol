// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;

/**
 * @title Raffle Contract
 * @author Zeref
 * @notice This contract initializes the Raffle contract
 * @dev This contract utilizes the chainlinkv2.3
 */

contract RaffleContract {
    uint immutable entranceFee;

    constructor(uint _entranceFee) {
        entranceFee = _entranceFee;
    }

    function enterRaffle() external payable {

    }

    function prizeWinner() external {}

    /**
     * Getter functions are defined from this line forward
     */



}