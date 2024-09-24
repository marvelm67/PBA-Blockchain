// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract FuzzContract {
    uint256 public number;
    uint256 public requiredMinNumber;

    error InvalidNumber(uint256 actualNumber, uint256 requiredMinNumber);

    constructor(uint256 _requiredMinNumber) {
        requiredMinNumber = _requiredMinNumber;
    }

    function forceSetNumber(uint256 _number) public {
        number = _number;
    }

    function setNumber(uint256 _number) public {
        if (requiredMinNumber > _number) {
            revert InvalidNumber(_number, requiredMinNumber);
        }
        number = _number;
    }
}
