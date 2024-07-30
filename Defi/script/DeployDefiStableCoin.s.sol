// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {DefiProtocol} from "src/DefiStableCoin.sol";

contract DeployDefiProtocol is Script {
    DefiProtocol defiContract;

    function run() external returns(DefiProtocol) {
        vm.startBroadcast();
        defiContract = new DefiProtocol();
        vm.stopBroadcast();
        return defiContract;
    }


}