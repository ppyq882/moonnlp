# MoonNLP API notes

## Core

`Trie` and `DoubleArrayTrie` expose insert, exact lookup, and prefix lookup. Invalid prefix offsets return no match rather than indexing outside the input.

## Segmentation

`DictSegmenter`, `HMMSegmenter`, and `HybridSegmenter` implement `Segmenter`. `HMMModel::train` accepts a non-empty array of non-empty token arrays and returns `Result`; `try_train` additionally validates positive finite smoothing. Pass the successful model to `HMMSegmenter::from_model`.

## Analysis

`DocumentPipeline::analyze(text, keyword_limit, summary_limit)` returns a `Result[DocumentAnalysis, String]`; both limits must be non-negative. `NaiveBayesClassifier::predict` returns `None` when no training class exists.

`TextSummarizer::summarize(text, max_sentences)` preserves its legacy recoverable behavior for a negative limit by returning an empty array. `SummaryOptions::new(max_sentences, min_sentence_length, position_weight, redundancy_threshold)` returns `Result` and rejects negative limits, non-finite position weights, and non-finite or out-of-range redundancy thresholds. `summarize_with_options` validates the options again at execution time.

The configurable summary combines TF-IDF, TextRank, a position bonus, and Jaccard-based redundancy suppression. A zero redundancy threshold removes only sentences with positive token overlap; selected sentences are returned in source order.
