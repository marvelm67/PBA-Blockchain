// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {BaseContract} from "../../src/1.Basics/BaseContract.sol";

contract BaseContractTest is Test {
    BaseContract public baseContract;

    function setUp() public {
        baseContract = new BaseContract();
    }

    function test_Increment() public {
        baseContract.increment();
        assert(baseContract.number() == 1);
    }
}
