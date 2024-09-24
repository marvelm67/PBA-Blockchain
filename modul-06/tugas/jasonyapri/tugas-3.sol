// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

// Notes:
// Mapping is already used for balances which is the most efficient way to store data in Solidity
// Mapping of distributed is not used internally inside the contract, so we can just emit events to log the data
// We can use custom error instead of custom error message in string to save gas
// We can just use array of struct instead of two separate arrays for recipients and amounts. This also eliminate the use of check if these two arrays are of the same length
// We should use calldata storage location for transfers struct instead of memory if we don't need to modify the data inside the function
// Use external access modifier for batchProcess functions instead of public as it is not used internally inside the contract
// Mapping, struct, event and error don't need to be packed in certain order, so we can just put them in the most logical order

contract OptimizedBatchProcessor {
    mapping(address => uint) public balances;

    struct Transfer {
        address recipient;
        uint amount;
    }

    event Distributed(address indexed from, address indexed to, uint amount);

    error InsufficientBalance();

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function batchProcess(Transfer[] calldata transfers) external {
        uint length = transfers.length;
        for (uint i = 0; i < length; i++) {
            if (balances[msg.sender] < transfers[i].amount)
                revert InsufficientBalance();

            balances[msg.sender] -= transfers[i].amount;
            balances[transfers[i].recipient] += transfers[i].amount;
            emit Distributed(
                msg.sender,
                transfers[i].recipient,
                transfers[i].amount
            );
        }
    }
}

contract BatchProcessor {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public distributed;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function batchProcess(
        address[] memory recipients,
        uint[] memory amounts
    ) public {
        require(
            recipients.length == amounts.length,
            "Arrays must be of equal length"
        );

        for (uint i = 0; i < recipients.length; i++) {
            require(balances[msg.sender] >= amounts[i], "Insufficient balance");
            balances[msg.sender] -= amounts[i];
            balances[recipients[i]] += amounts[i];
            distributed[msg.sender][recipients[i]] = amounts[i];
        }
    }
}
