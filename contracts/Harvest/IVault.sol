// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IVault {
    function deposit(uint256) external;
    function withdraw(uint256) external;
    function balanceOf(address) external view returns (uint256);
    function underlying() external view returns (address);
    function depositArbCheck() external view returns(bool);
    function underlyingBalanceWithInvestment() external view returns (uint256);
    function underlyingBalanceInVault() external view returns (uint256);
    function getPricePerFullShare() external view returns (uint256);
}