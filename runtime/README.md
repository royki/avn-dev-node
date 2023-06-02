# avn-dev-runtime
The avn-dev-runtime is a custom runtime that incorporates some of the AvN pallets. It allows the community to run a test chain with AvN components for development purposes.

## Implementation Details

The avn-dev-runtime includes core functionality of AvN, although certain pallets such as the summary pallet, have some of their functionality disabled.
Any traits implemented from the missing pallets, on which the runtime depended, have been emulated in [emulations.rs](src/emulations.rs)
### Ethereum Bridge
Currently, the ethereum bridge is disabled in this runtime. Neither the ethereum-events and ethereum-transaction pallets are included.

The runtime uses the default implementation of `ProcessedEventsChecker` interface, which always returns false when checking an event.

The token and nft-manager pallets are typically subscribed to the ethereum-events `ProcessedEventHandler` implementation to process token lifts and NFT actions. Since the pallets are not subscribing to a handler, such actions won't be enabled either. A new handler can be implemented to simulate this behaviour and provide the node with events ready for processing.

### On-Chain Finality Tracker

The default implementation of `FinalisedBlockChecker` is used, which always returns false.

### AvN Consumed Pallets
- avn
- token-manager
- nft-manager
- avn-proxy
- summary

### AvN Pallets to be Added
- avn-offence-handler
- validators-manager
- parachain-staking
