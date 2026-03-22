#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
# Prism Protocol × Venice — Private Inference Agent Loop
# ═══════════════════════════════════════════════════════════════════
#
# Demonstrates the full Prism agent flow:
#   1. Venice private inference (decide what to do)
#   2. On-chain execution via context wallet (do it)
#   3. Log everything (prove it)
#
# Usage: ./scripts/venice-agent.sh "Check CELO price and send 0.001 to owner if above $0.50"
# ═══════════════════════════════════════════════════════════════════

set -euo pipefail

# ── Config ──────────────────────────────────────────────────────
VENICE_KEY=$(cat ~/.config/secrets/venice.key)
AGENT_KEY=$(cat ~/.config/secrets/agentmotus.key)
CONTEXT_WALLET="0x69CA5D2dD933236b77b16Dabe90144a586ee9554"
OWNER_WALLET="0x64608C2d5E4685830348e9155bAB423bf905E9c9"
AGENT_WALLET="0xd0237E6B4aA31a1740E84423ed43A84D1Cb01fd8"
CELO_RPC="https://forno.celo.org"
VENICE_MODEL="llama-3.3-70b"
LOG_FILE="agent/venice_execution_log.json"
PRISM_CONTEXT_ABI='[{"inputs":[{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"value","type":"uint256"},{"internalType":"bytes","name":"data","type":"bytes"}],"name":"execute","outputs":[{"internalType":"bytes","name":"","type":"bytes"}],"stateMutability":"nonpayable","type":"function"}]'

# ── Colors ──────────────────────────────────────────────────────
C='\033[0;36m'; G='\033[0;32m'; Y='\033[1;33m'; R='\033[0;31m'; N='\033[0m'

echo -e "${C}═══════════════════════════════════════════════════════${N}"
echo -e "${C}  Prism Protocol × Venice — Private Agent Loop${N}"
echo -e "${C}═══════════════════════════════════════════════════════${N}"

# ── Step 0: Get task ────────────────────────────────────────────
TASK="${1:-Analyze the CELO balance of the context wallet and recommend an action}"
echo -e "\n${Y}📋 Task:${N} $TASK"

# ── Step 1: Gather on-chain data ────────────────────────────────
echo -e "\n${C}🔗 Step 1: Gathering on-chain data...${N}"

CONTEXT_BAL_WEI=$(cast balance "$CONTEXT_WALLET" --rpc-url "$CELO_RPC" 2>/dev/null || echo "0")
CONTEXT_BAL=$(cast from-wei "$CONTEXT_BAL_WEI" 2>/dev/null || echo "0")
echo -e "   Context wallet balance: ${G}$CONTEXT_BAL CELO${N}"

AGENT_BAL_WEI=$(cast balance "$AGENT_WALLET" --rpc-url "$CELO_RPC" 2>/dev/null || echo "0")
AGENT_BAL=$(cast from-wei "$AGENT_BAL_WEI" 2>/dev/null || echo "0")
echo -e "   Agent wallet balance:   ${G}$AGENT_BAL CELO${N}"

OWNER_BAL_WEI=$(cast balance "$OWNER_WALLET" --rpc-url "$CELO_RPC" 2>/dev/null || echo "0")
OWNER_BAL=$(cast from-wei "$OWNER_BAL_WEI" 2>/dev/null || echo "0")
echo -e "   Owner wallet balance:   ${G}$OWNER_BAL CELO${N}"

BLOCK=$(cast block-number --rpc-url "$CELO_RPC" 2>/dev/null || echo "unknown")
echo -e "   Current block:          ${G}$BLOCK${N}"

# ── Step 2: Venice private inference ────────────────────────────
echo -e "\n${C}🧠 Step 2: Venice private inference (no data retained)...${N}"

SYSTEM_PROMPT="You are AgentMotus, an autonomous AI agent operating on Celo mainnet via Prism Protocol.
You have a context wallet with delegated permissions (max 1 CELO/tx, 5 CELO/day).
Your job: analyze the situation and decide on an action.

IMPORTANT: Respond in JSON only with this schema:
{
  \"reasoning\": \"your private analysis\",
  \"action\": \"send\" | \"hold\" | \"report\",
  \"params\": {
    \"to\": \"address or null\",
    \"value_celo\": \"amount or 0\",
    \"data\": \"0x or calldata\"
  },
  \"confidence\": 0.0-1.0,
  \"risk_assessment\": \"low|medium|high\"
}"

USER_PROMPT="Task: $TASK

On-chain state:
- Context wallet ($CONTEXT_WALLET): $CONTEXT_BAL CELO
- Agent wallet ($AGENT_WALLET): $AGENT_BAL CELO  
- Owner wallet ($OWNER_WALLET): $OWNER_BAL CELO
- Current block: $BLOCK
- Chain: Celo Mainnet (42220)
- Constraints: max 1 CELO/tx, max 5 CELO/day, 30-day TTL

Decide what action to take. Be conservative with funds."

VENICE_RESPONSE=$(curl -s \
  -H "Authorization: Bearer $VENICE_KEY" \
  -H "Content-Type: application/json" \
  -d "$(jq -n \
    --arg model "$VENICE_MODEL" \
    --arg sys "$SYSTEM_PROMPT" \
    --arg usr "$USER_PROMPT" \
    '{model: $model, messages: [{role: "system", content: $sys}, {role: "user", content: $usr}], max_tokens: 500, temperature: 0.1}')" \
  https://api.venice.ai/api/v1/chat/completions)

DECISION=$(echo "$VENICE_RESPONSE" | python3 -c "
import sys, json
r = json.load(sys.stdin)
content = r['choices'][0]['message']['content']
# Extract JSON from response
import re
match = re.search(r'\{.*\}', content, re.DOTALL)
if match:
    d = json.loads(match.group())
    print(json.dumps(d))
else:
    print(json.dumps({'action':'hold','reasoning':'Could not parse','confidence':0,'risk_assessment':'high','params':{'to':None,'value_celo':'0','data':'0x'}}))
" 2>/dev/null || echo '{"action":"hold","reasoning":"Venice parse error","confidence":0,"risk_assessment":"high","params":{"to":null,"value_celo":"0","data":"0x"}}')

ACTION=$(echo "$DECISION" | jq -r '.action')
REASONING=$(echo "$DECISION" | jq -r '.reasoning')
CONFIDENCE=$(echo "$DECISION" | jq -r '.confidence')
RISK=$(echo "$DECISION" | jq -r '.risk_assessment')

echo -e "   ${Y}Decision:${N}   $ACTION"
echo -e "   ${Y}Reasoning:${N}  $REASONING"
echo -e "   ${Y}Confidence:${N} $CONFIDENCE"
echo -e "   ${Y}Risk:${N}       $RISK"

# ── Step 3: Execute on-chain (if action = send) ────────────────
TX_HASH="none"
if [ "$ACTION" = "send" ]; then
  TO=$(echo "$DECISION" | jq -r '.params.to')
  VALUE=$(echo "$DECISION" | jq -r '.params.value_celo')
  DATA=$(echo "$DECISION" | jq -r '.params.data // "0x"')
  
  echo -e "\n${C}⚡ Step 3: Executing on-chain via context wallet...${N}"
  echo -e "   To:    $TO"
  echo -e "   Value: $VALUE CELO"
  
  VALUE_WEI=$(cast to-wei "$VALUE" 2>/dev/null || echo "0")
  
  TX_HASH=$(cast send "$CONTEXT_WALLET" \
    "execute(address,uint256,bytes)" \
    "$TO" "$VALUE_WEI" "$DATA" \
    --rpc-url "$CELO_RPC" \
    --private-key "$AGENT_KEY" \
    --json 2>/dev/null | jq -r '.transactionHash' || echo "failed")
  
  if [ "$TX_HASH" != "failed" ] && [ "$TX_HASH" != "null" ]; then
    echo -e "   ${G}✅ TX: $TX_HASH${N}"
    echo -e "   ${G}🔗 https://celoscan.io/tx/$TX_HASH${N}"
  else
    echo -e "   ${R}❌ Transaction failed${N}"
    TX_HASH="failed"
  fi
else
  echo -e "\n${C}⏸️  Step 3: No on-chain action needed (decision: $ACTION)${N}"
fi

# ── Step 4: Log everything ──────────────────────────────────────
echo -e "\n${C}📝 Step 4: Logging execution...${N}"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Append to execution log
python3 << PYEOF
import json, os

log_path = "$LOG_FILE"
entry = {
    "timestamp": "$TIMESTAMP",
    "type": "venice_inference_execution",
    "task": $(jq -n --arg t "$TASK" '$t'),
    "venice": {
        "model": "$VENICE_MODEL",
        "privacy": "no-data-retention",
        "decision": json.loads('''$DECISION''')
    },
    "onchain": {
        "chain": "celo-mainnet-42220",
        "context_wallet": "$CONTEXT_WALLET",
        "agent_wallet": "$AGENT_WALLET",
        "tx_hash": "$TX_HASH",
        "block": "$BLOCK"
    },
    "balances_before": {
        "context": "$CONTEXT_BAL",
        "agent": "$AGENT_BAL",
        "owner": "$OWNER_BAL"
    }
}

# Read existing log or create new
if os.path.exists(log_path):
    with open(log_path) as f:
        log = json.load(f)
else:
    log = {"agentName": "AgentMotus", "venice_executions": []}

if "venice_executions" not in log:
    log["venice_executions"] = []

log["venice_executions"].append(entry)

with open(log_path, 'w') as f:
    json.dump(log, f, indent=2)

print(f"   Logged to {log_path}")
PYEOF

echo -e "\n${G}═══════════════════════════════════════════════════════${N}"
echo -e "${G}  ✅ Prism × Venice execution complete${N}"
echo -e "${G}═══════════════════════════════════════════════════════${N}"
echo -e "  Agent:    AgentMotus (agentmotus.prism-protocol.eth)"
echo -e "  Inference: Venice ($VENICE_MODEL, private)"
echo -e "  Action:   $ACTION (confidence: $CONFIDENCE)"
echo -e "  TX:       $TX_HASH"
echo -e "  Log:      $LOG_FILE"
