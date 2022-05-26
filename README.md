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

## BSC-TESTNET
```
$ truffle console --network bsc-testnet

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

truffle(bsc-testnet)> bounty.address
'0x21C75526aE28f83336820e9DcC36a317499c6B18'

truffle(bsc-testnet)> bounty.issueBounty('0x0000000000000000000000000000000000000000')
{
  tx: '0xce484c05df12e49f3200b786f968b8c8a30070967b7898691cb60e77d6d5afab',
  receipt: {
    blockHash: '0x72677bed106ffb4ace84fdfd29908dd434c50e6f4b5b9db56fb10d7449b6a219',
    blockNumber: 19629730,
    contractAddress: null,
    cumulativeGasUsed: 757092,
    from: '0x0dad1d5e11a921373516da4c93be439b33e71cc8',
    gasUsed: 72132,
    logs: [ [Object] ],
    logsBloom: '0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000020000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000020000002000000000000000000000000000000000101000000000000000000000000',
    status: true,
    to: '0x21c75526ae28f83336820e9dcc36a317499c6b18',
    transactionHash: '0xce484c05df12e49f3200b786f968b8c8a30070967b7898691cb60e77d6d5afab',
    transactionIndex: 6,
    type: '0x0',
    rawLogs: [ [Object] ]
  },
  logs: [
    {
      address: '0x21C75526aE28f83336820e9DcC36a317499c6B18',
      blockNumber: 19629730,
      transactionHash: '0xce484c05df12e49f3200b786f968b8c8a30070967b7898691cb60e77d6d5afab',
      transactionIndex: 6,
      blockHash: '0x72677bed106ffb4ace84fdfd29908dd434c50e6f4b5b9db56fb10d7449b6a219',
      logIndex: 7,
      removed: false,
      id: 'log_231ca574',
      event: 'BountyIssued',
      args: [Result]
    }
  ]
}

truffle(bsc-testnet)> bounty.contribute(0,1,{value:1})
{
  tx: '0x2c4c003797ab255b2dc6858f305b86eb3f952b4041e08f04ecb4e2012c58ad36',
  receipt: {
    blockHash: '0x7ab0bb1f59994aba9735584572173eafa36fa40287db0ae8ce0b00f9a505920e',
    blockNumber: 19629815,
    contractAddress: null,
    cumulativeGasUsed: 457797,
    from: '0x0dad1d5e11a921373516da4c93be439b33e71cc8',
    gasUsed: 118352,
    logs: [ [Object] ],
    logsBloom: '0x00000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000000000000000020000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000002000000000000000000000000000000000101000080000000000000000000',
    status: true,
    to: '0x21c75526ae28f83336820e9dcc36a317499c6b18',
    transactionHash: '0x2c4c003797ab255b2dc6858f305b86eb3f952b4041e08f04ecb4e2012c58ad36',
    transactionIndex: 3,
    type: '0x0',
    rawLogs: [ [Object] ]
  },
  logs: [
    {
      address: '0x21C75526aE28f83336820e9DcC36a317499c6B18',
      blockNumber: 19629815,
      transactionHash: '0x2c4c003797ab255b2dc6858f305b86eb3f952b4041e08f04ecb4e2012c58ad36',
      transactionIndex: 3,
      blockHash: '0x7ab0bb1f59994aba9735584572173eafa36fa40287db0ae8ce0b00f9a505920e',
      logIndex: 3,
      removed: false,
      id: 'log_3da917b9',
      event: 'ContributionAdded',
      args: [Result]
    }
  ]
}

truffle(bsc-testnet)> bounty.acceptFulfillment(0, [accounts[1],], [1,])
{
  tx: '0xbeb09444dd93c52546519833b5bfdbdf781548a8e5f47951f828ded7b2f519f0',
  receipt: {
    blockHash: '0xd335c5beca590011dbb0669dacda3dda25ba44a8bde1c7d54f9df37bcd7e76cd',
    blockNumber: 19629945,
    contractAddress: null,
    cumulativeGasUsed: 603045,
    from: '0x0dad1d5e11a921373516da4c93be439b33e71cc8',
    gasUsed: 147329,
    logs: [ [Object] ],
    logsBloom: '0x00000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000020000002000000000000000000000000000000000101000000000000000000000000',
    status: true,
    to: '0x21c75526ae28f83336820e9dcc36a317499c6b18',
    transactionHash: '0xbeb09444dd93c52546519833b5bfdbdf781548a8e5f47951f828ded7b2f519f0',
    transactionIndex: 6,
    type: '0x0',
    rawLogs: [ [Object] ]
  },
  logs: [
    {
      address: '0x21C75526aE28f83336820e9DcC36a317499c6B18',
      blockNumber: 19629945,
      transactionHash: '0xbeb09444dd93c52546519833b5bfdbdf781548a8e5f47951f828ded7b2f519f0',
      transactionIndex: 6,
      blockHash: '0xd335c5beca590011dbb0669dacda3dda25ba44a8bde1c7d54f9df37bcd7e76cd',
      logIndex: 4,
      removed: false,
      id: 'log_9033513f',
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
  fulfillers: [
    [
      '0x46E862372D29A958d2690feC84263eFc0857f2BB',
      '1',
      account: '0x46E862372D29A958d2690feC84263eFc0857f2BB',
      amount: '1'
    ]
  ]
]
```