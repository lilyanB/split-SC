const { expect, assert } = require("chai");
const { ethers } = require("hardhat");

describe("invest", async function () {
  let invest, erc20, owner, addr1, addr2;

  // deploy contract before the tests
  before("deploy the contract instance first", async function () {
    [owner, addr1, addr2] = await ethers.getSigners();
    const Invest = await ethers.getContractFactory("invest");
    invest = await Invest.deploy();
    await invest.deployed();

    const ERC20 = await ethers.getContractFactory("MyCollectible");
    erc20 = await ERC20.deploy(10);
    await erc20.deployed();


    console.log("invest", invest.address)
    console.log("erc20", erc20.address)
  });

  it("Good name", async function () {
    console.log(owner.address)
    console.log(addr1.address)
    console.log(addr2.address)
    const name = await invest.name()
    expect(name).to.equal("My Collection 1.0");
  });

  it("First creation", async function () {
    const supply = await invest.supply(1)
    const priceNFT = await invest.getValuesOfNFT(1)
    expect(supply.toString()).to.equal("10");
    expect(priceNFT.toString()).to.equal("10");
  });

  it("Second creation", async function () {
    const supply = await invest.supply(2)
    const priceNFT = await invest.getValuesOfNFT(2)
    expect(supply.toString()).to.equal("1");
    expect(priceNFT.toString()).to.equal("3");
  });

  it("third creation", async function () {
    const supply = await invest.supply(3)
    const priceNFT = await invest.getValuesOfNFT(3)
    expect(supply.toString()).to.equal("8");
    expect(priceNFT.toString()).to.equal("3");
  });


  it("New creation", async function () {
    uri = "https://ipfs.io/ipfs/bafybeibk2avibnccl5wcq5kqmmf3qyabugiq3ry6pwj5gux6hfgmm5xzom/"
    const txCreate = await invest.createNewToken(40, uri)
    await txCreate.wait()
    const txValues = await invest.setValuesOfNFT(300, 4)
    await txValues.wait()

    const supply = await invest.supply(4)
    const priceNFT = await invest.getValuesOfNFT(4)
    assert.equal(supply, 40);
    assert.equal(priceNFT, 300);
    const ID = await invest.currentID()
    assert.equal(ID - 1, 4)
  });

  it("test allowance", async function () {
    const balance = await erc20.balanceOf(owner.address)
    assert.equal(balance, 10 * 10 ** 18);
    const txIncreaseAllowance = await erc20.increaseAllowance(addr1.address, 20)
    await txIncreaseAllowance.wait()
    const allowance = await erc20.allowance(owner.address, addr1.address)
    assert.equal(allowance, 20);
  });

  it("transfer and force buy", async function () {
    const transferToken = await invest.safeTransferFrom(owner.address, addr1.address, 1, 2, "0x")
    await transferToken.wait()
    const numberOwnersWithoutMe = await invest.numberOwnersWithoutMe(1)
    assert.equal(numberOwnersWithoutMe, 2);

    const forceBuy = await invest.forceBuy(1)
    await forceBuy.wait()

    const numberOwnersWithoutMeAfterForceBuy = await invest.numberOwnersWithoutMe(1)
    assert.equal(numberOwnersWithoutMeAfterForceBuy, 0);


  });

});