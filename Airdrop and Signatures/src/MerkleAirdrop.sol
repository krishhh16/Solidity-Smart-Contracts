// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
contract AirDrop {
    using SafeERC20 for IERC20;
    error AirDrop__FailedToVerify();

    event ClaimToken(address to, uint amount);

    bytes32 immutable  i_merkleRoot;
    IERC20 private immutable i_airdropToken;

    constructor(bytes32 _merkleRoot, IERC20 _airdropToken) {
        i_merkleRoot = _merkleRoot;
        i_airdropToken = _airdropToken;
    }

    function claim(address _account, uint _amount, bytes32[] memory merkleProof ) external {
        bytes32 leaf = keccak256(abi.encode(keccak256(abi.encode(_account, _amount))));

        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)){
            revert AirDrop__FailedToVerify();
        }

        emit ClaimToken(_account, _amount);
        i_airdropToken.safeTransfer(_account, _amount);
    }

}