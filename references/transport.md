# Grok transport 约定

## 目标

把 Grok 的调用路径做成“可配置、可降级、可排查”的结构，而不是把调用逻辑写死在某个 wrapper 里。

## 推荐优先级

1. 用户显式配置的 Grok 入口
2. `turinggrok`（仅当本机已安装且已配置可用）
3. `grok-cli`
4. 直接 HTTP 调用

## 环境变量

如果要对外给用户示例，优先只暴露公开入口所需变量：

- `SUBLB_API_KEY`

公开示例入口：

- `https://sub-lb.tap365.org/v1/chat/completions`
- `https://sub-lb.tap365.org/v1/images/generations`

如果是内部实现或本机自定义 transport，再按实际环境补充：

- `GROK_API_KEY`
- `GROK_BASE_URL`
- `GROK_MODEL`
- `GROK_CHAT_PATH`

## 配置文件建议

优先使用一个明确的本地 env 文件，例如：

- `~/.config/grok/env`
- `~/.grok.env`

如果用户已经在 `~/.codex/config.toml` 里配置了 Grok-compatible provider，就把它当作参考信号，而不是唯一真相。

## 最小请求形态

公开聊天请求示例：

```json
{
  "model": "grok-4.1-fast",
  "messages": [
    {"role": "user", "content": "只回复 OK"}
  ],
  "stream": false
}
```

公开图片请求示例：

```json
{
  "model": "grok-imagine-1.0",
  "prompt": "一只橘猫坐在赛博朋克城市的窗边，电影感，高质量",
  "n": 1,
  "size": "1024x1024",
  "response_format": "b64_json"
}
```

如果本地工具层对字段名、路径或上游有额外约定，以内部配置为准，但不要把内部上游域名写进对外文档。对外图片示例优先使用 `b64_json`，避免默认 `url` 直接暴露底层文件域名。

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
