import { Secp256k1HdWallet, SigningCosmosClient } from "@cosmjs/launchpad";
import { DirectSecp256k1HdWallet, OfflineDirectSigner } from "@cosmjs/proto-signing";
import { StargateClient, SigningStargateClient, IndexedTx } from "@cosmjs/stargate"
import { MsgSend } from "cosmjs-types/cosmos/bank/v1beta1/tx"
import { Tx } from "cosmjs-types/cosmos/tx/v1beta1/tx"
import { DaobaountyClient, DaobaountyQueryClient } from "../ts/Daobaounty.client";
import { SigningCosmWasmClient } from "@cosmjs/cosmwasm-stargate";

const rpcEndpoint = "https://vota-rpc.dorafactory.org";
const restEndpoint = "https://vota-rest.dorafactory.org";
const mnemonic = "reduce fire private pull win pear pizza expose donate sausage crash width erase like can choose parade join slot wisdom fatal soccer diamond canvas";
const chainId = "doravota-devnet";
const prefix = "dora";
const recipient = "dora1nt4elvrtc8yg772h9u24fusv78c2wv9zv0zusr";

(async () => {
    const wallet = await Secp256k1HdWallet.fromMnemonic(mnemonic, {
        prefix,
    });
    const [{ address }] = await wallet.getAccounts();
    console.log("Address:", address);

    const client = await StargateClient.connect(rpcEndpoint)

    // 查询余额
    console.log("With client, chain id:", await client.getChainId(), ", height:", await client.getHeight())
    console.log(
        "Admin balances:",
        await client.getAllBalances(address)
    )

    const faucetTx: IndexedTx = (await client.getTx(
        "40AACE3950400FF61B359B23558CDD9ACC68A63BD5F99F8EC062C3A47C3B918D"
    ))!
    console.log("Faucet Tx:", faucetTx)
    const decodedTx: Tx = Tx.decode(faucetTx.tx)
    console.log("DecodedTx:", decodedTx)
    console.log("Decoded messages:", decodedTx.body!.messages)
    const sendMessage: MsgSend = MsgSend.decode(decodedTx.body!.messages[0].value)
    console.log("Sent message:", sendMessage)
    const faucet: string = sendMessage.fromAddress
    console.log("Faucet balances:", await client.getAllBalances(faucet))

    console.log("Gas fee:", decodedTx.authInfo!.fee!.amount)
    console.log("Gas limit:", decodedTx.authInfo!.fee!.gasLimit.toString(10))

    // 构建和发送交易
    const signingClient = await SigningStargateClient.connectWithSigner(rpcEndpoint, wallet)
    console.log(
        "With signing client, chain id:",
        await signingClient.getChainId(),
        ", height:",
        await signingClient.getHeight()
    )

    console.log("Admin balance before:", await client.getAllBalances(address))
    console.log("Recipient balance before:", await client.getAllBalances(recipient))
    // Execute the sendTokens Tx and store the result
    // const result = await signingClient.sendTokens(
    //     address,
    //     recipient,
    //     [{ denom: "uDORA", amount: "1000" }],
    //     {
    //         amount: [{ denom: "uDORA", amount: "20" }],
    //         gas: "200000",
    //     },
    // )
    // // Output the result of the Tx
    // console.log("Send tokens result:", result);

    const cosmWasmClient = await SigningCosmWasmClient.connectWithSigner(rpcEndpoint, wallet)

    const contract = new DaobaountyClient(cosmWasmClient, "dora1kw5qfnrxk9sw5gcyk3emktwtca94e5a4dau8y3", "dora1k8pms0ywhsa0kjvkxqx434atqd5dh6w54k0gr8j45ra36q02py5sdnwm47");


    const res = await contract.issueBounty({
        donationDenom: 'uDORA',
    }, {
        amount: [{ denom: "uDORA", amount: "20" }],
        gas: "200000",
    },)
    console.log("Issue bounty result:", res)

    contract.getBounty({
        bountyId: 0
    }).then((res) => {
        console.log("Bounty:", res)
    })

    const res2 = await contract.contribute({
        amount: "200",
        bountyId: 0,
    }, {
        amount: [{ denom: "uDORA", amount: "20" }],
        gas: "200000",
    }, undefined, [{ denom: "uDORA", amount: "200" }])
    console.log("Contribute result:", res2)

    contract.getBounty({
        bountyId: 0
    }).then((res) => {
        console.log("Bounty:", res)
    })

    const res3 = await contract.issueAndContribute({amount: "200", donationDenom: "uDORA"}, {
        amount: [{ denom: "uDORA", amount: "20" }],
        gas: "200000",
    }, undefined, [{ denom: "uDORA", amount: "200" }])
    console.log("Issue and contribute result:", res3)

    contract.getBounty({
        bountyId: 1.
    }).then((res) => {
        console.log("Bounty:", res)
    }
    )

})();