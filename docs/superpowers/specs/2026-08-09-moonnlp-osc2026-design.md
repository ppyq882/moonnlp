# MoonNLP OSC2026 整改设计

## 目标

将 MoonNLP 整改为一个真实可复用的纯 MoonBit NLP 基础库：保留已有分词、DAT、HMM、TF-IDF、TextRank、摘要、相似度和朴素贝叶斯 API，在不伪造代码规模的前提下补齐可训练模型、评估、流水线、示例、基准、文档、CI 和来源合规信息。

## 当前基线

- 模块：`ppyq882/moonnlp@0.2.0`，`preferred_target = "wasm-gc"`。
- 包：`core`、`segment`、`analysis`、`cmd/main`。
- 生产 `.mbt`：15 个文件，约 3,470 行非空且非行注释代码；测试约 145 行同口径代码；词典数据单独统计，不作为逻辑代码规模。
- 本机 MoonBit `0.1.20260713` 下，`moon check/build/test --target all`、`moon fmt --check`、`moon info --target all` 已通过，四个后端测试为 16/16。
- 主要真实缺口：HMM 发射概率由固定字符类别列表初始化；摘要只有简化的词频和位置评分；公开 API 的边界和错误行为测试不足；CI 曾失败且对 `fmt/info --deny-warn` 使用了当前 CLI 不支持的参数。

## 设计原则

1. 既有公开类型、函数和默认行为保持兼容；新增能力通过新类型、构造器或方法提供。
2. HMM 的默认模型可以提供可复现的内置小语料，但算法必须真正消费训练语料生成初始、转移和发射概率，不再将预测结果编码为样例分支。
3. 所有新增算法先写失败测试；每个缺陷都保留最小回归测试。
4. 生产逻辑、测试、示例、基准、生成接口和词典数据分别计量并在 README 中说明。
5. 只使用已核实的 MoonBit API；不凭记忆添加依赖或后端特定功能。

## 架构

### `core`

保持 `Trie` 和 `DoubleArrayTrie` 作为通用索引层，新增边界安全的输入检查辅助函数和可复用的字符分类/Unicode 处理工具。DAT 的查找接口继续返回可空值，构建过程避免对内部 Map 查询使用不可恢复的 `unwrap`。

### `segment`

新增 `HMMModel` 与训练配置：

- 从带词边界的句子语料构造 B/M/E/S 状态序列。
- 使用可配置 Add-k 平滑计算初始、转移和发射 log 概率。
- 提供 `HMMSegmenter::from_model` 和 `HMMModel::train`，保留 `HMMSegmenter::new` 作为可复现默认模型入口。
- 保留字典 FMM/BMM/BiMM 和 HybridSegmenter；将非中文、空白、标点、Emoji 和 ASCII 连续串的处理统一到可测试的 Unicode token policy。
- 为 POS tagger 增加空输入、未知词和重复训练数据测试，暂不改变现有默认标签集合。

### `analysis`

新增三个相互独立的能力层：

- `sentence.mbt`：句子切分、边界保留和空输入策略。
- `metrics.mbt`：分词边界 precision/recall/F1、分类 accuracy/precision/recall/F1 及混淆矩阵。
- `pipeline.mbt`：把分词、关键词、摘要和分类组合为明确的文档分析结果，不隐藏异常输入。

重构摘要评分为可解释的 `SummaryOptions`：TF-IDF 词项权重、TextRank 句子图、位置权重、重复句抑制、最大句数和最小句长；默认选项保持当前 `extract_summary` 的返回类型和基本语义。

### `cmd`、`examples`、`benchmarks`

- 保留 `cmd/main` 的综合展示，补充可复现的参数说明或固定输入输出契约。
- 添加 `examples/train_hmm`、`examples/document_pipeline`，示范训练、评估和摘要流程。
- 添加轻量 benchmark，分别测 DAT 查找、分词、关键词提取和摘要，不把 `moon run` 启动时间冒充算法吞吐量。

## 错误处理与边界

- 空文本、空语料、负数 top-k、空类别、未知词、纯 Emoji、混合 Unicode、极长连续 ASCII 和重复文档均有测试。
- 训练配置对非法平滑参数、空标签和不一致语料返回显式错误或使用文档化默认值；不调用 `panic`。
- 评价指标在分母为零时返回文档化的零值策略，避免 NaN 传播。
- DAT 对空键、越界起点和不存在键返回空结果；构建期间的内部不变量以测试锁定。

## 测试设计

- `core`：空 Trie、重复键、Unicode 键、空前缀、越界起点、DAT 与 Trie 等价性。
- `segment`：FMM/BMM/BiMM、HMM 训练后 OOV、未知字符、Emoji、空输入、重复训练、长文本和 Hybrid 回归。
- `analysis`：TF-IDF 空文档、TextRank 单节点/无边图、摘要排序/去重、指标零分母、分类器未训练和未知类别。
- README 与 examples 中的关键代码块转换为可运行的文档测试或等价测试。
- 运行矩阵至少覆盖 wasm、wasm-gc、js、native；严格警告仅使用当前 CLI 支持的命令参数。

## 文档与合规

- README 改为可复制的克隆、`moon update`、构建、测试、CLI、Examples、API、架构、benchmark、Mooncakes、贡献和发布流程。
- 增加 `docs/architecture.md`、`docs/api.md`、`docs/acceptance-checklist.md`、`CHANGELOG.md`、`CONTRIBUTING.md`。
- 增加 `THIRD_PARTY_NOTICES.md`，只记录实际使用的词典/算法资料、来源链接、许可证、复用范围和“参考设计/复用代码”的区别；未核实的来源不写入。
- License 保持 Apache-2.0；Mooncakes 版本、GitHub/GitLink ref 和 Release 状态在发布前单独核验。

## CI 设计

GitHub 与 GitLink 使用同一质量门禁：

```text
moon version --all
moon update
moon fmt --check
moon check --deny-warn --target all
moon build --target wasm,wasm-gc,js
moon info --target all
git diff --ignore-blank-lines --exit-code
moon test --deny-warn --target wasm,wasm-gc,js
moon build --target native
moon test --deny-warn --target native
```

`moon fmt --deny-warn` 与 `moon info --deny-warn` 仅在当前工具链明确支持时使用；当前本机 CLI 不支持，因此不把它们写成必过命令。

## 非目标

- 不引入与 NLP 无关的 UI、网络服务或外部 C/JS FFI。
- 不声称拥有未经核实的语料许可证。
- 不为达到行数而复制样例、重复实现或计入生成构建产物。
- 不在本设计阶段执行 Mooncakes 发布、GitHub/GitLink 推送或 Release 创建。

