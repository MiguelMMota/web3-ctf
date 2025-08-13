# A brief note

`foundry.toml`, `src/` (exercises) and part of the docs (`.gitignore` and this README) are taken from JohnnyTime's great repo [here](https://github.com/RealJohnnyTime/ethernaut-foundry-solutions-johnnytime). I added
1. my own solutions
2. explanation and my thought process for each exercise in this README
3. containerisation of test setup, for security
4. using accounts instead of passing private keys through environment variables
5. `justfile` with helpful commands (see [just](https://github.com/casey/just))


NB: several libs in the repository are outdated. Whenever possible, I focused on the exercises at hand and only updated the project setup when necessary.

# Ethernaut Foundry Solutions 2023 - by JohnnyTime

## Pre-requisites
1. [Docker](https://www.docker.com/)
2. Wallet accounts (requires [foundry](https://getfoundry.sh/)). Check what accounts you have setup with `cast wallet list`. Import new wallets with `cast wallet import <name>`.
3. `.env` with your values for the variables in `.env.example`
4. `.password` file with account passwords.
5. [just](https://github.com/casey/just) (optional, if you want to use the command shorthands in `justfile`). Make sure to adapt the rpc url and account arguments to the `solve` command to match your testnet/account settings.


> The password file should include the password for the accounts you set with cast. DO NOT WRITE YOUR PRIVATE_KEY IN THIS FILE, and do not commit this file to git.

## Installation

1. Start Docker engine
2. `docker-compose up``


## Repository Structure
1. We will create the challenge smart contract in our Foundry project in the `src\` folder.
2. For every challenge, we will create a script file with the solution in the `script\` folder.
3. We will get a challenge instance from the [Ethernaut Website](https://ethernaut.openzeppelin.com/).
4. We will paste the instance address in our foundry solution file.
5. We will run our solution script in Foundry with `just solve <testName>`. E.g.: `just solve Fallback`
6. We will submit the challenge through the [Ethernaut Website](https://ethernaut.openzeppelin.com/).

## Solutions

### 0 - How to Start + Challenge 0 Solution
Welcome to the best Ethernaut CTF Solutions Repository, with Foundry!

#### What is Ethernaut?
[Ethernaut](https://ethernaut.openzeppelin.com/), brought to us by [OpenZeppelin](https://www.openzeppelin.com/), is a Capture The Flag (CTF) style challenge focused on smart contract hacking and auditing. It consists of 29 levels, each progressively more complex, offering an excellent platform to master these skills.

#### 0. Hello Ethernaut solution
This is a simple introductory exercise on interacting with the contract. We can follow the steps by accessing the contract's public attributes and functions. When prompted to authenticate, we can check the contract abi for information on the password. After successfully authenticating, we submit the level.

---

### 1: Fallback Solution
The `Fallback` is short and easy to analyse. It seems that users are intended to interact with the contract mainly by contributing either with `contribute()` or by transfering ether directly to the contract, with the highest contributor being selected as the contract owner, who can additionally withdraw all the funds from the contract.

The vulnerability lies in the fact that, while `contribute()` correctly checks if the sender is the highest contributor before making them the new owner, a much weaker verification is made when the user transfers directly to the contract. In the latter case, the user only needs to be a pre-existing contributor who is transferring **any** non-zero amount. An attacker need only make a valid call to `contribute()` transferring at least 0.001 ether, and then a direct transfer of 1 wei to be made the new owner of the contracting, and eligible to withdraw all the funds.

---

### 2: Fallout Solution
On the surface it may seem that the `Fallout` contract has a bit more going on than `Fallback` did in the previous exercise, but a quick look at the "constructor" will show that it's not a constructor at all! An attacker can just claim ownership of the contract by calling `Fal1out`.

---

### 3: CoinFlip Solution
After reading the prompt for this exercise, we can immediately anticipate that this attack will somehow revolve around manipulating the RNG behind the coin flip result. The actual RNG manipulation part is pretty simple, but I learned a separate very valuable lesson on Foundry scripts and on-chain vs off-chain execution from this exercise! But let's get back to this later.

First, gaming the RNG: the CoinFlip contract doesn't obfuscate its logic for determining the winning side at all. We can always guess the correct result by replicating the logic for determining the flip result from the block number.

Now, for the on-chain vs off-chain learning: from the get-go, I wanted to set this up so that I could run the solution to this problem with a simple `just solve CoinFlip`. 

> **TL;DR:** Foundry works in a peculiar way, and we must construct our attacking script carefully so that
> - Different attacks run on transactions in different block
> - Attacks are atomic, so the block number doesn't change between calculating the guess and running the flip.

Long-winded explanation: let's iterate towards a solution that will work for us:

1. We can calculate the flip result once use a `while loop` in the `attack` function to flip the coin 10 times in the same transaction with this result. This fails because the contract prevents us from making two flips in the same block.
2. We can add a sleep after each iteration to wait for the previous transaction to go through, then make a new calculated guess and flip the coin. The idea is that we'd wait enough time for the transaction to go through and a new block to be mined before we started a new attack. This has two problems, one small, and a big one:
    - **Small:** the timed delay isn't a guarantee that the transaction went through. To increase confidence that we only move to the next iteration when there's a new block, we'd have to use a significantly longer timer than the expected delay for mining the block.
    - **Big:** when we run the attack script with Foundry, all the attacks are executed **off-chain** in the same block, regardless of any delay we may artifically enforce. Effectively, Foundry does the following:
    
        i. Locally (i.e.: **off-chain**)
      1. Run any private functions and transactions with internal contracts
      2. Queue transactions with internal contracts
      3. Manipulate execution with vm commands
    
      ii. **On-chain**
      1. Execute all queued transactions
    
      That means our attacking contract would do the following:  
    
      1. Calculate the guess based on block number
      2. Queue a `flip` transaction on the victim contract
      3. Pause the local script execution for a few seconds, without actually affecting 
      transaction timing or block number
      4. Repeat steps 1-3 10 times
      5. Execute all `flip()` transactions at once in the current block
  
      Clearly, this doesn't work for us, as we need each transaction to be included in a different block.
3. Instead of running a loop inside the contract, we can make our `attack` function flip a coin only once (without any timed delay), and run this several times with the help of a bash script. We can even add some nice functions to wait for a new block to be mined before moving on to the next iteration. This seemingly solves both our small and big problems from the previous approach... except for one issue. If you look back at the Foundry workflow when running our script, it will first calculate the guess and queue the external transaction **off-chain**, and only later execute the transaction. We have no guarantee that the block number will remain the same between the time we queue a `flip` call and the time the transaction finally executes **on-chain**. When I worked on this, it resulted in some very weird logs, because an attack would result in the number of consecutive wins being bumped, and the next attack would start at 0 consecutive wins, since my initial logs were based on the contract's state at the start of execution, and the final logged value reflected the expected state changes for the contract when running everything locally, even before the transaction was actually submitted. When ocassionally the submitted transaction was included in a new block, different from the one that was initially used to calculate the flip result, the guess would be wrong, and we'd start over.

4. The solution to the previous problem is to run both the guess calculation and the flip on-chain, which we can do by running them in the constructor for a separate contract.

This definitely feels like overkill for such a simple exercise. We could've simply run it in Remix IDE by calling a simple function 10 times. This took much longer to work through, but I think the lessons are worth it, and it helps to now have some tooling to replicate more complex attacks from a containerised solution with a simple command.

---

### 4: Telephone Solution
A classic problem to illustrate the difference between `tx.origin` and `msg.sender` (and why `tx.origin` should be used carefully). We can claim ownership of the contract by calling the 
`changeOwner` function indirectly.

---

### 5: Token Solution
Another classic problem for overflow/underflow checks on unsigned ints. If we transfer more than our balance to a different address, the balance difference wraps back around to a positive number because unsigned ints can never be negative.

We transfer our balance + 1 to a second account address. When the contract updates our balance with `balances[msg.sender] -= _value; <=> x = x - (x + 1) <=> x = -1`, this is represented in uint256 as 2^256 - 1.

---

### 6: Delegation Solution
Here we have a contract with a delegate whose address we can't know externally. However, we do know the signature of its `pwn()`. Since the main contract's fallback is to call the function on the delegate contract, we can just call `pwn()` on the main contract to trigger the function on the delegate and claim ownership.

---

### 7: Force Solution
Hmm, interesting. What are the ways we can transfer ether to another contract `c1`?
1. public/external payable functions in `c1`
2. fallback/receive functions in `c1`
3. by creating and funding a new contract `c2` and making it self-destruct, specifying that left-over funds should be moved to `c1`. This is the only option that works even if `c1` doesn't implement any functions from options 1 and 2.

While this attack may seem innocuous at first glance, some protocols (particularly in the Defi space) depend on tightly-managed token balances. For example, forcing a transfer of a large amount of ETH to a lending protocol that uses ETH as collateral may devalue borrowers' collateral to such an extent that their positions become elligible for liquidation.

---

### 8: Vault Solution
The unbreakable vault has a private password! Surely unbreakable. But **every** storage variable in our contract is stored and **visible** on chain. Attribute/Function visibility only applies to how these objects can interact with the contract and external contracts, and influence gas optimisations by the EVM. Since we are running our exercises on Sepolia ETH testnet, we can see the contract creation transaction on sepolia.etherscan. In the [State](https://sepolia.etherscan.io/tx/0x6cdd812e7d2fd94d62590b82c5604735fd2bb97473f95d8a39d4d7e1917e2fef#statechange) tab, we can see the updates to storage variables at address `0xA483DF2c9fEA5C9B33974B77e3D73E944bEAf559` (our vault address). The value at storage index 1 was changed to "A very strong secret password :)". Let's use that to crack open the vault.

---

### 9. King Solution
I noticed the `King` contract was vulnerable to reentrancy, and honed in on that. My initial thought was that we'd need to make a two-pronged attack, by draining the contract's funds first, and then somehow claiming ownership of the contract. But draining the contract doesn't guarantee draining the level address, so there was no guarantee that the level couldn't make a higher transfer at the end.

It turns out the solution is much simpler. Changing the king depends on transferring the prize to the previous king. If we're the king and we reject any such transfers, we make sure the crown can never be taken from us. We do need to make sure we claim kingship with our malicious contract, though, and not with our private account.

---

### 10. Re-entrancy Solution
This is another classic attack example. As long as make an initial `deposit()` we're eligible for one withdrawal of some limited amount, and we can drain the contract. Note that on `withdraw()` the victim contract sends the amount to the original sender **before** uploading the sender's balance. If the sender attempts another withdrawal upon receiving the funds, they can withdraw once more before their balance is updated. But that 2nd withdrawal triggers another transfers, which triggers another withdrawal, and so forth. We can add a check on the attacker contract to stop withdrawing when the victim's balance is drained to stop the infinite recursion.

Conveniently, even though the contract uses `safeMath` for deposits, it doesn't do so withdrawals, and so our series of withdrawals won't fail when our `uint256` balance would go below 0.

---

### 11. Elevator Solution
The `Elevator` contract is vulnerable to the fact that they rely on an unverified contract for data. We simply need to write a contract that **acts** like `Building`, but in reality will cleverly say first that a certain floor isn't the top floor, and then say it is. This will trick the elevator into allowing us into a floor that isn't supposed to be the top floor and then somehow thinking it is.

---

### 12. Privacy Solution
Since the data is in a fixed-size array, the values in the array occupy consecutive storage slots. The contract is a little sneaky because it declares some variables of smaller types as well.

When checking the contract's initial state on Sepolia etherscan, we see that it has 6 storage slots. Since we also have 6 state variables, we'd be inclined to think that it's storage slot per variable, and in that case the value in the data array storage slot would be some address pointing to the actual first value.

In reality, some of the state variables declared in the contract can be packed into a single storage slot, if they don't occupy the whole slot. So for the six slots we have:

Slot1 -> bool locked
Slot2 -> uint256 ID
Slot3 -> [uint8 flattening, uint8 denomination, uint16 awkwardness]
Slot4 -> data[0]
Slot5 -> data[1]
Slot6 -> data[2]

We can just check the value in Slot6 for the password seed use it to unlock the victim contract.

---

### 13. Gatekeeper One Solution
We have to bypass the three verifications:
1. gateOne -> by interacting with the victim via a malicious smart contract. We've done this before
2. gateTwo -> this is the trickiest part. I wanted to avoid determining this by brute force on the sepolia eth testnet, and eventually settled for getting an estimate by forking my sepolia testnet on a local (containerised) anvil instance and running a brute force on that. Because gas costs may vary slightly between running on my local anvil test and on the sepolia testnet, I then ran the attack with a smaller set of gas values around the local test estimate.
3. gateThree:
  i. part one -> use a `_gateKey` where the 3rd and 4th least-significant bytes are 0.
  ii. part two -> use a `_gateKey` where one of the 4 most-significant bytes is not 0.
  iii. part three -> the 2 least significant bytes of the `_gateKey` must be the original caller's (`tx.origin`) 2 least significant bytes

---

### 14. Gatekeeper Two Solution
We have to bypass the three verifications:
1. gateOne -> by interacting with the victim via a malicious smart contract, same as before
2. gateTwo -> this is meant to prevent other smart contracts from interacting with the victim smart contract. Since smart contracts has its bytecode stored at their addresses, they typically fail this check. However, there are 4 types of addresses that pass this check:
  i. EOA
  ii. Contracts in construction (e.g.: when a contract call a function that requires this check from its constructor)
  iii. An address where a contract will be created
  iv. An address where a contract was, which was self-descructed

  We'll use option ii.
3. gateThree -> `_gateKey` must be the bitwise complement of the last 8 bytes of the attack contract.

---

### 15. Naught Coin
We can transfer ERC20 tokens from an account using either `transfer` or `transferFrom`. The latter isn't guarded by the timelock constraint, so we can `approve` the transfer of funds from an accomplice account and use `transferFrom` to bypass the security measure.

---

### 16. Preservation
`delegatecalls` are very powerful because they allow contracts to execute logic that isn't in the contract itself *as if* the it had been. For simplicity, one can think of it as a contract C1 borrowing the logic from a target contract C2 which implements and running it directly, even though it's the exact opposite that is happening. In reality, C1 calls C2 and C2 operates as if it were C1, i.e.: with the original message parameters (sender, value, etc) and with the ability to affect tha C1's storage. This needs careful attention, as it opens C1 up to meaningful security vulnerabilities. We need to keep in mind:
1. Using `delegatecall` on an unknown contract allows a target contract to run malicious code directly on the target contract
2. The C1 and C2's storage must be defined identically, otherwise C2 will affect C1's storage variables incoherently.

We'll take advantage of these two principles to exploit the `Preservation` contract. Note that it delegates some functionality to a `LibraryContract`, whose storage variables don't follow the order in which storage variables are declared in `Preservation`. When we delegate the call to `LibraryContract`, it will set a `uint256` value on the first storage slot of `Preservation`. However, this slot is for the `timeZone1Library`. So by calling `setFirstTime` or `setSecondTime`, we'll change the address values of the first time zone library, pointing to an address of our choosing.

Here's what we'll do:
1. Create a malicious contract that will set `Preservation.owner` to our account address
2. Call `Preservation.setSecondTime` (could be `Preservation.setFirstTime`) with a value whose 20 least-significant bytes are the malicious contract address
3. Call `Preservation.setFirstTime` (has to be this one, because `timeZone1Library` now points to our malicious contract) with any value.

---

### 17. Recovery
The lost contract address can be found on Etherscan. Look up the level instance address, and inspect the contract creation transaction. A third "to" address is listed with 0.001 ether. We can simply destroy the contract, removing its ether balance.

---

### 18. Magic Number
We have to write a contract that will return 42 on any function call, directly in Assembly. [This article](https://medium.com/coinmonks/ethernaut-lvl-19-magicnumber-walkthrough-how-to-deploy-contracts-using-raw-assembly-opcodes-c50edb0f71a2) gives a brilliant explanation on how to write this script. We deploy it with the create2 opcode, and assign its address as the victim contract's solver.

---

### 19. Alien Codex
I noticed a few things at first that didn't seem accidental:
1. the solidity version of the contract set to ^0.5.0.
2. the contract decrements the codex dynamic array length explicitly instead of removing the last item.
3. the contract doesn't check the length of `codex` before updating an element at a given position.

The exercise requires that we use these properties of the contract to manipulate the `owner` address by interacting with `codex`.

We can see from the ABI that IsOwnable introduces an `owner` attribute and a few functions related to ownership. The superclass storage variables are declared and assigned storage slots first. With each slot having a capacity for 32 bytes of data, the AlienCodex storage slots would look like this:

0 -> `owner` (address: 20 bytes, 12 bytes free)
1 -> `contact` (bool: 1 byte, 31 bytes free)
2 -> address of `codex` first item (bytes32)
...
keccak256(2) -> first item of codex  // keccak256(2) because codex is at slot 2
keccak256(2) + 1 -> second item of codex
...

After Solidity packs consecutive storage variables together for efficiency, we get:
0 -> `owner` (address: 20 bytes, 12 bytes) + `contact` (bool: 1 byte). 11 bytes free
1 -> address of `codex` first item (uint256 -> 32 bytes)
...
keccak256(1) -> first item of codex  // keccak256(2) because codex is at slot 1
keccak256(1) + 1 -> second item of codex
...

Some key points with the choice of Solidity 0.5.0:
1. Prior to 0.6.0, it was possible to assign array length directly, as done in this smart contract.
2. Prior to 0.8.0, arithmetic operations would overflow/undeflow without reverting.

The attack vector is to manipulate the storage slot 0 (thus setting `owner`) by accessing a specific index in `codex`. codex[0] is at storage slot `keccak256(1)`. To update storage slot 0, we need to:
1. Make `codex` cover the entire storage space by causing its length to underflow.
2. Set codex[-keccak256(1)] to our player address. Since indexes are uint256, and codex[2**256] wraps around to codex[0], we can do codex[2**256-keccak256(i)].

---

### 20. Denial
We can set the withdrawing partner to a malicious contract whose fallback function consumes all remaining gas.

---

### 21. Shop
This is similar to the Elevator problem, but since `price()` is a view function, we can't change our contract's state during the function execution to return two different results. However, there is a change in the state of `Shop` between the two calls, and we can take advantage of it to return two different results depending on the state of `Shop` when `price()` is called.

A more complicated solution could perhaps be achieved by burning gas in the view function. After calling `price()` for the first time, the victim contract still has to run:
```
isSold = true  // ~20000 gas
buyer.price()  // overhead of ~2600 gas + whatever buyer.price() costs
price = ...    // ~5000 gas
// function completion overhead: ~200-500 gas.
```

All in all, the function should need ~28000 gas + the cost of our `price()` function. -22600 of these would be spent before calling `buyer.price()` for the second time. So we could write our `price()` function to return 100 and burn gas down to 28000 + `price()` gas cost + 3000 (margin) if the gasLeft is over that value. If it's over that value, return 0 and don't burn any gas. This would be less reliable, as gas estimates may differ depending on version, test chain, etc.

---

### 22. Dex
Because we hold a significant percentage of the Dex's reserve funds, we can manipulate price by swapping all our funds of one token to the other, and vice-versa, multiple times. The contract stipulates the amount (`swapAmount`) we can of `T_a` we can exchange for `T_b` at any time with

```
our_amount_of_T_a * dex_ratio_of_tb_to_ta
```

Let's represent the state `Si` of the problem with `((dex_token1_balance, dex_token2_balance), (attacker_token1_balance, attacker_token2_balance))` and `swap` transactions `Ti` with `(tokenToSwapFor, swapAmount)`, where tokenToSwapFor is T1 or T2 depending on whether player wants to get an amount of token1 or token2, respectively; and swapAmount is given by the formula above. We therefore may establish this sequence of states and swap transactions.

NB: For simplicity, I'm truncating token amounts

```
S0 = ((100, 100), (10, 10)) | T0 = (T2, 10)  // We can trade our 10 T1 for 10 * 100/100 = 10 T2
S1 = ((110, 90), (0, 20)) | T1 = (T1, 24)  // We can trade our 20 T2 for 20 * 110/90 ~= 24 T2
S2 = ((86, 110), (24, 0)) | T2 = (T2, 30)
S3 = ((110, 80), (0, 30)) | T3 = (T1, 41)
S4 = ((69, 110), (41, 0)) | T4 = (T2, 65)
S5 = ((110, 45), (0, 65)) | T5 = (T1, 158)
```

In `T5` we can swap an amount of 45 token2 to receive 45 * 110 / 45 = 110 token1. That will result in `S6 = ((0, 90), (110, 20))`, and the dex contract is out of token1.

We can build a malicious contract that does these swaps back and forth, always swapping all of its funds of one token for the other, until the victim contract doesn't have enough to fulfil the swap. In the final swap, we swap for the victim's full balance of the target token.

---

### 23. Dex Two
The `swap` function in this new dex contract removed the requirement that the swap pair should be token1 => token2 or token2 => token1. How can we take advantage of this to now drain all balances of token1 and token2?

Recall that we could already drain the balance of one token. For the sake of example let's say it was token1. At the end of the `Dex` attack, `S6` was `S6 = ((0, 90), (110, 20))` (see exercise 21 explanation above). What would happen if we tried to remove the remaining balance 90 of token2 from the dex? Let's indicate a swap transaction of token2 for token2 with `Ti = (tokenToSwapFor', swapAmount)`. Note the "'" after tokenToSwapFor to indicate that it's the same as the token given in the swap. In this case, `swapAmount = our_amount_of_T_a * dex_ratio_of_tb_to_ta = our_amount_of_T_a`. 

```
S6 = ((0, 90), (110, 20)) | T6 = ()
```

So it's no use to swap a token for itself. But nothing stops us now from creating a third token whose sole purpose is to allow us to swap it for token1 and token2. Let's adapt the notation from the previous exercise:
`Si` -> problem state represented by `((dex_token1_balance, dex_token2_balance, dex_token3_balance), (attacker_token1_balance, attacker_token2_balance, attacker_token3_balance))` and `swap` transactions `Ti` with `(tokenToSwapFor, swapAmount)`, where tokenToSwapFor is T1 or T2 depending on whether player wants to get an amount of token1 or token2, respectively; the token to give in the swap is always token3; and swapAmount is given by the same formula. We therefore may establish this sequence of steps:

1. Create a new ERC20 token token3 with an initial supply of 400
2. Transfer 100 token3 to the dex
3. S0 = ((100, 100, 100), (10, 10, 300)) | T0 = (T1, 100)  // We can trade 100 T3 for 100 * 100/100 = 100 T1
4. S1 = ((0, 100, 200), (110, 10, 200)) | T1 = (T2, 200)  // We can trade our remaining 200 T3 for 200 * 100/200 = 100 T2
5. S2 = ((0, 100, 400), (110, 110, 0))

The dex will be left with a worthless balance of 400 token3, and we'll have the full balance of token1 and token2.

---

### 24. Puzzle Wallet
What a great exercise!

For this one, we have to be on the lookout for multiple small vulnerabilities that seem innocuous in isolation, but allow us to take full control of the contract and drain its funds. Let's start by recapping what we learned from previous exercises about how `delegatecall` interacts with storage.
1. storage is divided into 2**256 32-byte slots
2. storage variables in contracts are simply labels to data in these slots. Therefore, when `PuzzleWallet` updates `owner`, it updates its first slot.
3. When a contract C1 does `delegatecall` on a contract C2, C2 executes its logic against C1's state, **and updating C1's state instead of its own**. 

We can assume that the `_implementation` address given to `PuzzleProxy` is an address for a `PuzzleWallet` contract. `PuzzleProxy` will delegate all the calls it can't handle directly to its implementation. So the storage variables in `PuzzleWallet` must align with the `PuzzleProxy` storage variables.

Let's analyse the storage variables of both contracts:

| Slot # | PuzzleProxy | PuzzleWallet |
|----------|----------|----------|
| 0 | pendingAdmin (20 bytes) | owner (20 bytes) |
| 1 | admin (20 bytes) | maxBalance (32 bytes) |
| 2 | - | empty - whitelisted mapping placeholder |
| 3 | - | empty - balances mapping placeholder |

`PuzzleWallet` will also have the mapping values scattered throughout storage space at addresses given by keccak256(key || mapping_slot_number), where mapping_slot_number is 2 for `whitelisted` and 3 for `balances`.

> **Vulnerability #1:** `PuzzleProxy.pendingAdmin` and `PuzzleWallet.owner` use the same storage slot. So our malicious contract can gain ownership privileges on `PuzzleWallet` by setting the pending admin, which doesn't require a privileged user level
> **Vulnerability #2:** `PuzzleProxy.admin` and `PuzzleWallet.maxBalance` use the same storage slot (even though the former only needs 20 bytes of it). So we can become the admin of `PuzzleProxy` by setting the max balance on `PuzzleWallet`.

We can trivially exploit Vulnerability #1. Vulnerability #2 requires some more work:
1. We need to whitelist our malicious contract address, which is trivial since it's now the owner
2. We need to drain the victim's funds. But how?

Let's brainstorm ideas for draining the victim's funds:
1. Some kind of reentrancy attack.
  a. `execute()` does a `call` on the transfer recipient, but only after updating the contract's state ❌
  b. `multicall(...)` does a `delegatecall`, but only on itself
2. Calling `execute()` once, and in our `receive()` doing another `delegatecall` to `execute()` to withdraw the whole victim balance. When the victim calls our contract in its `execute()` function, they become the `msg.sender`. So if we `delegatecall` (not `call`) back to their `execute()`, the aim is that we'll pass the requirements to transfer the whole value out of the victim's contract. However, recall that `delegatecall` executes everything against the original contract's storage and any ether sent to any other contract is sent from the original contract. ❌
3. If somehow we can do multiple deposits with a single transfer to the victim. Clearly the authors thought of this vulnerability, as they included a safeguard so that a `multicall()` doesn't have more than one `deposit()` action in its inputs. But what if a `multicall` was asked to do `multicall()` N times, and each of the nested multicalls did a single `deposit()`? That would work, since each `multicall()` would have its own tracker for multiple `deposit()` actions! This could be prevented by keeping track of `depositCalled` as a storage variable, which persists across different function scopes, and resetting it at the end of the multicall. ✅

Here's the summary of our exploit:
1. Create a malicious contract and give it a small amount of ether
2. Make the malicious contract the `PuzzleWallet` owner by setting `PuzzleProxy.pendingAdmin` to its address
3. Whitelist the malicious contract, so it can call the various privileged functions in `PuzzleWallet`
4. Run a `multicall` with (N + 1) single-deposit multicalls, where N is (victim_balance / malicious_contract_balance) rounded up. The extra '1' is so that we can get our deposit back in addition to the victim's initial balance. This will make the victim allocate us a balance of (N+1) * deposit_amount, even though we only transferred a single deposit_amount
5. Withdraw all our balance from the victim with `execute()`.
6. Now that the victim's balance is 0, we can set `maxBalance` to a `uint256` that makes `admin` read our player address on storage slot 2.

---
