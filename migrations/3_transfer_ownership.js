const { admin } = require("@openzeppelin/truffle-upgrades");

module.exports = async function (deployer, network) {
  // Use address of your Gnosis Safe
  const gnosisSafe = "0x1c14600daeca8852BA559CC8EdB1C383B8825906";

  // Don't change ProxyAdmin ownership for our test network
  if (network !== "test" && network !== "develop") {
    // The owner of the ProxyAdmin can upgrade our contracts
    await admin.transferProxyAdminOwnership(gnosisSafe);
  }
};
