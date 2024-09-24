// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract EventContract {
    uint256 public number;

    event NumberIncremented(uint256 currentNumber);
    event TestEventWithIndexedParams(uint256 indexed param1, uint256 indexed param2, uint256 indexed param3, uint256 param4, uint256 param5);

    function increment() public {
        number++;
        emit NumberIncremented(number);
    }

    function testEventWithIndexedParams() public {
        emit TestEventWithIndexedParams(1, 2, 3, 4, 5);
    }
}
