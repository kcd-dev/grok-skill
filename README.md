# Grok Skill

独立的 Grok 协作 skill，给 Codex 用来做架构设计、代码审查、故障判断和第二意见。

## 入口文档

- 中文说明：[`README_ZH.md`](./README_ZH.md)
- English: [`README_EN.md`](./README_EN.md)

## 快速开始

先准备环境变量：

```bash
export SUBLB_API_KEY="你的 SubLB API Key"
```

然后直接按公开调用方式做最小自检：

```bash
curl -sS https://sub-lb.tap365.org/v1/chat/completions \
  -H "Authorization: Bearer $SUBLB_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "grok-4.1-fast",
    "messages": [
      {"role": "user", "content": "只回复 OK"}
    ],
    "stream": false
  }'
```

图片生成调用示例：

```bash
curl -sS https://sub-lb.tap365.org/v1/images/generations \
  -H "Authorization: Bearer $SUBLB_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "grok-imagine-1.0",
    "prompt": "一只橘猫坐在赛博朋克城市的窗边，电影感，高质量",
    "n": 1,
    "size": "1024x1024",
    "response_format": "b64_json"
  }'
```

## 在 Codex 中如何使用

安装到 `~/.codex/skills/grok-skill` 后，重启 Codex。后续只要任务里出现“让 Grok 评审 / 给 Grok 第二意见 / 用 Grok 做架构判断 / 检查 turinggrok 是否可用”这类意图，Codex 会按 `SKILL.md` 的规则先解析 transport，再调用 Grok。

建议按下面顺序排查和使用。

### 1. 查看当前会走哪条 transport

```bash
~/.codex/skills/grok-skill/scripts/resolve-grok-transport.sh
```

典型输出会包含：

```text
transport=turinggrok
loaded_env_file=/Users/houzi/.config/grok/env
GROK_BASE_URL=https://sub-lb.tap365.org
GROK_MODEL=grok-4.1-fast
GROK_CHAT_PATH=/v1/chat/completions
```

### 2. 做配置自检

```bash
~/.codex/skills/grok-skill/scripts/smoke-grok-config.sh
```

看到 `结果: 通过` 只表示配置完整；真正业务可用还要跑一次 chat 或 image API。

### 3. 做一次真实文本调用

```bash
curl -sS https://sub-lb.tap365.org/v1/chat/completions \
  -H "Authorization: Bearer $SUBLB_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "grok-4.1-fast",
    "messages": [
      {"role": "user", "content": "你是 Grok 第二意见助手。请只用一句话回答：Grok skill 调用成功，并说明你的用途。"}
    ],
    "stream": false
  }'
```

验收口径：

- HTTP 状态码为 `200`
- `model` 为 `grok-4.1-fast`
- `choices[0].finish_reason` 为 `stop`
- `choices[0].message.content` 有有效回答

注意：部分返回可能包含 `<think>...</think>` 段。内部排障可以保留，面向用户展示时建议在调用层过滤掉该段。

## 现有文件

- `SKILL.md`：Codex 触发与协作规则
- `references/transport.md`：transport 解析和配置约定
- `scripts/resolve-grok-transport.sh`：当前机器会走哪条 Grok 路径
- `scripts/smoke-grok-config.sh`：最小配置自检

## 提醒

- 不要把真实 key、token、cookie、密码写进仓库
- 对外文档和示例统一使用公开入口 `https://sub-lb.tap365.org/v1`
- 图片对外示例优先用 `response_format=b64_json`，避免把底层文件域名直接暴露给用户
- 这个 skill 默认独立于 `turinggrok`，但会在本机安装且可用时优先使用它
