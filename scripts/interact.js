const API_KEY = process.env.API_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const CONTRACT_ADDRESS = process.env.CONTRACT_ADDRESS;
const CONTRACT_ADDRESS_ERC20 = process.env.CONTRACT_ADDRESS_ERC20;
const MY_ADRESS = process.env.MY_ADRESS;
const MAX_ADRESS = process.env.MAX_ADRESS;
const {
  ethers
} = require("hardhat");
const contract = require("../artifacts/contracts/invest.sol/invest.json");
const contractERC20 = require("../artifacts/contracts/MyCollectible.sol/MyCollectible.json");

//console.log(JSON.stringify(contract.abi));

const provider = new ethers.providers.AlchemyProvider(network="maticmum", API_KEY);
const signer = new ethers.Wallet(PRIVATE_KEY, provider);
const myContract = new ethers.Contract(CONTRACT_ADDRESS, contract.abi, signer);
const myContractERC20 = new ethers.Contract(CONTRACT_ADDRESS_ERC20, contractERC20.abi, signer);


async function main() {
  let lilA = MY_ADRESS
  let maxA = MAX_ADRESS
  let contract = CONTRACT_ADDRESS
  let contractERC20 = CONTRACT_ADDRESS_ERC20

  
  const erc20 = await myContract.ERC20Address();
  console.log("Address erc20 : ", erc20);

  // const newerc20 = await myContract.ChangeERC20Address("0x16058B460D6fB42a3c9b7201dC8e6D62f357e161",1)
  // console.log("Address erc20 : ", newerc20);

  
  // const transfert = await myContract.safeTransferFrom(lilA,maxA,1,1,2);
  // console.log("Info transfert : ", JSON.stringify(transfert));


  // const increase = await myContractERC20.increaseAllowance("0x4037dB72F35e48C820EACca56b9CCE10f82875B4",90)
  const allowance = await myContractERC20.allowance(lilA,contract);
  console.log("Current allowance : ", allowance);

  //const setValue = await myContract.setValuesOfNFT(10,1)
  const value = await myContract.getValuesOfNFT(1)
  console.log("Current value Wine : ", value);

  const myBalanceSaintEmilion = await myContract.balanceOf(MY_ADRESS, 1);
  console.log("Balance of SaintEmilion : ", JSON.stringify(myBalanceSaintEmilion));
  console.log("Balance of SaintEmilion : ", myBalanceSaintEmilion.toNumber());
  const myBalancemontre = await myContract.balanceOf(MY_ADRESS, 2);
  console.log("Balance of montre : ", myBalancemontre.toNumber());
  const myBalancenike = await myContract.balanceOf(MY_ADRESS, 3);
  console.log("Balance of nike : ", myBalancenike.toNumber());
  
  // const name = await myContract.name();
  // console.log("Name of Collection : ", name);

  // const supplySaintEmilion = await myContract.supply(1);
  // console.log("Supply of SaintEmilion : ", supplySaintEmilion.toNumber());
  // const supplymontre = await myContract.supply(2);
  // console.log("Supply of montre : ", supplymontre.toNumber());
  // const supplynike = await myContract.supply(3);
  // console.log("Supply of nike : ", supplynike.toNumber());

  
  // const balanceSaintEmilionLil = await myContract.percent(MY_ADRESS, 1);
  // console.log("Percent of SaintEmilion, Contract have : ", balanceSaintEmilionLil.toNumber());
  // const balanceSaintEmilion = await myContract.percent(MAX_ADRESS, 1);
  // console.log("Percent of SaintEmilion, Max have : ", balanceSaintEmilion.toNumber());
  // const balancemontre = await myContract.percent(MY_ADRESS, 2);
  // console.log("Percent of montre : ", balancemontre.toNumber());
  // const balancenike = await myContract.percent(MY_ADRESS, 3);
  // console.log("Percent of nike : ", balancenike.toNumber());


  
  const canBuyContract = await myContract.canBuyAll(MY_ADRESS, 1);
  console.log("If Me can buy all : ", canBuyContract);
  // const canBuyMax = await myContract.canBuyAll(MAX_ADRESS, 1);
  // console.log("If Max can buy all : ", canBuyMax);


  const allOwner1 = await myContract.allOwner(1);
  console.log("All owner of 1 : ", allOwner1);
  // const allOwner2 = await myContract.allOwner(2);
  // console.log("All owner of 2 : ", allOwner2);
  // const allOwner3 = await myContract.allOwner(3);
  // console.log("All owner of 3 : ", allOwner3);



  const ownersWithoutMe = await myContract.OwnersWithoutMe(1);
  console.log("All owners of Saint-Emilion whithout you : ", ownersWithoutMe);

  const montantPourTousAcheter = await myContract.valueToBuy(lilA,1);
  console.log( `You need ${montantPourTousAcheter} SPLIT to buy all Saint-Emilion`);


  // const forceBuy = await myContract.forceBuy(1)
  // console.log("Result force buy : ", forceBuy);

  /*const approve = await myContractERC20.approve(CONTRACT_ADDRESS,montantPourTousAcheter);
  console.log( `Is approve : ${approve}`); */

  /* const mint = await myContractERC20.mintToken();
  console.log( `mint : ${mint}`); */

  /* const forceBuy = await myContract.forceBuy(1, montantPourTousAcheter);
  console.log("Result force buy : ", forceBuy); */
 }
 
 main()
   .then(() => process.exit(0))
   .catch(error => {
     console.error(error);
     process.exit(1);
   });