# Pump.fun-clone
# Pump.fun Smart Contract

This repository contains the smart contract for **Pump.fun**, a decentralized platform for creating and trading meme tokens with automated liquidity provisioning.

## 🚀 Tech Stack
- **Solidity** (`^0.8.24`)
- **OpenZeppelin Contracts** (ERC20, Ownable)
- **Hardhat** (Development and testing framework)
- **Uniswap V2** (Liquidity integration)
- **Node.js & Ethers.js** (For deployment and interactions)

---

## 🛠️ Setup Instructions

### Prerequisites
Ensure you have the following installed:
- **Node.js** (>=16.x recommended)
- **Hardhat** (`npm install --save-dev hardhat`)
- **Metamask** (For interacting with the contract on testnets/mainnet)

### 1️⃣ Clone the Repository
```bash
git clone https://github.com/yourusername/pump-fun.git
cd pump-fun
```

### 2️⃣ Install Dependencies
```bash
npm install
```

### 3️⃣ Compile the Contracts
```bash
npx hardhat compile
```

### 4️⃣ Deploy the Contracts
Modify `hardhat.config.js` to set up your preferred network and deploy:
```bash
npx hardhat run scripts/deploy.js --network goerli
```

### 5️⃣ Verify Contract on Etherscan (Optional)
```bash
npx hardhat verify --network goerli <DEPLOYED_CONTRACT_ADDRESS>
```

---

## 📜 Contract Overview

### `Token.sol`
- Implements **ERC20** token standard
- Uses **Ownable** for admin control
- Minting function restricted to the contract owner

### `Factory.sol`
- Allows users to create new meme tokens
- Integrates **Uniswap V2** for liquidity provision
- Implements an automated bonding curve pricing model

---

## 🏗️ Contributing
Pull requests are welcome! Please ensure code follows Solidity best practices and is thoroughly tested.

---

## 📜 License
This project is licensed under the **MIT License**.

---

### 🔗 Useful Links
- [OpenZeppelin Docs](https://docs.openzeppelin.com/contracts/4.x/)
- [Hardhat Docs](https://hardhat.org/getting-started/)
- [Ethers.js Docs](https://docs.ethers.org/v5/)
- [Uniswap V2 Docs](https://docs.uniswap.org/contracts/v2)

