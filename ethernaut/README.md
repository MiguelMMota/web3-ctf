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
