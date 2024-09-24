// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract PrankContract {
    uint256 public number;

    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }

    function increment() public onlyOwner {
        number++;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }
}
