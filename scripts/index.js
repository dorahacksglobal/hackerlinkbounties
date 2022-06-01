module.exports = async function main(callback) {
  try {
    // Retrieve accounts from the local node
    const accounts = await web3.eth.getAccounts();
    console.log(accounts);

    const DaoBounty = artifacts.require("DaoBounty");
    const bounty = await DaoBounty.deployed();

    let issueBountyRs = await bounty.issueBounty(
      "0x0000000000000000000000000000000000000000"
    );
    console.log("issueBountyRs", issueBountyRs);

    await bounty.contribute(0, 1, { value: 1 });

    await bounty.acceptFulfillment(0, [accounts[1]], [1]);

    const getBountyRs = await bounty.getBounty(0);
    console.log("getBountyRs", getBountyRs);

    callback(0);
  } catch (error) {
    console.error(error);
    callback(1);
  }
};
