# Grok Skill Configuration

This repository is an independent Grok skill for Codex.

Its purpose is not to hard-bind Grok to a single wrapper, but to use Grok as a second-opinion source for Codex in tasks such as:

- architecture design
- code review
- failure analysis
- tradeoff decisions
- research and investigation

## Required environment variables

At minimum, set this one variable:

```bash
export SUBLB_API_KEY="your SubLB API key"
```

Then run a public chat smoke call:

```bash
curl -sS https://sub-lb.tap365.org/v1/chat/completions \
  -H "Authorization: Bearer $SUBLB_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "grok-4.1-fast",
    "messages": [
      {"role": "user", "content": "Reply with OK only"}
    ],
    "stream": false
  }'
```

Image generation example:

```bash
curl -sS https://sub-lb.tap365.org/v1/images/generations \
  -H "Authorization: Bearer $SUBLB_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "grok-imagine-1.0",
    "prompt": "An orange cat sitting by a cyberpunk city window, cinematic, high quality",
    "n": 1,
    "size": "1024x1024",
    "response_format": "b64_json"
  }'
```

## Recommended setup

### Option 1: temporary shell exports

```bash
export SUBLB_API_KEY="your SubLB API key"
```

Useful for ad-hoc tests.

### Option 2: a local env file

Create a local file such as `~/.config/grok/env`:

```bash
SUBLB_API_KEY=yourSubLBAPIKey
```

Then load it in your shell:

```bash
set -a
source ~/.config/grok/env
set +a
```

## Transport priority

This skill resolves Grok entry points in the following order:

1. user-provided environment variables
2. local `turinggrok` binary
3. local `grok-cli` binary
4. direct HTTP calls

If `turinggrok` is installed, it is preferred. If not, the skill falls back automatically and keeps working.

## Quick checks

See which route the current machine would take:

```bash
./scripts/resolve-grok-transport.sh
```

Run a minimal config smoke test:

```bash
./scripts/smoke-grok-config.sh
```

## Notes

- Never commit real keys to a public repository
- Never put tokens, cookies, or passwords into the skill docs
- Use the public entry `https://sub-lb.tap365.org/v1` in outward-facing docs and examples
- Prefer `response_format=b64_json` for outward-facing image examples so the backend file host is not exposed to users
- `turinggrok` is an optional preferred path, not the only supported path
