// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {DefiProtocol} from "src/DefiStableCoin.sol";
import {DSCEngine} from "src/DSCEngine.sol";
import {HelperConfigs} from "./HelperConfigs.s.sol";
import {console} from "forge-std/console.sol";


contract DeployDefiProtocol is Script {
    address[] private tokenAddresses;
    address[] private priceFeed;

    function run() external returns(DefiProtocol, DSCEngine, HelperConfigs) {
        HelperConfigs configs = new HelperConfigs();
        
        (address wethUsdPriceFeed,
        address wbtcUsdPriceFeed,
        address weth,
        address wbtc,
        uint deployerKey) = configs.activeNetwork();
        tokenAddresses = [weth, wbtc];
        priceFeed = [wethUsdPriceFeed,wbtcUsdPriceFeed];
        vm.startBroadcast(deployerKey);
        DefiProtocol dsc = new DefiProtocol();
        DSCEngine engine = new DSCEngine(
            tokenAddresses,
            priceFeed,
            address(dsc)
        );
        vm.stopBroadcast();

        return (dsc, engine, configs);
    }

}