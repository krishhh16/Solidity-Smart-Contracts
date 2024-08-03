// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract AirDrop is EIP712{
    using SafeERC20 for IERC20;
    error AirDrop__FailedToVerify();
    error AirDrop__AlreadyClaimed();
    error AirDrop__VerificationFailed();

    event ClaimToken(address to, uint amount);

    struct AirDropClaim {
        address account;
        uint amount;
    }

    bytes32 MESSAGE_STRUCT_HASH  = keccak256(abi.encodePacked("AirDropClaim(address account,uint amount)"));
    bytes32 immutable  i_merkleRoot;
    IERC20 private immutable i_airdropToken;

    mapping(address claimer => bool hasClaimed) private s_hasCalimed;

    constructor(bytes32 _merkleRoot, IERC20 _airdropToken) EIP712("Airdrop","1.0") {
        i_merkleRoot = _merkleRoot;
        i_airdropToken = _airdropToken;
    }

    function claim(address _account, uint _amount, bytes32[] memory merkleProof, uint8 v, bytes32 r, bytes32 s) external {
        if (s_hasCalimed[_account]) {
            revert AirDrop__AlreadyClaimed();
        }

        if (!_VierifiedSignature(_account, _MessageHashWStruct(_account, _amount),v,r,s )){
            revert AirDrop__VerificationFailed();
        }

        bytes32 leaf = keccak256(abi.encode(keccak256(abi.encode(_account, _amount))));

        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)){
            revert AirDrop__FailedToVerify();
        }
        s_hasCalimed[_account] = true;
        emit ClaimToken(_account, _amount);
        i_airdropToken.safeTransfer(_account, _amount);
    }


    function _MessageHashWStruct(address account, uint amount) public view returns (bytes32) {
        return _hashTypedDataV4(keccak256(
            abi.encode(
                MESSAGE_STRUCT_HASH,
                AirDropClaim({
                    account: account,
                    amount: amount
                })
            )
        ));
    }

    function _VierifiedSignature(address account, bytes32 message_hash, uint8 v, bytes32 r, bytes32 s) public pure returns (bool) {
        (address actualSigner,,) = ECDSA.tryRecover(message_hash, v, r, s);
        return account == actualSigner;
    }
}