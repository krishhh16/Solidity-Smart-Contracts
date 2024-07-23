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
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate()view public{
        uint version = fundMe.getVersion();
        assertEq(version,4);
    }

    function testExpectedRevert()  public {
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWhetherTheUserHasEnoughEth() public {
        vm.prank(User); //sends the transaction as address User
        fundMe.fund{value: 0.1 ether}();

        assertEq(fundMe.getAddressToAmount(User), 0.1 ether);
    }
}
