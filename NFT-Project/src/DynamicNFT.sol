// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {console} from "forge-std/console.sol";

contract DynamicNFT is ERC721 {
    error DynamicNFT__flipperNotOwnerOfTheNFT();

    string private s_happy_svgURI;
    string private s_sad_svgURI;
    uint private tokenCounter;
    enum Mood{
        HAPPY,
        SAD
    }

    mapping(uint => address) private s_tokenIdToOwner;  
    mapping(uint => Mood) private s_tokenIdToMood;

    constructor(
        string memory _happy_svg,
        string memory _sad_svg
    ) ERC721("DynamicNFT", "DN"){
        s_happy_svgURI = _happy_svg;
        s_sad_svgURI = _sad_svg;
    }

    function flipMood(uint tokenId) public {
        if (!_isApprovedOrOwner(msg.sender, tokenId)) {
            revert DynamicNFT__flipperNotOwnerOfTheNFT();
        }

        if (s_tokenIdToMood[tokenId] == Mood.HAPPY) {
            s_tokenIdToMood[tokenId] = Mood.SAD;
        } else {
            s_tokenIdToMood[tokenId] = Mood.HAPPY;  
        }
    }

    function _isApprovedOrOwner(address _who, uint tokenId) private view returns(bool) {
            if(s_tokenIdToOwner[tokenId] != _who) {
                return false;
            } else {
                return true;
            }
    } 

    function mintNft() public {
        _safeMint(msg.sender, tokenCounter);
        s_tokenIdToMood[tokenCounter] = Mood.HAPPY;
        s_tokenIdToOwner[tokenCounter] = msg.sender;
        tokenCounter++;
    }

    function tokenURI(uint tokenId) public view override returns (string memory) {
        string memory imageUri;
        if (s_tokenIdToMood[tokenId] == Mood.SAD){
            imageUri = s_sad_svgURI;
        }else {
            imageUri = s_happy_svgURI;
        }
        string memory returnVal = string(abi.encodePacked(_baseURI(), Base64.encode(bytes(abi.encodePacked(
            '{"name": ', name(), '"description": "This NFT describes your mood at a specific moment", "attributes": [{"trait_type": "moodiness", "value": 100}], "image": ', imageUri, '"}'
        )))));

        console.log(returnVal);

        //@dev Creates the metadata for the NFT in the format {"name": <name>, "description": <description>....."}
        return returnVal;
    }  

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }   
  
    function hash(string memory _str) private pure returns(bytes32)  {
        return keccak256(abi.encodePacked(_str));
    }

    function getTokenIdToOwner(uint tokenId) external view returns(address) {
            return s_tokenIdToOwner[tokenId];
    } 
    function getTokenIdToMood(uint tokenId) external view returns(Mood) {
            return s_tokenIdToMood[tokenId];
    }
    //     string private s_happy_svgURI;
    // string private s_sad_svgURI;
    // uint private tokenCounter;
    function getTokenCounts() external view returns (uint) {
        return tokenCounter;
    }
    function getURLs() external view returns (string memory, string memory) {
        return (s_happy_svgURI, s_sad_svgURI);
    }
}