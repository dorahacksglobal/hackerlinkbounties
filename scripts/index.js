module.exports = async function main(callback) {
  try {
    const network = this.artifacts.options.network;
    // Retrieve accounts from the local node
    const accounts = await web3.eth.getAccounts();
    console.log(accounts);

    const DaoBounty = artifacts.require("DaoBounty");
    const bounty = await DaoBounty.deployed();

    console.log("Contract Address:", bounty.address);

    let tokenAddress = "0x0000000000000000000000000000000000000000";

    // bsc-testnet TestToken
    if (network === "bsc-testnet") {
      tokenAddress = "0xd4b13907a34db5ba3f95d27596d5b03842cec34b";
    }

    // mumbai TestToken
    if (network === "mumbai") {
      tokenAddress = "0x21240d5e5a6556d0ccb93685902122e9ac284c4f";
    }

    const isErc20 = web3.utils.toBN(tokenAddress).toString() !== "0";

    console.log("Token Address:", tokenAddress, "ERC20:", isErc20);

    await bounty.addToWhitelist(tokenAddress);
    const tokenAddressWhitelist = await bounty.tokenWhitelist(tokenAddress);
    console.log({ tokenAddressWhitelist });

    let issueBountyRs = await bounty.issueBounty(tokenAddress);
    console.log("issueBountyRs", issueBountyRs);

    const bountyIssuedLog = issueBountyRs.logs.filter(
      (log) => log.event === "BountyIssued"
    )[0];

    const bountyId = bountyIssuedLog.args._bountyId;

    await bounty.contribute(bountyId, 1, { value: isErc20 ? 0 : 1 });

    await bounty.acceptFulfillment(bountyId, [accounts[1]], [1]);

    const getBountyRs = await bounty.getBounty(bountyId);
    console.log("getBountyRs", getBountyRs);

    callback(0);
  } catch (error) {
    console.error(error);
    callback(1);
  }
};
