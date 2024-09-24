pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {TimestampBasedContract, NotMinimumTimestampReached} from "../../src/3.TimeBased/TimestampBasedContract.sol";

contract TimestampBasedContractTest is Test {
    TimestampBasedContract public timestampBasedContract;

    uint256 _minTimestamp = 1000;
    uint256 _number = 5;

    function setUp() public {
        timestampBasedContract = new TimestampBasedContract(_minTimestamp);
    }

    function test_SetNumber() public {
        vm.warp(_minTimestamp);
        timestampBasedContract.setNumber(_number);
    }

    function test_RevertWhen_TimestampNotReached() public {
        vm.expectRevert(abi.encodeWithSelector(NotMinimumTimestampReached.selector, 1, _minTimestamp));
        timestampBasedContract.setNumber(_number);
    }
}
