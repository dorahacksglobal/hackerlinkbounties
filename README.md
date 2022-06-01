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
✗ npx truffle console --network bsc-testnet
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

   Deploying 'Migrations'
   ----------------------
   > transaction hash:    0xfea67167e8f60be21b83f46df6bffbd6fc3c1c081d1f0811a4d5a2c44390a1a6
   > Blocks: 5            Seconds: 14
   > contract address:    0xE35C93dD1879859E24f621e961818D78E86c4918
   > block number:        19804080
   > block timestamp:     1654052702
   > account:             0x0dad1D5e11A921373516dA4C93bE439b33E71cC8
   > balance:             0.296931009999999998
   > gas used:            248854 (0x3cc16)
   > gas price:           10 gwei
   > value sent:          0 ETH
   > total cost:          0.00248854 ETH

   Pausing for 2 confirmations...

   -------------------------------
   > confirmation number: 2 (block: 19804085)
   > Saving migration to chain.
   > Saving artifacts
   -------------------------------------
   > Total cost:          0.00248854 ETH


2_deploy.js
===========

   Deploying 'DaoBounty'
   ---------------------
   > transaction hash:    0x1867c04d13ed1338094f77d21f79ca23ca4408b13eb40d1389fbbfc71fae8530
   > Blocks: 4            Seconds: 14
   > contract address:    0x193e0A1b3884c0861FC71b8508E5de89832F9a22
   > block number:        19804098
   > block timestamp:     1654052756
   > account:             0x0dad1D5e11A921373516dA4C93bE439b33E71cC8
   > balance:             0.268716079999999998
   > gas used:            2778980 (0x2a6764)
   > gas price:           10 gwei
   > value sent:          0 ETH
   > total cost:          0.0277898 ETH

   Pausing for 2 confirmations...

   -------------------------------
   > confirmation number: 2 (block: 19804103)

   Deploying 'TransparentUpgradeableProxy'
   ---------------------------------------
   > transaction hash:    0x73fa444e3d6e1948894109ff75128672a10199b028863590ef02df5a51368e28
   > Blocks: 5            Seconds: 14
   > contract address:    0xE51567308ED28D4a3A75675a54EB8C72C88cDC88
   > block number:        19804112
   > block timestamp:     1654052798
   > account:             0x0dad1D5e11A921373516dA4C93bE439b33E71cC8
   > balance:             0.262262989999999998
   > gas used:            645309 (0x9d8bd)
   > gas price:           10 gwei
   > value sent:          0 ETH
   > total cost:          0.00645309 ETH

   Pausing for 2 confirmations...

   -------------------------------
   > confirmation number: 1 (block: 19804116)
   > confirmation number: 3 (block: 19804118)
Deployed 0xE51567308ED28D4a3A75675a54EB8C72C88cDC88
   > Saving migration to chain.
   > Saving artifacts
   -------------------------------------
   > Total cost:          0.03424289 ETH

Summary
=======
> Total deployments:   3
> Final cost:          0.03673143 ETH

truffle(bsc-testnet)> exec scripts/index.js
Using network 'bsc-testnet'.

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
issueBountyRs {
  tx: '0x3b28ddad948862c69374a79f187a4fddb9c1a288ef1fbbde020f5189f9228364',
  receipt: {
    blockHash: '0x3ee30f3b82da628802e226ae6e609e4a067c886905237ca3731e1eab0b755f1a',
    blockNumber: 19804184,
    contractAddress: null,
    cumulativeGasUsed: 128448,
    from: '0x0dad1d5e11a921373516da4c93be439b33e71cc8',
    gasUsed: 72132,
    logs: [ [Object] ],
    logsBloom: '0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000040000000000000000000000000000000000000000000000020000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000000040000000000000000000000000000000000000000000000000000000',
    status: true,
    to: '0xe51567308ed28d4a3a75675a54eb8c72c88cdc88',
    transactionHash: '0x3b28ddad948862c69374a79f187a4fddb9c1a288ef1fbbde020f5189f9228364',
    transactionIndex: 2,
    type: '0x0',
    rawLogs: [ [Object] ]
  },
  logs: [
    {
      address: '0xE51567308ED28D4a3A75675a54EB8C72C88cDC88',
      blockNumber: 19804184,
      transactionHash: '0x3b28ddad948862c69374a79f187a4fddb9c1a288ef1fbbde020f5189f9228364',
      transactionIndex: 2,
      blockHash: '0x3ee30f3b82da628802e226ae6e609e4a067c886905237ca3731e1eab0b755f1a',
      logIndex: 0,
      removed: false,
      id: 'log_89f05c27',
      event: 'BountyIssued',
      args: [Result]
    }
  ]
}
getBountyRs [
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

## Mumbai
```
✗ npx truffle console --network mumbai
truffle(mumbai)> migrate

Compiling your contracts...
===========================
> Everything is up to date, there is nothing to compile.


Starting migrations...
======================
> Network name:    'mumbai'
> Network id:      80001
> Block gas limit: 20000000 (0x1312d00)


1_initial_migration.js
======================

   Deploying 'Migrations'
   ----------------------
   > transaction hash:    0xd9b2d2bd9db890541bb325631185bf58e411569f0da255733a63776814f2aacf
   > Blocks: 1            Seconds: 9
   > contract address:    0xc3C58cF7480f93F9386AC950D4F96099D96313Ff
   > block number:        26545404
   > block timestamp:     1654022714
   > account:             0x0dad1D5e11A921373516dA4C93bE439b33E71cC8
   > balance:             0.099374614997748614
   > gas used:            250154 (0x3d12a)
   > gas price:           2.500000009 gwei
   > value sent:          0 ETH
   > total cost:          0.000625385002251386 ETH

   Pausing for 2 confirmations...

   -------------------------------
   > confirmation number: 1 (block: 26545406)
   > confirmation number: 2 (block: 26545407)
   > Saving migration to chain.
   > Saving artifacts
   -------------------------------------
   > Total cost:     0.000625385002251386 ETH


2_deploy.js
===========

   Deploying 'DaoBounty'
   ---------------------
   > transaction hash:    0x268feea0afd59ed580698e3026a95ab8893ed8bc93e30eeed4fff0b1fabcbaf6
   > Blocks: 3            Seconds: 13
   > contract address:    0x95aD5Fa971c4EF106f8a6dCec2e66e98E0bFa704
   > block number:        26545414
   > block timestamp:     1654022765
   > account:             0x0dad1D5e11A921373516dA4C93bE439b33E71cC8
   > balance:             0.092312382472324577
   > gas used:            2778980 (0x2a6764)
   > gas price:           2.500000009 gwei
   > value sent:          0 ETH
   > total cost:          0.00694745002501082 ETH

   Pausing for 2 confirmations...

   -------------------------------
   > confirmation number: 1 (block: 26545416)
   > confirmation number: 2 (block: 26545417)

   Deploying 'ProxyAdmin'
   ----------------------
   > transaction hash:    0x496bb21445186cfd520040d7222aef96c3c5a07a1bb8f792f539789c5a380a02
   > Blocks: 2            Seconds: 9
   > contract address:    0x6db8baB749B09ab33515CD462b13F424e05DE267
   > block number:        26545420
   > block timestamp:     1654022795
   > account:             0x0dad1D5e11A921373516dA4C93bE439b33E71cC8
   > balance:             0.091102332467968397
   > gas used:            484020 (0x762b4)
   > gas price:           2.500000009 gwei
   > value sent:          0 ETH
   > total cost:          0.00121005000435618 ETH

   Pausing for 2 confirmations...

   -------------------------------
   > confirmation number: 1 (block: 26545422)
   > confirmation number: 2 (block: 26545423)

   Deploying 'TransparentUpgradeableProxy'
   ---------------------------------------
   > transaction hash:    0xfbb093c36dba8159636629c8f737a36f8cac87cdd7b355926d0623500fb9efbb
   > Blocks: 1            Seconds: 9
   > contract address:    0x21C75526aE28f83336820e9DcC36a317499c6B18
   > block number:        26545427
   > block timestamp:     1654022830
   > account:             0x0dad1D5e11A921373516dA4C93bE439b33E71cC8
   > balance:             0.089491809961526307
   > gas used:            644209 (0x9d471)
   > gas price:           2.50000001 gwei
   > value sent:          0 ETH
   > total cost:          0.00161052250644209 ETH

   Pausing for 2 confirmations...

   -------------------------------
   > confirmation number: 1 (block: 26545429)
   > confirmation number: 2 (block: 26545430)
Deployed 0x21C75526aE28f83336820e9DcC36a317499c6B18
   > Saving migration to chain.
   > Saving artifacts
   -------------------------------------
   > Total cost:     0.00976802253580909 ETH

Summary
=======
> Total deployments:   4
> Final cost:          0.010393407538060476 ETH
```
