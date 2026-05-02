#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

say() {
  printf '%s\n' "$*"
}

fail() {
  say "失败: $*"
  exit 1
}

mask() {
  local v="${1:-}"
  if [[ -z "$v" ]]; then
    printf '%s' "unset"
    return
  fi
  if (( ${#v} <= 8 )); then
    printf '%s' "***"
    return
  fi
  printf '%s***%s' "${v:0:4}" "${v: -4}"
}

load_env_file() {
  local f="$1"
  [[ -f "$f" ]] || return 1
  # shellcheck disable=SC1090
  set -a
  . "$f"
  set +a
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

loaded_env_file=""
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

resolve_output="$("$ROOT_DIR/scripts/resolve-grok-transport.sh")"
transport=""
while IFS= read -r line; do
  case "$line" in
    transport=*)
      transport="${line#transport=}"
      break
      ;;
  esac
done <<<"$resolve_output"

say "Grok 配置自检"
say "transport=${transport:-unset}"
say "loaded_env_file=${loaded_env_file:-unset}"
say "SUBLB_API_KEY=$(mask "${SUBLB_API_KEY:-}")"
say "GROK_API_KEY=$(mask "${GROK_API_KEY:-}")"
say "GROK_BASE_URL=${GROK_BASE_URL:-unset}"
say "GROK_MODEL=${GROK_MODEL:-unset}"
say "GROK_CHAT_PATH=${GROK_CHAT_PATH:-/v1/chat/completions}"

[[ -n "${GROK_BASE_URL:-}" ]] || fail "缺少 GROK_BASE_URL"
[[ -n "${GROK_API_KEY:-}" ]] || fail "缺少 GROK_API_KEY 或 SUBLB_API_KEY"

case "$transport" in
  turinggrok|grok-cli|direct-http)
    ;;
  *)
    fail "无法识别的 transport: ${transport:-unset}"
    ;;
esac

say "结果: 通过"
