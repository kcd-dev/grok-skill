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
