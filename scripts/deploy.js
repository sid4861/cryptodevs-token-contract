const hre = require("hardhat");
const { CRYPTO_DEVS_NFT_CONTRACT_ADDRESS } = require("../constants");

async function main() {
    const CryptoDevsTokenFactory = await hre.ethers.getContractFactory("CryptoDevsToken");
    const CryptoDevsTokenDeployed = await CryptoDevsTokenFactory.deploy(CRYPTO_DEVS_NFT_CONTRACT_ADDRESS);
    await CryptoDevsTokenDeployed.deployed();
    console.log(CryptoDevsTokenDeployed.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });