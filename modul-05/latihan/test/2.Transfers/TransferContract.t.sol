// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";
import {TransferContract} from "../../src/2.Transfers/TransferContract.sol";

contract TransferContractTest is Test {
    TransferContract transferContract;

    address myAddress;

    function setUp() public {
        transferContract = new TransferContract();
        myAddress = address(1);
    }

    function test_AirdroppingEthers() public {
        uint256 startBalance = myAddress.balance;
        console.log("Start balance: ", startBalance);

        uint256 newBalance = 10 ether;

        deal(myAddress, newBalance);
        uint256 currentBalance = myAddress.balance;
        console.log("Current balance: ", currentBalance);

        assertEq(currentBalance, newBalance);
        assertNotEq(startBalance, currentBalance);
    }

    function test_SendEthers() public {
        uint256 newBalance = 10 ether;
        deal(myAddress, newBalance);
        vm.prank(myAddress);

        uint256 contractBalanceBefore = address(transferContract).balance;
        uint256 myAddressBalanceBefore = myAddress.balance;
        console.log("Contract balance before: ", contractBalanceBefore);
        console.log("MyAddress balance before: ", myAddressBalanceBefore);

        (bool success, ) = address(transferContract).call{value: newBalance}(
            ""
        );
        assertEq(success, true);

        uint256 contractBalanceAfter = address(transferContract).balance;
        uint256 myAddressBalanceAfter = myAddress.balance;
        console.log("Contract balance after: ", contractBalanceAfter);
        console.log("MyAddress balance after: ", myAddressBalanceAfter);

        assertEq(contractBalanceAfter, newBalance);
        assertEq(myAddressBalanceAfter, 0);
    }

    function test_SendEthers2() public {
        uint256 newBalance = 10 ether;
        hoax(myAddress, newBalance);

        (bool success, ) = address(transferContract).call{value: newBalance}(
            ""
        );
        assertEq(success, true);

        uint256 contractBalanceAfter = address(transferContract).balance;
        uint256 myAddressBalanceAfter = myAddress.balance;

        assertEq(contractBalanceAfter, newBalance);
        assertEq(myAddressBalanceAfter, 0);
    }
}
