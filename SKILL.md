# Prism Protocol — Agent Identity & Context Wallets on Celo

Use this skill when an agent needs to operate on-chain with scoped permissions, verifiable identity, and spending limits.

## What You Get

- **Context Wallet**: a smart wallet derived from your root, with enforced spending limits, daily caps, TTL, and instant revocation
- **ERC-8004 Identity**: on-chain agent registration with reputation tracking
- **Paymaster**: optional gas sponsorship for context wallets

## Requirements

- A **private key** with CELO balance (root wallet) — stored at a path you control
- `cast` and `forge` from [Foundry](https://book.getfoundry.sh/getting-started/installation)
- Celo Mainnet RPC: `https://forno.celo.org`

## Contract Addresses (Celo Mainnet — 42220)

```
PrismFactory V2:    0x21a7d7A3D28750961321479f57596dd58520521F
PrismRegistry:      0xEe0C5FffD437099789d4B1A67A765dA7a163Ced3
PrismPaymaster:     0x0240A986CC1CB5052547cd922ba5f9657e157A4c
8004scan Registry:  0x8004A169FB4a3325136EB29fA0ceB6D2e539a432
```

## Quick Start (4 steps)

### Step 1 — Generate Agent Wallet

Create a new wallet for the agent. This is NOT the root — it's the delegate key the agent will use.

```bash
cast wallet new --json | tee /tmp/agent-wallet.json
# Save the private key securely:
cat /tmp/agent-wallet.json | python3 -c "import sys,json; print(json.load(sys.stdin)[0]['private_key'])" > ~/.config/secrets/agent.key
chmod 600 ~/.config/secrets/agent.key
AGENT_ADDR=$(cat /tmp/agent-wallet.json | python3 -c "import sys,json; print(json.load(sys.stdin)[0]['address'])")
echo "Agent wallet: $AGENT_ADDR"
rm /tmp/agent-wallet.json
```

### Step 2 — Create Context Wallet (requires root key)

The root wallet calls PrismFactory to create a context wallet delegated to the agent.

```bash
ROOT_KEY="<your-root-private-key>"
AGENT_ADDR="<agent-wallet-from-step-1>"
RPC="https://forno.celo.org"
FACTORY="0x21a7d7A3D28750961321479f57596dd58520521F"

# Parameters (adjust to your needs):
#   spendingLimit: max CELO per transaction (in wei)
#   dailyLimit:    max CELO per 24h rolling window (in wei)
#   ttl:           seconds until context expires
#   salt:          unique bytes32 (use agent name hash)

SPENDING_LIMIT=$(cast to-wei 1)        # 1 CELO per tx
DAILY_LIMIT=$(cast to-wei 5)           # 5 CELO per day
TTL=2592000                            # 30 days
SALT=$(cast keccak "my-agent-name")

cast send "$FACTORY" \
  "createContextAndRegister(uint256,uint256,address[],uint256,address,bytes32,string)" \
  "$SPENDING_LIMIT" "$DAILY_LIMIT" "[]" "$TTL" "$AGENT_ADDR" "$SALT" \
  "data:application/json;base64,$(echo -n '{"type":"https://eips.ethereum.org/EIPS/eip-8004#registration-v1","name":"MyAgent","description":"Autonomous agent","active":true}' | base64 -w0)" \
  --rpc-url "$RPC" \
  --private-key "$ROOT_KEY" \
  --json

# The tx receipt logs contain the context wallet address.
# Find it in the logs or compute it:
CONTEXT=$(cast call "$FACTORY" \
  "getContextAddress(address,bytes32)(address)" \
  "$(cast wallet address --private-key $ROOT_KEY)" "$SALT" \
  --rpc-url "$RPC")
echo "Context wallet: $CONTEXT"
```

### Step 3 — Fund the Context Wallet

Send CELO to the context wallet so the agent can operate.

```bash
cast send "$CONTEXT" --value $(cast to-wei 0.5) \
  --rpc-url "$RPC" \
  --private-key "$ROOT_KEY"
echo "Funded context with 0.5 CELO"
```

### Step 4 — Agent Operates

The agent uses its own key to execute transactions through the context wallet. The contract enforces all limits.

```bash
AGENT_KEY=$(cat ~/.config/secrets/agent.key)
CONTEXT="<context-wallet-from-step-2>"
RPC="https://forno.celo.org"

# Send 0.001 CELO to any address:
TARGET="0xRecipientAddress"
VALUE=$(cast to-wei 0.001)

cast send "$CONTEXT" \
  "execute(address,uint256,bytes)(bytes)" \
  "$TARGET" "$VALUE" "0x" \
  --rpc-url "$RPC" \
  --private-key "$AGENT_KEY"
```

## Key Operations

### Check Balances
```bash
cast balance "$CONTEXT" --rpc-url https://forno.celo.org   # context balance
cast call "$CONTEXT" "spentToday()(uint256)" --rpc-url https://forno.celo.org  # daily spend
cast call "$CONTEXT" "config()(uint256,uint256,address[],uint256,address,uint256)" --rpc-url https://forno.celo.org  # full config
```

### Revoke Context (root only)
```bash
cast send "$CONTEXT" "revoke()" \
  --rpc-url https://forno.celo.org \
  --private-key "$ROOT_KEY"
```

### Check Agent Reputation
```bash
REGISTRY="0xEe0C5FffD437099789d4B1A67A765dA7a163Ced3"
AGENT_ID=1  # your agent's ID

cast call "$REGISTRY" "getReputation(uint256)(uint256,uint256)" "$AGENT_ID" \
  --rpc-url https://forno.celo.org
```

### Submit Feedback
```bash
cast send "$REGISTRY" \
  "submitFeedback(uint256,uint8,string)" \
  "$AGENT_ID" 5 "Task completed successfully" \
  --rpc-url https://forno.celo.org \
  --private-key "$ROOT_KEY"
```

## Venice Private Inference (Optional)

For agents that need to reason privately before executing:

```bash
# Requires Venice API key at ~/.config/secrets/venice.key
# Get one at https://venice.ai/settings/api

./scripts/venice-agent.sh "Analyze balances and recommend an action"
```

This runs: gather on-chain data → Venice inference (no data retained) → execute within caveats → log everything.

## Security Model

```
Root Wallet (YOU)
│ • Creates contexts
│ • Funds contexts  
│ • Revokes contexts
│ • Never shared with agents
│
└── Context Wallet (AGENT)
    • Operates within limits
    • Cannot exceed spending cap
    • Cannot outlive TTL
    • Cannot touch root funds
    • If compromised → revoke, root is safe
```

## Caveat Reference

| Caveat | Description | Example |
|--------|-------------|---------|
| `spendingLimit` | Max value per transaction | `1 ether` = 1 CELO/tx |
| `dailyLimit` | Max total value per 24h window | `5 ether` = 5 CELO/day |
| `allowlist` | Only these contract addresses allowed | `[0xUniswap, 0xAave]` |
| `ttl` | Context expires after this duration | `2592000` = 30 days |
| `delegate` | Only this address can call execute() | Agent wallet address |

## Links

- **Contracts**: [CeloScan](https://celoscan.io/address/0x21a7d7A3D28750961321479f57596dd58520521F)
- **Source**: [GitHub](https://github.com/AgentMotus/prism-protocol/tree/ethereum-root-identity)
- **ERC-8004**: [8004scan.io](https://8004scan.io)
- **ENS**: prism-protocol.eth
