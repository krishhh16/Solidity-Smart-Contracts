// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {DynamicNFT} from "src/DynamicNFT.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {console} from "forge-std/console.sol";

contract DeployDynamicNFT is Script {
    DynamicNFT deployer;

    function run() external returns (DynamicNFT) {
        string memory sadSvg = vm.readFile("./img/sad.svg");
        string memory happySvg = vm.readFile("./img/happy.svg");
        
        vm.startBroadcast();
        deployer = new DynamicNFT(svgToUri(happySvg), svgToUri(sadSvg));
        vm.stopBroadcast();
        return deployer;
    }

    function svgToUri(string memory svg) public pure returns (string memory) {
        string memory baseUrl = "data:image/svg+xml;base64,";

        string memory svgBase64Encoded = Base64.encode(bytes(abi.encodePacked(svg)));
        return string(abi.encodePacked(baseUrl, svgBase64Encoded));

    } 
}