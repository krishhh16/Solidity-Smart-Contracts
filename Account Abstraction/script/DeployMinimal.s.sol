// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MinimalAccount} from "src/MinimalAcc.sol";
import {HelperConfig} from "./HelperConfig.s.sol";


contract DeployMinimalAccount is Script {
    function run() public returns(MinimalAccount, HelperConfig) {
        return deployMinimalAccount();
    }

    function deployMinimalAccount() internal returns(MinimalAccount, HelperConfig) {
        HelperConfig helperconfigs = new HelperConfig();
        HelperConfig.NetworkConfig memory configs = helperconfigs.getConfig();

        vm.startBroadcast();
        MinimalAccount deployedAccount = new MinimalAccount(configs.entryPoint);
        vm.stopBroadcast();

        return (deployedAccount, helperconfigs);
    }
}
