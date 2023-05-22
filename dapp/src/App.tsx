import React from 'react';

const CONTRACT_ADDRESS = '0x2f234d8d4abb8a97adf9d049498efe2a65e37e4f3809eded3b030f9209a88d9a'

function App() {
  const wallet = window.aptos
  const [address, setAddress] = React.useState<string | null>(null);

  const connect = async () => {
    if (!wallet) {
      alert('Not found Petra Wallet')
      return
    }

    const { address } = await wallet.connect();
    setAddress(address);
  }

  const [bountyResult, setBountyResult] = React.useState<string>('');
  const issueBounty = async () => {

    const transaction = {
      arguments: [100000],
      function: CONTRACT_ADDRESS + '::bounty::issue_and_contribute',
      type: 'entry_function_payload',
      type_arguments: ['0x1::aptos_coin::AptosCoin'],
    }
    const result = await wallet.signAndSubmitTransaction(transaction)
    setBountyResult(JSON.stringify(result, null, 2))
  }

  const [bountyId, setBountyId] = React.useState<number>(0);
  const [hunterAddress, setHunterAddress] = React.useState<string>('');
  const [amount, setAmount] = React.useState<number>(0);

  const acceptFulfillment = async () => {
    if (!hunterAddress || !amount) {
      alert('Please enter a hunter address and amount')
      return
    }

    const transaction = {
      arguments: [bountyId, [hunterAddress], [amount]],
      function: CONTRACT_ADDRESS + '::bounty::accept_fulfillment',
      type: 'entry_function_payload',
      type_arguments: ['0x1::aptos_coin::AptosCoin'],
    }
    const result = await wallet.signAndSubmitTransaction(transaction)
    console.log(result)
  }

  return (
    <div>
      <div className='address' style={{ border: '1px solid blue', margin: '20px 20px' }}>
        <button onClick={connect}>Connect</button>
        <p>Account Address: <code>{address}</code></p>
      </div>
      <div className='bounty' style={{ border: '1px solid blue', margin: '20px 20px' }}>
        <button onClick={issueBounty}>Issue Bounty</button>
        <br />
        <label>Result of issuing bounty:</label>
        <textarea readOnly={true} rows={30} cols={100} value={bountyResult} />
      </div>
      <div className='fulfillment' style={{ border: '1px solid blue', margin: '20px 20px' }}>
        <label>Bounty ID:</label>
        <input type="number" value={bountyId} onChange={e => setBountyId(parseInt(e.target.value))} />
        <br />
        <label>Hunter Address:</label>
        <input type="text" value={hunterAddress} onChange={e => setHunterAddress(e.target.value)} style={
          { width: '500px' }
        } />
        <br />
        <label>Amount:</label>
        <input type="number" value={amount} onChange={e => setAmount(parseInt(e.target.value))} />
        <br />
        <button onClick={acceptFulfillment}>Accept Fulfillment</button>
      </div>
    </div>
  );
}

export default App;
