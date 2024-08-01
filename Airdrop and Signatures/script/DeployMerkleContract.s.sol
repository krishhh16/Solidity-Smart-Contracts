// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {AirDrop} from "src/MerkleAirdrop.sol";
import {PainToken} from "src/PainToken.sol";
import {Script} from "forge-std/Script.sol";

contract DeployMerkleAirDrop is Script {
    bytes32 ROOT= 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint STARTING_AMOUNT = 4 * 25 * 1e18;

    function run () external returns (AirDrop, PainToken) {
        return deployScript();
    }

    function deployScript() internal returns (AirDrop, PainToken) {
        vm.startBroadcast();
        PainToken painToken = new PainToken();
        AirDrop airdrop = new AirDrop( ROOT, painToken);
        painToken.mint(painToken.owner(), STARTING_AMOUNT);
        painToken.transfer(address(airdrop), STARTING_AMOUNT);
        vm.stopBroadcast();

        return (airdrop, painToken);
    }
}