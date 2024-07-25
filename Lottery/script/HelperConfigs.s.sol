// SPDX-License-Identifier:MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "test/mocks/LinkToken.sol";

abstract contract ConstantVariables {
    uint96 public MOCK_BASE_FEE = 0.25 ether;
    uint96 public MOCK_GAS_PRICE_LINK = 1e9;
    int public MOCK_WEI_PER_UINT_LINK = 4e15;
    uint public constant ETH_SEPOLIA_CHAINID = 11155111;
    uint public constant LOCAL_CHAIN_ID = 31337;
}

contract HelperConfigs is ConstantVariables, Script {
    error ChainIdNotFound();

    struct NetworkConfigs {
        uint entranceFee;
        uint interval;
        address vrfCoordinator;
        uint subscriptionId;
        uint32 callbackGasLimit;
        bytes32 keyHash;
        address link;
    }

    NetworkConfigs localNetworkConfig;
    mapping (uint chainId => NetworkConfigs) public networkConfigs;

    constructor() {
        networkConfigs[ETH_SEPOLIA_CHAINID] = getSepoliaEthConfigs();
    }

    function getConfigs() external returns(NetworkConfigs memory) {
        return getConfigsByChainId(block.chainid);
    }

    function getConfigsByChainId(uint chainId) public returns(NetworkConfigs memory) {
        if (networkConfigs[chainId].vrfCoordinator != address(0)){
            return networkConfigs[chainId];
        } else if (chainId == LOCAL_CHAIN_ID) {
            return getOrCreateAnvilConfigs();
        } else {
            revert ChainIdNotFound();
        }
    }

    function getSepoliaEthConfigs() public pure returns (NetworkConfigs memory) {
        return NetworkConfigs( {
            entranceFee: 0.0001 ether, 
            interval: 30,
            vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
            keyHash: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            callbackGasLimit: 500000,
            subscriptionId: 83953620150640821931143417501646584112286897284169140199126694328503757470924,
            link: 0x779877A7B0D9E8603169DdbD7836e478b4624789
        });
    } 

    function getOrCreateAnvilConfigs() public returns (NetworkConfigs memory) {
        if (localNetworkConfig.vrfCoordinator != address(0)){
            return localNetworkConfig;
        }

        vm.startBroadcast();
        VRFCoordinatorV2_5Mock vrfCoordinatorMock = new VRFCoordinatorV2_5Mock(MOCK_BASE_FEE, MOCK_GAS_PRICE_LINK, MOCK_WEI_PER_UINT_LINK);
        LinkToken linkToken = new LinkToken();
        vm.stopBroadcast();

        return NetworkConfigs({
            entranceFee: 0.0001 ether, 
            interval: 30,
            vrfCoordinator: address(vrfCoordinatorMock),
            keyHash: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            callbackGasLimit: 500000,
            subscriptionId: 0,
            link: address(linkToken)
        });
    }
}