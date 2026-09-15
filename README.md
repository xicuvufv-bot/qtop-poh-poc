# qtop PoH-lite (Proof of Humanity, lightweight)

A drop-in, dependency-light Proof-of-Humanity registry for open-source
projects. A participant proves they are a person who can be reached, in
under five minutes, using nothing but a signed git commit and a mailbox.

This repository is the **generic, reusable proof-of-concept (PoC)** for
the design proposed to the [qtop](https://github.com/qtop/qtop)
project in [issue #551](https://github.com/qtop/qtop/issues/551)
("Make the PoH process lighter, more rewarding and more engaging for PR
participants").

It deliberately has **zero runtime dependencies** (POSIX sh + git +
openssl only), as qtop is often run on early/bare HPC clusters.

---

## What it does

1. **Register** — a contributor adds a 5-claim YAML row to
   `members.yaml` in a PR (github, email, orcid, keybase, matrix).
2. **Prove** — every commit in the PR must be **signed**
   (SSH/GPG). CI rejects unsigned commits.
3. **Verify** — a maintainer (or bot) sends a one-time **email nonce**
   to the claimed address; the contributor echoes it into a signed
   commit. Whoever controls the source mailbox AND the signing key is
   granted the row.
4. **Reward** — the contributor's handle lands in the PoH-verified
   pool. A CI job marks their future PRs with a `poh ✓` badge and the
   maintainers give verified contributors **priority triage** — the
   "rewarding" part that costs the project nothing.
5. **Repeat / vouch** — trusted, already-verified humans may `vouch`
   for newcomers (`vouched_by`), which short-circuits the email step
   and keeps engagement high.

## Rationale (why "lighter" than Keybase/Keyoxide)

| Concern               | Keyoxide/Keybase route        | PoH-lite                       |
|-----------------------|-------------------------------|--------------------------------|
| Extra service account | Required (sign-up + profile)  | None (git + mailbox you own)   |
| Setup time            | 20–40 min                     | < 5 min                        |
| Identity anchor       | Platform-mediated             | Git-native signed commit + nonce |
| Bot resistance        | Account farms                 | Real signing key + mailbox     |
| Maintenance           | External service             | One YAML + one shell script    |

## Repository layout

```
├── members.yaml            # the registry (example entries)
├── schema.yaml             # field contract for the YAML rows
├── docs/
│   ├── PROTOCOL.md         # full flow, v0.9
│   └── anti-abuse.md       # threat model & failure modes
├── bin/
│   ├── poh-nonce.sh        # generate a one-time nonce
│   └── verify-poh.sh       # validate registry + PR (run from CI)
└── .github/workflows/
    └── poh-check.yml       # GitHub Action that enforces the checks
```

## Quick start (as a contributor)

```sh
git clone https://github.com/<you>/qtop-poh-poc
cd qtop-poh-poc
# 1. register (edit members.yaml, add your 5 claims)
# 2. commit signed:
git commit -S -m "poh: add <handle> to registry (DCO)"
# 3. pull request; CI checks signature + schema
# 4. reply to the nonce email by appending:
#    bin/poh-nonce.sh verify <nonce> <your-email>
#    git add members.yaml && git commit -S -m "poh: echo nonce"
```

## Locally

```sh
# validate the whole registry
./bin/verify-poh.sh --members members.yaml --schema schema.yaml
# generate a fresh nonce
./bin/poh-nonce.sh new <email>
# verify an echoed nonce
./bin/poh-nonce.sh verify <nonce> <email>
```

---

License: this PoC repo is made available under the same liberal terms as
qtop (see `LICENSE` note in PROPOSAL). AI-assisted authorship is
disclosed in the qtop pull request description per `CONTRIBUTING.md`.