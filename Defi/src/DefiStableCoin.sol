// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {ERC20Burnable, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Decentralized stable coin contract
 * @author Zeref
 * @notice This contract initializes the smart contract for my stable coin which will have a value of $1
 * This stable coin has the following features:
 * Minting: Algorithmic
 * Relative stability: Pegged($1)
 * Collatoral: Exogenous(wETH & wBTC)
 */

contract DefiProtocol is ERC20Burnable, Ownable {
    error DefiProtocol__NonPositiveAmount();
    error DefiProtocol__NotEnoughBalance();
    error DefiProtocol__InvalidAddressProvided();
    constructor() ERC20("Decentralizedstablecoin", "DSC") Ownable(msg.sender) {}

    function burn(uint _amount) public override onlyOwner {
        uint balance = balanceOf(msg.sender);
        if (_amount <= 0){
            revert DefiProtocol__NonPositiveAmount();
        }
        if (balance < _amount) {
            revert DefiProtocol__NotEnoughBalance();
        }
        super.burn(_amount);
    }

    function mint(address _to, uint _amount) external onlyOwner returns(bool){
        if (_to == address(0)){
            revert DefiProtocol__InvalidAddressProvided();
        }
        if (_amount <= 0){
            revert DefiProtocol__NonPositiveAmount();
        }
        _mint(_to, _amount);
        return true;
    }

}