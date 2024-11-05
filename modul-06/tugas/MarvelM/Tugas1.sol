// Tugas 1
pragma solidity ^0.8.13;

contract MyContract {
    function foo() external {}
    function bar() external {}
}

// Question :  In MyContract, why does bar() use more gas than foo(), even though their code is the same?
// Answer : 
// There are several reason why we should use foo rather than bar,

//1. Function Visibility
// - The visibility of a function (e.g., public, external, or internal) affects gas costs. Public functions are generally more expensive than internal functions because they require additional checks for access control and can be called from other contracts4.
// 2. Storage and Memory
// - If either function interacts with storage variables, the number of storage reads/writes can significantly impact gas costs. Writing to storage (using SSTORE) is more expensive than using memory (with MSTORE), so if bar() writes to storage more frequently or in a different manner than foo(), it will consume more gas4.
// 3. Internal State Changes
// - Even if the code looks the same, if bar() modifies the state of the contract or calls other functions that do, it will incur additional gas costs. For example, if bar() has side effects that involve state changes or external calls, these will increase gas consumption5.
// 4. Compiler Optimizations
// - The Solidity compiler may optimize functions differently based on their context or usage patterns. If one function is called more frequently or in different scenarios, it may be optimized differently than another function, leading to variations in gas usage4.
// 5. Gas Refunds and Costs
// - Certain operations can yield gas refunds when executed under specific conditions (like deleting storage variables). If foo() benefits from such optimizations while bar() does not, this could explain the difference in gas costs despite identical code45.

// Contract Example of using foo dan bar: 
//// SPDX-License-Identifier: MIT
// pragma solidity ^0.8.13;

// contract MyContract {
//     uint256 public counter;

//     // Function foo - Public visibility
//     function foo() public {
//         counter += 1; // Modifies storage
//     }

//     // Function bar - External visibility
//     function bar() external {
//         counter += 1; // Modifies storage
//     }
// }

// Function Explanation : 

// 1. Function Visibility:
// foo() is declared as public, which means it can be called both internally and externally.
// bar() is declared as external, which means it can only be called from outside the contract.

// 2. Storage Modification:
// Both functions modify the same state variable, counter, which is stored on the blockchain.
// Gas Consumption Differences
// Despite having identical logic, the gas consumption can differ due to the following reasons:
// - Calling Context: If foo() is called internally (e.g., from another function within the contract), it may consume less gas than calling bar(), which requires an external call.
// - Overhead of External Calls: When calling bar() from another contract or externally, there’s additional overhead associated with the external call mechanism, which can increase gas costs.
