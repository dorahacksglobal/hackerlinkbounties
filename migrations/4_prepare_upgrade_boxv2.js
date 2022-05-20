const Box = artifacts.require("Box");
const BoxV2 = artifacts.require("BoxV2");

const { prepareUpgrade } = require("@openzeppelin/truffle-upgrades");

module.exports = async function (deployer) {
  const box = await Box.deployed();
  await prepareUpgrade(box.address, BoxV2, { deployer });
};
