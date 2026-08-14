# MoonNLP OSC2026 验收收口设计

## 目标

让当前 GitHub/GitLink `main` 对应的 MoonNLP 代码、文档、生成接口和 Mooncakes 版本形成一致、可复现的验收材料，同时保留真实 Git 历史，不伪造第三方来源或贡献者。

## 方案

以当前 `main` 的 0.2.0 代码为基线，将包含 HMM 训练、可配置摘要、文档流水线和完整示例的当前仓库提升为下一个语义版本 `0.3.0`。已有 Mooncakes `0.2.0` 不覆盖、不重写；README 明确历史版本与当前版本的关系，并使用可验证的安装命令。

词典来源不具备可复核快照时，不继续声称其来自公共领域或 CC-CEDICT。源码注释与 `THIRD_PARTY_NOTICES.md` 统一为保守、可审计的表述，并明确发布前仍需补充来源清单，避免制造虚假许可证证明。

`pkg.generated.mbti` 只通过 `moon info --target all` 重新生成。若当前稳定工具链仅产生空白或接口格式变化，保留生成结果并在验证报告中记录；不手工编辑生成文件。

## 验收边界

- GitHub 历史不重写；本地整改使用 `codex/acceptance-fix` 分支。
- 不新增第三方依赖、不引入无意义代码、不改变已有公开 API 的行为契约。
- `moon fmt --deny-warn` 和 `moon info --deny-warn` 若仍被当前 CLI 拒绝，只报告为工具链能力限制。
- Mooncakes 发布、GitHub/GitLink 推送和 Release 创建只有在凭据与权限可用时执行；失败时保留本地可验证结果，不伪造发布成功。

## 验证

在干净工作树依次执行：`moon version --all`、`moon fmt --check`、`moon check --deny-warn --target all`、`moon build --target all`、`moon test --deny-warn --target all`、`moon info --target all`、`git diff --check`，并运行 CLI、HMM 示例、文档流水线、benchmark 以及独立消费者安装测试。
