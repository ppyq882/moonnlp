# MoonNLP

MoonNLP is a pure-MoonBit library for deterministic, Chinese-oriented text processing. It provides dictionary, HMM, and hybrid segmentation; Double Array Trie lookup; part-of-speech tagging; TF-IDF and TextRank keyword extraction; extractive summaries; a small Naive Bayes classifier; and analysis metrics.

The project is a reusable library with runnable demonstrations. It is not a hosted service, a general-purpose language model, a production corpus, or a guarantee of linguistic accuracy for every language and domain.

## Scope and features

- `core`: Trie and Double Array Trie data structures with checked prefix lookup.
- `segment`: dictionary FMM/BMM/BiMM segmentation, trainable BMES HMM segmentation, hybrid segmentation, and POS tagging.
- `analysis`: sentence splitting, TF-IDF, TextRank, similarity, classification, metrics, configurable extractive summaries, and a document pipeline.
- `cmd`, `examples`, and `benchmarks`: deterministic executable demonstrations and a workload smoke harness.

## Requirements

- Git
- MoonBit toolchain with `moon` and `moonc`
- A C compiler is needed only for the native target on machines where MoonBit requires one.

The checked worktree used Moon `0.1.20260713` and Moonc `v0.10.4`. The workflow installs the current stable toolchain instead of pinning a historical installer version.

## Clone, build, and test

Run these commands from the repository root:

```powershell
git clone https://github.com/ppyq882/moonnlp.git
Set-Location moonnlp
moon version --all
moon update
moon fmt --check
moon check --deny-warn --target all
moon build --target all
moon test --deny-warn --target all
moon info --target all
```

The repository also contains a local acceptance wrapper:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/verify_acceptance.ps1 -SkipUpdate
```

`moon fmt --deny-warn` and `moon info --deny-warn` are not accepted by the checked CLI. The wrapper therefore uses `moon fmt --check`, `moon info --target all`, and a generated-interface diff check. Do not interpret the unsupported flags as passed checks.

## Quick start

The CLI demo intentionally takes no arguments and prints deterministic analysis output:

```powershell
moon run cmd/main
```

It exercises tokenization, keywords, extractive summary, and optional classification through `DocumentPipeline`.

## HMM training example

Use tokenized input to train a vocabulary-sensitive model. The default `HMMSegmenter::new()` is only a neutral BMES fallback; it does not contain a named sample lexicon. For domain quality, train a model from your own tokenized corpus and pass it to `HMMSegmenter::from_model`.

```moonbit
let corpus = [["alpha", "beta"], ["alpha", "gamma"]]
match @segment.HMMModel::train(corpus) {
  Ok(model) => {
    let segmenter = @segment.HMMSegmenter::from_model(model)
    println(segmenter.segment("alphabeta"))
  }
  Err(message) => println("HMM training error: " + message)
}
```

Run the checked executable example from the repository root:

```powershell
moon run examples/train_hmm
```

For Chinese-domain use, replace the example corpus with tokenized Unicode text from your application and validate the resulting segmentation against held-out examples.

## Document analysis example

```moonbit
let classifier = @analysis.NaiveBayesClassifier::new()
classifier.train("technology", ["MoonBit", "compiler", "tokenizer"])
let pipeline = @analysis.DocumentPipeline::with_classifier(classifier)
match pipeline.analyze("MoonBit compiler tokenizer", 3, 1) {
  Ok(result) => println(result.summary)
  Err(message) => println("analysis error: " + message)
}
```

Run the complete executable pipeline:

```powershell
moon run examples/document_pipeline
```

## Public API and architecture

Import the local packages from a package inside this module:

```json
import {
  "ppyq882/moonnlp/core",
  "ppyq882/moonnlp/segment",
  "ppyq882/moonnlp/analysis",
}
```

The generated interfaces are refreshed by `moon info --target all`.

- `core` owns checked prefix data structures and Unicode character helpers.
- `segment` consumes the shared token policy. Dictionary lookup uses the Double Array Trie; HMM training computes initial, transition, and emission probabilities with smoothing; hybrid segmentation combines dictionary and HMM paths.
- `analysis` composes tokenization with statistical scoring and classification. `DocumentPipeline` is the convenience boundary for sentences, tokens, keywords, summaries, and an optional label.

See [docs/architecture.md](docs/architecture.md) for data flow and [docs/api.md](docs/api.md) for API contracts and error boundaries.

## Benchmark scope

```powershell
moon run benchmarks
```

The benchmark is a deterministic workload smoke harness. It constructs data and models outside the loop, repeats DAT lookup, segmentation, keyword extraction, and summary work, and prints iterations plus a checksum. The portable API used here does not expose a monotonic timer, so the output is not a throughput claim.

## Mooncakes

Version `0.2.0` of `ppyq882/moonnlp` is published to Mooncakes. The package metadata is declared in `moon.mod`, and the following installation preflight successfully resolved the registry index:

```powershell
moon add ppyq882/moonnlp --dry-run
```

Install the published package in another MoonBit module with:

```powershell
moon add ppyq882/moonnlp
```

The local publish command correctly rejects a duplicate `0.2.0` upload with HTTP 409, which confirms that the version already exists. Future releases must increment the semantic version, update [CHANGELOG.md](CHANGELOG.md), run the full gates, and use an authorized maintainer account.

## CI

GitHub Actions runs on Ubuntu, macOS, and Windows. Each job installs the current stable MoonBit toolchain and runs the acceptance wrapper:

- `moon version --all`
- `moon fmt --check`
- `moon check --deny-warn --target all`
- `moon build --target wasm,wasm-gc,js`
- `moon info --target all`
- generated-interface drift check
- `moon test --deny-warn --target wasm,wasm-gc,js`
- native build and test when the runner has a C compiler

See [.github/workflows/ci.yml](.github/workflows/ci.yml) and [docs/acceptance-checklist.md](docs/acceptance-checklist.md).

## Development, contribution, and release

Read [CONTRIBUTING.md](CONTRIBUTING.md) before changing public APIs. The expected local loop is:

```powershell
moon fmt --check
moon check --deny-warn --target all
moon build --target all
moon test --deny-warn --target all
moon info --target all
git diff --check
```

Add behavior-level tests for normal paths, invalid input, errors, boundaries, regressions, examples, and important performance paths. Review generated interfaces after `moon info`. Update [CHANGELOG.md](CHANGELOG.md) for user-visible changes.

Release and Mooncakes publication require explicit maintainer authorization, a verified creator account, a release tag, and platform credentials outside source control. Ordinary pull requests must not require publication secrets.

## License, references, and acknowledgement

MoonNLP is licensed under [Apache-2.0](LICENSE). The algorithmic references, lexicon provenance limits, license scope, and acknowledgement policy are documented in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

The HMM design is informed by Rabiner's HMM tutorial, TF-IDF by Salton and Buckley, and TextRank by Mihalcea and Tarau. These are design references only; this repository does not claim copied source code. The bundled lexicon has not yet been tied to a pinned upstream snapshot, so no stronger data-license or reuse claim is made.

## Known boundaries

- Segmentation, tagging, and summary quality depend on deterministic algorithms and the included data; evaluate them against your domain.
- `HMMModel` is a trainable model API, not a pretrained language model service.
- `NaiveBayesClassifier` is a small in-memory classifier without persistence or probability calibration.
- The CLI is a deterministic demonstration, not a general-purpose argument parser.
