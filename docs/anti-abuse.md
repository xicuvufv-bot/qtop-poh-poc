# qtop PoH-lite — Threat model & failure modes

The point of PoH-lite is *a fence*, not a fortress. qtop is an HPC
monitoring tool; the realistic adversary is a person (or a bot herd)
who wants attention, merge speed, or a payout without doing real work.
State that honestly up front: any PoH scheme based on a YAML registry is
a *weak* proof. It is only meant to raise the cost of faking, and to
make maintainers' lives easier, not to be a biometric KYC system.

## Adversaries considered

| Threat                          | Where PoH-lite pushes back                              |
|---------------------------------|---------------------------------------------------------|
| Bot auto-opens spam PRs         | Signed-commit requirement + GitHub `verified` check     |
| Sock puppets: many fake handles | `gpg_key_id`/`ssh_fingerprint` reused? CI flags         |
| Claiming a dead person's email  | Nonce expires in 72 h; only the mailbox owner can echo  |
| Bulk YAML farming               | Uniqueness of handle+github; max one pending nonce/PR   |
| Identity reuse across projects  | Row includes per-project nonce; optional cross-refs     |
| Dishonest maintainer           | Content is public; anyone can diff registry history     |

## Failure modes & mitigations

1. **Email is transient or shared**
   – Accept a pull request verification as "moderate confidence";
   require `vouched_by` for collisions, or escalate to live-call PoH.

2. **CI can't read the GitHub API (local-only runs)**
   – `verify-poh.sh` degrades to schema + YAML checks and prints a
   warning when the GitHub API is unreachable; merge policy stays
   manual in that case.

3. **Nonce lost/expired**
   – A new PR simply re-issues a fresh nonce; no data is lost.

4. **A verified human goes rogue**
   – The registry is version-controlled: a revert PR removes the row,
   and past `vouched_by` links are re-evaluated.

5. **Bot learns to sign commits**
   – Signing keys are expensive to farm per-identity; the nonce still
   requires the mailbox. If needed, raise to live-call PoH.

## Explicit non-goals

- No KYC, no ID documents, no national IDs (the project explicitly
  forbids personal-document exchange in `CONTRIBUTING.md`).
- No monetary stake (keeps it welcoming, no token purchase needed).
- No cross-project global identity system — only the qtop pool.