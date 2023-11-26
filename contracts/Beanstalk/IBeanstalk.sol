// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBeanstalk {
    function deposit(address token, uint256 amount) external;
    function vote(uint32 bip) external;
    function emergencyCommit(uint32 bip) external;
}