// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.18;

import "forge-std/Test.sol";
import "../src/Counter.sol";

contract CounterTest is Test {
    Counter public counter;

    function setUp() public {
        counter = new Counter();
        counter.setNumber(0);
    }

    function testIncrement() public {
        counter.increment();
        assertEq(counter.number(), 10_000);
    }

    function testSetNumber(uint x) public {
        counter.setNumber(x);
        assertEq(counter.number(), x);
    }
}
