# qtop PoH-lite — Generic PoC

Lightweight, git-native, mailbox-proved Proof-of-Humanity for open-source
projects. POSIX sh only; zero runtime dependencies.

**Proposed to:** [qtop/qtop issue #551](https://github.com/qtop/qtop/issues/551)
("Make the PoH process lighter, more rewarding and more engaging for PR
participants").

**PoH bounty on Opire:** $135,062.00 (as of 2026-09-10, verified via
`api.opire.dev/rewards`). Repository qtop/qtop; reward id `01M24CPAN10ENHF7NZP6D0ZDSS`.
Maintainer / point of contact: **Fotis Georgatos** (`fgeorgatos` on GitHub,
Keybase, and Matrix).

---

## What is here

| File | Purpose |
|---|---|
| `members.yaml` | Example registry (5-claim rows: github, email, orcid, keybase, matrix) |
| `schema.yaml` | Field contract for the YAML rows |
| `bin/verify-poh.sh` | Validates registry, enforces GitHub-signed HEAD commits |
| `bin/poh-nonce.sh` | Generate / verify one-time email nonces |
| `ci/poh-check.yml` | GitHub Actions workflow (needs `workflow` scope to deploy) |
| `docs/PROTOCOL.md` | Full protocol spec |
| `docs/anti-abuse.md` | Threat model and failure modes |

## Status

The proposal doc (`docs/poh-lite/PROPOSAL.md`) is on the fork branch
`poh-lite-proposal` on `xicuvufv-bot/qtop`. GitHub interaction limits
on `qtop/qtop` currently block new-contributor PRs and comments.
Submission path: Opire dashboard + maintainer contact (below).

## Next steps (for the submitter)

### 1. Claim the Opire bounty
- Log into https://opire.dev with the GitHub account `xicuvufv-bot`.
- Navigate to the qtop issue #551 bounty and **claim** it (via the
  dashboard — bot is not installed on qtop).
- Link your PR / branch URL so the reward creator can see the work.

### 2. Configure payout
- In Opire settings → connect a **Stripe account** (bank or Stripe
  if available in your region).
- Once the maintainer reviews and approves, payment is processed via
  Stripe: 100% to you, 1–7 business days.

### 3. Contact the maintainer
- **Email (no-reply, won't receive):** `fgeorgatos@users.noreply.github.com`
  (from the existing PoH registry — usable for reference only).
- **GitHub:** https://github.com/fgeorgatos
  (currently blocked for direct comment; DM via Keybase/Matrix preferred).
- **Keybase:** https://keybase.io/fgeorgatos
- **Matrix:** `@fgeorgatos:matrix.org`
- **PoC repo link (use in Opire claim message):**
  https://github.com/xicuvufv-bot/qtop-poh-poc
- **Fork + branch ready to PR:**
  https://github.com/xicuvufv-bot/qtop/tree/poh-lite-proposal

### 4. When the interaction limit lifts
```bash
gh pr create \
  --repo qtop/qtop \
  --base develop \
  --head xicuvufv-bot:poh-lite-proposal \
  --title "docs: PoH-lite — lighter, more rewarding, more engaging PoH (issue #551)" \
  --body-file pr-body.md   # see PR body template on the branch
```

### 5. (Optional) Enable CI on this PoC repo
The workflow file lives at `ci/poh-check.yml` (moved out of `.github/`
because the GitHub OAuth token lacks `workflow` scope). To deploy it:
```bash
gh auth refresh -s workflow   # one-time interactive browser auth
# then move ci/poh-check.yml → .github/workflows/poh-check.yml
```