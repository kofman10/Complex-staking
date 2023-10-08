// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {Kofman10WETH} from "../../script/Kofman10WETH.s.sol";
import {Kofman10} from "../../script/Kofman10.s.sol";
import {Kofman10} from "../../src/Kofman10.sol";
import {Kofman10WETH} from "../../src/Kofman10WETH.sol";
import {Stake} from "../../src/Stake.sol";

contract StakeTest is Test {

   Kofman10WETH public kfmw;
   Kofman10 public kfm;
   Stake public stk;
      address weth = 0xf531B8F309Be94191af87605CfBf600D71C2cFe0;
   
    function setUp() public {

        // Deploy Kofman10 token and Stake contract
      kfm = new Kofman10();
      kfmw = new Kofman10WETH();
        stk = new Stake(address(kfm), address(weth), address(kfmw));
    }

    function testStakeETH() public {
        // Prepare test values
        uint256 depositAmount = 10 ether;
        address user = address(this);

        // Ensure user has enough WETH to deposit
        weth.deposit{value: depositAmount}();
        weth.transfer(address(stk), depositAmount);

        // Stake ETH
        stk.stakeETH{value: depositAmount}();

        // Check user's staked balance and Kofman10WETH tokens
        uint256 expectedStakedBalance = depositAmount;
        uint256 expectedKfmwTokens = depositAmount;
        uint256 actualStakedBalance = stk.userStakedBalance(user);
        uint256 actualKfmwTokens = stk.userKfmwTokens(user);

        assertEq(actualStakedBalance, expectedStakedBalance);
        assertEq(actualKfmwTokens, expectedKfmwTokens);
    }

    function testOptInCompounding() public {
        // Prepare test values
        uint256 depositAmount = 10 ether;
        address user = address(this);

        // Ensure user has enough WETH to deposit
        weth.deposit{value: depositAmount}();
        weth.transfer(address(stk), depositAmount);

        // Stake ETH
        stk.stakeETH{value: depositAmount}();

        // Opt-in for compounding
        stk.optInCompounding();

        // Calculate rewards since the last compounding event
        uint256 expectedRewards = stk.calculateRewards(user);
        uint256 actualRewards = stk.userKfmwTokens(user);

        // Assert that the user's Kofman10WETH tokens increased by the expected rewards
        assertEq(actualRewards, expectedRewards);
    }

    function testWithdraw() public {
        // Prepare test values
        uint256 depositAmount = 10 ether;
        address user = address(this);

        // Ensure user has enough WETH to deposit
        weth.deposit{value: depositAmount}();
        weth.transfer(address(stk), depositAmount);

        // Stake ETH
        stk.stakeETH{value: depositAmount}();

        // Opt-in for compounding
        stk.optInCompounding();

        // Withdraw staked ETH and rewards
        stk.withdraw();

        // Check that user's balance is 0 and rewards are 0
        uint256 actualStakedBalance = stk.userStakedBalance(user);
        uint256 actualKfmwTokens = stk.userKfmwTokens(user);

        assertEq(actualStakedBalance, 0);
        assertEq(actualKfmwTokens, 0);
    }

    function testCalculateRewards() public {
        // Prepare test values
        uint256 depositAmount = 10 ether;
        address user = address(this);

        // Ensure user has enough WETH to deposit
        weth.deposit{value: depositAmount}();
        weth.transfer(address(stk), depositAmount);

        // Stake ETH
        stk.stakeETH{value: depositAmount}();

        // Opt-in for compounding
        stk.optInCompounding();

        // Calculate rewards since the last compounding event
        uint256 expectedRewards = stk.calculateRewards(user);
        uint256 actualRewards = stk.userKfmwTokens(user);

        assertEq(actualRewards, expectedRewards);
    }
}
