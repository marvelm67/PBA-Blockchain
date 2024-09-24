// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";
import {IWETH} from "../../src/4.Forks/IWETH.sol";

contract ForkWETHContract is Test {
    IWETH public weth;

    //address wethAddress = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // mainnet
    address wethAddress = 0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9; // sepolia

    function setUp() public {
        weth = IWETH(wethAddress);
    }

    function test_Deposit() public {
        console.log("My address:    ", msg.sender);
        address myAddress = address(this);
        vm.startPrank(myAddress);

        uint256 balanceBefore = weth.balanceOf(myAddress);
        console.log("balance WETH before:   ", balanceBefore);
        assertEq(balanceBefore, 0);

        uint256 sendingValue = 1000;
        weth.deposit{value: sendingValue}();

        uint256 balanceAfter = weth.balanceOf(myAddress);
        console.log("balance WETH after:    ", balanceAfter);
        assertEq(balanceAfter, sendingValue);

        uint256 dealValue = 99999;
        deal(wethAddress, myAddress, dealValue);
        uint256 balanceDeal = weth.balanceOf(myAddress);
        console.log("balance WETH deal:    ", balanceDeal);
        assertEq(balanceDeal, dealValue);
    }
}
