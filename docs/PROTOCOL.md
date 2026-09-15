# qtop PoH-lite — Protocol (v0.9)

This document specifies the lightweight Proof-of-Humanity flow that the
PoC implements. It is intentionally small: the whole registration is
done with `git`, a mailbox, and two shell scripts. No external PoH
service is required.

## 1. Goal

- **Lighter** than Keybase/Keyoxide: no extra accounts, ~5 minutes, no
  external dependencies at runtime.
- **More rewarding**: verified humans get a `poh ✓` badge on their PRs,
  priority triage, and a public hall-of-trust listing.
- **More engaging**: a guided PR template, one-click `Verify me`
  automation, and optional social vouching for newcomers.

## 2. Registry (members.yaml)

A single YAML file, one entry per person, with **five identity claims**
per person by default:

```
github, email, orcid, keybase, matrix
```

Optional extra anchors: `gpg_key_id`, `ssh_fingerprint`, `vouched_by`,
and `proof.*`. The field contract lives in `schema.yaml` and is enforced
in CI.

## 3. Enrolment flow

```
 contributor                     PoH repo (CI)                maintainer
     |  add row + signed commit      |                            |
     |----------------------------->| 1. schema check             |
     |                               | 2. signature check         |
     |                               | 3. uniqueness check        |
     |                               |---------------------------->|
     |                               |   nonce mailed to email     |
     |<------------------------------|----------------------------|
     | echo nonce in new signed      |                            |
     | commit ---------------------->| 4. nonce verified          |
     |                               | 5. marked verified        |
     |<-------------------------------- merged: added to pool     |
```

### 3.1 Step 1 — Register

The contributor forks the PoH repo, appends their own row to
`members.yaml`, and opens a Pull Request. The commit must be **signed**
(SSH or GPG); the PR description must include the DCO sign-off line, as
already required by qtop's `CONTRIBUTING.md`.

### 3.2 Step 2 — Static checks (CI)

`poh-check.yml` runs `verify-poh.sh` and fails the PR unless:

1. The YAML parses and obey `schema.yaml`.
2. The row's `github` matches the PR author's handle.
3. `handle` and `github` are unique in the registry.
4. Emails are well-formed and not reused across rows.
5. The **HEAD commit is verified** (GitHub API
   `commit.verification.verified == true`) — unsigned or unknown-signer
   commits are rejected automatically.

### 3.3 Step 3 — The nonce

The maintainer (or a bot) generates a one-time nonce:

```sh
bin/poh-nonce.sh new <email>          # -> POH-LITE-<uuid>
```

The nonce is mailed to the row's email address. Every branch/PR can
carry at most one outstanding nonce, and the nonce expires after 72 h.

### 3.4 Step 4 — Echo

The contributor replies in a new signed commit (or a signed tag) by
setting the value of `proof.nonce`. CI verifies the echoed value matches
the issued nonce for `<email>` and that the commit is still signed by
the same key. This step proves the person in the PR **controls the
mailbox** named in their claim.

### 3.5 Step 5 — Accept

The maintainer merges the PR once the nonce matches (or optionally skips
the nonce if the row already carries `vouched_by` from two verified
humans). The contributor is now in the PoH-verified pool. A
`poh ✓ <handle>` badge is attached to their subsequent PRs and the
project's maintainers agree to triage verified PRs first.

## 4. Rewarding, without spending a cent

- `poh ✓` badge + priority triage for verified PRs.
- Public hall-of-trust list in the registry README.
- Automatic "thank you" comment from the bot on the first verified PR.
- Contributors who vouch and keep the registry tidy are listed as
  **PoH stewards** — a small, meaningful mantle in a bot-heavy era.

## 5. Engaging, without grinding

- A `< 3 minute` guided registration template with examples.
- One-click `Verify me` (`workflow_dispatch`) that produces a printable
  "PoH receipt" (signed row + SHA-256) the contributor can post anywhere.
- Optional **live-call PoH** for anyone who wants the `human` tag in
  `CONTRIBUTING.md`: 5-minute video call, no personal documents
  exchanged — matches the project's existing `(human)` PR flag.
- Vouching keeps onboard newcomers social instead of bureaucratic.

## 6. Deliberate exclusions (anti-abuse)

- No real-money stake (keeps it welcoming, no token purchase).
- No PII beyond what contributors already publish on GitHub/Mastodon.
- No personal documents are ever requested.
- See `anti-abuse.md` for the threat model.