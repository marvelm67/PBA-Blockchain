// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {PrankContract} from "../../src/1.Basics/PrankContract.sol";

contract PrankContractTest is Test {
    PrankContract public prankContract;

    address owner = address(1);

    function setUp() public {
        prankContract = new PrankContract(owner);
    }

    function test_Increment() public {
        vm.prank(owner);
        prankContract.increment();
        assertEq(prankContract.number(), 1);
    }

    function test_MultipleIncrement() public {
        vm.startPrank(owner);
        prankContract.increment();
        assertEq(prankContract.number(), 1);

        prankContract.increment();
        assertEq(prankContract.number(), 2);
    }

    function testRevert_IfNotOwner_Increment() public {
        vm.expectRevert("not owner");
        prankContract.increment();
    }
}
