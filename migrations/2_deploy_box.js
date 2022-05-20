const Box = artifacts.require("Box");

const { deployProxy } = require("@openzeppelin/truffle-upgrades");

module.exports = async function (deployer) {
  await deployProxy(Box, [42], { deployer, initializer: "store" });
};
