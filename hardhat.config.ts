import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import { config as dotEnvConfig } from "dotenv";

dotEnvConfig();

const config: HardhatUserConfig = {
    solidity: {
        compilers: [
            {
                version: "0.7.6",
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200
                    }
                }
            }
        ]
    },
    networks: {
        hardhat: {
            // forking: {
            //     enabled: true,
            //     url: "https://eth-mainnet.g.alchemy.com/v2/" + process.env.ALCHEMY_KEY,
            //     // blockNumber: 11540123
            //     // blockNumber: 11542274
            //     blockNumber: 11542278
            //     // blockNumber: 11542297
            //     // blockNumber: 11542309
            //     // blockNumber: 11542320
            // }
        },
    }
};

export default config;
