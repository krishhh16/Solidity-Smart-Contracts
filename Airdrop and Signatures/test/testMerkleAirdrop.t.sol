// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {AirDrop} from "src/MerkleAirdrop.sol";
import {PainToken} from "src/PainToken.sol";
import {DeployMerkleAirDrop} from "script/DeployMerkleContract.s.sol";

contract TestMerkleAirdrop is Test {
    AirDrop airdrop;
    PainToken painToken;
    bytes32 ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    address user;
    uint userPrivateKey;    

    uint STARTING_BALANCE = 25 * 1e18;
    uint AMOUNT_FOR_CONTRACT = STARTING_BALANCE * 4;

    bytes32 proof1 = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proof2 = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] PROOF = [proof1, proof2];

    function setUp() external {
        DeployMerkleAirDrop deployer = new DeployMerkleAirDrop();
        (airdrop, painToken) = deployer.run();

        (user, userPrivateKey) = makeAddrAndKey("user");
    }

    function testUserCanClaim() external {
        uint startingBalance = painToken.balanceOf(user);
        
        vm.prank(user);
        airdrop.claim(user, STARTING_BALANCE, PROOF);

        uint endingBalance = painToken.balanceOf(user);
        assertEq(endingBalance - startingBalance , STARTING_BALANCE);        
    }


}