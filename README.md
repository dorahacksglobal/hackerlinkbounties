# DAO Bounty Contract

Requirements
https://fi193tzrws.larksuite.com/docs/docusFKhOaaeS890u3nVelzBRXg

## Setting up your project

1. Install Dependencies
`yarn`

2. Start develop console
`yarn develop`

3. Migrate
`truffle(develop)> migrate`  or `yarn migrate`

4. Test
`truffle(develop)> test` or `yarn test`

5. Connect your Metamask to locally running Truffle's Network
- Use option, Connect using “Custom RPC”, at address http://127.0.0.1:9545/
- Use the Private Keys provided by Truffle to import at least two accounts.

## Upgrade migration example

`./migrations/3_upgrade.js`

```js
const { upgradeProxy } = require("@openzeppelin/truffle-upgrades");

const DaoBounty = artifacts.require("DaoBounty");
const DaoBountyV2 = artifacts.require("DaoBountyV2");

module.exports = async function (deployer) {
  const bounty = await DaoBounty.deployed();
  const instance = await upgradeProxy(bounty.address, DaoBountyV2, {
    deployer,
  });
  console.log("Upgraded", instance.address);
};

```

## BSC-TESTNET
```
$ truffle console --network bsc-testnet

truffle(bsc-testnet)> migrate --reset

Compiling your contracts...
===========================
> Everything is up to date, there is nothing to compile.


Starting migrations...
======================
> Network name:    'bsc-testnet'
> Network id:      97
> Block gas limit: 30000000 (0x1c9c380)


1_initial_migration.js
======================

   Replacing 'Migrations'
   ----------------------
   > transaction hash:    0x3ffc38020d6cb427c584a734adc49da4db632300b7bae636c42e263df641e552
   > Blocks: 4            Seconds: 14
   > contract address:    0xF11540c5195d3cA4Bda2440BE49fe8Fac7f27080
   > block number:        19649054
   > block timestamp:     1653587044
   > account:             0x0dad1D5e11A921373516dA4C93bE439b33E71cC8
   > balance:             0.009712579999999999
   > gas used:            248854 (0x3cc16)
   > gas price:           10 gwei
   > value sent:          0 ETH
   > total cost:          0.00248854 ETH

   Pausing for 2 confirmations...

   -------------------------------
   > confirmation number: 2 (block: 19649059)
   > Saving migration to chain.
   > Saving artifacts
   -------------------------------------
   > Total cost:          0.00248854 ETH


2_deploy.js
===========

   Deploying 'TransparentUpgradeableProxy'
   ---------------------------------------
   > transaction hash:    0x55283ff23d88466433c1a7ffd6c99fcd1e933f476a27f19d8d6df83ae57f7813
   > Blocks: 6            Seconds: 18
   > contract address:    0x96398724f62baB7FcF46D7ce53e857029efDaf73
   > block number:        19649077
   > block timestamp:     1653587113
   > account:             0x0dad1D5e11A921373516dA4C93bE439b33E71cC8
   > balance:             0.002834359999999999
   > gas used:            645309 (0x9d8bd)
   > gas price:           10 gwei
   > value sent:          0 ETH
   > total cost:          0.00645309 ETH

   Pausing for 2 confirmations...

   -------------------------------
   > confirmation number: 1 (block: 19649081)
   > confirmation number: 3 (block: 19649083)
Deployed 0x96398724f62baB7FcF46D7ce53e857029efDaf73
   > Saving migration to chain.
   > Saving artifacts
   -------------------------------------
   > Total cost:          0.00645309 ETH

Summary
=======
> Total deployments:   2
> Final cost:          0.00894163 ETH


truffle(bsc-testnet)> accounts = await web3.eth.getAccounts();
undefined

truffle(bsc-testnet)> accounts
[
  '0x0dad1D5e11A921373516dA4C93bE439b33E71cC8',
  '0x46E862372D29A958d2690feC84263eFc0857f2BB',
  '0x09980F9070dd99B087803e500b15a90ee94AB9A3',
  '0x3EbBb946A5CCeD687B384d3D1939C4546f2ea94d',
  '0xFF6e62305fDE0F0d88b222a0c165178293914CFD',
  '0x5928754edc1da9271261AC154c9cf5Ebfd175cFb',
  '0x641eaEFA2d88B2266313F6a7152F541530FF929b',
  '0x289E769BceE05AD64cB519549122FA7F6Eed908C',
  '0x5f3666A6cb87eB85b70512c8065A2d2b9a28b3cF',
  '0x742f18f8028039b195c08F13c95Bc70478a23b21'
]

truffle(bsc-testnet)> bounty = await DaoBounty.deployed()
undefined

truffle(bsc-testnet)> bounty.address
'0x96398724f62baB7FcF46D7ce53e857029efDaf73'

truffle(bsc-testnet)> bounty.issueBounty('0x0000000000000000000000000000000000000000')
{
  tx: '0x85325c3ef0ee1000e6b20fbdc970e41737f74be3f16ba09086a92244b01e96f9',
  receipt: {
    blockHash: '0x901e37bbc2e08ef6c75f23c74bafb62eb5f742677c3044d9f8364c591dd082c8',
    blockNumber: 19649343,
    contractAddress: null,
    cumulativeGasUsed: 331504,
    from: '0x0dad1d5e11a921373516da4c93be439b33e71cc8',
    gasUsed: 72132,
    logs: [ [Object] ],
    logsBloom: '0x00000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000020000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000000000000000000040000800000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000',
    status: true,
    to: '0x96398724f62bab7fcf46d7ce53e857029efdaf73',
    transactionHash: '0x85325c3ef0ee1000e6b20fbdc970e41737f74be3f16ba09086a92244b01e96f9',
    transactionIndex: 5,
    type: '0x0',
    rawLogs: [ [Object] ]
  },
  logs: [
    {
      address: '0x96398724f62baB7FcF46D7ce53e857029efDaf73',
      blockNumber: 19649343,
      transactionHash: '0x85325c3ef0ee1000e6b20fbdc970e41737f74be3f16ba09086a92244b01e96f9',
      transactionIndex: 5,
      blockHash: '0x901e37bbc2e08ef6c75f23c74bafb62eb5f742677c3044d9f8364c591dd082c8',
      logIndex: 2,
      removed: false,
      id: 'log_a441d780',
      event: 'BountyIssued',
      args: [Result]
    }
  ]
}

truffle(bsc-testnet)> bounty.contribute(0,1,{value:1})
{
  tx: '0x3ee670de5df413f13bb11a5dd45667d861c0eafb748f509d3a1d1bb94b1b9c9d',
  receipt: {
    blockHash: '0x0bf2b3547ec5defee29930cee2047df39dbab97fcb6307437a194f7b0577a39a',
    blockNumber: 19649372,
    contractAddress: null,
    cumulativeGasUsed: 282405,
    from: '0x0dad1d5e11a921373516da4c93be439b33e71cc8',
    gasUsed: 118352,
    logs: [ [Object] ],
    logsBloom: '0x00000000000000000000000000000000002000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000000000000000020000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000080000000000000000000',
    status: true,
    to: '0x96398724f62bab7fcf46d7ce53e857029efdaf73',
    transactionHash: '0x3ee670de5df413f13bb11a5dd45667d861c0eafb748f509d3a1d1bb94b1b9c9d',
    transactionIndex: 2,
    type: '0x0',
    rawLogs: [ [Object] ]
  },
  logs: [
    {
      address: '0x96398724f62baB7FcF46D7ce53e857029efDaf73',
      blockNumber: 19649372,
      transactionHash: '0x3ee670de5df413f13bb11a5dd45667d861c0eafb748f509d3a1d1bb94b1b9c9d',
      transactionIndex: 2,
      blockHash: '0x0bf2b3547ec5defee29930cee2047df39dbab97fcb6307437a194f7b0577a39a',
      logIndex: 1,
      removed: false,
      id: 'log_76fe450e',
      event: 'ContributionAdded',
      args: [Result]
    }
  ]
}

truffle(bsc-testnet)> bounty.acceptFulfillment(0, [accounts[1],], [1,])
{
  tx: '0xba02a308aaf08e524b5ca87bdd024651d7a2cf467bb2de16b87886f97893b0df',
  receipt: {
    blockHash: '0x6d098618e88d08c1a0d82b6353dad2cbc44930e7389698539f2832d444199198',
    blockNumber: 19649422,
    contractAddress: null,
    cumulativeGasUsed: 153536,
    from: '0x0dad1d5e11a921373516da4c93be439b33e71cc8',
    gasUsed: 123484,
    logs: [ [Object], [Object] ],
    logsBloom: '0x00000000000000000000000000000000200000000800000000000000000000000000000010000000000000000004000000000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000040000000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000100000000000000020000000000000000000000000000000000000000000000000000000000000000000',
    status: true,
    to: '0x96398724f62bab7fcf46d7ce53e857029efdaf73',
    transactionHash: '0xba02a308aaf08e524b5ca87bdd024651d7a2cf467bb2de16b87886f97893b0df',
    transactionIndex: 1,
    type: '0x0',
    rawLogs: [ [Object], [Object] ]
  },
  logs: [
    {
      address: '0x96398724f62baB7FcF46D7ce53e857029efDaf73',
      blockNumber: 19649422,
      transactionHash: '0xba02a308aaf08e524b5ca87bdd024651d7a2cf467bb2de16b87886f97893b0df',
      transactionIndex: 1,
      blockHash: '0x6d098618e88d08c1a0d82b6353dad2cbc44930e7389698539f2832d444199198',
      logIndex: 0,
      removed: false,
      id: 'log_d61bba1f',
      event: 'BountyPaiedOut',
      args: [Result]
    },
    {
      address: '0x96398724f62baB7FcF46D7ce53e857029efDaf73',
      blockNumber: 19649422,
      transactionHash: '0xba02a308aaf08e524b5ca87bdd024651d7a2cf467bb2de16b87886f97893b0df',
      transactionIndex: 1,
      blockHash: '0x6d098618e88d08c1a0d82b6353dad2cbc44930e7389698539f2832d444199198',
      logIndex: 1,
      removed: false,
      id: 'log_7832e848',
      event: 'FulfillmentAccepted',
      args: [Result]
    }
  ]
}

truffle(bsc-testnet)> bounty.getBounty(0)
[
  '0x0dad1D5e11A921373516dA4C93bE439b33E71cC8',
  '0x0000000000000000000000000000000000000000',
  '0',
  true,
  [
    [
      '0x0dad1D5e11A921373516dA4C93bE439b33E71cC8',
      '1',
      account: '0x0dad1D5e11A921373516dA4C93bE439b33E71cC8',
      amount: '1'
    ]
  ],
  [
    [
      '0x46E862372D29A958d2690feC84263eFc0857f2BB',
      '1',
      account: '0x46E862372D29A958d2690feC84263eFc0857f2BB',
      amount: '1'
    ]
  ],
  issuer: '0x0dad1D5e11A921373516dA4C93bE439b33E71cC8',
  tokenAddress: '0x0000000000000000000000000000000000000000',
  balance: '0',
  hasPaidOut: true,
  contributions: [
    [
      '0x0dad1D5e11A921373516dA4C93bE439b33E71cC8',
      '1',
      account: '0x0dad1D5e11A921373516dA4C93bE439b33E71cC8',
      amount: '1'
    ]
  ],
  fulfillments: [
    [
      '0x46E862372D29A958d2690feC84263eFc0857f2BB',
      '1',
      account: '0x46E862372D29A958d2690feC84263eFc0857f2BB',
      amount: '1'
    ]
  ]
]
```

## RINKEBY
```
$ npx truffle console --network rinkeby
truffle(rinkeby)> migrate

Compiling your contracts...
===========================
> Everything is up to date, there is nothing to compile.


Starting migrations...
======================
> Network name:    'rinkeby'
> Network id:      4
> Block gas limit: 30000000 (0x1c9c380)


1_initial_migration.js
======================

   Deploying 'Migrations'
   ----------------------
   > transaction hash:    0xe0b0ae9158d75eefe074402df32e4e26c7dfe4205ba775e0f7012db5d2138d02
   > Blocks: 1            Seconds: 18
   > contract address:    0xc3C58cF7480f93F9386AC950D4F96099D96313Ff
   > block number:        10748364
   > block timestamp:     1653643256
   > account:             0x0dad1D5e11A921373516dA4C93bE439b33E71cC8
   > balance:             1.999374614993495996
   > gas used:            250154 (0x3d12a)
   > gas price:           2.500000026 gwei
   > value sent:          0 ETH
   > total cost:          0.000625385006504004 ETH

   Pausing for 2 confirmations...

   -------------------------------
   > confirmation number: 1 (block: 10748365)
   > confirmation number: 2 (block: 10748366)
   > Saving migration to chain.
   > Saving artifacts
   -------------------------------------
   > Total cost:     0.000625385006504004 ETH


2_deploy.js
===========

   Deploying 'DaoBounty'
   ---------------------
   > transaction hash:    0x1d6114340dd7c9452c60e1d9705fdeb6507419dabf025b88c1c039c3955b4f5a
   > Blocks: 1            Seconds: 18
   > contract address:    0x95aD5Fa971c4EF106f8a6dCec2e66e98E0bFa704
   > block number:        10748369
   > block timestamp:     1653643331
   > account:             0x0dad1D5e11A921373516dA4C93bE439b33E71cC8
   > balance:             1.992312352425744189
   > gas used:            2778992 (0x2a6770)
   > gas price:           2.500000024 gwei
   > value sent:          0 ETH
   > total cost:          0.006947480066695808 ETH

   Pausing for 2 confirmations...

   -------------------------------
   > confirmation number: 1 (block: 10748370)
   > confirmation number: 2 (block: 10748371)

   Deploying 'ProxyAdmin'
   ----------------------
   > transaction hash:    0x9cd5c80a27d1321f4986fb83edd718a8f1e77f1435a3b4abb3c093b85ee473b5
   > Blocks: 2            Seconds: 22
   > contract address:    0x6db8baB749B09ab33515CD462b13F424e05DE267
   > block number:        10748373
   > block timestamp:     1653643391
   > account:             0x0dad1D5e11A921373516dA4C93bE439b33E71cC8
   > balance:             1.991102302414127709
   > gas used:            484020 (0x762b4)
   > gas price:           2.500000024 gwei
   > value sent:          0 ETH
   > total cost:          0.00121005001161648 ETH

   Pausing for 2 confirmations...

   -------------------------------
   > confirmation number: 1 (block: 10748374)
   > confirmation number: 2 (block: 10748375)

   Deploying 'TransparentUpgradeableProxy'
   ---------------------------------------
   > transaction hash:    0x74fa843360ccf458f9ff70f4937c070631eac2eb1abd0131ade2ed65da064628
   > Blocks: 2            Seconds: 18
   > contract address:    0x21C75526aE28f83336820e9DcC36a317499c6B18
   > block number:        10748377
   > block timestamp:     1653643451
   > account:             0x0dad1D5e11A921373516dA4C93bE439b33E71cC8
   > balance:             1.989491779899955111
   > gas used:            644209 (0x9d471)
   > gas price:           2.500000022 gwei
   > value sent:          0 ETH
   > total cost:          0.001610522514172598 ETH

   Pausing for 2 confirmations...

   -------------------------------
   > confirmation number: 1 (block: 10748378)
   > confirmation number: 2 (block: 10748379)
Deployed 0x21C75526aE28f83336820e9DcC36a317499c6B18
   > Saving migration to chain.
   > Saving artifacts
   -------------------------------------
   > Total cost:     0.009768052592484886 ETH

Summary
=======
> Total deployments:   4
> Final cost:          0.01039343759898889 ETH
```