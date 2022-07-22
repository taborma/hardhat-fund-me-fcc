// function deployFunc() {
//     console.log("Deploying contract...")
// }

const { getNamedAccounts, deployments, network } = require("hardhat")
const { networkConfig } = require("../helper-hardhat-config")
const {
    developmentChains,
    DECIMALS,
    INITIAL_PRICE
} = require("../helper-hardhat-config")
const { verify } = require("../utils/verify")
// module.exports.default = deployFunc
//below is diffrent syntax for the above
//hre is hardhat runtime environment

// module.exports = async hre => {
//     const { getNamedAccounts, deployments } = hre
// }

//above syntax of importing is the same as:
// const helperConfig = require("../helper-hardhat-config")
// const networkConfig = helperConfig.networkConfig

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId
    //when going for localhost or hardhat network we want to use a mock

    //const ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"]
    let ethUsdPriceFeedAddress
    if (chainId == 31337) {
        const ethUsdAggregator = await deployments.get("MockV3Aggregator")
        ethUsdPriceFeedAddress = ethUsdAggregator.address
    } else {
        ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"]
    }
    //const args = [ethUsdPriceFeedAddress]
    const fundMe = await deploy("FundMe", {
        from: deployer,
        args: [ethUsdPriceFeedAddress], // put price feed address here
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1
    })
    log(`FundMe deployed at ${fundMe.address}`)

    if (chainId != 31337 && process.env.ETHERSCAN_API_KEY) {
        await verify(fundMe.address, [ethUsdPriceFeedAddress])
    }
    log("----------------------------------------------------------")
}

module.exports.tags = ["fundme", "all"]
