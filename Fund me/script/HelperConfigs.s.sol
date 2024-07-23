// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperContract is Script {
    struct NetworkConfigs {
        address priceFeed;
    }
    NetworkConfigs public activeNetworkConfigs;

    uint8 DECIMALS = 8;
    int256 INTIALS = 200e8;
    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfigs = getSepoliaEthConfigs();
        } else {
            activeNetworkConfigs = getAnvilEthConfigs();
        }
    }

    function getSepoliaEthConfigs() public pure returns (NetworkConfigs memory) {
        NetworkConfigs memory s_priceFeed = NetworkConfigs({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return s_priceFeed;
    } 

    
    function getAnvilEthConfigs() public returns (NetworkConfigs memory) {
        vm.startBroadcast();
        MockV3Aggregator mockv3agg = new MockV3Aggregator(DECIMALS, INTIALS);
        vm.stopBroadcast();

        NetworkConfigs memory a_priceFeed = NetworkConfigs({
            priceFeed: address(mockv3agg)
        });

        return a_priceFeed; 
    } 

    
}