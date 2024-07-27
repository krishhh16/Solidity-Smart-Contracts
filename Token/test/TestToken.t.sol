// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;
import {Token} from "src/Token.sol";
import {Test, console} from "forge-std/Test.sol";
import {DeployToken} from "script/DeployToken.s.sol";

contract TestToken is Test{
    DeployToken private deployedContract;
    Token private tokenContract;
    address bob = makeAddr("bob");
    address alice = makeAddr("alice");
    uint private INITIAL_BALANCE = 100 ether;

    function setUp() public {
        deployedContract = new DeployToken();
        tokenContract = deployedContract.run();
        vm.prank(msg.sender);
        tokenContract.transfer(bob, INITIAL_BALANCE);
    }

    function testBobInitialBalance() external view{
        console.log(tokenContract.balanceOf(bob));
        assertEq(tokenContract.balanceOf(bob), INITIAL_BALANCE);
    }

    function testAliceAllowedTheRightAmountToSpendafterApprove() external {
        uint sendAmount = 10 ether;

        vm.prank(bob);
        tokenContract.approve(alice, sendAmount);

        assert(tokenContract.allowance(bob, alice) == sendAmount);
    }

    function testTransfer() external {
    uint transferAmount = 50 ether;

    vm.prank(bob);
    tokenContract.transfer(alice, transferAmount);

    assertEq(tokenContract.balanceOf(bob), INITIAL_BALANCE - transferAmount);
    assertEq(tokenContract.balanceOf(alice), transferAmount);
}
    function testTransferToZeroAddress() external {
    uint transferAmount = 50 ether;

    vm.prank(bob);
    vm.expectRevert();
    tokenContract.transfer(address(0), transferAmount);
}

    function testTransferInsufficientBalance() external {
        uint transferAmount = 200 ether; // more than INITIAL_BALANCE

        vm.prank(bob);
        vm.expectRevert();
        tokenContract.transfer(alice, transferAmount);
    }

    function testTransferFrom() external {
        uint approveAmount = 50 ether;
        uint transferAmount = 20 ether;

        vm.prank(bob);
        tokenContract.approve(alice, approveAmount);

        vm.prank(alice);
        tokenContract.transferFrom(bob, alice, transferAmount);

        assertEq(tokenContract.balanceOf(bob), INITIAL_BALANCE - transferAmount);
        assertEq(tokenContract.balanceOf(alice), transferAmount);
        assertEq(tokenContract.allowance(bob, alice), approveAmount - transferAmount);
}
    function testTransferFromWithoutApproval() external {
        uint transferAmount = 20 ether;

        vm.prank(alice);
        vm.expectRevert();
        tokenContract.transferFrom(bob, alice, transferAmount);
}

    function testTransferFromInsufficientAllowance() external {
        uint approveAmount = 10 ether;
        uint transferAmount = 20 ether;

        vm.prank(bob);
        tokenContract.approve(alice, approveAmount);

        vm.prank(alice);
        vm.expectRevert();
        tokenContract.transferFrom(bob, alice, transferAmount);
}
    

    
}
