# MoonNLP architecture

MoonNLP has three public library packages and a small executable layer.

```text
core
  Trie -> DoubleArrayTrie -> Unicode predicates
segment
  dictionary/HMM/hybrid tokenizers -> POS tagging
analysis
  sentence splitter + tokens -> TF-IDF/TextRank/summary/classifier/metrics
cmd, examples, benchmarks
  public APIs only
```

`core` owns deterministic prefix data structures. `segment` uses those data structures for dictionary segmentation and supplies a trainable B/M/E/S HMM model for sequence segmentation. `analysis` composes tokenization with statistical scoring and lightweight classification; `DocumentPipeline` is the convenience boundary that returns sentences, tokens, keywords, summaries, and an optional label in one result.

The executable packages do not access private fields. They construct models and input data once, invoke public APIs, and print results. The benchmark executable uses the same boundary but is deliberately a workload smoke harness rather than a timing framework.

All library state is in memory. There is no network access, persistence layer, native FFI, background worker, or external model download in this module.
