// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract BaseContract {
    uint256 public number;

    function increment() public {
        number++;
    }
}
