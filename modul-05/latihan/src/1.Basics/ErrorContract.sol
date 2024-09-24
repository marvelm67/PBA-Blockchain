// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract ErrorContract {
    uint256 public number;
    uint256 public requiredMinNumber;

    error InvalidNumber(uint256 actualNumber, uint256 requiredMinNumber);
    error InvalidNumber2();

    constructor(uint256 _requiredMinNumber) {
        requiredMinNumber = _requiredMinNumber;
    }

    function setNumber(uint256 _number) public {
        if (requiredMinNumber > _number) {
            revert InvalidNumber(_number, requiredMinNumber);
        }
        number = _number;
    }

    function setNumber2(uint256 _number) public {
    if (requiredMinNumber > _number) {
            revert InvalidNumber2();
        }        
        number = _number;
    }

    function setNumber3(uint256 _number) public {
        require(_number >= requiredMinNumber, "number not big enough");
        number = _number;
    }
}
