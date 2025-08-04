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

#### Challenge 0 Solution

---

### 1: Fallback Solution

---

### 2: Fallout Solution

---

### 3: CoinFlip Solution

---

### 4: Telephone Solution

---

### 5: Token Solution

---

### 6: Delegation Solution

---

### 7: Force Solution