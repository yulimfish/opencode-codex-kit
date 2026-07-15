# opencode-codex-kit

> 把 [opencode](https://github.com/opencode-ai/opencode) 升级成 **Codex 级别** 的编码 agent：安全、记忆、纪律、UI 预览、工作流巩固 —— 全是可组合的小碎片。

一行安装脚本会拉一组精心挑选的插件 + 技能，装完之后你会得到：

- 🛡  **Guardrails 护栏** —— 硬拦 `rm -rf /`、fork bomb、`curl \| sh`；对 `git push --force`、`drop database`、`sudo` 弹提示；前端文件上自动带 UI 预览提醒。
- 🧠 **Memory 记忆** —— 通过 [`opencode-mem`](https://www.npmjs.com/package/opencode-mem) 提供的语义长时记忆，向量走本地 OpenAI 兼容 shim 转发到火山方舟 `doubao-embedding-vision-250615`（2048 维）。
- 🎯 **Discipline 纪律** —— 五条硬规则，阻止 agent 在 30 行分片重读、串行化本该并行的调用、shell 工具乱选上浪费轮次。
- 🖼  **UI-preview-first** —— 任何会移动 DOM 的改动前，先给 ASCII wireframe。
- 🌙 **Memory Dream** —— 睡眠隐喻的手动碎片巩固。
- ❓ **Clarify-before-act** —— 分支决策前一条消息拿到确认。
- 🕸  **Swarm Cluster** —— 主 Agent 遇到复杂任务时自主拆解，并行 spawn 2-4 个 subagent（可指定不同 model：kimi / deepseek / glm / minimax），最后汇总。
- 🔍 **Post-Task Audit** —— 任务完成后派出零上下文污染的 subagent 独立核查，必要时多维度并行开审（功能 / 合规 / 安全 / 意图对齐）。

## 内容清单

| 仓库 | 角色 | 安装 |
| --- | --- | --- |
| [`opencode-codex-guardrails`](https://github.com/Yulimfish/opencode-codex-guardrails) | 插件 · 安全 | `npm i opencode-codex-guardrails` |
| [`opencode-codex-doubao-shim`](https://github.com/Yulimfish/opencode-codex-doubao-shim) | 插件 · embedding 代理 | `npm i opencode-codex-doubao-shim` |
| [`opencode-skill-clarify-before-act`](https://github.com/Yulimfish/opencode-skill-clarify-before-act) | 技能 | git clone |
| [`opencode-skill-ui-preview-first`](https://github.com/Yulimfish/opencode-skill-ui-preview-first) | 技能 | git clone |
| [`opencode-skill-long-term-memory`](https://github.com/Yulimfish/opencode-skill-long-term-memory) | 技能 | git clone |
| [`opencode-skill-memory-graph-ui`](https://github.com/Yulimfish/opencode-skill-memory-graph-ui) | 技能 | git clone |
| [`opencode-skill-tool-call-discipline`](https://github.com/Yulimfish/opencode-skill-tool-call-discipline) | 技能 | git clone |
| [`opencode-skill-memory-dream`](https://github.com/Yulimfish/opencode-skill-memory-dream) | 技能 | git clone |
| [`opencode-skill-swarm-cluster`](https://github.com/Yulimfish/opencode-skill-swarm-cluster) | 技能 · 集群 | git clone |
| [`opencode-skill-post-task-audit`](https://github.com/Yulimfish/opencode-skill-post-task-audit) | 技能 · 核查 | git clone |
| [`opencode-swarm-agents`](https://github.com/Yulimfish/opencode-swarm-agents) | Agent 集 · 5 worker + 1 synth | git clone → agent/ |

## 一行安装

```bash
curl -fsSL https://raw.githubusercontent.com/Yulimfish/opencode-codex-kit/main/install.sh | bash
```

脚本会：

1. 检查前置（opencode、bun、npm）。
2. 把 8 个技能 clone 到 `~/.config/opencode/skills/`。
3. 把 opencode-swarm-agents clone 出来，把里面的 6 个 agent md 复制到 `~/.config/opencode/agent/`（装完需要重启一次 opencode 让 Task 白名单识别）。
4. 把两个插件 `npm install` 到 `~/.config/opencode/`。
5. 打印你需要粘到 `opencode.jsonc` / `opencode-mem.jsonc` 的确切片段。
6. 如果你打算用 doubao shim，提醒你设置 `ARK_KEY`。

**全流程幂等** —— 反复跑没关系。

## 手动安装

想自己一步一步来：

```bash
# 插件
npm install opencode-codex-guardrails opencode-codex-doubao-shim

# 技能
mkdir -p ~/.config/opencode/skills
for s in clarify-before-act ui-preview-first long-term-memory \
         memory-graph-ui tool-call-discipline memory-dream \
         swarm-cluster post-task-audit; do
  git clone --depth=1 "https://github.com/Yulimfish/opencode-skill-$s.git" \
    "$HOME/.config/opencode/skills/$s"
done

# Agent bundle：5 个 worker + 1 个 synth 的 md 定义（可选，供 swarm-cluster 用）
mkdir -p ~/.config/opencode/agent
git clone --depth=1 https://github.com/Yulimfish/opencode-swarm-agents.git /tmp/swarm-agents \
  && cp /tmp/swarm-agents/agent/*.md ~/.config/opencode/agent/ \
  && rm -rf /tmp/swarm-agents
```

然后编辑 `~/.config/opencode/opencode.jsonc`：

```jsonc
{
  "plugin": [
    "opencode-codex-guardrails",
    "opencode-codex-doubao-shim",
    "opencode-mem"
  ]
}
```

导出方舟 key：

```bash
export ARK_KEY="ark-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx-xxxxx"
```

去 <https://console.volcengine.com/ark> 领。shim 需要它去连 `doubao-embedding-vision-250615`。

## 一屏截图看到的东西

```
$ opencode
[codex-doubao-shim] health OK at :4748
[codex-guardrails] armed — 9 hard rules, 10 prompt rules, UI hint active
[opencode-mem] loaded 42 memories, profile v3
> 你好

Recalled 2 relevant memories （依据 memory mem_… · 2026-07-15）
…
```

试试：

```
> rm -rf ~/*
[guardrails] refused: rm -rf ~ …
```

## 设计目标

1. **可组合。** 每一块都是独立仓库，各取所需。
2. **零魔法。** ~180 行的 guardrails、~80 行的 shim、纯 markdown 的技能。装之前先读源码。
3. **可挽回。** 破坏性动作要么被拦要么弹提示，事件全部落日志。
4. **快。** 热路径没有阻塞网络调用，embedding shim 全在 localhost，技能懒加载。

## 卸载

```bash
curl -fsSL https://raw.githubusercontent.com/Yulimfish/opencode-codex-kit/main/uninstall.sh | bash
```

或者手动：`npm uninstall opencode-codex-*`，然后 `rm -rf ~/.config/opencode/skills/{clarify-before-act,ui-preview-first,long-term-memory,memory-graph-ui,tool-call-discipline,memory-dream,swarm-cluster,post-task-audit}`，再 `rm -f ~/.config/opencode/agent/swarm-*.md`。

## 许可

MIT © Yulimfish
