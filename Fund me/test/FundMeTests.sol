// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test,console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test{
    FundMe fundMe;
   
    address User = makeAddr("user");
    uint256 constant STARTING_BALANCE = 10 ether;
    function setUp() external{
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(User,STARTING_BALANCE );
    }
    


    function testMinimumDollarIsFive() view public{
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() view public{
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate()view public{
        uint version = fundMe.getVersion();
        assertEq(version,4);
    }

    function testExpectedRevert()  public {
        vm.expectRevert();
        fundMe.withdraw();
    }

    modifier sendFunds() {
        vm.prank(User);
        fundMe.fund{value: 0.1 ether}();
        _;
    }

    function testWhetherTheUserHasEnoughEth() public sendFunds {
        assertEq(fundMe.getAddressToAmount(User), 0.1 ether);
    }

    function testFunderExists() public sendFunds {
        assertEq(fundMe.getFunder(0), User);
    }

    function testOnlyOwnerCanWithdraw() public sendFunds {
        vm.prank(User);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public sendFunds {
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithMultipleFundsAndWithdraw() public sendFunds{ 
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), 0.1 ether);
            fundMe.fund{value: 0.1 ether}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
            fundMe.getOwner().balance
        );
    }

}
