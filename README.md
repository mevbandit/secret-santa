# On-Chain Secret Santa

Uses off-chain randomness via VRF to fairly mix and distribute ERC-721 gifts.

Gifts can only be unwrapped on Christmas day. 

![1-snoopy-christmas-peter-b-lutes](https://user-images.githubusercontent.com/94731243/146124210-e6c19734-d9a3-4b15-b133-ff26a47d0fd4.jpeg)

Merry Christmas!

# Setup

### Running Tests

[Install Foundry](https://github.com/foundry-rs/foundry/tree/master/foundryup)

In order to run unit tests, run:

```sh
forge install
forge test
```

For longer fuzz campaigns, run:

```sh
FOUNDRY_PROFILE="intense" forge test
```

### Running Slither

After installing [Poetry](https://python-poetry.org/docs/#installing-with-the-official-installer) and [Slither](https://github.com/crytic/slither#how-to-install) run:
[Slither on Apple Silicon](https://github.com/crytic/slither/issues/1051)
```sh
poetry install
poetry shell
slither src/SecretSanta.sol --config-file slither.config.json
```


### Updating Gas Snapshots

To update the gas snapshots, run:

```sh
forge snapshot
```

### Generating Coverage Report

To see project coverage, run:

```shell
forge coverage
```

## License

GNU General Public License (GPL) 
