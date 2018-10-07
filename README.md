# testBlockProducersManagement
Technical test related to a blockchain project.

The test aim to allocate block producers to Proof of Stake  side chains.

I elected to use and study sidechains on Ethereum inspiring myself with Plasma and Plasma Cash. Mainly because the research on those projects is very promising and I am already familiar with Solidity.

This project use Truffle and Ganache locally.

TODO:
- Write tests.
- Research if there is an optimal way to sort result on chain. Use https://github.com/Modular-Network/ethereum-libraries/blob/master/LinkedListLib/LinkedListLib.sol ?
- Add a minimum of votes based on total amount of token for result to be valid.
- Study how to automatise election rounds on or off chain.
- IterableMapping (https://github.com/ethereum/dapp-bin/blob/master/library/iterable_mapping.sol) might be better in some cases, investigate.
