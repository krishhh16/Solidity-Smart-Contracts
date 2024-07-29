// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFT is ERC721 {
    uint private s_tokenCount;
    mapping(uint => string) private s_tokenIdToUrl;

    constructor() ERC721("Dog", "DG"){
        s_tokenCount = 0;
    }
    
    function mintNFT(
        string memory tokenUri
    ) public{
        s_tokenIdToUrl[s_tokenCount] = tokenUri;
        _safeMint(msg.sender, s_tokenCount);
        s_tokenCount++;
    }
    

    function tokenURI(
        uint tokenId
    ) public view override returns (string memory) {
        return s_tokenIdToUrl[tokenId];
    }
}