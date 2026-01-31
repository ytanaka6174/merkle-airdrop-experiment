//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test,console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {ToasterToken} from "src/ToasterToken.sol";
import {ZkSyncChainChecker} from "foundry-devops/src/ZkSyncChainChecker.sol";
import {DeployTokenAndAirdrop} from "script/DeployTokenAndAirdrop.s.sol";

contract MerkleAirDropTests is ZkSyncChainChecker, Test {
    MerkleAirdrop public merkleAirdrop;
    ToasterToken public toasterToken;

    bytes32 public constant ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4; //getting this from output.json
    uint256 public constant AMOUNT_TO_CLAIM = 25e18;
    uint256 public constant AMOUNT_TO_SEND = AMOUNT_TO_CLAIM * 4;
    bytes32 proofOne = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a; // get these from output.json also
    bytes32 proofTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public PROOF = [proofOne, proofTwo];
    address gasPayer;
    address user;
    uint256 userKey;
    DeployTokenAndAirdrop deployer;

    function setUp() public {
        if(!isZkSyncChain()){
            deployer = new DeployTokenAndAirdrop();
            (merkleAirdrop, toasterToken) = deployer.run();
        }
        else {
            toasterToken = new ToasterToken();
            toasterToken.mint(toasterToken.owner(), AMOUNT_TO_SEND);
            merkleAirdrop = new MerkleAirdrop(ROOT, toasterToken);
            toasterToken.transfer(address(merkleAirdrop), AMOUNT_TO_SEND);
        }

    }

    function testUserCanClaim() public {
        gasPayer = makeAddr("gasPayer");
        (user, userKey) = makeAddrAndKey("user");
        bytes32 digest = merkleAirdrop._getMessage(user, AMOUNT_TO_CLAIM);

        uint256 startingBalance = toasterToken.balanceOf(user);
        
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userKey, digest);


        //gaspayer calls claim using signature from user
        vm.prank(gasPayer);
        merkleAirdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);
        uint256 endingBalance = toasterToken.balanceOf(user);
        console.log(endingBalance);
        assert(endingBalance - AMOUNT_TO_CLAIM == startingBalance);
    }

}
