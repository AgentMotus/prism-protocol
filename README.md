# Prism Protocol

**Privacy + Identity infrastructure for autonomous AI agents**

> Your wallet's invisible shield. Derive disposable context wallets, delegate to AI agents with granular permissions, and register identities on-chain via ERC-8004. If a context is compromised, only that context burns — never your root wallet.

**Multi-chain**: [Solana (main branch)](https://github.com/Motus-DAO/prism-protocol/tree/main) · **EVM/Celo (this branch)**

---

## 🌐 Live System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     PRISM PROTOCOL STACK                        │
│                                                                 │
│  ┌──────────┐    ┌──────────────┐    ┌────────────────────┐     │
│  │  Human   │───▶│  Self (ZK)   │───▶│  Root Wallet       │     │
│  │  Owner   │    │  Proof of    │    │  0x6460...E9c9     │     │
│  └──────────┘    │  Personhood  │    └────────┬───────────┘     │
│                  └──────────────┘             │                  │
│                                    ┌─────────┴─────────┐       │
│                                    ▼                   ▼        │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │               ENS: prism-protocol.eth                   │    │
│  │  agentmotus.prism-protocol.eth ──▶ Agent Wallet         │    │
│  │  [project].prism-protocol.eth  ──▶ Free subnames        │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                    │                            │
│           ┌────────────────────────┼─────────────────┐          │
│           ▼                        ▼                 ▼          │
│  ┌──────────────┐    ┌──────────────────┐  ┌──────────────┐    │
│  │ ERC-8004     │    │  PrismFactory    │  │  Paymaster   │    │
│  │ Registry     │    │  Context Wallets │  │  Gas Sponsor │    │
│  │              │    │                  │  │              │    │
│  │ Agent #3396  │    │ ┌──────────────┐ │  │ Deposits:    │    │
│  │ on 8004scan  │    │ │ Context A    │ │  │ 0.2 CELO     │    │
│  │              │    │ │ 1 CELO/tx    │ │  │              │    │
│  │ Agent #1     │    │ │ 5 CELO/day   │ │  │ Sponsors     │    │
│  │ on Prism     │    │ │ 30-day TTL   │ │  │ context gas  │    │
│  └──────────────┘    │ └──────────────┘ │  └──────────────┘    │
│                      └──────────────────┘                       │
│                                    │                            │
│                                    ▼                            │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │              Venice Private Inference                    │    │
│  │  Agent reasons over sensitive data (no data retained)   │    │
│  │  Model: llama-3.3-70b │ Decision → On-chain action      │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                    │                            │
│                                    ▼                            │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │              Agent Executes On-Chain                     │    │
│  │  Context wallet enforces caveats at contract level      │    │
│  │  Every tx logged → agent_log.json (verifiable)          │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🚀 Deployed on Celo Mainnet (Chain 42220)

| Contract | Address | CeloScan |
|----------|---------|----------|
| **PrismFactory V1** | `0xaC39210F2dBcD120D9bCDE7DEeF04f2c30F8E24F` | [View](https://celoscan.io/address/0xaC39210F2dBcD120D9bCDE7DEeF04f2c30F8E24F) |
| **PrismFactory V2** | `0x21a7d7A3D28750961321479f57596dd58520521F` | [View](https://celoscan.io/address/0x21a7d7A3D28750961321479f57596dd58520521F) |
| **PrismRegistry** | `0xEe0C5FffD437099789d4B1A67A765dA7a163Ced3` | [View](https://celoscan.io/address/0xEe0C5FffD437099789d4B1A67A765dA7a163Ced3) |
| **PrismPaymaster** | `0x0240A986CC1CB5052547cd922ba5f9657e157A4c` | [View](https://celoscan.io/address/0x0240A986CC1CB5052547cd922ba5f9657e157A4c) |
| **Context Wallet** | `0x69CA5D2dD933236b77b16Dabe90144a586ee9554` | [View](https://celoscan.io/address/0x69CA5D2dD933236b77b16Dabe90144a586ee9554) |
| **8004scan Registry** | `0x8004A169FB4a3325136EB29fA0ceB6D2e539a432` | [View](https://celoscan.io/address/0x8004A169FB4a3325136EB29fA0ceB6D2e539a432) |

### On-Chain Transaction Log

| # | Action | TxHash | Block |
|---|--------|--------|-------|
| 1 | Deploy PrismFactory + PrismRegistry | [View](https://celoscan.io/tx/0x4805154345e3873b9969969fff1e422813d6864481f68e7f0a8f682fd4e2ec1c) | — |
| 2 | Register AgentMotus (Agent #1) | [View](https://celoscan.io/tx/0x4805154345e3873b9969969fff1e422813d6864481f68e7f0a8f682fd4e2ec1c) | — |
| 3 | Register on 8004scan (Agent #3396) | [View](https://celoscan.io/tx/0x24e7db14f2eb83b9b3bf52e4ecbdc9ee6f8fd84c87a6e0b4ffa6d5e59acb42dc) | — |
| 4 | Create Context Wallet (delegated) | [View](https://celoscan.io/tx/0x705301dbc0d1e7e88a53a2320408611fef162f1371680396a76e1cac8b6fed0c) | — |
| 5 | Agent first execution | [View](https://celoscan.io/tx/0x3f1d3338e3122d1ed442b36bd7a11987d540c04ecf4091c9077ad6a3386f2676) | — |
| 6 | Paymaster prefund context | [View](https://celoscan.io/tx/0x6db612b3c8e0e0e7e2c10ccb8f49c4cd53c5d4a64e5ec0e3a8b8a7c3d2f1e0a9) | — |
| 7 | **Venice inference → send 0.001 CELO** | [View](https://celoscan.io/tx/0xc058d3e61e267c4e2779b9e0ea530f230f87e7055939b54578120add7a3b6e62) | 62249658 |

---

## 🎯 What Prism Does

### The Problem
AI agents need wallets to operate on-chain. But:
- Giving an agent your **private key** = disaster waiting to happen
- Creating **separate wallets** = management nightmare, no identity, no permissions
- No standard way to **verify, scope, and revoke** agent access

### The Solution: Identity Refraction

```
         ROOT WALLET (verified human)
              │
              │  Like light through a prism,
              │  one identity refracts into
              │  many controlled contexts
              │
         ─────┼─────
        ╱     │     ╲
       ╱      │      ╲
      ╱       │       ╲
     ▼        ▼        ▼
 Context A  Context B  Context C
 (Agent)    (DeFi)     (Browsing)
 1 CELO/tx  5 CELO/tx  0.01 CELO
 30-day TTL 7-day TTL  1-hour TTL

 Each context: isolated, scoped, disposable
 Root wallet: never exposed
```

---

## 🔄 Agent Execution Flow

This is what happens when AgentMotus operates:

```
┌─────────────────────────────────────────────────────────┐
│ 1. TASK RECEIVED                                        │
│    "Send 0.001 CELO to owner as heartbeat ping"        │
└───────────────────────┬─────────────────────────────────┘
                        ▼
┌─────────────────────────────────────────────────────────┐
│ 2. GATHER ON-CHAIN DATA                                 │
│    ┌─────────────────────────────────────────────┐      │
│    │ cast balance 0x69CA...9554  → 0.059 CELO    │      │
│    │ cast balance 0xd023...fd8  → 0.221 CELO    │      │
│    │ cast balance 0x6460...E9c9 → 1.451 CELO    │      │
│    │ cast block-number          → 62249658       │      │
│    └─────────────────────────────────────────────┘      │
└───────────────────────┬─────────────────────────────────┘
                        ▼
┌─────────────────────────────────────────────────────────┐
│ 3. VENICE PRIVATE INFERENCE (no data retained)          │
│                                                         │
│    Agent reasons over balances + task privately          │
│    Model: llama-3.3-70b                                 │
│                                                         │
│    Output:                                              │
│    ┌─────────────────────────────────────────────┐      │
│    │ {                                           │      │
│    │   "action": "send",                         │      │
│    │   "reasoning": "Balance 0.059 > 0.01...",   │      │
│    │   "confidence": 0.99,                       │      │
│    │   "risk_assessment": "low",                 │      │
│    │   "params": {                               │      │
│    │     "to": "0x6460...E9c9",                  │      │
│    │     "value_celo": "0.001"                   │      │
│    │   }                                         │      │
│    │ }                                           │      │
│    └─────────────────────────────────────────────┘      │
└───────────────────────┬─────────────────────────────────┘
                        ▼
┌─────────────────────────────────────────────────────────┐
│ 4. EXECUTE VIA CONTEXT WALLET                           │
│                                                         │
│    context.execute(owner, 0.001 ether, 0x)             │
│                                                         │
│    Contract enforces:                                   │
│    ✓ value ≤ 1 CELO (spending limit)                   │
│    ✓ daily total ≤ 5 CELO                              │
│    ✓ caller = delegate (AgentMotus)                    │
│    ✓ TTL not expired                                   │
│                                                         │
│    TX: 0xc058d3...6e62 ✅                              │
└───────────────────────┬─────────────────────────────────┘
                        ▼
┌─────────────────────────────────────────────────────────┐
│ 5. LOG EXECUTION (agent_log.json)                       │
│                                                         │
│    Verifiable receipt with:                             │
│    - Venice model + decision                           │
│    - On-chain tx hash                                  │
│    - Balances before/after                             │
│    - Timestamp                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 🏗️ Architecture

### Contract Stack

```
┌──────────────────────────────────────────────────┐
│                  PrismFactory                     │
│  ┌────────────────────────────────────────────┐  │
│  │  createContext(config, salt) → wallet addr │  │
│  │  createContextAndRegister() → wallet + 8004│  │
│  │  Deterministic via CREATE2                 │  │
│  └────────────────────────────────────────────┘  │
│                      │                            │
│           creates    │    registers                │
│                      ▼                            │
│  ┌────────────────────────┐  ┌────────────────┐  │
│  │    PrismContext        │  │ PrismRegistry  │  │
│  │    (Smart Wallet)      │  │  (ERC-8004)    │  │
│  │                        │  │                │  │
│  │  • execute(to,val,data)│  │  • register()  │  │
│  │  • spending limits     │  │  • feedback()  │  │
│  │  • daily caps          │  │  • reputation  │  │
│  │  • allowlist           │  │  • ERC-721 NFT │  │
│  │  • TTL expiry          │  │                │  │
│  │  • revoke()            │  │                │  │
│  └────────────────────────┘  └────────────────┘  │
│                                                   │
│  ┌────────────────────────────────────────────┐  │
│  │           PrismPaymaster                   │  │
│  │  Sponsors gas for context wallets          │  │
│  │  Owner deposits → contexts transact free   │  │
│  └────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────┘
```

### Core Contracts

#### PrismFactory
Derives deterministic context wallets from your root identity using CREATE2.

```solidity
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

#### PrismRegistry (ERC-8004)
On-chain agent identity and reputation, fully compliant with [ERC-8004](https://eips.ethereum.org/EIPS/eip-8004).

```solidity
uint256 agentId = registry.register(agentURI);
registry.submitFeedback(agentId, 5, "Excellent execution");
(uint256 score, uint256 reviews) = registry.getReputation(agentId);
```

---

## 🔐 Venice Integration — Private Cognition

Prism uses [Venice AI](https://venice.ai) for **privacy-preserving agent inference**:

```
┌─────────────────────────────────────────────┐
│           TRADITIONAL AGENT                  │
│                                              │
│  User data ──▶ Cloud LLM ──▶ Action         │
│                    │                         │
│              Data retained!                  │
│              Provider sees everything!       │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│        PRISM + VENICE AGENT                  │
│                                              │
│  On-chain data ──▶ Venice ──▶ Decision       │
│                      │                       │
│              No data retained!               │
│              Private inference!               │
│                      │                       │
│              Decision ──▶ Context wallet     │
│                          (caveats enforced)  │
└─────────────────────────────────────────────┘
```

**Run it yourself:**
```bash
./scripts/venice-agent.sh "Check balances and send 0.001 CELO to owner if balance > 0.01"
```

---

## 🏭 Namespace Factory (Roadmap)

```
┌─────────────────────────────────────────────────────────────┐
│                PRISM NAMESPACE SYSTEM                        │
│                                                              │
│  FREE TIER (subnames of prism-protocol.eth)                 │
│  ┌──────────────────────────────────────────┐               │
│  │  register("agentmotus")                  │               │
│  │  → agentmotus.prism-protocol.eth         │               │
│  │  → Context wallet + ERC-8004 + ENS name  │               │
│  │  → Cost: $0 (Celo gas only)              │               │
│  └──────────────────────────────────────────┘               │
│                                                              │
│  PAID TIER (your own namespace)                             │
│  ┌──────────────────────────────────────────┐               │
│  │  createNamespace("myproject") → ~$3      │               │
│  │  → Deploys your own subname registrar    │               │
│  │  → Give subnames to YOUR agents:         │               │
│  │    agent1.myproject.prism                │               │
│  │    agent2.myproject.prism                │               │
│  │  → Full Prism stack included             │               │
│  └──────────────────────────────────────────┘               │
└─────────────────────────────────────────────────────────────┘
```

---

## 📁 Project Structure

```
contracts/
├── PrismFactory.sol          # Context wallet factory (CREATE2)
├── PrismContext.sol           # Smart wallet with caveats
├── PrismRegistry.sol          # ERC-8004 agent identity + reputation
├── PrismPaymaster.sol         # Gas sponsorship for contexts
├── interfaces/                # Contract interfaces
└── libraries/
    └── PrismErrors.sol        # Custom errors

scripts/
└── venice-agent.sh            # Venice private inference → on-chain execution

agent/
├── agent.json                 # Protocol Labs agent manifest
├── agent_log.json             # Execution receipts with TxIDs
├── venice_execution_log.json  # Venice inference + execution log
├── registration.json          # ERC-8004 registration file
└── registration-8004scan.json # 8004scan official registration
```

---

## 🛠️ Development

### Prerequisites
- [Foundry](https://book.getfoundry.sh/getting-started/installation) (forge, cast, anvil)

### Build & Test
```bash
git clone https://github.com/AgentMotus/prism-protocol.git
cd prism-protocol
git checkout ethereum-root-identity
forge build
forge test
```

### Run Venice Agent
```bash
# Requires: Venice API key at ~/.config/secrets/venice.key
#           Agent key at ~/.config/secrets/agentmotus.key
./scripts/venice-agent.sh "Your task here"
```

---

## 🎯 Use Cases

| Use Case | How Prism Helps |
|----------|----------------|
| 🤖 **AI Agent Ops** | Scoped wallet with spending limits, not raw private keys |
| 🏭 **Agent Orchestrators** | Spawn agents, each gets own context + identity + ENS |
| 🛡️ **Wallet Protection** | Risky sites get disposable context; root never exposed |
| 🧠 **Private DeFi** | Venice inference → trade without exposing strategy |
| ⭐ **Agent Reputation** | On-chain track record via ERC-8004 |
| 🔄 **Multi-Agent Swarms** | Each agent: own context, own limits, own identity |

---

## 🏆 Synthesis Hackathon 2026

| Bounty | Prize | Integration |
|--------|-------|-------------|
| **Protocol Labs** | $16,000 | ERC-8004 identity, agent.json, agent_log.json, full autonomy loop |
| **Venice** | $11,500 | Private inference → trusted on-chain action |
| **Celo** | $5,000 | Deployed on Celo mainnet, real transactions, real utility |
| **MetaMask** | $5,000 | Delegation framework via context wallets + caveats |
| **ENS** | $1,500 | prism-protocol.eth, human-readable agent identity |
| **Self** | $1,000 | ZK-based human verification for root wallet |

**Total addressable: $40,000+**

---

## 🔗 Links

- **Live Agent:** [AgentMotus on 8004scan](https://8004scan.io/agent/3396)
- **ENS:** [prism-protocol.eth](https://app.ens.domains/prism-protocol.eth)
- **GitHub:** [AgentMotus/prism-protocol](https://github.com/AgentMotus/prism-protocol/tree/ethereum-root-identity)
- **PR:** [Motus-DAO/prism-protocol #2](https://github.com/Motus-DAO/prism-protocol/pull/2)
- **MetaMask Track Plan:** [docs/METAMASK_TRACK.md](./docs/METAMASK_TRACK.md)

---

## 📜 License

MIT

---

**Built by [MotusDAO](https://github.com/Motus-DAO) + [AgentMotus](https://github.com/AgentMotus)** ⚡

*An AI agent that built its own identity infrastructure, registered itself on-chain, and executes autonomously within human-defined boundaries.*
