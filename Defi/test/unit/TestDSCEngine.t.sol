// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DefiProtocol} from "src/DefiStableCoin.sol";
import {DeployDefiProtocol} from "script/DeployDefiStableCoin.s.sol";
import {console} from "forge-std/console.sol";
import {DSCEngine} from "src/DSCEngine.sol";
import {HelperConfigs} from "script/HelperConfigs.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";

contract TestDefiStableCoin is Test {
    DefiProtocol dsc;
    DSCEngine engine;
    HelperConfigs configs;
    address weth;
    address wbtc;
    address User = makeAddr("USER");
    function setUp() external {
        DeployDefiProtocol deployer = new DeployDefiProtocol();
        (dsc, engine, configs) = deployer.run();
        (,,weth,wbtc,) = configs.activeNetwork();
    }

    function testGetUsdPrice() external view {
        uint ethAmount = 15e18;

        uint expectedAmount = 30000e18;
        uint actualAmount = engine.getTokenPriceInUSD(weth, ethAmount);
        console.log(actualAmount, expectedAmount, actualAmount/expectedAmount);
        assert(expectedAmount == actualAmount);
    }

    function testRevertsIfCollatoralZero() external {
        vm.startPrank(User);
        ERC20Mock(weth).approve(address(engine), 10 ether);

        vm.expectRevert();
        engine.depositeCollatoral(weth, 0);
    }
}