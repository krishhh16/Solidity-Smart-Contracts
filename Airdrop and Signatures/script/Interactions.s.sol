// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {AirDrop} from "src/MerkleAirdrop.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract ClaimAirDrop is Script {
    address CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    bytes32 proof1 = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32 proof2 = 0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32[] PROOF = [proof2, proof1];
    uint CLAIMING_AMOUNT  = 25 * 1e18; 
    bytes private SIGNATURE = hex"4d783a71faa0f097a9b6a44e1fdd7a1532f48cdcf584b4a7df8632ca5842b7f7482226c83b0fa8e6e8dfe9ac1571b0a3b2d5783f003cee332f00c9309cb39cf31c";
    error CLAIN_AIRDROP__INVALID_SIGNATURE_LENGTH();

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("AirDrop", block.chainid);
        claimAirDrop(mostRecentlyDeployed);
    }

    function claimAirDrop(address airdrop) internal {
        vm.startBroadcast();
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(SIGNATURE);
        AirDrop(airdrop).claim(CLAIMING_ADDRESS, CLAIMING_AMOUNT, PROOF, v, r, s);
        vm.stopBroadcast();
    }

    function splitSignature(bytes memory sig) internal pure returns(uint8 v, bytes32 r, bytes32 s) {
        if (sig.length != 65) { // bytes of v + r + s(since v == 1 bytes here)
            revert CLAIN_AIRDROP__INVALID_SIGNATURE_LENGTH();
        }

            assembly {
                r := mload(add(sig, 32))
                s := mload(add(sig, 64))
                v := byte(0, mload(add(sig, 96)))
            }
    }
}