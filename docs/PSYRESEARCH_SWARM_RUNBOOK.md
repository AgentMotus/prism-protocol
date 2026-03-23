# PsyResearch Swarm — Runbook (Hybrid Human + AI)

## Objective
Run sensitive research workflows with:
- private inference (Venice)
- verifiable agent identity (ENS + ERC-8004)
- bounded execution (delegation + revoke)
- durable receipts (IPFS/Filecoin CID)

## Roles
1. **orchestrator**
2. **research**
3. **validator**
4. **publisher**
5. **human gate** (required)

## Identity Matrix (current)
| Role | Wallet | ENS | 8004 | Session Label |
|---|---|---|---|---|
| orchestrator | `0x64608C2d5E4685830348e9155bAB423bf905E9c9` | `orchestrator.prism-protocol.eth` | pending | `swarm-orchestrator` |
| research | `0xd0237E6B4aA31a1740E84423ed43A84D1Cb01fd8` | `agentmotus.prism-protocol.eth` | `3396` | `swarm-research` |
| validator | `0x27ec91c68A7797C774C44923681794D5Eaa94773` | `validator.prism-protocol.eth` (pending) | pending | `swarm-validator` |
| publisher | `0x1BeF0E6a26dE6EfCB6852A9dABdBa32FAB410391` | `publisher.prism-protocol.eth` (pending) | pending | `swarm-publisher` |

## Inputs
- `research-inputs/research-1.pdf`
- `research-inputs/research-2.pdf`

## Required Outputs
- `research-inputs/research_draft.md`
- `research-inputs/validation_report.md`
- `research-inputs/human_signoff.md`
- `agent/research_swarm_run.json`
- `receipts-bundle.tar.gz`

## Receipts
Current CID:
- `bafybeihg7zdj2slku6g6avfo6shte7bda6ezlgoofyn3fjpk7kyprmheey`

## Execution Flow
1. Ingest docs.
2. Research agent drafts claims/methods/limits.
3. Validator agent classifies: validated vs proposed, plus risk flags.
4. Human signs off.
5. Publisher bundles artifacts + tx evidence.
6. Upload to IPFS/Filecoin and set `ipfs_cid`.
7. (Optional) write CID to ENS text record: `receipts_cid`.

## Security Rules
- Do **not** store private keys in project repo.
- Store keys under host-only path (e.g. `~/.config/prism/keys` with `chmod 600`).
- If a key is exposed in logs/chat, rotate immediately.
- Context revocation limits delegated permissions, but does not “un-leak” a compromised base private key.

## Submission Checklist
- [ ] ENS set for validator + publisher
- [ ] 8004 registrations complete (or explicitly marked pending)
- [ ] session labels mapped to roles in README/SUBMISSION
- [ ] all tx hashes listed
- [ ] CID listed in README/SUBMISSION
- [ ] demo script (2–3 min) updated
