# Merkle Airdrop

A Merkle tree-based airdrop contract with EIP-712 signature verification. Built with Foundry.

## What's in here

- `MerkleAirdrop.sol` - The airdrop contract. Users claim tokens by providing a Merkle proof + a signature.
- `ToasterToken.sol` - Simple ERC20 token (TOT) used for the airdrop.
- Scripts for generating the Merkle tree and deploying everything.

## How it works

1. Generate a list of addresses and amounts (`script/GenerateInput.s.sol`)
2. Build the Merkle tree and get the root (`script/MakeMerkle.s.sol`)
3. Deploy the token and airdrop contract with that root
4. Users sign a message and claim with their proof

The signature requirement means someone else can submit the claim tx on your behalf (gas abstraction).

## Usage

```shell
forge build
forge test
```

## Deploy

```shell
forge script script/DeployTokenAndAirdrop.s.sol --rpc-url <rpc_url> --private-key <key> --broadcast
```
