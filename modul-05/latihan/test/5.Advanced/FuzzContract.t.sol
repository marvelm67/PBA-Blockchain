// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {FuzzContract} from "../../src/5.Advanced/FuzzContract.sol";

contract FuzzContractTest is Test {
    FuzzContract public fuzzContract;

    uint256 requiredMinNumber = 10;

    function setUp() public {
        fuzzContract = new FuzzContract(requiredMinNumber);
    }

    function testFuzz_ForceSetNumber(uint256 x) public {
        fuzzContract.forceSetNumber(x);
        assertEq(fuzzContract.number(), x);
    }

    function testFuzz_SetNumber(uint256 x) public {
        vm.assume(x > requiredMinNumber);
        fuzzContract.setNumber(x);
        assertEq(fuzzContract.number(), x);
    }

    function testFuzz_RevertWhen_NumberNotGreaterThanRequiredMin(
        uint256 x
    ) public {
        vm.assume(requiredMinNumber > x);
        vm.expectRevert(
            abi.encodeWithSelector(
                FuzzContract.InvalidNumber.selector,
                x,
                requiredMinNumber
            )
        );

        fuzzContract.setNumber(x);
    }
}
