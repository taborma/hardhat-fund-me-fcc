require("@nomicfoundation/hardhat-toolbox")
require("dotenv").config()
require("@nomiclabs/hardhat-etherscan")
require("hardhat-gas-reporter")
require("solidity-coverage")
require("hardhat-deploy")

/** @type import('hardhat/config').HardhatUserConfig */

const RPC_URL_RINKEBY = process.env.RPC_URL_RINKEBY || "https://eth-rinkeby"
const PRIVATE_KEY_RINKEBY = process.env.PRIVATE_KEY_RINKEBY || "0xkey"
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY || "0xkey"
const RPC_URL_LOCALHOST = process.env.RPC_URL_LOCALHOST || "localhost::"
const PRIVATE_KEY_LOCALHOST = process.env.PRIVATE_KEY_LOCALHOST || "0xkey"
const COINMARKETCAP_API_KEY = process.env.COINMARKETCAP_API_KEY || "0xkey"

module.exports = {
    defaultNetwork: "hardhat",
    networks: {
        rinkeby: {
            url: RPC_URL_RINKEBY,
            accounts: [PRIVATE_KEY_RINKEBY],
            chainId: 4,
            blockConfirmations: 6
        },
        localhost: {
            url: RPC_URL_LOCALHOST,
            accounts: [PRIVATE_KEY_LOCALHOST],
            chainId: 31337
        }
    },
    solidity: {
        compilers: [
            {
                version: "0.8.8"
            },
            {
                version: "0.6.6"
            }
        ]
    },
    etherscan: {
        apiKey: ETHERSCAN_API_KEY
    },
    gasReporter: {
        enabled: true,
        outputFile: "gas-report.txt",
        noColors: true,
        currency: "USD",
        coinmarketcap: COINMARKETCAP_API_KEY,
        token: "ETH"
    },
    namedAccounts: {
        deployer: {
            default: 0
        }
    }
}
