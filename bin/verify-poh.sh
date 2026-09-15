#!/usr/bin/env bash
# qtop PoH-lite — registry & PR validator.
# POSIX sh + awk/grep. No YAML parser or Python dependency.
#   --members FILE  (default: members.yaml)
#   --schema  FILE  (default: schema.yaml)
# Set env PR_AUTHOR to the PR author's GitHub handle for extra checks.
# When GITHUB_TOKEN is set the CI job verifies the HEAD commit signature.
set -u

MEMBERS="${MEMBERS:-members.yaml}"
SCHEMA="${SCHEMA:-schema.yaml}"
AUTHOR="${PR_AUTHOR:-}"
FAIL=0

say()  { echo "poh-check: $*"; }
fail() { say "FAIL: $*"; FAIL=1; }

[ -f "$MEMBERS" ] || { fail "members file not found: $MEMBERS"; }
[ -f "$SCHEMA" ]  || { fail "schema file not found: $SCHEMA"; }

# ——— 1. Basic structure ——————————————————————————————————————
if ! grep -q 'handle:' "$MEMBERS"; then
  fail "no 'handle' field found in $MEMBERS"
elif ! grep -q 'github:' "$MEMBERS"; then
  fail "no 'github' field found in $MEMBERS"
fi

# ——— 2. Uniqueness ———————————————————————————————————————————
_extract() { awk '/handle:/{ for(i=1;i<=NF;i++) if ($i=="handle:") print $(i+1) }' "$1"; }
_extract_gh() { awk '/github:/{ for(i=1;i<=NF;i++) if ($i=="github:") print $(i+1) }' "$1"; }

_dupes=$(_extract "$MEMBERS" | sort | uniq -d)
if [ -n "$_dupes" ]; then
  fail "duplicate handles found: $_dupes"
fi

_dupes_gh=$(_extract_gh "$MEMBERS" | sort | uniq -d)
if [ -n "$_dupes_gh" ]; then
  fail "duplicate github handles found: $_dupes_gh"
fi

# ——— 3. Required claim columns —————————————————————————————————
for field in github email orcid keybase matrix; do
  if ! grep -q "${field}:" "$MEMBERS"; then
    fail "missing required column in $MEMBERS: $field"
  fi
done

# ——— 4. Email shape ———————————————————————————————————————————
emails=$(
  awk '/email:/{ for(i=1;i<=NF;i++) if ($i=="email:") print $(i+1) }' "$MEMBERS"
)
for e in $emails; do
  if ! echo "$e" | grep -qE '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$'; then
    fail "bad email format: $e"
  fi
done

# ——— 5. PR author info ———————————————————————————————————————
if [ -n "$AUTHOR" ]; then
  if grep -q "github:.*${AUTHOR}" "$MEMBERS"; then
    say "$AUTHOR is already in the PoH registry (looks like a renewal)."
  else
    say "$AUTHOR is not in the registry — this is an enrolment PR."
  fi
fi

# ——— 6. GitHub HEAD commit verification (CI only) ——————————————————
if [ -n "${GITHUB_TOKEN:-}" ] && [ -n "${GITHUB_REPOSITORY:-}" ] && [ -n "${GITHUB_HEAD_SHA:-}" ]; then
  v="$(curl -sf \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/$GITHUB_REPOSITORY/commits/$GITHUB_HEAD_SHA" \
      | awk -F\" '/"verified"/{print $4; exit}')" || v=""
  if [ "$v" = "true" ]; then
    say "HEAD commit ($GITHUB_HEAD_SHA) is GitHub-verified ✓"
  else
    fail "HEAD commit is NOT GitHub-verified (verification=$v). Signed commits only."
  fi
fi

# ——— Summary ——————————————————————————————————————————————————
if [ "$FAIL" -eq 1 ]; then
  say "PoH checks FAILED"
  exit 1
fi
say "PoH checks PASSED"
exit 0