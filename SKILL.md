---
name: prism-ethereum-root-identity
description: Install and operate Prism Protocol on the ethereum-root-identity branch for AI agents (Cursor/OpenClaw). Use when setting up agent wallets, creating bounded context wallets, registering identity (ERC-8004), assigning ENS subdomains, and running revoke-safe onchain execution on Celo.
---

# Prism Protocol Skill (Technical)

Use this to onboard any agent into Prism quickly and safely.

## Network + Contracts
- Chain: **Celo Mainnet (42220)**
- RPC: `https://forno.celo.org`
- PrismFactory V2: `0x21a7d7A3D28750961321479f57596dd58520521F`
- PrismRegistry: `0xEe0C5FffD437099789d4B1A67A765dA7a163Ced3`
- PrismPaymaster: `0x0240A986CC1CB5052547cd922ba5f9657e157A4c`
- ERC-8004 Registry: `0x8004A169FB4a3325136EB29fA0ceB6D2e539a432`

## 0) Bootstrap (Cursor/OpenClaw)
```bash
git clone https://github.com/AgentMotus/prism-protocol.git
cd prism-protocol
git checkout ethereum-root-identity

# tools
curl -L https://foundry.paradigm.xyz | bash
~/.foundry/bin/foundryup

# optional but useful
sudo apt-get update && sudo apt-get install -y jq
```

If `cast` is not in PATH, use `~/.foundry/bin/cast`.

## 1) Key Storage Rule (non-negotiable)
Never store private keys in repo files.
Use host-only location:
```bash
mkdir -p ~/.config/prism/keys
chmod 700 ~/.config/prism ~/.config/prism/keys
```

## 2) Create Agent Wallet (delegate key)
```bash
~/.foundry/bin/cast wallet new --json > ~/.config/prism/keys/agent.json
chmod 600 ~/.config/prism/keys/agent.json
```
Quick extract:
```bash
AGENT_ADDR=$(python3 - <<'PY'
import json,os
p=os.path.expanduser('~/.config/prism/keys/agent.json')
print(json.load(open(p))[0]['address'])
PY)
AGENT_KEY=$(python3 - <<'PY'
import json,os
p=os.path.expanduser('~/.config/prism/keys/agent.json')
print(json.load(open(p))[0]['private_key'])
PY)
```

## 3) Create Context Wallet from Root
Inputs required:
- `ROOT_KEY` (root wallet private key; never commit)
- `AGENT_ADDR`
- policy params (`spendingLimit`, `dailyLimit`, `ttl`, `allowlist`)

```bash
RPC=https://forno.celo.org
FACTORY=0x21a7d7A3D28750961321479f57596dd58520521F

SPENDING_LIMIT=$(~/.foundry/bin/cast to-wei 1)   # 1 CELO per tx
DAILY_LIMIT=$(~/.foundry/bin/cast to-wei 5)      # 5 CELO/day
TTL=2592000                                       # 30 days
SALT=$(~/.foundry/bin/cast keccak "agent-name-unique")

~/.foundry/bin/cast send "$FACTORY" \
  "createContextAndRegister(uint256,uint256,address[],uint256,address,bytes32,string)" \
  "$SPENDING_LIMIT" "$DAILY_LIMIT" "[]" "$TTL" "$AGENT_ADDR" "$SALT" \
  "data:application/json;base64,$(echo -n '{\"type\":\"https://eips.ethereum.org/EIPS/eip-8004#registration-v1\",\"name\":\"Agent\",\"description\":\"Prism scoped agent\",\"active\":true}' | base64 -w0)" \
  --rpc-url "$RPC" --private-key "$ROOT_KEY" --json

ROOT_ADDR=$(~/.foundry/bin/cast wallet address --private-key "$ROOT_KEY")
CONTEXT=$(~/.foundry/bin/cast call "$FACTORY" "getContextAddress(address,bytes32)(address)" "$ROOT_ADDR" "$SALT" --rpc-url "$RPC")
echo "CONTEXT=$CONTEXT"
```

## 4) Fund + Execute as Agent
```bash
# root funds context
~/.foundry/bin/cast send "$CONTEXT" --value $(~/.foundry/bin/cast to-wei 0.5) --rpc-url "$RPC" --private-key "$ROOT_KEY"

# agent executes within caveats
TARGET=0x000000000000000000000000000000000000dEaD
VALUE=$(~/.foundry/bin/cast to-wei 0.001)
~/.foundry/bin/cast send "$CONTEXT" \
  "execute(address,uint256,bytes)(bytes)" \
  "$TARGET" "$VALUE" "0x" \
  --rpc-url "$RPC" --private-key "$AGENT_KEY"
```

## 5) Revoke (root only)
```bash
~/.foundry/bin/cast send "$CONTEXT" "revoke()" --rpc-url "$RPC" --private-key "$ROOT_KEY"
```

## 6) ENS + Identity Mapping (recommended)
Assign one subdomain per role:
- `orchestrator.prism-protocol.eth`
- `agentmotus.prism-protocol.eth`
- `validator.prism-protocol.eth`
- `publisher.prism-protocol.eth`

Keep matrix in README/SUBMISSION:
- role, wallet, ENS, 8004 id, session label, tx hashes, CID.

## 7) OpenClaw Session Layout (recommended)
Create 4 isolated sessions/labels:
- `swarm-orchestrator`
- `swarm-research`
- `swarm-validator`
- `swarm-publisher`

Each session stores **only**:
- role profile (address, ENS, limits, objective)
- no private keys in workspace files.

## 8) Artifacts to produce in every run
- `research-inputs/research_draft.md`
- `research-inputs/validation_report.md`
- `research-inputs/human_signoff.md`
- `agent/research_swarm_run.json`
- `receipts-bundle.tar.gz`
- IPFS CID in run json (`ipfs_cid`)

## 9) Fast Handoff Prompt (for Cursor/OpenClaw agent)
"Use SKILL.md in this repo. Checkout branch `ethereum-root-identity`. Set up Prism context wallet flow on Celo mainnet with strict caveats, run execute+revoke proof, maintain artifacts + identity matrix, and output tx hashes + receipts CID. Never store private keys in repo."
