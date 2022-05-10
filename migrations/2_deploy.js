const DaoBounty = artifacts.require("DaoBounty");

module.exports = async function (deployer) {
  await deployer.deploy(DaoBounty);
};
