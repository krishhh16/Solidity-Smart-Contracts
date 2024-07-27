// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFT is ERC721 {
    uint private s_tokenCount;
    constructor() ERC721("Dog", "DG"){
        s_tokenCount = 0;
    }
    
    function mintNFT() public{}

    function tokenURI(
        uint tokenId
    ) public view override returns (string memory) {

    }
}