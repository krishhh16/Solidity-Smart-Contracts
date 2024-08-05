// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DeployMinimalAccount} from "script/DeployMinimal.s.sol";
import {MinimalAccount} from "src/MinimalAcc.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";


contract TestMinimalAccount is Test{ 
    MinimalAccount minimalAcc;
    HelperConfig configs;
    ERC20Mock usdc;
    uint constant AMOUNT = 1e18;
    address randomUser = makeAddr("random");

    function setUp() external {
        DeployMinimalAccount deployer = new DeployMinimalAccount();
        (minimalAcc, configs) = deployer.run();
        usdc = new ERC20Mock();
    }

    function testOwnerCanExecurteCommands() public {
        assertEq(usdc.balanceOf(address(minimalAcc)), 0);
        address dest = address(usdc);
        uint value = 0;
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAcc), AMOUNT);

        vm.prank(minimalAcc.owner());
        minimalAcc.execute(dest, value, functionData);


        assertEq(usdc.balanceOf(address(minimalAcc)),AMOUNT);
    }

    function testRecoverSignedOp() public view {
        
    }
}