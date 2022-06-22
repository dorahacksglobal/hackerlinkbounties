/*
usage:
truffle(network)> exec scripts/add-token.js <TOKEN_ADDRESS>
*/

/*
Polygon
  DAI:  0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063 18
  USDC: 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174 6
  USDT: 0xc2132D05D31c914a87C6611C10748AEb04B58e8F 6
Bsc
  DAI:  0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3 18
  USDC: 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d 18
  USDT: 0x55d398326f99059fF775485246999027B3197955 18
*/

module.exports = async (callback) => {
  const argument = process.argv[2] || '';

  const matched = argument.match(/0x[0-9a-fA-F]{40}$/);

  if (!matched) {
    callback(1);
    return;
  }

  const tokenAddress = matched[0];

  try {
    // Retrieve accounts from the local node
    const accounts = await web3.eth.getAccounts();
    console.log(accounts);

    const DaoBounty = artifacts.require("DaoBounty");
    const bounty = await DaoBounty.deployed();

    console.log("Contract Address:", bounty.address);

    const isErc20 = web3.utils.toBN(tokenAddress).toString() !== "0";

    console.log("Token Address:", tokenAddress, "ERC20:", isErc20);

    await bounty.addToWhitelist(tokenAddress);
    const tokenAddressWhitelist = await bounty.tokenWhitelist(tokenAddress);
    console.log({ tokenAddressWhitelist });

    callback(0);
  } catch (error) {
    console.log(error.message || error);
    callback(1);
  }
}
