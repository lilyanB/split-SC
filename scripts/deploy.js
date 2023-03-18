const {
  ethers
} = require("hardhat");

async function main() {
  const invest = await ethers.getContractFactory("invest");

  // Start deployment, returning a promise that resolves to a contract object
  const myContract = await invest.deploy();
  await myContract.deployed();
  console.log("Contract deployed to address:", myContract.address);
}

async function main2() {
  const MyCollectible = await ethers.getContractFactory("MyCollectible");

  // Start deployment, returning a promise that resolves to a contract object
  const myContract = await MyCollectible.deploy(100000);
  await myContract.deployed();
  console.log("Contract deployed to address:", myContract.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });