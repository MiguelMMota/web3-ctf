// SDPX-License-Identifier: MIT

pragma solidity ^0.6.2;

import {Script, console} from "forge-std/Script.sol";

import {Constants} from "./Constants.s.sol";

interface IMagicNumber {
    function setSolver(address _solver) external;
}

contract MagicNumberAttacker is Constants, Script {
    function run() public {
        IMagicNumber victim = IMagicNumber(MAGIC_NUMBER_ADDRESS);

        vm.startBroadcast(ATTACKER_ADDRESS);
        attack(victim);
        vm.stopBroadcast();
    }

    function attack(IMagicNumber victim) private {
        bytes32 salt = keccak256("magic_number_0xCDc986e956f889b6046F500657625E523f06D5F0");
        bytes memory bytecode = hex"600a600c600039600a6000f3602a60005260206000f3";
        
        address deployed;
        assembly {
            deployed := create2(
                0,
                add(bytecode, 0x20),
                mload(bytecode),
                salt
            )
        }
        
        console.log("Solver: ", deployed);

        victim.setSolver(deployed);
    }
}