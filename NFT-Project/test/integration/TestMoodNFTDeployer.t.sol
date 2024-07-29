// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DeployDynamicNFT} from "script/DeployDynamicNFT.s.sol";
import {DynamicNFT} from "src/DynamicNFT.sol";

contract TestDeployDynamicNFT is Test {
    DeployDynamicNFT deployer;
    DynamicNFT dynamiContract;
    address USER = makeAddr("USER");

    function setUp() external {
        deployer = new DeployDynamicNFT();
        dynamiContract = deployer.run();
    }
    function hash(string memory _str) private pure returns(bytes32)  {
        return keccak256(abi.encodePacked(_str));
    }

    function testRightURLGeneratedByTheDeployScript() external view {
        string memory expectedUrl= "data:image/svg+xml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgMjAwIDIwMCIgd2lkdGg9IjQwMCIgIGhlaWdodD0iNDAwIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPjxjaXJjbGUgY3g9IjEwMCIgY3k9IjEwMCIgZmlsbD0ieWVsbG93IiByPSI3OCIgc3Ryb2tlPSJibGFjayIgc3Ryb2tlLXdpZHRoPSIzIi8+PGcgY2xhc3M9ImV5ZXMiPjxjaXJjbGUgY3g9IjcwIiBjeT0iODIiIHI9IjEyIi8+PGNpcmNsZSBjeD0iMTI3IiBjeT0iODIiIHI9IjEyIi8+PC9nPjxwYXRoIGQ9Im0xMzYuODEgMTE2LjUzYy42OSAyNi4xNy02NC4xMSA0Mi04MS41Mi0uNzMiIHN0eWxlPSJmaWxsOm5vbmU7IHN0cm9rZTogYmxhY2s7IHN0cm9rZS13aWR0aDogMzsiLz48L3N2Zz4=";
        string memory deployerUrl = deployer.svgToUri('<svg viewBox="0 0 200 200" width="400"  height="400" xmlns="http://www.w3.org/2000/svg"><circle cx="100" cy="100" fill="yellow" r="78" stroke="black" stroke-width="3"/><g class="eyes"><circle cx="70" cy="82" r="12"/><circle cx="127" cy="82" r="12"/></g><path d="m136.81 116.53c.69 26.17-64.11 42-81.52-.73" style="fill:none; stroke: black; stroke-width: 3;"/></svg>');

        console.log(deployerUrl, expectedUrl);
        assert(hash(expectedUrl) == hash(deployerUrl));
    }

    
    function testFlipMoodFunctionChangesMoodCorrectly() external {
        vm.startPrank(USER);
        dynamiContract.mintNft();
        dynamiContract.flipMood(0);
        vm.stopPrank();

        assert(dynamiContract.getTokenIdToMood(0) == DynamicNFT.Mood.SAD );
    }

    function testMoodChangesAllTheStateVariables() external {
        vm.prank(USER);
        dynamiContract.mintNft();

        assert(dynamiContract.getTokenIdToMood(0) == DynamicNFT.Mood.HAPPY);
        assert(dynamiContract.getTokenCounts() == 1);
        assert(dynamiContract.getTokenIdToOwner(0) == USER);
    }


    

    
}
