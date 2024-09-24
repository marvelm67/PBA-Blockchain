// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

error NotMinimumTimestampReached(
    uint256 currentTimestamp,
    uint256 requiredTimestamp
);

contract TimestampBasedContract {
    uint256 public number;
    uint256 public minTimestamp;

    constructor(uint256 _minTimestamp) {
        minTimestamp = _minTimestamp;
    }

    function setNumber(uint256 newNumber) public {
        if (block.timestamp < minTimestamp) {
            revert NotMinimumTimestampReached(block.timestamp, minTimestamp);
        }
        number = newNumber;
    }
}
