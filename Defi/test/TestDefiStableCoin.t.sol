// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DefiProtocol} from "src/DefiStableCoin.sol";
import {DeployDefiProtocol} from "script/DeployDefiStableCoin.s.sol";
import {console} from "forge-std/console.sol";

contract TestDefiStableCoin is Test {
    DefiProtocol defiContract;
    DeployDefiProtocol deployScript;
    address USER = makeAddr("USER");

    function setUp() external {
        deployScript = new DeployDefiProtocol();
        defiContract = deployScript.run();
    }

}