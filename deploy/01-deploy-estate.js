const { networkConfig, developmentChains } = require("../helper-hardhat-config")
const { network } = require("hardhat")
const { verify } = require("../utils/verify")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()

    // address = "0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e"
    const chainId = network.config.chainId

    const args = []

    const estate = await deploy("Estate", {
        from: deployer,
        args: args,
        log: true,
        waitConfirmation: network.config.blockConfirmations || 1,
    })

    if (
        !developmentChains.includes(network.name) &&
        process.env.ETHERSCAN_API_KEY
    ) {
        await verify(estate.address, args)
    }
}

module.exports.tags = ["all", "estate"]
