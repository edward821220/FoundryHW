// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {Test, console2} from "../lib/forge-std/src/Test.sol";

interface IBAYC {
    function mintApe(uint256 numberOfTokens) external payable;
    function balanceOf(address owner) external view returns (uint256 balance);
}

contract BAYCTest is Test {
    address bayc = 0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D;
    address alice = makeAddr("Alice");

    function setUp() public {
        uint256 forkId = vm.createFork(vm.envString("MAINNET_RPC_URL"));
        vm.selectFork(forkId);
        vm.rollFork(12299047);
        deal(alice, 10 ether);
    }

    function testMint() public {
        uint256 balanceBefore = address(bayc).balance;
        vm.startPrank(alice);
        for (uint256 i = 1; i <= 5; i++) {
            IBAYC(bayc).mintApe{value: 1.6 ether}(20);
        }
        assertEq(IBAYC(bayc).balanceOf(alice), 100);
        assertEq(address(bayc).balance, balanceBefore + 8 ether);
        vm.stopPrank();
    }
}
