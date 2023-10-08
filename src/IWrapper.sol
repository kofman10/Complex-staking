// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface IWrapper {
    event Deposit(address indexed dst, uint256 amount);
    event Withdrawal(address indexed src, uint256 amount);

    function deposit() external payable;

    function withdraw(uint256 amount) external;
}
