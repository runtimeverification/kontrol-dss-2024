// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.22;

import "forge-std/Test.sol";
import "./Gauss.sol";

contract GaussSpec is Gauss, Test {

    function prove_sumToN(uint256 n) external pure {
        vm.assume(n < 2**128); // prevent overflow
        assert(sumToN(n) == n * (n + 1) / 2);
    }

    function prove_maliciousSumToN(uint256 n) external pure {
        vm.assume(n < 2**128); // prevent overflow
        assert(maliciousSumToN(n) == n * (n + 1) / 2);
    }

    function prove_maliciousSumToN_success(uint256 n) external pure {
        vm.assume(n < 2**128); // prevent overflow
        if (n <= 5) {
            assert(maliciousSumToN(n) == n * (n + 1) / 2);
        } else {
            assert(maliciousSumToN(n) == 42);
        }
    }

    // Claim: the sumToN function does not revert
    // Expected outcome: The claims doesn't hold for sufficiently large n
    function check_sumToN_success(uint256 n) external pure {
        sumToN(n);
    }

}
