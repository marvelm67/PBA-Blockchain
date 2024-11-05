// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract OptimizedBatchProcessor {
    mapping(address => uint) private balances;
    mapping(address => mapping(address => uint)) private distributed;

    error InsufficientBalance();

    struct TransferData {
        address recipient;
        uint amount;
    }

    event TransferBalance(
        address indexed sender,
        address indexed recipient,
        uint amount 
    );

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function batchProcess(TransferData[] calldata transfers) external {
        uint senderBalance = balances[msg.sender]; // Cache sender's balance

        for (uint i = 0; i < transfers.length; i++) {
            TransferData memory transfer = transfers[i];

            if (senderBalance < transfer.amount) {
                revert InsufficientBalance();
            }

            senderBalance -= transfer.amount; 
            balances[transfer.recipient] += transfer.amount;
            distributed[msg.sender][transfer.recipient] += transfer.amount; 

            emit TransferBalance(msg.sender, transfer.recipient, transfer.amount); 
        }

        balances[msg.sender] = senderBalance; 
    }
}