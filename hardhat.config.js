/** @type import('hardhat/config').HardhatUserConfig */

require('@nomiclabs/hardhat-waffle');
require('@nomicfoundation/hardhat-toolbox');
require('@nomiclabs/hardhat-etherscan');
require('dotenv').config();

module.exports = {
  solidity: "0.8.27", 
    hardhat: {},
    fuji: {
      url: `https://api.avax-test.network/ext/bc/C/rpc`,
      chainId: 43113,
      accounts: [process.env.PRIVATE_KEY]
    },
    avalanche: { 
      url: `https://api.avax.network/ext/bc/C/rpc`,
      chainId: 43114,
      accounts: [process.env.PRIVATE_KEY]
    },
  
  etherscan: {
    apiKey: process.env.AVAXSCAN_API_KEY 
  },
};
