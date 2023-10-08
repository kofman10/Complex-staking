// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Kofman10WETH} from "../../src/Kofman10WETH.sol";
import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

contract Kofman10WETHTest is StdCheats, Test {

    Kofman10WETH kfmw;

    function setUp() public {
        kfmw = new Kofman10WETH();
    }

    function testMustMintMoreThanZero() public {
        vm.prank(kfmw.owner());
        vm.expectRevert();
        kfmw.mint(address(this), 0);
    }

 

    function testCantMintToZeroAddress() public {
        vm.startPrank(kfmw.owner());
        vm.expectRevert();
        kfmw.mint(address(0), 100);
        vm.stopPrank();
    }
}