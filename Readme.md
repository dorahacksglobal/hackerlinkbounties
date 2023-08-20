# DAO Bounty Contract

Requirements
<https://fi193tzrws.larksuite.com/docs/docusFKhOaaeS890u3nVelzBRXg>

## Quick Start

[Setup Rust](https://rustup.rs/)

```sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup target add wasm32-unknown-unknown
```

Run tests

```sh
cargo test
```

```sh
npm install -g @cosmwasm/ts-codegen
```

```sh
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

```sh
cargo wasm
```

optimize

```sh
cargo run-script optimize
```

check

```sh
cargo run-script check
```

deploy

```sh
export CHAIN_ID="doravota-devnet"
export NODE="http://doravota-devnet-rpc.dorafactory.org:26657"
export TXFLAG="--node ${NODE} --chain-id ${CHAIN_ID} --gas-prices 0.1uDORA --gas auto --gas-adjustment 1.5"
export DORA_ADDRESS=dora1nt4elvrtc8yg772h9u24fusv78c2wv9zv0zusr
```

```sh
eval dorad tx wasm store artifacts/daobounty-aarch64.wasm --from=$(echo $DORA_ADDRESS) $TXFLAG
```

*replace txhash below*

```sh
dorad query tx 6F3ED862EE76B248E4B8578736BB048BD30F2E1792FB89261784ADD957B361A3 --node $NODE
```

rpelace code_id below

```sh
dorad tx wasm instantiate 31 '{"admins":["dora1nt4elvrtc8yg772h9u24fusv78c2wv9zv0zusr"]}' --no-admin --label=DaobountyTestInstance --from=dora1nt4elvrtc8yg772h9u24fusv78c2wv9zv0zusr --node $NODE --chain-id doravota-devnet --gas-prices 0.1uDORA --gas auto --gas-adjustment 1.5
```

```sh
dorad query wasm list-contract-by-code 31 --node ${NODE}
```

dora14uu78aa4xswpr5v85umx9znswvemqqcht6a8amjnhzsxj4w8xs3s6qppjr
