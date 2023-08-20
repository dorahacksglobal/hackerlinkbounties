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
dorad query tx F9CF8A980C155A423DC17637482D33128717477AE6999141B9DD90629C471B1C --node $NODE
```

rpelace code_id below

```sh
dorad tx wasm instantiate 30 '{"admins":["dora1nt4elvrtc8yg772h9u24fusv78c2wv9zv0zusr"]}' --no-admin --label=DaobountyTestInstance --from=dora1nt4elvrtc8yg772h9u24fusv78c2wv9zv0zusr --node $NODE --chain-id doravota-devnet --gas-prices 0.1uDORA --gas auto --gas-adjustment 1.5
```

```sh
dorad query wasm list-contract-by-code 30 --node ${NODE}
```

dora1kjvyqf4mttwrhfuq5gfj9xgxx9jdt92xnxzf770x853567ymx8csw8xkhp
