// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

contract BoxV2 {
    uint number;

    function getNumber() external view returns(uint) {
        return number;
    }

    function getVersion() external pure returns(uint) {
        return 2;
    }

    function setNumber(uint _num) external  {
        number = _num;
    }

}