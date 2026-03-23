# Synthesis Submission — Prism Protocol (EVM / Celo)

## One-liner
**Prism Protocol is human-rooted agent infrastructure:** one human root wallet derives bounded context wallets for multiple AI agents, each with revocable permissions, ENS identity, and verifiable onchain receipts.

---

## What We Built

### 1) Human-root security model (core)
- **Human is root authority** (`0x64608C2d5E4685830348e9155bAB423bf905E9c9`)
- Root creates/funds/revokes agent contexts
- Agents never receive root key

### 2) Agent execution model
Each agent uses:
1. **Delegate EOA** (signer)
2. **Prism Context Wallet** (smart wallet with caveats)

Context caveats:
- per-tx spending limit
- daily spending limit
- TTL expiry
- allowlist (optional)
- instant revoke

### 3) Verifiable identity layer
- ENS subdomains per role:
  - `agentmotus.prism-protocol.eth`
  - `orchestrator.prism-protocol.eth`
  - `validator.prism-protocol.eth`
  - `publisher.prism-protocol.eth`
- ERC-8004 registration live for core agent (`agentId: 3396`)

### 4) Private reasoning + public execution
- Venice used for private inference path
- Onchain action executed through bounded context wallets
- Receipts bundled and published to IPFS/Filecoin

---

## Deployed Contracts (Celo Mainnet 42220)

- PrismFactory V1: `0xaC39210F2dBcD120D9bCDE7DEeF04f2c30F8E24F`
- PrismFactory V2: `0x21a7d7A3D28750961321479f57596dd58520521F`
- PrismRegistry: `0xEe0C5FffD437099789d4B1A67A765dA7a163Ced3`
- PrismPaymaster: `0x0240A986CC1CB5052547cd922ba5f9657e157A4c`
- ERC-8004 Registry (official): `0x8004A169FB4a3325136EB29fA0ceB6D2e539a432`

---

## Evidence: Key Transactions

### Prior core proofs
- Venice execution tx: `0xc058d3e61e267c4e2779b9e0ea530f230f87e7055939b54578120add7a3b6e62`
- MetaMask delegated execute: `0xd167bf08543df816c305287864f0400ce54b96331434ffb8ce137bb818fc5a0c`
- Revoke tx: `0xec1bd5804777ca2e35769478f8430b21186c0fd1d29f1dbeaeb44525de7f2f91`

### Final multi-agent flow (validator/publisher contexts)
Stored at: `agent/final_swarm_onchain_flow.json`

- Create validator context: `0xba3c0d4fb28edd6da009b801d13021b3fbeb9b8baffd1e19db38e94049fce4a7`
- Create publisher context: `0x749e12e175c48b80b17fb0aa29a389d636389aa06e92bf2dc20be8eb98ac6b09`
- Fund validator context: `0x22f1253f762b57d063ede3ea3d0a28481e0adf9cf918d0b4200c6b4dc90333fb`
- Fund publisher context: `0x52984eba3ad47c266f3fe1c5a7a1e44ecabe1b0ad9a999ff2a49344eb4b0b732`
- Fund validator delegate gas: `0x482b47aceec3345b212a1046bdeb1e5a9ae44a7b8c00f5e1b65173138a213a5a`
- Fund publisher delegate gas: `0xeefaf4a838b283eaad5e27c980ffe9227809e5a7a48cb4a9bc0f4c29667bf3a4`
- Validator execute -> Publisher context: `0xd075c366040b124c1e4b50f0e44992eb6736cf32aab9edee6b028a43fc4519f5`
- Publisher execute -> Root: `0xc5a273e79e4cb6204a83eeade42ab0608cf93d7b5d8aae54cc470af2feb43d0a`

---

## Hybrid PsyResearch Swarm (real run)

Real documents ingested + processed:
- `research-inputs/research-1.pdf`
- `research-inputs/research-2.pdf`

Artifacts:
- `research-inputs/research_draft.md`
- `research-inputs/validation_report.md`
- `research-inputs/human_signoff.md`
- `agent/research_swarm_run.json`

Receipts bundle CID:
- `bafybeihg7zdj2slku6g6avfo6shte7bda6ezlgoofyn3fjpk7kyprmheey`
- https://w3s.link/ipfs/bafybeihg7zdj2slku6g6avfo6shte7bda6ezlgoofyn3fjpk7kyprmheey

---

## Why this matters (judge view)

Most agent wallets are either:
- too permissive (raw key risk), or
- too centralized (no per-agent boundaries).

Prism ships a practical middle layer:
- **human governance at root**,
- **agent autonomy within cryptographic boundaries**,
- **instant revocation**,
- **public verifiability through ENS + tx receipts + CID artifacts**.

---

## Reusability / Dev tooling

### Technical skill package (for other agents)
- `prism-technical.skill` (portable)
- `skills/prism-technical/SKILL.md`
- `skills/prism-technical/references/PSYRESEARCH_SWARM_RUNBOOK.md`

### Swarm skill
- `skills/psyresearch-swarm/SKILL.md`

---

## Current branch / repo
- Branch: `ethereum-root-identity`
- Fork: `https://github.com/AgentMotus/prism-protocol`
- Upstream PR: `https://github.com/Motus-DAO/prism-protocol/pull/2`

---

## Final items before Devfolio submit
- [ ] Update frontend page with final architecture + evidence links
- [ ] Record final 2–3 min demo video
- [ ] Ensure ENS text record `receipts_cid` is set
- [ ] (Optional) register validator/publisher on ERC-8004

---

## Integrity note
This submission reflects live transactions and real artifacts produced in this branch, not mock-only flows.
