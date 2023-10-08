// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Kofman10} from "../src/Kofman10.sol";

contract DeployFundMe is Script {
    function run() external returns (Kofman10) {

        vm.startBroadcast();
        Kofman10 kfm = new Kofman10();
        vm.stopBroadcast();
        return (kfm);
    }
}