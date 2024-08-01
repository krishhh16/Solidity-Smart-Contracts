// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract PainToken is ERC20, Ownable{

    constructor() ERC20("PAIN", "PN") Ownable(msg.sender) {

    }

    function mint(address _to, uint _amount) public onlyOwner {
        _mint(_to, _amount);
    }

}