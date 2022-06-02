module.exports = async function main(callback) {
  try {
    // Retrieve accounts from the local node
    const accounts = await web3.eth.getAccounts();
    console.log(accounts);

    const DaoBounty = artifacts.require("DaoBounty");
    const bounty = await DaoBounty.deployed();

    // bsc-testnet TestToken
    if ((network_id = 97)) {
      const bscTestnetTokenAddress =
        "0xd4b13907a34db5ba3f95d27596d5b03842cec34b";
      await bounty.addToWhitelist(bscTestnetTokenAddress);
      const bscTestnetTokenAddressWhitelist = await bounty.tokenWhitelist(
        bscTestnetTokenAddress
      );
      console.log({ bscTestnetTokenAddressWhitelist });
    }

    // mumbai TestToken
    if ((network_id = 80001)) {
      const mumbaiTokenAddress = "0x21240d5e5a6556d0ccb93685902122e9ac284c4f";
      await bounty.addToWhitelist(mumbaiTokenAddress);
      const mumbaiTokenAddressWhitelist = await bounty.tokenWhitelist(
        mumbaiTokenAddress
      );
      console.log({ mumbaiTokenAddressWhitelist });
    }

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
