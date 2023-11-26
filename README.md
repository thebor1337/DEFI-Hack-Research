
# DeFi Hack Research Repository

## Overview

This repository is dedicated to the research and analysis of DeFi hacks in the Ethereum blockchain ecosystem. My aim is to provide a comprehensive resource for developers, security analysts, and enthusiasts to understand the vulnerabilities exploited in various DeFi platforms and learn how to safeguard against them. Most of the hacks are written by real geniuses and use the subtlest vulnerabilities and features of the EVM and blockchain, so studying them can help you understand the workings of the world of DEFI and the blockchain.

I will gradually increase the collection of hacks I have analyzed in this repository. Some analysis of hacks is done in Proof of Concept format, some completely repeat the process with all the corresponding numbers.

## How to run

1) Set your ALCHEMY_KEY in .env file (it's needed for forking mainnet to reproduce the state at the moment of some hack)
2) `npm install`
3) `npx hardhat run <HACK_LOCATION>`

## List

| Hack           | Explained                                                              | Location              |
| -------------- | ---------------------------------------------------------------------- | --------------------- |
| BeanStalk      | https://rekt.news/beanstalk-rekt/                                      | scripts/Beanstalk.ts  |
| Harvest        | https://www.finder.com.au/harvest-finance-farm-hack-explained-simply   | scripts/Harvest.ts    |
| Cover Protocol | https://mudit.blog/cover-protocol-hack-analysis-tokens-minted-exploit/ | scripts/Blacksmith.ts |

## Disclaimer

The information provided in this repository is for educational purposes only. I am not liable for any losses arising from the use of this information. I'm just trying to understand how EVM and blockchain systems work in every detail and to learn what mistakes developers have made in the past to avoid it in the future.
