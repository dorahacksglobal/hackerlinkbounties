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

## deploy doravota-devnet

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

## deploy doravota-mainnet

```sh
export CHAIN_ID="vota-ash"
export NODE="http://54.254.158.153:26657/"
export TXFLAG="--node ${NODE} --chain-id ${CHAIN_ID} --gas-prices 0.01peaka --gas auto --gas-adjustment 1.3"
export DORA_ADDRESS=dora1nt4elvrtc8yg772h9u24fusv78c2wv9zv0zusr
```

```sh
eval dorad tx wasm store artifacts/daobounty-aarch64.wasm --from=$(echo $DORA_ADDRESS) $TXFLAG
```

*replace txhash below*

```sh
dorad query tx F1B72C77912016EFC2341C0DDB52AD71015A1CC61076BE439352E078115AB1C7 --node $NODE
```

rpelace code_id below

```sh
dorad tx wasm instantiate 1 '{"admins":["dora1nt4elvrtc8yg772h9u24fusv78c2wv9zv0zusr", "dora1pntxsj79xkjm9q096fj9ry9wvtexmtk6ms6fag"]}' --no-admin --label=DaobountyInstance --from=dora1nt4elvrtc8yg772h9u24fusv78c2wv9zv0zusr --node $NODE --chain-id vota-ash --gas-prices 0.01peaka --gas auto --gas-adjustment 1.3
```

```sh
dorad query wasm list-contract-by-code 1 --node ${NODE}
```

dora14hj2tavq8fpesdwxxcu44rty3hh90vhujrvcmstl4zr3txmfvw9s8nvku9

## deploy archway

```sh
export CHAIN_ID="archway-1"
export NODE="https://rpc.mainnet.archway.io:443"
export TXFLAG="--node ${NODE} --chain-id ${CHAIN_ID} --gas auto --gas-prices $(archwayd q rewards estimate-fees 1 --node ${NODE} --output json | jq -r '.gas_unit_price | (.amount + .denom)') --gas-adjustment 1.3 -y"
export DORA_ADDRESS=archway1ae43lk7g2jlwe0g8ylya8czz6gha6xvw2jdzcx
```

```sh
eval archwayd tx wasm store artifacts/daobounty-aarch64.wasm --from=$(echo $DORA_ADDRESS) $TXFLAG
```

*replace txhash below*

```sh
archwayd query tx 7004F5E90BD20349C693F7940FD13A2FDF012B6226186005E3A1882ABB630838 --node $NODE
```

rpelace code_id below

```sh
archwayd tx wasm instantiate 122 '{"admins":["archway1ae43lk7g2jlwe0g8ylya8czz6gha6xvw2jdzcx"]}' --no-admin --label=DaobountyTestInstance --from=$(echo $DORA_ADDRESS) --node ${NODE} --chain-id ${CHAIN_ID} --gas auto --gas-prices $(archwayd q rewards estimate-fees 1 --node ${NODE} --output json | jq -r '.gas_unit_price | (.amount + .denom)') --gas-adjustment 1.3 -y
```

```sh
archwayd query wasm list-contract-by-code 122 --node ${NODE}
```

archway1h60e3x2dje8xry9nm94l3kch03f3e799wctlnn9jqlkz4s49qhaqtgqvf9

## deploy archway testnet

```sh
export CHAIN_ID="constantine-3"
export NODE="https://rpc.constantine.archway.tech:443"
export TXFLAG="--node ${NODE} --chain-id ${CHAIN_ID} --gas auto --gas-prices $(archwayd q rewards estimate-fees 1 --node ${NODE} --output json | jq -r '.gas_unit_price | (.amount + .denom)') --gas-adjustment 1.3 -y"
export DORA_ADDRESS=archway1ae43lk7g2jlwe0g8ylya8czz6gha6xvw2jdzcx
```

```sh
eval archwayd tx wasm store artifacts/daobounty-aarch64.wasm --from=$(echo $DORA_ADDRESS) $TXFLAG
```

*replace txhash below*

```sh
archwayd query tx 2142D2969CD8817ABE5CDCA0C8BBE89A03699D3314377467269044476E29C4BA --node $NODE
```

rpelace code_id below

```sh
archwayd tx wasm instantiate 1150 '{"admins":["archway1ae43lk7g2jlwe0g8ylya8czz6gha6xvw2jdzcx"]}' --no-admin --label=DaobountyTestInstance --from=$(echo $DORA_ADDRESS) --node ${NODE} --chain-id ${CHAIN_ID} --gas auto --gas-prices $(archwayd q rewards estimate-fees 1 --node ${NODE} --output json | jq -r '.gas_unit_price | (.amount + .denom)') --gas-adjustment 1.3 -y
```

```sh
archwayd query wasm list-contract-by-code 1150 --node ${NODE}
```

archway10q2cnny2v5c4w8w7rfnpevsa5638cw22vhj6x3kyn2pedxuzd73sadvpuq
