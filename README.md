# MoonNLP

MoonNLP is a pure-MoonBit library for deterministic Chinese-oriented text processing. It provides dictionary, HMM, and hybrid segmentation; Double Array Trie lookup; part-of-speech tagging; TF-IDF and TextRank keyword extraction; extractive summaries; a small Naive Bayes classifier; and analysis metrics.

It is a library and a collection of executable demonstrations. It is not a hosted service, a general-purpose model, a production-quality linguistic corpus, or a guarantee of linguistic accuracy for every language and domain.

## Clone, build, and test

Run these commands from a PowerShell terminal. They are the project-local workflow; they do not publish anything or contact a registry.

```powershell
git clone https://github.com/ppyq882/moonnlp.git
cd moonnlp
moon version
moon fmt --check
moon check --deny-warn --target all
moon build --target all
moon test --deny-warn --target all
moon info --target all
```

The local acceptance wrapper is also available:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/verify_acceptance.ps1 -SkipUpdate
```

The current toolchain in this worktree is `moon 0.1.20260713` with `moonc v0.10.4`. Its `moon fmt` and `moon info` commands do not support `--deny-warn`; the wrapper uses `moon fmt --check`, `moon info --target all`, and a generated-interface diff check instead. Use newer compatible stable toolchains when their documented flags differ.

## Quick start

The executable is intentionally a deterministic no-argument demo. It does not pretend to support flags that this project has not implemented.

```powershell
moon run cmd/main
```

It prints sentence and token counts plus real keyword, summary, and optional classification output from `DocumentPipeline`.

### Segmentation and HMM training

要复制下面的库代码，请在模块目录下创建一个包，例如 `examples/my_demo/`。
最小 `moon.pkg` 配置为：

```json
import {
  "ppyq882/moonnlp/segment",
  "ppyq882/moonnlp/analysis",
}
```

将代码保存为同目录的 `main.mbt`，然后从仓库根目录运行
`moon run examples/my_demo`。仓库中的 `examples/train_hmm` 和
`examples/document_pipeline` 是同样方式组织的完整可运行版本。

```moonbit
let corpus = [["南京", "长江", "大桥"], ["南京", "长江"]]
match @segment.HMMModel::train(corpus) {
  Ok(model) => {
    let segmenter = @segment.HMMSegmenter::from_model(model)
    println(segmenter.segment("南京长江大桥"))
  }
  Err(message) => println(message)
}
```

Run the corresponding example from the repository root:

```powershell
moon run examples/train_hmm
```

上面的片段需要在 `moon.pkg` 中同时声明 `segment`；文档管线片段还需要
`analysis`。完整可复制版本见 `examples/document_pipeline/main.mbt`。

### Document analysis

```moonbit
let classifier = @analysis.NaiveBayesClassifier::new()
classifier.train("technology", ["MoonBit", "自然语言处理"])
let pipeline = @analysis.DocumentPipeline::with_classifier(classifier)
match pipeline.analyze("MoonBit 支持自然语言处理。", 3, 1) {
  Ok(result) => println(result.summary)
  Err(message) => println(message)
}
```

The complete executable version trains a small classifier and prints sentence and token counts, keywords, summary, and classification:

```powershell
moon run examples/document_pipeline
```

## Public API and architecture

Packages are local to this module and imported as `@core`, `@segment`, and `@analysis` in the examples above. The public interfaces are generated in each package's `pkg.generated.mbti` file after `moon info`.

- `core`: `Trie` and `DoubleArrayTrie` plus Unicode character predicates.
- `segment`: dictionary segmentation, trainable `HMMModel`, `HMMSegmenter`, `HybridSegmenter`, and `POSTagger`.
- `analysis`: keyword extraction, summary APIs, document pipeline, classifier, similarity, sentence splitting, and metrics.

See [architecture](docs/architecture.md) for data flow and [API notes](docs/api.md) for behavior and error boundaries.

## Benchmark scope

```powershell
moon run benchmarks
```

`benchmarks` is a deterministic workload smoke harness: it repeats DAT lookup, segmentation, keyword extraction, and summary with models and input data built outside the workload loop. The available portable API in this project does not provide a monotonic timer, so it reports iterations and a checksum only. It is not a performance measurement and does not support a speed claim.

## Mooncakes status

`moon.mod` declares the local module version as `0.2.0`. This worktree does not verify that a `ppyq882/moonnlp` package has been published to Mooncakes, so no registry installation command is claimed to work. Until a maintainer verifies a published package and version through an authorized release process, use a clone of this repository and its local module packages. Do not infer registry publication from the version field.

## Development, contribution, and release

Read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a change. It defines the required local gates, review expectations, and release authorization boundary. The local unreleased history is summarized in [CHANGELOG.md](CHANGELOG.md).

## License, references, and acknowledgement

MoonNLP is licensed under [Apache-2.0](LICENSE). Algorithmic references and the evidence limits around the bundled lexicon are in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md). Those references describe algorithms or provenance questions; they do not claim copied third-party code.

## Known boundaries

- Segmentation, tagging, and summary quality depend on the small included data and deterministic algorithms; evaluate them against your domain before use.
- `HMMModel` is trained from tokenized input, not a pre-trained corpus service.
- `NaiveBayesClassifier` is a small in-memory classifier and has no persistence or probability-calibration API.
- The CLI is a demo, not a safe argument-parsing interface.
