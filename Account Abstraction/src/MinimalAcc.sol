    // SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {IAccount} from "lib/account-abstraction/contracts/interfaces/IAccount.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {SIG_VALIDATION_FAILED, SIG_VALIDATION_SUCCESS} from "lib/account-abstraction/contracts/core/Helpers.sol";
import {IEntryPoint} from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";

contract MinimalAccount is IAccount, Ownable {
    IEntryPoint private immutable i_entryPoint;

    error MinimalAccount__InvalidEntryPoint();

    modifier onlyEntryPoint() {
        if (msg.sender != owner() ) {
            revert MinimalAccount__InvalidEntryPoint();
        }
        
        _;
    }
    constructor(address entryPoint) Ownable(msg.sender) {
        i_entryPoint = IEntryPoint(entryPoint);
    }

    // if the validateUserOp is failed(With a return value of 0), then the operation that was supposed to happen shall not occurxz
    function validateUserOp(
        PackedUserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 missingAccountFunds
    ) external onlyEntryPoint  returns (uint256 validationData){
        _verifySignature(userOp, userOpHash);

        _prefund(missingAccountFunds);
    }


    function _prefund(uint missingAccountFunds) internal {
        if (missingAccountFunds > 0) {
            (bool success,) = payable(msg.sender).call{value: missingAccountFunds, gas: type(uint).max}("");
            (success);
        }
    }

    // This function is where you will be validating and returning if certain condtions are met or not. They could be anything. 
    // Maybe all your friends signing a signature before it being validated. You return 0(SIG_VALIDATION_FAILED) if it is validated, and 1 if not
    function _verifySignature(PackedUserOperation calldata userOp,bytes32 userOpHash) internal view returns (uint) {
        bytes32 ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(userOpHash);
        address sender = ECDSA.recover(ethSignedMessageHash, userOp.signature);
        if (owner() != sender ){
            return SIG_VALIDATION_FAILED; 
        }
        return SIG_VALIDATION_SUCCESS;
    }

    

}
