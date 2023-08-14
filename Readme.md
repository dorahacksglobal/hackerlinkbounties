# DAO Bounty Contract

Requirements
https://fi193tzrws.larksuite.com/docs/docusFKhOaaeS890u3nVelzBRXg

## Quick Start

[Setup Rust](https://rustup.rs/)

```
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup target add wasm32-unknown-unknown
```

Run tests

```
cargo test
```

```
npm install -g @cosmwasm/ts-codegen
```

```
cargo schema
cosmwasm-ts-codegen generate \
          --plugin client \
          --schema ./schema \
          --out ./ts \
          --name daobaounty \
          --no-bundle
```

## Publish

build

```
cargo wasm
```

optimize

```
cargo run-script optimize
```

check

```
cargo run-script check
```

deploy
```
export CHAIN_ID="doravota-devnet"
export NODE="http://doravota-devnet-rpc.dorafactory.org:26657"
export TXFLAG="--node ${NODE} --chain-id ${CHAIN_ID} --gas-prices 0.1uDORA --gas auto --gas-adjustment 1.5"
export DORA_ADDRESS=dora1nt4elvrtc8yg772h9u24fusv78c2wv9zv0zusr
```

```
eval dorad tx wasm store artifacts/daobounty-aarch64.wasm --from=$(echo $DORA_ADDRESS) $TXFLAG
```


```
dorad query tx 9F4224C51815382D58AC3464FD308A4DB6D79C8A150CF41681E095B67B95C0E8 --node $NODE
```

```
dorad tx wasm instantiate 28 '{"admins":["dora1nt4elvrtc8yg772h9u24fusv78c2wv9zv0zusr"]}' --no-admin --label=DaobountyTestInstance --from=dora1nt4elvrtc8yg772h9u24fusv78c2wv9zv0zusr --node $NODE --chain-id doravota-devnet --gas-prices 0.1uDORA --gas auto --gas-adjustment 1.5
```

```
dorad query wasm list-contract-by-code 28 --node ${NODE}
```

dora1rqf9dzpsd384txpkunq3dgpqqr5kdpmxmgkz86gugqj03jxnuvrqflaauk
