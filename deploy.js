const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const SoulboundCarbonOffsetToken = await hre.ethers.getContractFactory("SoulboundCarbonOffsetToken");
  const tokenURI = "https://your-base-uri.com/metadata/";
  const soulboundCarbonOffsetToken = await SoulboundCarbonOffsetToken.deploy(tokenURI);

  await soulboundCarbonOffsetToken.deployed();

  console.log("SoulboundCarbonOffsetToken deployed to:", soulboundCarbonOffsetToken.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
