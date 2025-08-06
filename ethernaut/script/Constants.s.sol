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
    address public constant FORCE_ADDRESS = 0x6a592A1E5A5975d9Fe92D6394680E8815979BD45;
    address public constant VAULT_ADDRESS = 0xA483DF2c9fEA5C9B33974B77e3D73E944bEAf559;
    address payable public constant KING_ADDRESS = payable(0x12d139372dFaCd28Df205361Ef8c0d0fB7aC6374);
    address payable public constant REENTRANCY_ADDRESS = payable(0xE76B0D1520f11A7455cC62F0998db32Ff4bddd4D);
}