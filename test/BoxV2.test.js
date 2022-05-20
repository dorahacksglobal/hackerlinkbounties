// test/BoxV2.test.js
// Load dependencies
const { expect } = require("chai");

// Load compiled artifacts
const BoxV2 = artifacts.require("BoxV2");

// Start test block
contract("BoxV2", function () {
  beforeEach(async function () {
    // Deploy a new BoxV2 contract for each test
    this.boxV2 = await BoxV2.new();
  });

  // Test case
  it("retrieve returns a value previously stored", async function () {
    // Store a value
    await this.boxV2.store(42);

    // Test if the returned value is the same one
    // Note that we need to use strings to compare the 256 bit integers
    expect((await this.boxV2.retrieve()).toString()).to.equal("42");
  });

  // Test case
  it("retrieve returns a value previously incremented", async function () {
    // Increment
    await this.boxV2.increment();

    // Test if the returned value is the same one
    // Note that we need to use strings to compare the 256 bit integers
    expect((await this.boxV2.retrieve()).toString()).to.equal("1");
  });
});
