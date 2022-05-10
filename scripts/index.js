module.exports = async function main(callback) {
  try {
    // Our code will go here
    // Retrieve accounts from the local node
    const accounts = await web3.eth.getAccounts();
    console.log(accounts);
    const DaoBounty = artifacts.require("DaoBounty");
    const box = await DaoBounty.deployed();
    let value = await box.retrieve();
    console.log("DaoBounty value is", value.toString());
    // Send a transaction to store() a new value in the DaoBounty
    await box.store(23);

    // Call the retrieve() function of the deployed DaoBounty contract
    value = await box.retrieve();
    console.log("DaoBounty value is", value.toString());

    callback(0);
  } catch (error) {
    console.error(error);
    callback(1);
  }
};
