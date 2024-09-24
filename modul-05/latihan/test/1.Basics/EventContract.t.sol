// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {EventContract} from "../../src/1.Basics/EventContract.sol";

contract EventContractTest is Test {
    EventContract public eventContract;

    event NumberIncremented(uint256 currentNumber);
    event TestEventWithIndexedParams(
        uint256 indexed param1,
        uint256 indexed param2,
        uint256 indexed param3,
        uint256 param4,
        uint256 param5
    );

    function setUp() public {
        eventContract = new EventContract();
    }

    function test_Increment() public {
        uint256 expectedNumber = 1;
        vm.expectEmit(true, true, true, true);
        emit NumberIncremented(expectedNumber);

        eventContract.increment();
    }

    function test_EventWithIndexedParams() public {
        vm.expectEmit(true, true, true, true);
        emit TestEventWithIndexedParams(1, 2, 3, 4, 5);

        eventContract.testEventWithIndexedParams();
    }
}
