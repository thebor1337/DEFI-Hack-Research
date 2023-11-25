// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUSDT {
    function approve(address _spender, uint256 _value) external;
    function transfer(address _to, uint256 _value) external;
    function balanceOf(address _owner) external view returns (uint256);
}