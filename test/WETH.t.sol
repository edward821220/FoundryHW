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
    uint256 initialAmount = 1 ether;

    function setUp() public {
        weth = new WETH();
        deal(alice, initialAmount);
        deal(address(weth), initialAmount);
        deal(address(weth), alice, initialAmount);
    }

    function testDeposit(uint256 _amount) public {
        uint256 aliceWethBefore = weth.balanceOf(alice);
        uint256 contractBalanceBefore = address(weth).balance;
        _amount = bound(_amount, 1, initialAmount);

        // 測項 3: deposit 應該要 emit Deposit event
        vm.expectEmit(true, true, false, false);
        emit Deposit(alice, _amount);
        vm.prank(alice);
        weth.deposit{value: _amount}();

        // 測項 1: deposit 應該將與 msg.value 相等的 ERC20 token mint 給 user
        assertEq(weth.balanceOf(alice), aliceWethBefore + _amount);

        // 測項 2: deposit 應該將 msg.value 的 ether 轉入合約
        assertEq(address(weth).balance, contractBalanceBefore + _amount);
    }

    function testWithdraw(uint256 _amount) public {
        uint256 wethTotalSupplyBefore = weth.totalSupply();
        uint256 wethbalanceBefore = weth.balanceOf(alice);
        uint256 ethBalanceBefore = alice.balance;
        _amount = bound(_amount, 1, initialAmount);

        // 測項 6: withdraw 應該要 emit Withdraw event
        vm.expectEmit(true, true, false, false);
        emit Withdraw(alice, _amount);
        vm.prank(alice);
        weth.withdraw(_amount);

        // 測項 4: withdraw 應該要 burn 掉與 input parameters 一樣的 erc20 token
        assertEq(weth.totalSupply(), wethTotalSupplyBefore - _amount);
        assertEq(weth.balanceOf(alice), wethbalanceBefore - _amount);

        // 測項 5: withdraw 應該將 burn 掉的 erc20 換成 ether 轉給 user
        assertEq(alice.balance, ethBalanceBefore + _amount);
    }

    function testTransfer(uint256 _amount) public {
        uint256 balanceAlice = weth.balanceOf(alice);
        _amount = bound(_amount, 1, initialAmount);

        vm.prank(alice);
        weth.transfer(bob, _amount);

        // 測項 7: transfer 應該要將 erc20 token 轉給別人
        assertEq(weth.balanceOf(bob), _amount);
        assertEq(weth.balanceOf(alice), balanceAlice - _amount);
    }

    function testApprove(uint256 _amount) public {
        uint256 allwnaceBefore = weth.allowance(alice, bob);
        _amount = bound(_amount, 1, initialAmount);

        vm.prank(alice);
        weth.approve(bob, _amount);

        // 測項 8: approve 應該要給他人 allowance
        assertEq(weth.allowance(alice, bob), allwnaceBefore + _amount);
    }

    function testTransferFrom(uint256 _approveAmount, uint256 _transferAmount) public {
        _approveAmount = bound(_approveAmount, 1, initialAmount);
        vm.prank(alice);
        weth.approve(bob, _approveAmount);

        uint256 allwnaceBefore = weth.allowance(alice, bob);

        // 測項 9: transferFrom 應該要可以使用他人的 allowance
        _transferAmount = bound(_transferAmount, 1, _approveAmount);
        vm.prank(bob);
        weth.transferFrom(alice, bob, _transferAmount);

        // 測項 10: transferFrom 後應該要減除用完的 allowance
        uint256 allwnaceAfter = weth.allowance(alice, bob);
        assertEq(allwnaceAfter, allwnaceBefore - _transferAmount);
    }
}
