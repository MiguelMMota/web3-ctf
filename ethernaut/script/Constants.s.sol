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
    address public constant ELEVATOR_ADDRESS = 0x9E9d0781AF8Bde367d34AEF6aB35a1907b62de15;
    address public constant PRIVACY_ADDRESS = 0x5ab468267a4d9068545DCB4aa8d9720F79c19d30;
    address public constant GATEKEEPER_TWO_ADDRESS = 0x318a5d6F8888f5188b61E071F07BdCb24e019a59;
    address public constant NAUGHT_COIN_ADDRESS = 0x1ed8Daad2b37EB930CF911bd25229867f1D527B9;
    address public constant PRESERVATION_ADDRESS = 0x08e312B31b9Ef5eD8fDe77C6F6a3272A50271589;
    address public constant RECOVERY_ADDRESS = 0x399745B7f9A54C7cfD6F0657f1DEB3E8F65567D9;  // NB: this is the address of the deployed token, not the instance address
    address public constant MAGIC_NUMBER_ADDRESS = 0x64f20bdA5ea4F030B9DbcaFbe2Bb64ac5aF1C183;
    address public constant ALIEN_CODEX_ADDRESS = 0x7cB8fC064684926924eaBB6f4203E20cB0BE3406;
    address public constant DENIAL_ADDRESS = 0xF05EC693Ed7F9A5CfbB03eAEB979EB5f00CAaeaA;
    address public constant SHOP_ADDRESS = 0x23097cc793456b4fc5873c9e45C3cf541711DE0E;
}