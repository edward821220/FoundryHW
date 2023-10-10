// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {Test, console2} from "../lib/forge-std/src/Test.sol";
import "../src/WETH.sol";

contract WETHTest is Test {
    event Deposit(address indexed from, uint256 indexed amount);
    event Withdraw(address indexed to, uint256 indexed amount);

    WETH public weth;
    address alice = makeAddr("Alice");
    address bob = makeAddr("Bob");
    uint256 amount = 1 ether;

    function setUp() public {
        weth = new WETH();
    }

    function testDeposit() public {
        deal(alice, amount);

        // 測項 3: deposit 應該要 emit Deposit event
        vm.expectEmit(true, true, false, false);
        emit Deposit(alice, amount);
        vm.prank(alice);
        weth.deposit{value: amount}();

        // 測項 1: deposit 應該將與 msg.value 相等的 ERC20 token mint 給 user
        assertEq(weth.balanceOf(alice), amount);

        // 測項 2: deposit 應該將 msg.value 的 ether 轉入合約
        assertEq(address(weth).balance, amount);
    }

    function testWithdraw() public {
        deal(address(weth), amount);
        deal(address(weth), alice, amount);
        uint256 totalSupplyBefore = weth.totalSupply();
        uint256 balanceBefore = weth.balanceOf(alice);

        // 測項 6: withdraw 應該要 emit Withdraw event
        vm.expectEmit(true, true, false, false);
        emit Withdraw(alice, amount);
        vm.prank(alice);
        weth.withdraw(amount);

        // 測項 4: withdraw 應該要 burn 掉與 input parameters 一樣的 erc20 token
        assertEq(weth.totalSupply(), totalSupplyBefore - amount);
        assertEq(weth.balanceOf(alice), balanceBefore - amount);

        // 測項 5: withdraw 應該將 burn 掉的 erc20 換成 ether 轉給 user
        assertEq(alice.balance, amount);
    }

    function testTransfer() public {
        deal(address(weth), alice, amount);
        uint256 balanceAlice = weth.balanceOf(alice);

        vm.prank(alice);
        weth.transfer(bob, amount);

        // 測項 7: transfer 應該要將 erc20 token 轉給別人
        assertEq(weth.balanceOf(bob), amount);
        assertEq(weth.balanceOf(alice), balanceAlice - amount);
    }

    function testApprove() public {
        deal(address(weth), alice, amount);
        uint256 allwnaceBefore = weth.allowance(alice, bob);

        vm.prank(alice);
        weth.approve(bob, amount);

        // 測項 8: approve 應該要給他人 allowance
        assertEq(weth.allowance(alice, bob), allwnaceBefore + amount);
    }

    function testTransferFrom() public {
        deal(address(weth), alice, amount);
        vm.prank(alice);
        weth.approve(bob, amount);

        uint256 allwnaceBefore = weth.allowance(alice, bob);

        // 測項 9: transferFrom 應該要可以使用他人的 allowance
        vm.prank(bob);
        weth.transferFrom(alice, bob, amount);

        // 測項 10: transferFrom 後應該要減除用完的 allowance
        uint256 allwnaceAfter = weth.allowance(alice, bob);
        assertEq(allwnaceAfter, allwnaceBefore - amount);
    }
}
