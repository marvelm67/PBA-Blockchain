// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

contract MyContract {
    function foo() external {}
    function bar() external {}
}

// Question: In MyContract, why does foo() use more gas than bar(), even though their code is the same?
// Answer:
// At EVM level, there is only one giant function that have a switch case statement to determine which function to call.
// Every function in Solidity will be converted into function selector based on the first 4 bytes of the keccak hash of the function signature
// It will be ordered starting from the smallest value of the function selector
// In that case, the higher the value of the function selector, the more iteration it will take to reach the function
// That is why in Remix IDE, we can see that bar() will use more gas than foo()
// It will likely change if we add more function in the contract
