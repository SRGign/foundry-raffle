pragma solidity ^0.8.19;

import "forge-std/Test.sol";

contract HelloWorldTest is Test {
    function testHelloWorld() public {
        assertEq(uint256(1) + uint256(1), uint256(2));
    }
}