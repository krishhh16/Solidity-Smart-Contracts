// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {DefiProtocol} from "./DefiStableCoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
contract DSCEngine is ReentrancyGuard {
    error DSCEngine__ValueNonNegative();
    error DSCEngine__WrongArgumentsProvided();
    error DSCEngine__InvalidTokenAddress();
    error DSCEngine__TransferFailed();
    ////////////////////////
    /// State Variables ////
    ////////////////////////
    mapping(address token => address collatoralToken) private s_priceFeed;
    mapping (address user => uint tokenMinted) private s_tokenMinted;
    /**
     * @dev This is the collatoral deposited by the user 
     * colOwner -> Owner of the collatoral
     * TokenId -> a valid tokenId from s_priceFeed
     * amount -> the amount of collatoral colOwner is willing to deposit
     */
    mapping(address colOwner => mapping(address tokenId => uint amount)) private s_amountDeposited;
    address[] private s_tokenAddress;
    DefiProtocol private immutable i_dscToken;
    
    /////////////////////
    /// Events      ////
    ///////////////////
    event CollatoralDeposited(address indexed colOwner, address indexed tokenId, uint indexed amount);
    ////////////////////////
    ///Modifiers //////////
    ////////////////////////
    modifier checkPositive(uint _val) {
        if (_val <= 0) {
            revert DSCEngine__ValueNonNegative();
        }
        _;
    }

    modifier tokenAllowed(address _tokenAddress) {
        if (s_priceFeed[_tokenAddress] == address(0)) {
            revert DSCEngine__InvalidTokenAddress();
        }
        _;
    }

    constructor(
        address[] memory tokenAddress,
        address[] memory collatoralAddress,
        address dscAddress
    ) {
        if (tokenAddress.length != collatoralAddress.length) {
            revert DSCEngine__WrongArgumentsProvided();
        }

        for (uint i = 0; i < tokenAddress.length; i++) {
            s_priceFeed[tokenAddress[i]] = collatoralAddress[i];
            s_tokenAddress.push(tokenAddress[i]);
        }
        i_dscToken = DefiProtocol(dscAddress);
    }

    ////////////////////////
    ///External Functions///
    ////////////////////////

    function depositeCollatoral(
        address _toAddress,
        uint _amount
    ) external checkPositive(_amount) tokenAllowed(_toAddress) nonReentrant {
        s_amountDeposited[msg.sender][_toAddress] = _amount;
        emit CollatoralDeposited(msg.sender, _toAddress, _amount);
        bool success = IERC20(_toAddress).transferFrom(msg.sender, address(this), _amount);

        if (!success) {
            revert DSCEngine__TransferFailed();
        }
    }

    function mintDsc(uint256 amountDscToMint) external checkPositive(amountDscToMint) nonReentrant {
        s_tokenMinted[msg.sender] += amountDscToMint;

        _revertIfHealthOfAccountIsBroken(msg.sender);
    }
    /////////////////////////////////
    ///Internal/Private view Functions///
    ///////////////////////////////

    function _revertIfHealthOfAccountIsBroken(address user) internal view {

    } 

    function _healthOfAccount(address user) private view returns(uint) {
        (uint dscMintedValue, uint collatoralDepositedInUSD) = _getAccountDetails(user);
    }

    /////////////////////////////////
    ///Public view  Functions    ///
    ///////////////////////////////
    function _getAccountDetails(address _user) public view returns(uint, uint) {
        for(uint i= 0;  i< s_tokenAddress.length; i++) {
            address token = s_tokenAddress[i];
            uint amount = s_amountDeposited[_user][token];
            getTokenPriceInUSD(token, amount);
        } 
    }

    function getTokenPriceInUSD(address _token, uint _amount) public view returns(uint) {

    }
}
