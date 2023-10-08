// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "./IWrapper.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { Kofman10WETH } from "./Kofman10WETH.sol";
import { Kofman10} from "./Kofman10.sol";


contract Stake is ReentrancyGuard {

    Kofman10WETH private immutable i_kfmw;
    Kofman10 private immutable i_kfm;
   // Address of the WETH contract
    address public wethAddress ;
    
    // Mapping to track user balances
    mapping(address => uint256) public userStakedBalance;
    
    // Mapping to track user rTokens
    mapping(address => uint256) public userKfmwTokens;
    
    // Reward token details
    uint256 public annualRewardRate = 1400; // 14% annual rate, multiplied by 100 for precision
    
    // Ratio of reward tokens to ETH (1:10)
    uint256 public rewardTokenRatio = 10;

    // Fee for compounding (1% per month)
    uint256 public compoundingFeeRate = 100; // 1%
    uint256 public compoundingFeePeriod = 30 days; // 30 days in seconds
    
    // Timestamp when the last compounding occurred for each user
    mapping(address => uint256) public lastCompoundingTimestamp;

    // mapping(address => bool) public compoundingOrNot;
    
    // Event to log deposits
    event Deposited(address indexed user, uint256 amount);
    
    // Event to log withdrawals
    event Withdrawn(address indexed user, uint256 amount);
    
    // Event to log rewards
    event Rewarded(address indexed user, uint256 amount);

        event Compounded(address indexed user, uint256 compoundedAmount);


    constructor(address _rewardToken, address _wethAddress, address _receiptToken) {
        i_kfmw = Kofman10WETH(_receiptToken);
        i_kfm = Kofman10(_rewardToken);
        wethAddress = _wethAddress;
    }
    
    // Function to deposit ETH and receive Kofman10WETH Tokens
    function stakeETH() external payable {
        require(msg.value > 0, "Must deposit more than 0 ETH");
        
        // Convert ETH to WETH
        IWrapper(wethAddress).deposit{value: msg.value}();  
        IERC20(wethAddress).transfer(address(this), msg.value);      
        // Calculate rTokens based on the 1:10 ratio
        
        // Mint kfmwTokens to the user
        userKfmwTokens[msg.sender] += msg.value;

        // User's balance of eth in this contract
        userStakedBalance[msg.sender] += msg.value;

        i_kfmw.mint(msg.sender, msg.value);
         i_kfm.mint(msg.sender, msg.value);

        // Emit the deposit event
        emit Deposited(msg.sender, msg.value);
    }

      // Function for users to opt in for monthly compounding
function optInCompounding() external {
    require(userStakedBalance[msg.sender] > 0, "No staked amount to compound");

    // Calculate rewards since the last compounding event
    uint256 rewards = calculateRewards(msg.sender);
    lastCompoundingTimestamp[msg.sender] = block.timestamp; // Update the last compounding timestamp

    // Apply compounding fee (1% for an entire month)
    uint256 compoundingFee = (userStakedBalance[msg.sender] * rewardTokenRatio) / 100; // 1% fee
    require(rewards >= compoundingFee, "Insufficient rewards to cover the compounding fee");

    // Convert rewards to WETH and stake back as principal
    IWrapper(wethAddress).deposit{value: compoundingFee}();
    IERC20(wethAddress).transfer(address(this), compoundingFee);

    // Update user balances
    userKfmwTokens[msg.sender] += compoundingFee;
    userStakedBalance[msg.sender] += compoundingFee;
    i_kfmw.mint(msg.sender, compoundingFee);

    // Deduct the compounding fee from rewards
    rewards -= compoundingFee;

    emit Compounded(msg.sender, compoundingFee);

    // Mint additional rewards for the user every month
    uint256 timeElapsed = block.timestamp - lastCompoundingTimestamp[msg.sender];
    uint256 monthlyRewards = (userStakedBalance[msg.sender] * annualRewardRate / 12) / 10000; // Monthly rewards
    uint256 monthlyCompounding = monthlyRewards * rewardTokenRatio * timeElapsed / (30 days); // Apply time and ratio
    rewards += monthlyCompounding;

    // Transfer the remaining rewards to the user
    userKfmwTokens[msg.sender] += rewards;
    i_kfmw.mint(msg.sender, rewards);
}

// Function to withdraw staked ETH and rewards
function withdraw() external {
    uint256 userBalance = userStakedBalance[msg.sender];

    require(userBalance > 0, "No balance to withdraw");

    // Calculate and send rewards
    uint256 rewards = calculateRewards(msg.sender);

    // Convert WETH back to ETH and send it to the user
    IWrapper(wethAddress).withdraw(userBalance);
    payable(msg.sender).transfer(userBalance);

    // Update user balances and reset rewards
    userStakedBalance[msg.sender] = 0;
    userKfmwTokens[msg.sender] = 0;

    // Emit withdrawal event
    emit Withdrawn(msg.sender, userBalance);

    if (rewards > 0) {
        // Transfer the earned rewards to the user
        userKfmwTokens[msg.sender] += rewards;
        i_kfmw.mint(msg.sender, rewards);

        // Emit reward event
        emit Rewarded(msg.sender, rewards);
    }
}

 
    
    // Function to calculate rewards based on the annual rate
    function calculateRewards(address user) internal view returns (uint256) {
    uint256 timeElapsed = block.timestamp - lastCompoundingTimestamp[user];
    uint256 annualETHRewards = (userStakedBalance[user] * annualRewardRate) / 10000; // Use 0.14 for 14%
    uint256 rewards = (annualETHRewards * rewardTokenRatio * timeElapsed) / (365 days); // Apply time and ratio
    return rewards;
}

  
}
