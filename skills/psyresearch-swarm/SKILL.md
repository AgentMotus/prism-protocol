---
name: psyresearch-swarm
description: Reusable hybrid research swarm with role-based wallets, ENS identity, human approval gate, and IPFS receipts.
---

# PsyResearch Swarm Skill

## Use when
- You need multi-agent research on sensitive docs.
- You need auditable outputs with human-in-the-loop approval.
- You want to port this structure (wallet/ENS/receipts) into another project.

## Minimal setup
1. Create 4 role wallets (orchestrator/research/validator/publisher).
2. Assign ENS subdomains to each wallet.
3. (Optional strong trust) register each role on ERC-8004.
4. Create 4 session labels matching roles.
5. Keep keys outside repo.

## Role prompts
### orchestrator
"Coordinate the run. Ingest docs, assign tasks, enforce human signoff before publish, and write run metadata."

### research
"Extract hypotheses, methods, assumptions, limits, and practical implications. Output `research_draft.md`."

### validator
"Classify claims into validated/proposed, flag overclaims and safety boundaries. Output `validation_report.md`."

### publisher
"Bundle outputs + tx proofs + metadata; upload to IPFS/Filecoin; return CID; update run json."

## Artifacts contract
- `research-inputs/research_draft.md`
- `research-inputs/validation_report.md`
- `research-inputs/human_signoff.md`
- `agent/research_swarm_run.json`
- `receipts-bundle.tar.gz`

## Non-negotiables
- Human approval before publication.
- No private keys in repository.
- Explicitly track tx hashes + ENS + 8004 + CID.
