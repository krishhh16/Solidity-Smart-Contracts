// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {UUPSUpgradeable} from "@openzeppelin/contracts-ownable/proxy/utils/UUPSUpgradeable.sol";

contract BoxV2 is  UUPSUpgradeable {
    uint number;
    
    function _authorizeUpgrade(address newImplementation) internal override{}

    function getNumber() external view returns(uint) {
        return number;
    }

    function getVersion() external pure returns(uint) {
        return 1;
    }

    function setNumber(uint _num) external  {
        number = _num;
    }

}