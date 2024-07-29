// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;
import {Script} from "forge-std/Script.sol";
import {NFT} from "src/NFT.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {DynamicNFT} from "src/DynamicNFT.sol";
import {console} from "forge-std/console.sol";

contract MintBasicNFT is Script {
    string public constant PUG_URI =
        "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json"; 
    
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "NFT",
            block.chainid
        );
        mintNftOrContract(mostRecentlyDeployed);
    }

    function mintNftOrContract(address _address) private {
        vm.startBroadcast();
        NFT(_address).mintNFT(PUG_URI);
        vm.stopBroadcast();
    }
}
