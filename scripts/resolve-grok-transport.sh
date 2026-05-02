#!/usr/bin/env bash
set -euo pipefail

say() {
  printf '%s\n' "$*"
}

mask() {
  local v="${1:-}"
  if [[ -z "$v" ]]; then
    say "unset"
    return
  fi
  if (( ${#v} <= 8 )); then
    say "***"
    return
  fi
  printf '%s***%s\n' "${v:0:4}" "${v: -4}"
}

load_env_file() {
  local f="$1"
  if [[ -f "$f" ]]; then
    # shellcheck disable=SC1090
    set -a
    . "$f"
    set +a
    return 0
  fi
  return 1
}

normalize_public_env() {
  if [[ -n "${SUBLB_API_KEY:-}" && -z "${GROK_API_KEY:-}" ]]; then
    GROK_API_KEY="${SUBLB_API_KEY}"
  fi
  if [[ -z "${GROK_BASE_URL:-}" ]]; then
    GROK_BASE_URL="https://sub-lb.tap365.org"
  fi
  if [[ -z "${GROK_MODEL:-}" ]]; then
    GROK_MODEL="grok-4.1-fast"
  fi
  if [[ -z "${GROK_CHAT_PATH:-}" ]]; then
    GROK_CHAT_PATH="/v1/chat/completions"
  fi
}

for candidate in \
  "${GROK_ENV_FILE:-}" \
  "$HOME/.config/grok/env" \
  "$HOME/.grok.env" \
  "$HOME/.codex/grok.env"
do
  [[ -n "${candidate:-}" ]] || continue
  if load_env_file "$candidate"; then
    loaded_env_file="$candidate"
    break
  fi
done

normalize_public_env

transport="direct-http"
reason="fallback"

if command -v turinggrok >/dev/null 2>&1; then
  transport="turinggrok"
  reason="binary-present"
elif command -v grok-cli >/dev/null 2>&1; then
  transport="grok-cli"
  reason="binary-present"
fi

say "transport=${transport}"
say "reason=${reason}"
say "loaded_env_file=${loaded_env_file:-unset}"
say "grok_cli=$(command -v grok-cli 2>/dev/null || true)"
say "turinggrok=$(command -v turinggrok 2>/dev/null || true)"
say "SUBLB_API_KEY=$(mask "${SUBLB_API_KEY:-}")"
say "GROK_API_KEY=$(mask "${GROK_API_KEY:-}")"
say "GROK_BASE_URL=${GROK_BASE_URL:-unset}"
say "GROK_MODEL=${GROK_MODEL:-unset}"
say "GROK_CHAT_PATH=${GROK_CHAT_PATH:-/v1/chat/completions}"
