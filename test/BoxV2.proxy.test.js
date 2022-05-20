const { expect } = require("chai");
const { deployProxy, upgradeProxy } = require("@openzeppelin/truffle-upgrades");

// Load compiled artifacts
const Box = artifacts.require("Box");
const BoxV2 = artifacts.require("BoxV2");

// Start test block
contract("BoxV2 (proxy)", function () {
  beforeEach(async function () {
    // Deploy a new Box contract for each test
    this.box = await deployProxy(Box, [42], { initializer: "store" });
    this.boxV2 = await upgradeProxy(this.box.address, BoxV2);
  });

  // Test case
  it("retrieve returns a value previously incremented", async function () {
    // Increment
    await this.boxV2.increment();

    // Test if the returned value is the same one
    // Note that we need to use strings to compare the 256 bit integers
    expect((await this.boxV2.retrieve()).toString()).to.equal("43");
  });
});
