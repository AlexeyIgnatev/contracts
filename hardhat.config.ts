import {HardhatUserConfig, vars} from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
    solidity: "0.8.28",
    networks: {
        local: {
            url: `http://localhost:8545`,
            accounts: [vars.get("LOCAL_PRIVATE_KEY")],
            chainId: 8888,
        },
        remote: {
            url: `http://192.168.254.120:8545`,
            accounts: [vars.get("LOCAL_PRIVATE_KEY")],
            chainId: 8888,
        },
    },
    etherscan: {
        apiKey: {
            local: 'empty',
            remote: 'empty'
        },
        customChains: [
            {
                network: 'local',
                chainId: 8888,
                urls: {
                    apiURL: "http://localhost/api",
                    browserURL: "http://localhost"
                }
            },
            {
                network: 'remote',
                chainId: 8888,
                urls: {
                    apiURL: "http://localhost/api",
                    browserURL: "http://localhost"
                }
            }
        ]
    }
};

export default config;
