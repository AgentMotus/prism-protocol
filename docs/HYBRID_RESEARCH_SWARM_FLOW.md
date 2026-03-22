# Hybrid Research Swarm Flow (Human + AI) — Synthesis

## Objective
Demonstrate a **human-in-the-loop** research pipeline for sensitive academic/clinical workflows:
- private reasoning (Venice)
- agent identity (ENS + ERC-8004)
- bounded execution (context wallets + paymaster)
- verifiable receipts (onchain tx + Filecoin/IPFS bundle)

## Roles (agents)
1. **orchestrator.prism-protocol.eth**
   - Splits tasks, routes to specialist agents, enforces approvals.
2. **agentmotus.prism-protocol.eth (Research Agent)**
   - Extracts claims, methods, limitations from research inputs.
3. **validator.prism-protocol.eth (Validation Agent)**
   - Checks consistency, citation hygiene, risk statements.
4. **publisher.prism-protocol.eth (Receipt Agent)**
   - Publishes logs/receipts to IPFS/Filecoin and returns CID.

## Human Gates (mandatory)
- Gate A: Approve research scope + sensitivity level.
- Gate B: Approve synthesized findings before publication.
- Gate C: Approve final receipt bundle + CID publication.

## Execution Loop
1. Human submits research docs + objective.
2. Orchestrator creates task graph and sends to Research Agent.
3. Research Agent runs private reasoning and generates draft outputs.
4. Validation Agent reviews and returns pass/fix list.
5. Human reviews (Gate B) and signs off.
6. Publisher Agent stores receipts bundle to Filecoin/IPFS.
7. Orchestrator writes final summary + tx/CID proofs.

## What goes into receipts
- `agent.json`
- `agent_log.json`
- `research_swarm_run.json`
- `metamask_delegation_proof.json`
- `metamask_track_txs.json`
- `venice_execution_log.json`

## Blockchain touchpoints
- ENS names identify agent roles.
- ERC-8004 IDs anchor trust/reputation.
- Context wallet execution proves bounded authority.
- Revoke tx proves safety control.

## Win condition for judges
A clear, replayable timeline showing:
- who (ENS identity)
- did what (logs)
- with which permissions (delegation/caveats)
- and where proof is stored (tx hashes + CID)
