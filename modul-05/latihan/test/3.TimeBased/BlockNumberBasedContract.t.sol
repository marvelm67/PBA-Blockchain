pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {
    BlockNumberBasedContract, NotMinimumBlockNumberReached
} from "../../src/3.TimeBased/BlockNumberBasedContract.sol";

contract BlockNumberBasedContractTest is Test {
    BlockNumberBasedContract public blockNumberBasedContract;

    uint256 _minBlockNumber = 1000;
    uint256 _number = 5;

    function setUp() public {
        blockNumberBasedContract = new BlockNumberBasedContract(_minBlockNumber);
    }

    function test_SetNumber() public {
        vm.roll(_minBlockNumber);
        blockNumberBasedContract.setNumber(_number);
    }

    function test_RevertWhen_BlockNumberNotReached() public {
        vm.expectRevert(abi.encodeWithSelector(NotMinimumBlockNumberReached.selector, 1, _minBlockNumber));
        blockNumberBasedContract.setNumber(_number);
    }
}
