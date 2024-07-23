// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";

contract HelperContract is Script {
    struct NetworkConfigs {
        address priceFeed;
    }
    NetworkConfigs public activeNetworkConfigs;

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

    
    function getAnvilEthConfigs() public pure returns (NetworkConfigs memory) {
        // Yet to change the configs
        NetworkConfigs memory s_priceFeed = NetworkConfigs({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return s_priceFeed;
    } 

    
}