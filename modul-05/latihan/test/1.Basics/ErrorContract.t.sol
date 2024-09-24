// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {ErrorContract} from "../../src/1.Basics/ErrorContract.sol";

contract ErrorContractTest is Test {
    ErrorContract public errorContract;

    uint256 requiredMinNumber = 10;

    function setUp() public {
        errorContract = new ErrorContract(requiredMinNumber);
    }

    function test_SetNumber() public {
        uint256 number = requiredMinNumber + 1;
        errorContract.setNumber(number);
        assertEq(errorContract.number(), number);
    }

    function test_RevertWhen_NumberNotGreaterThanRequiredMin() public {
        uint256 number = requiredMinNumber - 1;
        vm.expectRevert(
            abi.encodeWithSelector(
                ErrorContract.InvalidNumber.selector,
                number,
                requiredMinNumber
            )
        );

        errorContract.setNumber(number);
    }

    function test_RevertWhen_NumberNotGreaterThanRequiredMin2() public {
        uint256 number = requiredMinNumber - 1;
        vm.expectRevert(ErrorContract.InvalidNumber2.selector);

        errorContract.setNumber2(number);
    }

    function test_RevertWhen_NumberNotGreaterThanRequiredMin3() public {
        uint256 number = requiredMinNumber - 1;
        vm.expectRevert("number not big enough");

        errorContract.setNumber3(number);
    }
}
