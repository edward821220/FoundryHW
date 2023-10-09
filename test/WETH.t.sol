// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import "../src/WETH.sol";

contract WETHTest is Test {
    event Deposit(address indexed from, uint indexed amount);
    WETH public weth;

    function setUp() public {
        weth = new WETH();
    }

    function testDeposit() public {
        address user = makeAddr("user");
        vm.deal(user, 1 ether);
        vm.prank(user);
        // 3. deposit 應該要 emit Deposit event
        vm.expectEmit(true, true, false, false);
        emit Deposit(user, 1 ether);
        weth.deposit{value: 1 ether}();
        // 1. deposit 應該將與 msg.value 相等的 ERC20 token mint 給 user
        assertEq(weth.balanceOf(user), 1 ether);
        // 2. deposit 應該將 msg.value 的 ether 轉入合約
        assertEq(address(weth).balance, 1 ether);
    }
}
