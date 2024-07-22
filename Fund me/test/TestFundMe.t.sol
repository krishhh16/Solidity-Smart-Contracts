//SPDX-Licence-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {FundMe} from "../src/FundMe.sol";

contract TestFundMe is Test {
    FundMe fundme;

    function setUp() external {
        fundme = new FundMe();
    }

    function testMinimumUsd() public {
        console.log('Hello world');

        assertEq(fundme.MINIMUM_USD(), 5e18);
    }
}