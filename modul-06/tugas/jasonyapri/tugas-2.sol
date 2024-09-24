// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

contract AssemblyCounter {
    uint256 private count;

    function increment() public {
        assembly {
            sstore(count.slot, add(sload(count.slot), 1))
        }
    }

    function decrement() public {
        assembly {
            let errorMessage1 := "Counter: "
            let errorMessage2 := "cannot decrement below 0"
            if iszero(gt(sload(count.slot), 0)) {
                let size := add(mload(errorMessage1), mload(errorMessage2))
                revert(and(errorMessage1, errorMessage2), size)
            }
            sstore(count.slot, sub(sload(count.slot), 1))
        }
    }

    function reset() public {
        assembly {
            sstore(count.slot, 0)
        }
    }

    function getCount() public view returns (uint256 result) {
        assembly {
            result := sload(count.slot)
        }
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
