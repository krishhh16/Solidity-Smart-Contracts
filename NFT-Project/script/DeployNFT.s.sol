// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {NFT} from "src/NFT.sol";

contract DeployNFT is Script{
    function run() external returns(NFT) {
        vm.startBroadcast();
        NFT nftContract = new NFT();
        vm.stopBroadcast();
        return nftContract;
    }
}