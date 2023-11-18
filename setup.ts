import { loadFixture, reset, time, mineUpTo } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { ethers } from "hardhat";
import { expect } from "chai";
import "@nomicfoundation/hardhat-chai-matchers";

const RPC_URL = "https://eth-mainnet.g.alchemy.com/v2/" + process.env.ALCHEMY_KEY;

export { loadFixture, ethers, expect, reset, time, RPC_URL };