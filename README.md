# Prism Protocol

**Privacy + Identity infrastructure for autonomous agents**

> Your wallet's invisible shield. Derive disposable context wallets, delegate to AI agents with granular permissions, and register agent identities on-chain via ERC-8004. If a context is compromised, only that context burns — never your root wallet.

**Multi-chain**: [Solana (main branch)](https://github.com/Motus-DAO/prism-protocol/tree/main) · **EVM/Celo (this branch)**

---

## 🚀 Deployed on Celo Mainnet

| Contract | Address | CeloScan |
|----------|---------|----------|
| **PrismFactory** | `0xaC39210F2dBcD120D9bCDE7DEeF04f2c30F8E24F` | [View](https://celoscan.io/address/0xaC39210F2dBcD120D9bCDE7DEeF04f2c30F8E24F) |
| **PrismRegistry** | `0xEe0C5FffD437099789d4B1A67A765dA7a163Ced3` | [View](https://celoscan.io/address/0xEe0C5FffD437099789d4B1A67A765dA7a163Ced3) |

### On-Chain Activity

| Action | TxHash | Details |
|--------|--------|---------|
| Deploy contracts | [View Tx](https://celoscan.io/tx/0x4805154345e3873b9969969fff1e422813d6864481f68e7f0a8f682fd4e2ec1c) | PrismFactory + PrismRegistry deployed |
| Register AgentMotus (Agent #1) | [View Tx](https://celoscan.io/tx/0x4805154345e3873b9969969fff1e422813d6864481f68e7f0a8f682fd4e2ec1c) | First ERC-8004 agent registered on-chain |
| Create Context Wallet | [View Tx](https://celoscan.io/tx/0x705301dbc0d1e7e88a53a2320408611fef162f1371680396a76e1cac8b6fed0c) | Delegated to AgentMotus with caveats |
| AgentMotus first execution | [View Tx](https://celoscan.io/tx/0x3f1d3338e3122d1ed442b36bd7a11987d540c04ecf4091c9077ad6a3386f2676) | Agent executed tx from context wallet within limits |

---

## 🎯 What Prism Does

### The Problem
AI agents need wallets to operate on-chain. But giving an agent your private key is a disaster waiting to happen. And creating separate wallets for each agent is a management nightmare with no identity, no permissions, and no revocation.

### The Solution

```
Root Wallet (your main wallet, verified as human via Self)
│
├── ERC-8004 Identity Registry
│   └── AgentMotus = Agent #1 (NFT + registration file)
│
├── Context A → Smart Wallet (delegated to Agent A)
│   ├── Spending limit: 1 CELO/tx
│   ├── Daily limit: 5 CELO/day
│   ├── Allowlist: only approved contracts
│   ├── TTL: 30 days (auto-expires)
│   └── Revocable instantly by owner
│
├── Context B → Smart Wallet (delegated to Agent B)
│   ├── Different limits, different rules
│   └── Compartmentalized — can't affect Context A
│
└── Context C → Risky browsing
    ├── 0.01 CELO max, 1-hour TTL
    └── If hacked → only this context is affected
```

**Key insight**: Each context is a disposable, permission-scoped smart wallet. Your root identity is never exposed. If an agent goes rogue or a context is compromised, you revoke it — your root wallet and other contexts are untouched.

---

## 🏗️ Architecture

### Core Contracts

#### PrismFactory
Derives deterministic context wallets from your root identity using CREATE2.

```solidity
// Create a context wallet for your agent
factory.createContext(
    ContextConfig({
        contextType: "agent",
        spendingLimit: 1 ether,      // max per transaction
        dailyLimit: 5 ether,         // max per 24h window
        allowlist: [],               // allowed target contracts
        ttl: 30 days,                // auto-expire
        delegate: agentAddress       // who can operate this wallet
    }),
    salt
);
```

#### PrismContext (Smart Wallet)
Each context wallet enforces caveats on every transaction:
- **Per-tx spending limit** — agent can't drain funds in one shot
- **Daily spending limit** — rolling 24h window cap
- **Contract allowlist** — restrict which contracts the agent can interact with
- **TTL** — auto-expires after set duration
- **Revocation** — owner can instantly revoke at any time

```solidity
// Agent executes from context wallet (within caveats)
context.execute(targetContract, value, calldata);

// Owner revokes if needed
context.revoke();
```

#### PrismRegistry (ERC-8004)
On-chain agent identity and reputation, fully compliant with [ERC-8004: Trustless Agents](https://eips.ethereum.org/EIPS/eip-8004).

```solidity
// Register an agent (mints ERC-721 NFT)
uint256 agentId = registry.register(agentURI);

// Submit reputation feedback
registry.submitFeedback(agentId, 5, "Excellent execution");

// Check reputation
(uint256 score, uint256 reviews) = registry.getReputation(agentId);
```

Registration file follows the ERC-8004 spec:
```json
{
  "type": "https://eips.ethereum.org/EIPS/eip-8004#registration-v1",
  "name": "AgentMotus",
  "description": "AI strategic operator by MotusDAO",
  "services": [
    { "name": "MCP", "endpoint": "...", "version": "2025-06-18" }
  ],
  "active": true,
  "registrations": [
    {
      "agentId": 1,
      "agentRegistry": "eip155:42220:0xEe0C5FffD437099789d4B1A67A765dA7a163Ced3"
    }
  ],
  "supportedTrust": ["reputation"]
}
```

---

## 🔑 Key Innovations

### 1. Context-Based Identity Compartmentalization
Your root wallet refracts into many context wallets — like light through a prism. Each context is isolated, permissioned, and disposable.

### 2. Caveat-Enforced Delegation
Agents operate within hard on-chain limits. No trust assumptions — the smart contract enforces the rules.

### 3. ERC-8004 Agent Registry
First implementation of the Trustless Agents standard on Celo. Agents are discoverable, rated, and verifiable on-chain.

### 4. Multi-Chain
Solana version on `main` branch. EVM version (Celo, Base, Ethereum) on `ethereum-root-identity`. Same protocol, multiple chains.

---

## 🛠️ Development

### Prerequisites
- [Foundry](https://book.getfoundry.sh/getting-started/installation)

### Build
```bash
git clone https://github.com/Motus-DAO/prism-protocol.git
cd prism-protocol
git checkout ethereum-root-identity
forge build
```

### Test
```bash
forge test
```

### Deploy
```bash
# Set your private key
export PRIVATE_KEY=0x...

# Deploy to Celo mainnet
forge script script/Deploy.s.sol:Deploy --rpc-url https://forno.celo.org --broadcast

# Register an agent
REGISTRY=0xEe0C5FffD437099789d4B1A67A765dA7a163Ced3 \
AGENT_URI="data:application/json;base64,..." \
forge script script/RegisterAgent.s.sol:RegisterAgent --rpc-url https://forno.celo.org --broadcast

# Create a context wallet
FACTORY=0xaC39210F2dBcD120D9bCDE7DEeF04f2c30F8E24F \
DELEGATE=0xYourAgentAddress \
forge script script/CreateContext.s.sol:CreateContext --rpc-url https://forno.celo.org --broadcast
```

---

## 📁 Project Structure

```
contracts/
├── PrismFactory.sol          # Context wallet factory (CREATE2)
├── PrismContext.sol           # Smart wallet with caveats
├── PrismRegistry.sol          # ERC-8004 agent identity + reputation
├── interfaces/                # Contract interfaces
└── libraries/
    └── PrismErrors.sol        # Custom errors
script/
├── Deploy.s.sol               # Deploy all contracts
├── RegisterAgent.s.sol        # Register agent on registry
└── CreateContext.s.sol        # Create context wallet
agent/
├── agent.json                 # Protocol Labs agent manifest
├── agent_log.json             # Execution receipts with TxIDs
└── registration.json          # ERC-8004 registration file
```

---

## 🎯 Use Cases

- **🤖 AI Agent Operations** — Give your agent a scoped wallet, not your keys
- **🛡️ Wallet Drain Protection** — Risky sites get a disposable context with minimal funds
- **🗳️ Anonymous DAO Voting** — Prove membership via ZK without revealing your main wallet
- **💱 Private DeFi** — Trade from contexts that can't be linked to your root
- **⭐ Reputation Without Doxxing** — Prove your agent's track record without exposing your identity
- **🔄 Multi-Agent Orchestration** — Each agent gets its own context with different permission levels

---

## 🏆 Hackathon: Synthesis 2026

This project is being submitted to the [Synthesis Hackathon](https://synthesis.devfolio.co/) targeting:

| Bounty | Fit |
|--------|-----|
| Protocol Labs ($16k) | ERC-8004 implementation + agent.json/agent_log.json |
| Celo ($5k) | Deployed on Celo mainnet with real transactions |
| MetaMask ($5k) | Delegation framework alignment + ERC-7715 |
| Venice ($11.5k) | Private inference for agent decision-making |
| Self ($3k) | Human verification for root identity |

---

## 📜 License

MIT

---

**Built by [MotusDAO](https://github.com/Motus-DAO) + [AgentMotus](https://github.com/AgentMotus)** ⚡
