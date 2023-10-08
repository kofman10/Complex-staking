##  Staking contract

- A staking contract that only accepts eth, eth is automatically converted to weth(then stored in the contract) and receipt tokens are minted to the depositor
- the reward token is your own token at an APR of 14% , at a ratio of 1:10...meaning if i bring in 1 eth i should be earning 14% of x tokens times 10 per year provided no compounding is done
- users can opt in for compounding which means their earned x tokens can be automatically converted to weth  using the 1:10 ratio and staked back as principal, this opt in removes 1% from their weth deposited at the beginning to make sure their is a reward for the person who triggers this operation as a reward. note that this 1% is for an entire month so don't let your contract spend it all in one place



## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
