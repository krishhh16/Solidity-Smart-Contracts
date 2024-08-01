// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {StdInvariant} from 'forge-std/StdInvariant.sol';
import {DSCEngine} from "src/DSCEngine.sol";
import {DefiProtocol} from "src/DefiStableCoin.sol";
import {HelperConfigs} from "script/HelperConfigs.s.sol";
import {DeployDefiProtocol} from "script/DeployDefiStableCoin.s.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Handler} from "./Handler.t.sol";

contract InvariantTest is StdInvariant, Test {
    DeployDefiProtocol deployer;
    DSCEngine engine;
    DefiProtocol dsc;
    HelperConfigs configs;
    address weth;
    address wbtc;
    Handler handler;

    function setUp() external {
        deployer = new DeployDefiProtocol();
        (dsc, engine, configs) = deployer.run();
        handler = new Handler(engine, dsc);
        (,,weth, wbtc,) = configs.activeNetwork();
        targetContract(address(handler));
    }   

    function invariant_protocolMustHaveMoreValueThanTotalSupply() public view {
        uint totalSupply = dsc.totalSupply();
        uint totalWethDeposited = IERC20(weth).balanceOf(address(engine));
        uint totalBtcDeposited = IERC20(wbtc).balanceOf(address(engine));

        uint wethValue = engine.getTokenPriceInUSD(weth, totalWethDeposited);
        uint wbtcValue = engine.getTokenPriceInUSD(wbtc, totalBtcDeposited);

        assert(wethValue + wbtcValue >= totalSupply);
    }
}