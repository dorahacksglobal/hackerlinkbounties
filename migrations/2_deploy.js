const { deployProxy } = require("@openzeppelin/truffle-upgrades");

const DaoBounty = artifacts.require("DaoBounty");

module.exports = async function (deployer) {
  const instance = await deployProxy(DaoBounty, { deployer });
  console.log("Deployed", instance.address);
};
