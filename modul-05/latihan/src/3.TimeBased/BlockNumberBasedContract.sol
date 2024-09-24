// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

error NotMinimumBlockNumberReached(uint256 currentBlockNumber, uint256 requiredBlockNumber);

contract BlockNumberBasedContract {
    uint256 public number;
    uint256 public minBlockNumber;

    constructor(uint256 _minBlockNumber) {
        minBlockNumber = _minBlockNumber;
    }

    function setNumber(uint256 newNumber) public {
        if (block.number < minBlockNumber) {
            revert NotMinimumBlockNumberReached(block.number, minBlockNumber);
        }
        number = newNumber;
    }
}
