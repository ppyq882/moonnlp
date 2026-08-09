# MoonNLP OSC2026 整改实施计划

Goal: 将 ppyq882/moonnlp 整改为可训练、可评估、可复现的 MoonBit NLP 基础库；补齐真实功能、测试、示例、基准、合规材料和跨后端 CI，不伪造规模、发布或平台状态。

Architecture: core 负责安全索引和 Unicode 基础能力；segment 使用可训练 B/M/E/S HMMModel 与共享 token policy；analysis 增加句子、指标、可配置摘要和文档管线；cmd、examples、benchmarks 只调用公开 API。旧构造器、函数和默认行为保持兼容，新能力以新类型和 options 暴露。

Tech Stack: MoonBit 0.1.20260713（终验前重新记录 moon version --all）、wasm、wasm-gc、js、native、GitHub Actions、GitLink Actions、PowerShell。

## Global Constraints

- 不使用、记录或回显聊天中出现的密码、Token、私钥。推送、Tag、Release、Mooncakes 发布不是本计划自动动作。
- 每个功能先加入最小失败测试；每个缺陷保留回归测试。
- 不改变既有公开 API 的签名、返回类型或默认语义。若需要破坏性变更，停止并提出兼容层。
- 分开统计生产逻辑、测试、examples/benchmarks 与 segment/dict_data.mbt；不得用生成物、重复代码或词典数据凑规模。
- 当前 CLI 不支持 moon fmt --deny-warn 与 moon info --deny-warn，不能把这两个 flag 设为必过门禁。
- 第三方 notices 只能记录已核实、实际使用的资料，并明确是否复制代码。

## Task 1: 固化本地验收门禁并修复 CI

Files:
- Create: scripts/verify_acceptance.ps1
- Modify: .github/workflows/ci.yml
- Modify: README.md

Test first: 脚本必须按顺序运行如下命令，并支持 -SkipUpdate；没有该参数时先运行 moon update。

    moon fmt --check
    moon check --deny-warn --target all
    moon build --target wasm,wasm-gc,js
    moon info --target all
    git diff --ignore-blank-lines --exit-code
    moon test --deny-warn --target wasm,wasm-gc,js
    moon build --target native
    moon test --deny-warn --target native

Verify failure: powershell -ExecutionPolicy Bypass -File scripts/verify_acceptance.ps1 -SkipUpdate。预期基线因为脚本缺失而失败。

Implementation: 采用社区工作流同等的跨平台矩阵；先 moon version --all 与 moon update，再执行相同质量门禁。移除将不支持 flag 静默剥离的 shell 包装器。README 记录实际工具链版本及 flag 兼容性。

Verify: powershell -ExecutionPolicy Bypass -File scripts/verify_acceptance.ps1 -SkipUpdate 成功，并且 git diff --ignore-blank-lines --exit-code 成功。

Commit:

    git add scripts/verify_acceptance.ps1 .github/workflows/ci.yml README.md
    git commit -m "ci: add reproducible MoonBit quality gate"

## Task 2: 加固 Trie/DAT 的边界行为

Files:
- Modify: core/dat.mbt
- Modify: core/trie_test.mbt
- Create: core/dat_test.mbt

Test first: 覆盖空键、重复键、Unicode 键、缺失键、非法起点和 DAT/Trie 等价性。最小语义为：插入月亮映射 7 后，DAT 查询月亮返回 Some(7)，从越界起点查询返回 None。测试只走公开 API，不访问私有数组。

Verify failure: moon test core --target all。预期边界 API 或安全构建语义尚不存在。

Implementation: DoubleArrayTrie::build 中所有内部 Map 查询用显式 match 处理，不使用不可恢复 unwrap。空键、缺失键、越界起点返回 documented Option 或空匹配，不能 panic。

Verify: moon test core --target all；moon check --deny-warn --target all。

Commit:

    git add core/dat.mbt core/trie_test.mbt core/dat_test.mbt
    git commit -m "fix(core): make DAT boundary lookups safe"

## Task 3: 用真实训练统计替代硬编码 HMM 发射表

Files:
- Create: segment/hmm_model.mbt
- Modify: segment/hmm_segmenter.mbt
- Modify: segment/segment.mbt
- Create: segment/hmm_model_test.mbt
- Modify: segment/segment_test.mbt

Test first:
- 以 [["南京", "长江", "大桥"], ["南京", "长江"]] 训练，输入 南京长江 得到 ["南京", "长江"]。
- 空语料与非正平滑值返回 Result 错误。
- 覆盖单字、多字、重复训练、OOV、空输入以及 Hybrid 的字典优先级。

Verify failure: moon test segment --target all。预期 HMMModel 和 HMMSegmenter::from_model 尚不存在。

Implementation: 从 token 化语料构造 B/M/E/S 状态序列，统计初始、转移、发射计数，使用 Add-k 平滑计算 log 概率。增加 HMMModel::try_train、HMMModel::train 和 HMMSegmenter::from_model。HMMSegmenter::new 改为消费仓库内标注来源的确定性最小训练语料；删除 b_only/e_only/m_only/s_only 字符表决定预测的路径。

Verify: moon test segment --target all；moon check --deny-warn --target all。

Commit:

    git add segment/hmm_model.mbt segment/hmm_segmenter.mbt segment/segment.mbt segment/hmm_model_test.mbt segment/segment_test.mbt
    git commit -m "feat(segment): train and use HMM probability models"

## Task 4: 统一 Unicode token policy 和 POS 边界

Files:
- Create: segment/token_policy.mbt
- Modify: segment/dict_segmenter.mbt
- Modify: segment/hybrid_segmenter.mbt
- Modify: segment/pos_tagger.mbt
- Modify: segment/segment_test.mbt
- Create: segment/pos_tagger_test.mbt

Test first: 输入 MoonBit、emoji 与数字的混合字符串，输出三个稳定 token；并覆盖纯 Emoji、空白、连续 ASCII、中文/ASCII 混合、未知词和重复 POS 训练。

Implementation: token_policy.mbt 是唯一的字符分类与前进规则来源。字典、HMM、Hybrid 共用它，确保每轮至少前进一个字符。POS 对空输入和未知词遵循已有默认标签或 documented Option，不能 panic。

Verify: moon test segment --target all；旧中文分词快照保持不变。

Commit:

    git add segment/token_policy.mbt segment/dict_segmenter.mbt segment/hybrid_segmenter.mbt segment/pos_tagger.mbt segment/segment_test.mbt segment/pos_tagger_test.mbt
    git commit -m "feat(segment): unify Unicode token handling"

## Task 5: 新增句子、指标和文档分析管线

Files:
- Create: analysis/sentence.mbt
- Create: analysis/metrics.mbt
- Create: analysis/pipeline.mbt
- Create: analysis/sentence_test.mbt
- Create: analysis/metrics_test.mbt
- Create: analysis/pipeline_test.mbt
- Modify: analysis/analysis_test.mbt

Test first: 覆盖句末/连续标点、空输入、无末尾标点、精确/部分边界匹配、空预测、空金标、未知分类和混淆矩阵。空预测与空金标时 F1 必须按文档返回 0.0，不能传播 NaN。

Implementation: 新增 SentenceSplitter、SegmentationScore、ClassificationScore、ConfusionMatrix 和 DocumentAnalysis。DocumentPipeline 返回 tokens、keywords、summary 和可选 classification，不吞非法参数。

Verify: moon test analysis --target all；moon check --deny-warn --target all。

Commit:

    git add analysis/sentence.mbt analysis/metrics.mbt analysis/pipeline.mbt analysis/sentence_test.mbt analysis/metrics_test.mbt analysis/pipeline_test.mbt analysis/analysis_test.mbt
    git commit -m "feat(analysis): add sentence metrics and document pipeline"

## Task 6: 将摘要升级为可解释、可配置、可去重的算法

Files:
- Modify: analysis/summarizer.mbt
- Modify: analysis/summarizer_test.mbt
- Modify: analysis/tfidf.mbt
- Modify: analysis/textrank.mbt

Test first: 覆盖最大句数为零/负数、最短句长、重复句抑制、稳定排序、空文档、单节点图、无边图以及旧 extract_summary 结果。对于重复句 月亮很亮。月亮很亮。MoonBit 很快。的摘要，不能选入同一句两次。

Implementation: 保留 extract_summary 的签名与默认语义；增加 SummaryOptions 和 TextSummarizer::with_options。显式组合 TF-IDF、TextRank、位置、长度和 token-overlap/Jaccard 冗余阈值，选择后按原文位置输出。

Verify: moon test analysis --target all。

Commit:

    git add analysis/summarizer.mbt analysis/summarizer_test.mbt analysis/tfidf.mbt analysis/textrank.mbt
    git commit -m "feat(analysis): add configurable extractive summaries"

## Task 7: 添加可运行 CLI、examples、benchmark 和维护文档

Files:
- Modify: cmd/main/main.mbt
- Create: cmd/main/main_test.mbt
- Create: examples/train_hmm/main.mbt
- Create: examples/train_hmm/moon.pkg.json
- Create: examples/document_pipeline/main.mbt
- Create: examples/document_pipeline/moon.pkg.json
- Create: benchmarks/main.mbt
- Create: benchmarks/moon.pkg.json
- Modify: README.md
- Create: docs/architecture.md
- Create: docs/api.md
- Create: docs/acceptance-checklist.md
- Create: CHANGELOG.md
- Create: CONTRIBUTING.md
- Create: THIRD_PARTY_NOTICES.md
- Modify: LICENSE

Test first: 为 CLI 固定 input/output 写 smoke test；两个 examples 分别展示 HMM 训练/指标、文档管线/关键词/摘要。若稳定 MoonBit API 不支持安全参数解析，保持 deterministic 无参数 demo，并在 README 准确说明。

Implementation: benchmark 在循环外构造数据和模型，单独计时 DAT、分词、关键词和摘要，打印迭代数/单位，禁止把 moon run 启动时间称为算法吞吐。README 逐项提供用途和边界、安装、clone/update/build/test、API、CLI、examples、架构、benchmark、Mooncakes 发布前核验条件、贡献/发布、License、References/Acknowledgements。notices 只记真实来源、许可证、范围和是否复用代码。

Verify:

    moon test cmd/main --target all
    moon run examples/train_hmm
    moon run examples/document_pipeline
    moon run benchmarks
    rg -n "[T]ODO|[T]BD" README.md docs CHANGELOG.md CONTRIBUTING.md THIRD_PARTY_NOTICES.md

Commit:

    git add examples benchmarks cmd/main README.md docs CHANGELOG.md CONTRIBUTING.md THIRD_PARTY_NOTICES.md LICENSE
    git commit -m "docs: add runnable MoonNLP examples and provenance"

## Task 8: 生成接口、四后端终验和诚实规模报告

Files:
- Modify as generated: package generated interfaces only after diff review
- Modify: docs/acceptance-checklist.md

Run exactly:

    moon version --all
    moon fmt --check
    moon check --deny-warn --target all
    moon build --target wasm,wasm-gc,js
    moon info --target all
    git diff --ignore-blank-lines --exit-code
    moon test --deny-warn --target wasm,wasm-gc,js
    moon build --target native
    moon test --deny-warn --target native
    powershell -ExecutionPolicy Bypass -File scripts/verify_acceptance.ps1 -SkipUpdate

Review git diff --check and the generated interface diff. Use fixed rg/PowerShell commands to report production .mbt, tests, examples/benchmarks and dictionary data separately in the checklist. If the measured scope does not meet the target, report it as an acceptance risk rather than claiming success.

Commit:

    git add docs/acceptance-checklist.md
    git commit -m "docs: record OSC2026 local verification"

Stop condition: keep the branch local. GitHub/GitLink push, Tag/Release, and Mooncakes publication require a separate user authorization and a credential-free check of the creator account write permission and current remote/package state.
