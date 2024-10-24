const { expect } = require("chai");

describe("OwnershipContract", function () {
  it("Should mint ownership tokens", async function () {
    const [owner] = await ethers.getSigners();
    const OwnershipContract = await ethers.getContractFactory("OwnershipContract");
    const ownershipContract = await OwnershipContract.deploy();
    await ownershipContract.deployed();

    await ownershipContract.mintOwnershipToken(owner.address, "ipfs://example");

    expect(await ownershipContract.ownerOf(0)).to.equal(owner.address);
    expect(await ownershipContract.getTokenMetadata(0)).to.equal("ipfs://example");
  });
});
