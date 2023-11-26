// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "../interfaces/IERC20.sol";

interface IBean is IERC20 {
    function mint(address account, uint256 amount) external returns (bool);
}