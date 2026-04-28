# Grok transport 约定

## 目标

把 Grok 的调用路径做成“可配置、可降级、可排查”的结构，而不是把调用逻辑写死在某个 wrapper 里。

## 推荐优先级

1. 用户显式配置的 Grok 入口
2. `turinggrok`（仅当本机已安装且已配置可用）
3. `grok-cli`
4. 直接 HTTP 调用

## 环境变量

建议至少准备这些变量：

- `GROK_API_KEY`
- `GROK_BASE_URL`
- `GROK_MODEL`
- `GROK_CHAT_PATH`

建议值：

- `GROK_BASE_URL=https://grok74.tap365.org/v1`
- `GROK_CHAT_PATH=/v1/chat/completions`

如果用户的网关或兼容层暴露的是其他路径，比如 `/v1/chat/complete`，就把它写进 `GROK_CHAT_PATH`，不要在 skill 里写死。

## 配置文件建议

优先使用一个明确的本地 env 文件，例如：

- `~/.config/grok/env`
- `~/.grok.env`

如果用户已经在 `~/.codex/config.toml` 里配置了 Grok-compatible provider，就把它当作参考信号，而不是唯一真相。

## 最小请求形态

通用 OpenAI-compatible 文本请求通常长这样：

```json
{
  "model": "grok-4.1-fast",
  "stream": false,
  "messages": [
    {"role": "system", "content": "你是资深架构审查助手。"},
    {"role": "user", "content": "请给出结论、风险和推荐方案。"}
  ]
}
```

如果本地工具层对字段名有额外约定，以该工具约定为准，不要混写。

## 失败判定

以下情况都算失败，不要假装成功：

- 只检测到 binary，但没有可用 key
- 只有 base URL，没有模型
- endpoint 返回 401 / 403 / 429 / 5xx
- 路径不匹配，返回 404
- 请求超时

## 记录方式

每次调用 Grok 后都记录三件事：

1. 入口：`turinggrok` / `grok-cli` / direct HTTP
2. 配置来源：环境变量 / env 文件 / Codex 配置
3. 结果：成功、失败、降级路径
