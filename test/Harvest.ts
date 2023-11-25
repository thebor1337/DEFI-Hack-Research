import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect, ethers } from "../setup";

const HACKER = "0xF224ab004461540778a914ea397c589b677E27bb";
const WETH9 = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";

describe("HarvestAttack", function () {
    async function deploy() {
        const hacker = await ethers.getImpersonatedSigner(HACKER);

        const HarvestFactory = await ethers.getContractFactory("HarvestAttack");
        const harvest = await HarvestFactory.deploy();
        await harvest.waitForDeployment();

        return { hacker, harvest: harvest.connect(hacker) };
    }

    it("test", async () => {
        const { hacker, harvest } = await loadFixture(deploy);

        await harvest.test();
    });
});