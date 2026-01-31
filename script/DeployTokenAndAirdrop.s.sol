//SPDX-License-Identifier: MIt

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {ToasterToken} from "src/ToasterToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployTokenAndAirdrop is Script {
    ToasterToken public token;
    MerkleAirdrop public airdrop;
    bytes32 private ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 public constant AMOUNT_TO_AIRDROP = 4 * 25e18;

    function run() external returns (MerkleAirdrop, ToasterToken) {
        vm.startBroadcast();
        token = new ToasterToken();
        token.mint(token.owner(), AMOUNT_TO_AIRDROP);
        airdrop = new MerkleAirdrop(ROOT, token);
        token.transfer(address(airdrop), AMOUNT_TO_AIRDROP);
        vm.stopBroadcast();
        return (airdrop, token);
    }
}