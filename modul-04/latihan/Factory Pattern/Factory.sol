// SPDX-License-Identifier: MIT
// MyTokenFactory: https://sepolia-blockscout.lisk.com/address/0xf80946950b81c822E19Dfd2b0b6BE68219f24199?tab=read_contract
// MyToken: https://sepolia-blockscout.lisk.com/address/0x7549323B9a2C03053CaC5cb6E04a7e281610B530
pragma solidity ^0.8.26;

// Factory Contract
contract MyTokenFactory {
    address[] public deployedTokens;

    function createToken(uint256 initialSupply) public {
        address newToken = address(new MyToken(initialSupply));
        deployedTokens.push(newToken);
    }

    function getDeployedTokens() public view returns (address[] memory) {
        return deployedTokens;
    }
}

// Product Contract
contract MyToken {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    constructor(uint256 initialSupply) {
        name = "MyToken";
        symbol = "MTK";
        decimals = 18;
        totalSupply = initialSupply * 10 ** uint256(decimals);
    }
}
