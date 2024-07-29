// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract DynamicNFT is ERC721 {
    string private s_happy_svgURI;
    string private s_sad_svgURI;
    uint private tokenCounter;
    enum Mood{
        HAPPY,
        SAD
    }

    mapping(uint => Mood) private s_tokenIdToMood;

    constructor(
        string memory _happy_svg,
        string memory _sad_svg
    ) ERC721("DynamicNFT", "DN"){
        s_happy_svgURI = _happy_svg;
        s_sad_svgURI = _sad_svg;
    }
    function hash(string memory _str) private pure returns(bytes32)  {
        return keccak256(abi.encodePacked(_str));
    }


    function mintNft(string memory _mood) public {
        _safeMint(msg.sender, tokenCounter);
        if (hash(_mood) == hash("Happy")){
            s_tokenIdToMood[tokenCounter] = Mood.HAPPY;
        } else {
            s_tokenIdToMood[tokenCounter] = Mood.SAD;
        }
        tokenCounter++;
    }

    function tokenURI(uint tokenId) public view override returns (string memory) {
        string memory imageUri;
        if (s_tokenIdToMood[tokenId] == Mood.SAD){
            imageUri = s_sad_svgURI;
        }else {
            imageUri = s_happy_svgURI;
        }

        //@dev Creates the metadata for the NFT in the format {"name": <name>, "description": <description>....."}
        return string(abi.encodePacked(_baseURI(), Base64.encode(bytes(abi.encodePacked(
            '{"name": ', name(), '"description": "This NFT describes your mood at a specific moment", "attributes": [{"trait_type": "moodiness", "value": 100}], "image": ', imageUri, '"}'
        )))));
    }  

    function _baseURI() internal pure override returns (string memory) {
        return "data:image/svg+xml;base64,";
    }   
}