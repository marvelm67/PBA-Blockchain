// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract CombinedAssemblyCounter {
    uint256 private count;

    function increment() public {
        assembly {
            let currentCount := sload(count.slot)
            sstore(count.slot, add(currentCount, 1))
        }
    }

    function decrement() public {
        assembly {
            let currentCount := sload(count.slot)

            if iszero(gt(currentCount, 0)) {
                let errorMsg := mload(0x40)
                mstore(errorMsg, "Counter: cannot decrement below 0");
                revert(errorMsg, 32)
            }

            sstore(count.slot, sub(currentCount, 1))
        }
    }


contract Counter {
    uint256 private count;

    function increment() public {
        count += 1;
    }

    function decrement() public {
        require(count > 0, "Counter: cannot decrement below 0");
        count -= 1;
    }

    function reset() public {
        count = 0;
    }

    function getCount() public view returns (uint256) {
        return count;
    }
}
}