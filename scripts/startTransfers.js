const {ethers} = require('hardhat');

async function main() {
    const Token = await ethers.getContractFactory("ESom");
    const token = Token.attach("0x3B72bed884B366ECe576f88b61b83812C3d0eaf0");
    await token.resumeTransfers();
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });