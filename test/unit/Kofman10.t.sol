// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Kofman10} from "../../src/Kofman10.sol";
import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

contract Kofman10Test is StdCheats, Test {

    Kofman10 kfm;

    function setUp() public {
        kfm = new Kofman10();
    }

    function testMustMintMoreThanZero() public {
        vm.prank(kfm.owner());
        vm.expectRevert();
        kfm.mint(address(this), 0);
    }

 

    function testCantMintToZeroAddress() public {
        vm.startPrank(kfm.owner());
        vm.expectRevert();
        kfm.mint(address(0), 100);
        vm.stopPrank();
    }
}