# Grok Skill 配置说明

这个仓库是给 Codex 使用的独立 Grok 协作 skill。

它的定位不是“把 Grok 绑死在某个 wrapper 上”，而是把 Grok 作为 Codex 的第二意见来源，用于：

- 架构设计
- 代码审查
- 故障判断
- 方案取舍
- 研究与调研

## 需要配置的环境变量

至少配置下面一个变量：

```bash
export SUBLB_API_KEY="你的 SubLB API Key"
```

然后直接做公开接口自检：

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

图片生成示例：

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

## 推荐配置方式

### 方式 1：当前 shell 临时导出

```bash
export SUBLB_API_KEY="你的 SubLB API Key"
```

适合临时测试。

### 方式 2：写入本地 env 文件

创建一个本地文件，例如 `~/.config/grok/env`：

```bash
SUBLB_API_KEY=你的SubLBAPIKey
```

然后让 shell 读取：

```bash
set -a
source ~/.config/grok/env
set +a
```

## 入口优先级

这个 skill 会按下面顺序找 Grok 入口：

1. 用户显式配置的环境变量
2. 本机是否存在 `turinggrok`
3. 本机是否存在 `grok-cli`
4. 直接 HTTP 调用

如果 `turinggrok` 存在，就优先尝试它；不存在时自动回退，不影响任务继续。

## 快速检测

运行下面脚本看当前机器会走哪条路：

```bash
./scripts/resolve-grok-transport.sh
```

运行下面脚本做最小配置自检：

```bash
./scripts/smoke-grok-config.sh
```

## 注意事项

- 不要把真实 key 写进公开仓库
- 不要把 token、cookie、密码写进 skill 文档
- 对外文档和示例统一使用公开入口 `https://sub-lb.tap365.org/v1`
- 图片对外示例优先用 `response_format=b64_json`，避免把底层文件域名直接暴露给用户
- `turinggrok` 只是优先路径，不是唯一入口
