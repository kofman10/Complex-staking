// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Kofman10WETH} from "../src/Kofman10WETH.sol";

contract DeployFundMe is Script {
    function run() external returns (Kofman10WETH) {

        vm.startBroadcast();
        Kofman10WETH kfmw = new Kofman10WETH();
        vm.stopBroadcast();
        return (kfmw);
    }
}