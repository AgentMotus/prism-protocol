# Prism Protocol — Ethereum Build Plan (Synthesis Hackathon)

## Branch: `ethereum-root-identity`

## Vision
Prism Protocol multi-chain: privacy + identity + context wallets for AI agents on EVM (Celo first, then Base/Ethereum). Solana version stays on `main`.

---

## Architecture

```
Root Wallet (EOA, e.g. 0xF632...D24)
│   Verified via Self (proof of personhood)
│
├── PrismFactory.sol
│   └── createContext(contextType, salt) → deterministic address (CREATE2)
│
├── Context A (Smart Wallet) → delegated to AgentMotus
│   ├── Spending limit: 1 CELO/day
│   ├── Allowlist: Lido, Uniswap
│   ├── TTL: 30 days
│   └── Revocable by root
│
├── Context B (Smart Wallet) → risky browsing
│   ├── Spending limit: 0.01 CELO
│   ├── TTL: 1 hour
│   └── Auto-burn
│
├── PrismRegistry.sol (ERC-8004)
│   ├── register(agentURI) → agentId (NFT)
│   ├── Reputation signals
│   └── Validation hooks
│
└── ENS (optional per context)
```

---

## Deliverables (48h)

### Block 1 (0-4h): Foundation
- [x] Clone repo, create branch
- [ ] Setup Foundry project structure
- [ ] Configure Celo testnet (Alfajores) in foundry.toml
- [ ] Create interfaces: IPrismFactory, IPrismContext, IPrismRegistry

### Block 2 (4-8h): Core Contracts
- [ ] `PrismContext.sol` — Smart wallet with caveats
  - execute(to, value, data) with permission checks
  - spending limits (per-tx, per-window)
  - allowlist (contract/function whitelist)
  - TTL (auto-expire)
  - revoke() by owner
- [ ] `PrismFactory.sol` — Context derivation
  - createContext(contextType, salt) → CREATE2 deterministic address
  - predictAddress(owner, contextType, salt) → precompute
  - getContexts(owner) → list all contexts
  - Event: ContextCreated(owner, contextAddress, contextType)

### Block 3 (8-12h): Identity Registry (ERC-8004)
- [ ] `PrismRegistry.sol` — ERC-721 + URIStorage
  - register(agentURI) → mint NFT, return agentId
  - setAgentURI(agentId, newURI) — owner only
  - getAgent(agentId) → owner, URI, active status
  - deactivate(agentId) / reactivate(agentId)
- [ ] `PrismReputation.sol` — Feedback signals
  - submitFeedback(agentId, score, comment)
  - getReputation(agentId) → aggregate score
- [ ] Registration file JSON schema + IPFS upload script

### Block 4 (12-16h): ZK Verification (Lightweight)
- [ ] Simple ZK circuit (Noir or Circom): prove "reputation > threshold" without revealing score
- [ ] Verifier contract on Celo
- [ ] Integration: agent proves reputation to access service without doxxing wallet

### Block 5 (16-20h): SDK
- [ ] `@prism-protocol/evm-sdk` (TypeScript)
  - `createContext(wallet, type, caveats)`
  - `delegateToAgent(context, agentAddress, permissions)`
  - `registerAgent(name, description, services)`
  - `proveReputation(threshold)` → ZK proof
  - `revokeContext(contextAddress)`
- [ ] CLI tool for quick operations

### Block 6 (20-24h): Demo + Deploy
- [ ] Deploy all contracts to Celo Alfajores
- [ ] Register AgentMotus on-chain (first agent!)
- [ ] End-to-end demo script:
  1. Root wallet creates context
  2. Delegates to AgentMotus with caveats
  3. AgentMotus executes tx within limits
  4. AgentMotus tries exceeding limit → blocked
  5. Root revokes context
  6. Show on 8004scan.io (if Celo supported) or custom explorer
- [ ] Record demo video (3 min)

### Block 7 (24-28h): Polish + Submission
- [ ] Update README.md (multi-chain narrative)
- [ ] Create agent.json + agent_log.json (Protocol Labs format)
- [ ] Write SUBMISSION.md for Synthesis
- [ ] Push to GitHub
- [ ] Register at synthesis.devfolio.co

---

## Contract Addresses (TBD after deploy)

| Contract | Alfajores (testnet) | Celo (mainnet) |
|----------|-------------------|----------------|
| PrismFactory | | |
| PrismContext (impl) | | |
| PrismRegistry | | |
| PrismReputation | | |
| ZKVerifier | | |

---

## Bounty Targeting

| Bounty | How we hit it | Potential |
|--------|---------------|-----------|
| Protocol Labs ($16k) | ERC-8004 registry + IPFS + agent.json/agent_log.json | ⭐⭐⭐ |
| Venice ($11.5k) | Private inference for agent decisions | ⭐⭐ |
| MetaMask ($5k) | Delegation Framework integration for caveats | ⭐⭐⭐ |
| Celo ($5k) | Deployed on Celo, mobile-first narrative | ⭐⭐⭐ |
| Self ($3k) | Root identity verified as human | ⭐⭐ |
| OpenServ ($5k) | Multi-agent orchestration demo | ⭐⭐ |
| Lido ($9.5k) | Staking use case with delegated context | ⭐⭐ |

**Total addressable: ~$54.5k**

---

## File Structure (new)

```
contracts/
├── PrismFactory.sol
├── PrismContext.sol
├── PrismRegistry.sol
├── PrismReputation.sol
├── ZKVerifier.sol
├── interfaces/
│   ├── IPrismFactory.sol
│   ├── IPrismContext.sol
│   └── IPrismRegistry.sol
└── libraries/
    └── PrismErrors.sol
script/
├── Deploy.s.sol
├── RegisterAgent.s.sol
└── CreateContext.s.sol
test/
├── PrismFactory.t.sol
├── PrismContext.t.sol
├── PrismRegistry.t.sol
└── Integration.t.sol
sdk/
├── package.json
├── src/
│   ├── index.ts
│   ├── factory.ts
│   ├── context.ts
│   ├── registry.ts
│   └── zk.ts
└── examples/
    └── register-agent.ts
agent/
├── agent.json          ← Protocol Labs format
├── agent_log.json      ← execution receipts
└── registration.json   ← ERC-8004 registration file
foundry.toml
remappings.txt
```

---

## Key Decisions
- **Celo first** (Gerry has funds), then Base/Ethereum
- **Foundry** for contracts (fast, battle-tested)
- **CREATE2** for deterministic context addresses
- **ERC-721 + URIStorage** for identity (ERC-8004 compliant)
- **Lightweight ZK** (prove threshold, not full Noir stack from Solana version)
- **Keep Solana on `main`** — multi-chain narrative strengthens product
