// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.22;

contract Gauss {

    function sumToN(uint256 n) public pure returns (uint256) {
        uint256 result = 0;
        uint256 i = 0;
        while (i < n) {
            i = i + 1;
            result = result + i;
        }
        return result;
    }


    function maliciousSumToN(uint256 n) public pure returns (uint256) {
        uint256 result = 0;
        uint256 i = 0;
        while (i < n) {
            i = i + 1;
            result = result + i;
            if (i > 4) result = 42;
        }
        return result;
    }


    function triangleNumber(uint256 n) public pure returns (uint256) {
        return n * (n + 1) / 2;
    }

}
