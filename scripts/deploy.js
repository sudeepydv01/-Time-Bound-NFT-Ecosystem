const hre = require("hardhat");

async function main() {
  // Replace this with your desired owner address, or use deployer's address
  const [deployer] = await hre.ethers.getSigners();
  const initialOwner = deployer.address;

  console.log("Deploying contract with account:", initialOwner);

  const ChronoNFT = await hre.ethers.getContractFactory("ChronoNFT");
  const chronoNFT = await ChronoNFT.deploy(initialOwner);

  await chronoNFT.deployed();

  console.log("ChronoNFT deployed to:", chronoNFT.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
