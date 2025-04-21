const {ethers} = require('hardhat');

async function main() {
    const Token = await ethers.getContractFactory("ESom");
    const token = Token.attach("0x3B72bed884B366ECe576f88b61b83812C3d0eaf0");
    await token.updateBlacklist('0x7f922448B4954c8e1df22C67E790d1B86ccdfd4c', false);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });