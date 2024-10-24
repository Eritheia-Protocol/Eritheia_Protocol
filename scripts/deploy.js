async function main() {
    // Get the deployer's address
    const [deployer] = await ethers.getSigners();

    console.log("Deploying contracts with the account:", deployer.address);
    console.log("Account balance:", (await deployer.getBalance()).toString());

    // Get the contract factory for RoyaltyContract
    const RoyaltyContract = await ethers.getContractFactory("RoyaltyContract");

    // Deploy the contract
    const royaltyContract = await RoyaltyContract.deploy();
    await royaltyContract.deployed();

    // Log the address where the contract is deployed
    console.log("RoyaltyContract deployed to:", royaltyContract.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
