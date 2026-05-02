---
name: grok-skill
description: This skill should be used when the user wants Codex to consult Grok for architecture review, code review, second opinions, or research, and when Grok transport must be resolved from local config or environment with an optional turinggrok fallback if the binary is installed and usable.
version: 0.2.0
date: 2026-05-02
---

# Grok + Codex 协作

把 Grok 当成 Codex 的第二意见引擎，而不是主执行器。适合架构设计、代码审查、故障判断、方案取舍、长链路分析和“先听一个外部判断再落决定”的场景。

## 什么时候触发

当用户说出下面这类意图时，优先启用本 skill：

- “让 Grok 帮我评审一下”
- “把这段代码给 Grok 看看”
- “给我一个 Grok 的第二意见”
- “用 Grok 做架构设计 / code review / 风险分析”
- “根据本机配置调用 Grok”
- “检查 `turinggrok` 是否可用，不可用就走一般途径”

## 默认原则

1. 先读配置，再发请求。
2. 把 Grok 当作补充判断，不要把它当成唯一真理。
3. 每次只问一个明确问题，避免把多个决策揉成一锅。
4. 严格保护密钥、Cookie、token、数据库密码和用户隐私。
5. 记录最终使用的 transport、base URL、模型和失败原因，方便回溯。

## 先做 transport 解析

按下面顺序判断该走哪条路：

1. 读取用户显式配置的 Grok 环境。
   - 优先 shell 环境变量
   - 再读用户本地 `.env` / 配置文件
   - 再读 `~/.codex/config.toml` 里的相关提示
2. 检查 `turinggrok` 是否真的安装在 PATH 中。
   - 只把它当作可选优化路径
   - 不要因为它不存在就中断任务
3. 优先使用用户已经配置好的 Grok 入口。
4. 如果 `turinggrok` 不可用，改走通用 `grok-cli`。
5. 如果 `grok-cli` 也不可用，退回到直接 HTTP 调用。

## 配置读取规则

优先读取这些来源：

- 当前 shell 里的 `SUBLB_API_KEY`
- 当前 shell 里的 `GROK_API_KEY`
- 当前 shell 里的 `GROK_BASE_URL`
- 当前 shell 里的 `GROK_MODEL`
- 当前 shell 里的 `GROK_CHAT_PATH`
- `~/.config/grok/env`
- `~/.grok.env`
- 其他项目里显式约定的 Grok env 文件
- `~/.codex/config.toml` 里的 Grok 相关提示

如果用户是对外公开示例或面向 SubLB 用户说明，默认优先使用：

- `SUBLB_API_KEY`
- `https://sub-lb.tap365.org/v1/chat/completions`
- `https://sub-lb.tap365.org/v1/images/generations`

如果是本机 transport / 内部兼容层，再继续沿用 `GROK_API_KEY`、`GROK_BASE_URL`、`GROK_MODEL`、`GROK_CHAT_PATH` 这套变量。

如果用户已经把 Grok 接到某个 OpenAI-compatible 网关，不要重新发明新的 key 命名；直接复用现有约定。

## 执行 Grok 前先整理输入

把输入压缩成四块：

1. 目标：这次要 Grok 判断什么。
2. 约束：时间、成本、兼容性、平台限制。
3. 证据：相关文件、日志、接口返回、diff、截图。
4. 期望输出：结论、风险、推荐路径、未确定项。

对 Grok 的问题要写得很尖：

- 架构设计：给出方案 A / B / C 的取舍
- 代码审查：指出 bug、边界条件、性能和安全风险
- 方案决策：给出推荐方案和不推荐原因
- 故障分析：拆分根因、验证步骤、下一步动作

## Grok 提问模板

使用这种结构发给 Grok：

```text
你是资深架构/代码审查助手。

目标：
<一句话说明要 Grok 判断的事情>

上下文：
<只放相关文件片段、日志、接口返回、关键 diff>

约束：
<平台、兼容性、性能、成本、上线边界>

请输出：
1. 直接结论
2. 主要风险
3. 推荐方案
4. 不确定项和需要补证的地方
```

## 调用顺序

### 1. `turinggrok` 可用时

如果用户本来就在用 `turinggrok`，并且本机确实装好了该二进制，就优先沿用它的现有配置。不要把它当作 Grok 的唯一入口，也不要强依赖它。

### 2. `turinggrok` 不可用时

切到 `grok-cli`。这是通用路径，适合直接做文本对话、架构评审和代码审查。

### 3. `grok-cli` 也不可用时

直接按用户配置的 Grok-compatible endpoint 走 HTTP。

常见请求路径是 `POST /v1/chat/completions`，但如果用户的网关约定的是别的路径，比如 `/v1/chat/complete`，就以配置为准，不要写死。

如果当前任务是在写对外文档、README、公告或用户示例，默认不要暴露内部上游域名；优先写公开入口 `https://sub-lb.tap365.org/v1/...`。

## 输出与回写

在最终答复里固定写清楚：

- 使用了哪条 Grok 路径
- 读取了哪个配置来源
- 是否命中了 `turinggrok`
- Grok 给出的关键结论
- 最后由 Codex 做了什么整合判断

如果 Grok 调用失败，原样保留失败类型，不要把失败包装成成功：

- `turinggrok` 不存在
- `grok-cli` 不存在
- API key 缺失
- base URL 缺失
- 401 / 403 / 429 / 5xx
- 超时

## 和本 skill 一起使用的文件

- `references/transport.md`：记录 transport 解析规则和配置约定
- `scripts/resolve-grok-transport.sh`：本机检测脚本，输出推荐入口

## 记住边界

- 不要代用户抓取第三方 session、cookie、token。
- 不要把 Grok 输出当成自动正确答案。
- 不要把大段无关上下文一起喂给 Grok。
- 不要在没有配置的情况下臆造 base URL 或 key。
- 对外图片接口示例优先使用 `response_format=b64_json`，避免把底层文件域名直接暴露给用户。
