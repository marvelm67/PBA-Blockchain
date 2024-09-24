// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IWETH {
    function balanceOf(address) external view returns (uint256);
    function deposit() external payable;
}
