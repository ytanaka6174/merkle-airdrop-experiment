//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {ToasterToken} from "src/ToasterToken.sol";

error __ClaimAirdrop_Invalid_Signature();

contract ClaimAirdrop is Script {
    address CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 CLAIMING_AMOUNT = 25 * 1e18;
    bytes32 PROOF_1 = 0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32 PROOF_2 = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] proof = [PROOF_1, PROOF_2];
    bytes private signature = hex"9e8a0c405cb1cd47fb9e81488b57f4600e90a11c9b2d82b8ca30e7da45737a8c4cdefd782925ae5bf3b319eab9f01f6c8051df966fcadee0761c672e71dc78a11c";

    function splitSignature(bytes memory sig) public pure returns(uint8 v, bytes32 r, bytes32 s) {
        if(sig.length != 65) {
            revert __ClaimAirdrop_Invalid_Signature();
        }
        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

    }
    
    function claimAirdrop(address airdrop) public {
        vm.startBroadcast();
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);
        MerkleAirdrop(airdrop).claim(CLAIMING_ADDRESS, CLAIMING_AMOUNT, proof, v, r, s);
        vm.stopBroadcast();
    }

    function run() public {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);
        claimAirdrop(mostRecentlyDeployed);
    }

}