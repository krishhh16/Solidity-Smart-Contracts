// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DeployNFT} from "script/DeployNFT.s.sol";
import {NFT} from "src/NFT.sol";

contract TestNFT is Test{
    DeployNFT deployedContract;
    NFT nftContract;
    address private USER = makeAddr("User");
    string public constant PUG_URI =
        "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json"; 
    
    function setUp() external {
        deployedContract = new DeployNFT();
        nftContract = deployedContract.run();
    }

    function hash(string memory _str) private pure returns(bytes32)  {
        return keccak256(abi.encodePacked(_str));
    }

    function testMintedNftFromUser() external {
        vm.prank(USER);
        nftContract.mintNFT(PUG_URI);

        assert(hash(PUG_URI) == hash(nftContract.tokenURI(0)));
    }    
    
}