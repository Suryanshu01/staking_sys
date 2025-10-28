const hre = require("hardhat");


async function main() {
const tokenAddress = process.env.TOKEN_ADDRESS; // address of deployed token on target network
if (!tokenAddress) throw new Error("Set TOKEN_ADDRESS env var to the BEP20 token address");


const Staking = await hre.ethers.getContractFactory("Staking");
const staking = await Staking.deploy(tokenAddress);
await staking.deployed();


console.log("Staking deployed to:", staking.address);
}


main().catch((error) => {
console.error(error);
process.exitCode = 1;
});
