const { expect } = require("chai");

// Import utilities from Test Helpers
const { BN, expectEvent, expectRevert } = require("@openzeppelin/test-helpers");

// Load compiled artifacts
const DaoBounty = artifacts.require("DaoBounty");
const TestToken = artifacts.require("TestToken");

// Start test block
contract("DaoBounty", function ([owner, other]) {
  // Use large integers ('big numbers')
  const value = new BN("42");

  before(async () => {
    this.token = await TestToken.new(1000000);
    console.log("Deployed Test Token ==>", this.token.address);
    const balance = await this.token.balanceOf(owner);
    expect(balance).to.be.bignumber.equal("1000000");
  });

  beforeEach(async () => {
    this.bounty = await DaoBounty.new();
    console.log("Deployed Bounty ==>", this.bounty.address);
    await this.bounty.addToWhitelist(this.token.address);
  });

  it("Verifies that I can issue a bounty paying without locking up funds", async () => {
    await this.bounty.issueBounty(this.token.address);

    let total = await this.bounty.numBounties();
    expect(total).to.be.bignumber.equal("1");
  });

  it("[ERC20] Verifies that I can issue a bounty paying in ERC20 tokens while locking up funds", async () => {
    await this.token.approve(this.bounty.address, 1000, { from: owner });
    await this.bounty.issueAndContribute(this.token.address, 1, {
      from: owner,
    });

    let total = await this.bounty.numBounties();
    expect(total).to.be.bignumber.equal("1");

    let bounty = await this.bounty.bounties(0);
    expect(bounty.balance).to.be.bignumber.equal("1");
  });

  it("[ERC20] Verifies that I can't issue a bounty in tokens contributing both tokens and ETH", async () => {
    await this.token.approve(this.bounty.address, 1000, { from: owner });
    await expectRevert(
      this.bounty.issueAndContribute(this.token.address, 1, {
        value: 1,
        gasLimit: 1000000,
      }),
      "Bounty can't be issued in both ETH and ERC20"
    );
  });

  it("[ERC20] Verifies that I can't issue a bounty contributing less than the deposit amount", async () => {
    await this.token.approve(this.bounty.address, 1, { from: owner });
    await expectRevert(
      this.bounty.issueAndContribute(this.token.address, 10, {
        value: 0,
        gasLimit: 1000000,
      }),
      "ERC20: insufficient allowance"
    );
  });

  it("[ERC20] Verifies that I can contribute to a bounty in ERC20 tokens", async () => {
    await this.token.approve(this.bounty.address, 1000, { from: owner });
    const rs = await this.bounty.issueAndContribute(this.token.address, 1);
    await this.bounty.contribute(0, 1);

    const bounty = await this.bounty.bounties(0);
    expect(bounty.balance).to.be.bignumber.equal("2");
  });

  it("[ERC20] Verifies that I can accept fulfillment", async () => {
    await this.token.approve(this.bounty.address, 1000, { from: owner });
    const rs = await this.bounty.issueAndContribute(this.token.address, 100);
    await this.bounty.acceptFulfillment(0, [other], [40]);

    const bounty = await this.bounty.bounties(0);
    expect(bounty.balance).to.be.bignumber.equal("60");

    const balance = await this.token.balanceOf(other);
    expect(balance).to.be.bignumber.equal("40");
  });

  it("[ERC20] Verifies that I can't accept a fulfillment paying out more than the balance of my bounty ", async () => {
    await this.token.approve(this.bounty.address, 1000, { from: owner });
    const rs = await this.bounty.issueAndContribute(this.token.address, 100);

    await expectRevert(
      this.bounty.acceptFulfillment(0, [other], [500]),
      "Amount should not be greater than bounty balance"
    );
  });
});
