import { ethers, Typed } from "ethers";

import { AbiCoder } from "ethers";

const coder = AbiCoder.defaultAbiCoder();
console.log(coder.encode(["uint256", "string"], [42, "hello world"]));

const hex = ethers.toQuantity(42);
console.log(hex);

const encoded = ethers.encodeBytes32String("hello world");
console.log(encoded);
console.log(ethers.decodeBytes32String(encoded));

const bigInt = BigInt(1000);
console.log(bigInt);
console.log(bigInt ** bigInt);

// const abi = [
//     "function foo(address bar)",
//     "function foo(uint160 bar)",
//     "function bar(address addr)"
// ];

// const contract = new ethers.Contract("0x0000", abi);
// contract["foo(address)"]("0x1234");
// contract["foo(address addr)"]("0x1234");
// contract["foo(uint160)"](1234);
// contract["foo(uint160 bar)"](1234);
// contract.foo(Typed.address("0x1234"));
// contract.foo(Typed.uint160(1234));

// contract.bar.staticCall("0x1234");
// contract.bar.send("0x1234");
// contract.bar.estimateGas("0x1234");