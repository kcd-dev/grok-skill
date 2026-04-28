# Grok Skill

独立的 Grok 协作 skill，给 Codex 用来做架构设计、代码审查、故障判断和第二意见。

## 入口文档

- 中文说明：[`README_ZH.md`](./README_ZH.md)
- English: [`README_EN.md`](./README_EN.md)

## 快速开始

先准备环境变量：

```bash
export GROK_API_KEY="你的 Grok API Key"
export GROK_BASE_URL="https://grok74.tap365.org/v1"
export GROK_MODEL="grok-4.1-fast"
export GROK_CHAT_PATH="/v1/chat/completions"
```

然后做一次最小自检：

```bash
./scripts/smoke-grok-config.sh
```

## 现有文件

- `SKILL.md`：Codex 触发与协作规则
- `references/transport.md`：transport 解析和配置约定
- `scripts/resolve-grok-transport.sh`：当前机器会走哪条 Grok 路径
- `scripts/smoke-grok-config.sh`：最小配置自检

## 提醒

- 不要把真实 key、token、cookie、密码写进仓库
- 如果你的网关不是 `/v1/chat/completions`，就改 `GROK_CHAT_PATH`
- 这个 skill 默认独立于 `turinggrok`，但会在本机安装且可用时优先使用它
