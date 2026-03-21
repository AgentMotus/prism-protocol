# One-Shot Prompt: Prism Protocol Dashboard & Landing Page

## Context
Prism Protocol is a multi-chain privacy + identity infrastructure for AI agents. It lets users derive disposable "context wallets" from their root wallet, delegate them to AI agents with granular permissions (spending limits, allowlists, TTL), and register agents on-chain via ERC-8004. Already deployed on Celo mainnet.

## Tech Stack
- Next.js 14+ (App Router)
- TypeScript
- Tailwind CSS + shadcn/ui
- wagmi v2 + viem (wallet connection)
- RainbowKit or ConnectKit (wallet UI)
- Framer Motion (animations)

## Smart Contract Addresses (Celo Mainnet - Chain ID 42220)
- PrismFactory: `0xaC39210F2dBcD120D9bCDE7DEeF04f2c30F8E24F`
- PrismRegistry: `0xEe0C5FffD437099789d4B1A67A765dA7a163Ced3`

## ABIs
Import from `out/` folder after `forge build`, or define inline:

### PrismFactory
- `createContext((string contextType, uint256 spendingLimit, uint256 dailyLimit, address[] allowlist, uint256 ttl, address delegate), uint256 salt) → address`
- `getContexts(address owner) → address[]`
- `revokeContext(address contextAddress)`
- `predictAddress(address owner, uint256 salt) → address`

### PrismContext (each context wallet)
- `execute(address to, uint256 value, bytes data) → bytes`
- `isActive() → bool`
- `owner() → address`
- `delegate() → address`
- `remainingDailyAllowance() → uint256`
- `revoke()`
- `revoked() → bool`

### PrismRegistry
- `register(string agentURI) → uint256 agentId`
- `setAgentURI(uint256 agentId, string newURI)`
- `deactivate(uint256 agentId)`
- `reactivate(uint256 agentId)`
- `submitFeedback(uint256 agentId, uint8 score, string comment)`
- `getReputation(uint256 agentId) → (uint256 totalScore, uint256 reviewCount)`
- `isActive(uint256 agentId) → bool`
- `tokenURI(uint256 agentId) → string` (ERC-721)
- `ownerOf(uint256 agentId) → address` (ERC-721)

## Pages to Build

### 1. Landing Page (`/`)
Hero section with:
- Headline: "Your wallet's invisible shield for AI agents"
- Subheadline: "Derive disposable context wallets. Delegate to agents with granular permissions. If compromised, only the context burns — not your root."
- CTA: "Launch Dashboard" → `/dashboard`
- Visual: animated diagram showing Root → Context derivation
- Stats: contracts deployed, agents registered, contexts created (read from chain)
- How it works: 3-step visual (Connect Wallet → Create Context → Delegate to Agent)
- Multi-chain badge: Solana + Celo + Ethereum

### 2. Dashboard (`/dashboard`)
Connected wallet view:
- **My Contexts**: list of context wallets with status (active/expired/revoked), delegate address, spending limits, remaining allowance, TTL countdown
- **Create Context**: form with fields: contextType (dropdown), delegate address, spending limit, daily limit, TTL, allowlist
- **Revoke Context**: one-click revoke button per context

### 3. Agent Registry (`/agents`)
- Browse registered agents (paginated, read from PrismRegistry)
- Agent cards: name, description, reputation score, owner, status
- Register new agent: form with name, description, services JSON
- Agent detail page: full registration file, reputation history, feedback form

### 4. Agent Detail (`/agents/[id]`)
- Full agent profile from registration JSON
- Reputation score + individual reviews
- Submit feedback form (1-5 stars + comment)
- Owner actions: update URI, deactivate/reactivate

## Design Direction
- Dark theme (deep navy/black backgrounds)
- Glassmorphism cards with subtle borders
- Accent: electric blue (#3B82F6) + cyan (#06B6D4)
- Monospace font for addresses/hashes
- Smooth transitions with Framer Motion
- Mobile responsive
- Professional/technical feel — this is infrastructure, not a meme coin

## Key Features
- Wallet connection (MetaMask, WalletConnect, Coinbase Wallet)
- Real-time contract reads (wagmi hooks)
- Transaction signing for create/revoke/register/feedback
- Toast notifications for tx confirmations
- Copy-to-clipboard for addresses
- Links to CeloScan for all transactions
- ENS/address resolution where possible

## File Structure
```
apps/web/
├── app/
│   ├── layout.tsx
│   ├── page.tsx              (landing)
│   ├── dashboard/
│   │   └── page.tsx
│   ├── agents/
│   │   ├── page.tsx          (browse/register)
│   │   └── [id]/
│   │       └── page.tsx      (detail)
│   └── providers.tsx         (wagmi + rainbowkit)
├── components/
│   ├── ui/                   (shadcn components)
│   ├── landing/
│   │   ├── Hero.tsx
│   │   ├── HowItWorks.tsx
│   │   └── Stats.tsx
│   ├── dashboard/
│   │   ├── ContextList.tsx
│   │   ├── CreateContextForm.tsx
│   │   └── ContextCard.tsx
│   ├── agents/
│   │   ├── AgentCard.tsx
│   │   ├── AgentList.tsx
│   │   ├── RegisterAgentForm.tsx
│   │   └── FeedbackForm.tsx
│   └── shared/
│       ├── Navbar.tsx
│       ├── Footer.tsx
│       └── AddressDisplay.tsx
├── lib/
│   ├── contracts.ts          (addresses + ABIs)
│   ├── wagmi.ts              (config)
│   └── utils.ts
├── hooks/
│   ├── useContexts.ts
│   ├── useRegistry.ts
│   └── useReputation.ts
└── public/
```

## Important
- Use Celo mainnet (chain ID 42220, RPC: https://forno.celo.org)
- All contract interactions must be real (no mocks)
- Show real on-chain data
- Handle loading/error states gracefully
- Include proper TypeScript types for all contract interactions
