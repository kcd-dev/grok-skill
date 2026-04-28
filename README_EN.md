# Grok Skill Configuration

This repository is an independent Grok skill for Codex.

Its purpose is not to hard-bind Grok to a single wrapper, but to use Grok as a second-opinion source for Codex in tasks such as:

- architecture design
- code review
- failure analysis
- tradeoff decisions
- research and investigation

## Required environment variables

At minimum, set these two variables:

```bash
export GROK_API_KEY="your Grok API key"
export GROK_BASE_URL="https://grok74.tap365.org/v1"
```

Recommended optional variables:

```bash
export GROK_MODEL="grok-4.1-fast"
export GROK_CHAT_PATH="/v1/chat/completions"
```

If your gateway exposes `/v1/chat/complete` instead, put that value into `GROK_CHAT_PATH`. Do not hardcode it in the skill.

## Recommended setup

### Option 1: temporary shell exports

```bash
export GROK_API_KEY="your Grok API key"
export GROK_BASE_URL="https://grok74.tap365.org/v1"
```

Useful for ad-hoc tests.

### Option 2: a local env file

Create a local file such as `~/.config/grok/env`:

```bash
GROK_API_KEY=yourGrokAPIKey
GROK_BASE_URL=https://grok74.tap365.org/v1
GROK_MODEL=grok-4.1-fast
GROK_CHAT_PATH=/v1/chat/completions
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
- If your gateway path is not `/v1/chat/completions`, adjust `GROK_CHAT_PATH`
- `turinggrok` is an optional preferred path, not the only supported path
