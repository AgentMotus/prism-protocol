# MetaMask Track — Proof Plan (Celo Mainnet)

Goal: make it crystal clear for judges that Prism uses MetaMask-style delegations with enforceable caveats.

## Demo Parameters
- Delegator (burner): `0x64608C2d5E4685830348e9155bAB423bf905E9c9`
- Delegate (agent): `0xd0237E6B4aA31a1740E84423ed43A84D1Cb01fd8`
- Chain: Celo Mainnet (42220)
- Limits: `2 CELO max/tx`, `24h TTL`

## What Judges Need to See
1. **Permission request UX (MetaMask)**
2. **Delegation created with caveats** (cap + TTL + delegate)
3. **Agent execution using delegated permissions**
4. **Revocation path**

## 5-Minute Live Checklist

### 1) Create delegation intent (human-readable)
Show this object on-screen (README/demo slide):

```json
{
  "delegate": "0xd0237E6B4aA31a1740E84423ed43A84D1Cb01fd8",
  "chainId": 42220,
  "permissions": {
    "maxValueWei": "2000000000000000000",
    "ttlSeconds": 86400,
    "allowedTargets": ["*"],
    "description": "Agent ops within 2 CELO and 24h"
  }
}
```

### 2) Execute delegated context in Prism (onchain proof)
Use existing Prism context flow (already live on Celo) and run a tx <= 2 CELO.

Example tx already proven:
- `0xc058d3e61e267c4e2779b9e0ea530f230f87e7055939b54578120add7a3b6e62`

### 3) Show enforcement
Attempt a tx that violates policy (optional) and show revert.

### 4) Revoke
Owner calls `revoke()` on context wallet and show subsequent execution fails.

## Why this qualifies for MetaMask track
- Delegator/delegate model
- Fine-grained permissions (value cap, TTL)
- Onchain enforceability via smart account logic
- Clear user authorization UX + revocation

## Evidence Bundle for Submission
- Screenshot: permission screen / delegation summary
- Tx hash: successful delegated execution
- Tx hash: revoke (optional but recommended)
- Short clip (20–30s) showing request → execute → revoke
- Link to `scripts/venice-agent.sh` and Prism contracts

### Live Proof (Celo Mainnet)
- Success execution (delegate within limits):
  - `0xd167bf08543df816c305287864f0400ce54b96331434ffb8ce137bb818fc5a0c`
- Context revoked by owner:
  - `0xec1bd5804777ca2e35769478f8430b21186c0fd1d29f1dbeaeb44525de7f2f91`
- Post-revoke execution attempt:
  - Reverted with `ContextRevoked` (expected)
- Signed EIP-712 artifact:
  - `agent/metamask_delegation_proof.json`
- Tx evidence artifact:
  - `agent/metamask_track_txs.json`
