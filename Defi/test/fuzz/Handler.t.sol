// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DSCEngine} from "src/DSCEngine.sol";
import {DefiProtocol} from "src/DefiStableCoin.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";

contract Handler is Test{
    DSCEngine engine;
    DefiProtocol dsc;

    ERC20Mock weth;
    ERC20Mock wbtc;

    uint MAX_DEPOSIT_SIZE = type(uint96).max;

    constructor(DSCEngine _engine, DefiProtocol _dsc) {
        engine = _engine;
        dsc = _dsc;

        address[] memory collateralTokens = engine.getCollateralTokens();
        weth = ERC20Mock(collateralTokens[0]);
        wbtc = ERC20Mock(collateralTokens[1]);
    }

    function depositCollateral(uint collateralSeed, uint amountCollateral) public {
        ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);
        amountCollateral = bound(amountCollateral, 0 , MAX_DEPOSIT_SIZE);

        vm.startPrank(msg.sender);
        collateral.mint(msg.sender, amountCollateral);
        collateral.approve(address(engine), amountCollateral);
        engine.depositeCollatoral(address(collateral), amountCollateral);
    }


    function _getCollateralFromSeed(uint collateralSeed) private view returns (ERC20Mock) {
        if (collateralSeed %2 == 0){
            return weth;
        }
        return wbtc;
    }
}