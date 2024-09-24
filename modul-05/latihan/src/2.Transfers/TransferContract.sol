// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract TransferContract {
    event EthDeposited(address depositor, uint256 amount);

    receive() external payable {
        emit EthDeposited(msg.sender, msg.value);
    }
}
