// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "src/FundMe.sol";
import {HelperContract} from "./HelperConfigs.s.sol";
contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        HelperContract helperConfigs = new HelperContract();
        address ethConfigs = helperConfigs.activeNetworkConfigs();
        vm.startBroadcast();
        FundMe fundme = new FundMe(ethConfigs);
        vm.stopBroadcast();
        return fundme;
    }
}