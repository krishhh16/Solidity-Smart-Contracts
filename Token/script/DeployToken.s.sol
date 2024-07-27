// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;
import {Token} from "src/Token.sol";
import {Script} from "forge-std/Script.sol";


contract DeployToken is Script {
    uint constant INITIAL_SUPPLY = 100 ether;

    function run() public returns (Token){
        vm.startBroadcast();
        Token tokenContract = new Token(INITIAL_SUPPLY);
        vm.stopBroadcast();
        return tokenContract;
    }
}