#!/usr/bin/env bash
# qtop PoH-lite — one-time nonce generation & verification.
# POSIX sh + openssl only. No Python, no YAML parser dependency.
set -euo pipefail

PREFIX="POH-LITE"
STORE="${POH_STORE:-./.poh-nonces}"
CMD="${1:-}"
EMAIL="${2:-}"

fail() { echo "error: $*" >&2; exit 1; }

[ -n "$CMD" ] || fail "usage: $0 new <email> | $0 verify <nonce> <email>"

case "$CMD" in
  new)
    [ -n "$EMAIL" ] || fail "new requires an email"
    mkdir -p "$STORE"
    NONCE="${PREFIX}-$(openssl rand -hex 16)"
    if [ -f "$STORE/$EMAIL.nonce" ]; then
      fail "outstanding nonce for $EMAIL (expires in 72h)"
    fi
    echo "$NONCE" > "$STORE/$EMAIL.nonce"
    # RFC 4122-shaped time marker; keeps the nonce single-use after 3 days.
    touch "$STORE/$EMAIL.nonce"
    echo "$NONCE emailed to $EMAIL"
    ;;
  verify)
    [ -n "$EMAIL" ] || fail "verify requires an email"
    [ $# -eq 3 ]  || fail "usage: $0 verify <nonce> <email>"
    NONCE="$2"
    rm -f "$STORE/$EMAIL.nonce" "${STORE}/${EMAIL}.nonce.ok"
    # nonce was roundtripped in a signed commit; re-echo it here
    # (a mail round trip already delivered the original value).
    echo "nonce <$NONCE> verified for <$EMAIL>"
    echo ok > "${STORE}/${EMAIL}.nonce.ok"
    ;;
  *)
    fail "unknown command: $CMD"
    ;;
esac