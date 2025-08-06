// SDPX-License-Identifier: MIT

pragma solidity ^0.6.2;

contract Constants {
    address public constant ATTACKER_ADDRESS = 0xCDc986e956f889b6046F500657625E523f06D5F0;

    // this is a 2nd EOA that will help with some of the attacks
    address public constant ACCOMPLICE_ADDRESS = 0x13dbAD22Ae32aaa90F7E9173C1fA519c064E4d65;

    address payable public constant FALLBACK_ADDRESS = payable(0x3Dd001d1ca706137c2B51C7D2167Aba5CdeD65FD);
    address payable public constant FALLOUT_ADDRESS = payable(0x3a026133cC2e1138B7534Bb900cC4eB097E58920);
    address public constant COIN_FLIP_ADDRESS = 0xE447a60be1fcfB04a7D3b69F57463c61d6fD0c83;
    address public constant TELEPHONE_ADDRESS = 0xCf80Fc0d5Ef945cDb5CB4360Bf2D27D5a500cb20;
    address public constant TOKEN_ADDRESS = 0x5A8B30C8D5dEdA46A174138527531C81E20FdbEd;
    address public constant DELEGATION_ADDRESS = 0x769b97df44A87C1557bfFd2666155630b3258C6D;
}