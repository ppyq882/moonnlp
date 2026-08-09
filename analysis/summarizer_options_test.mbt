///|
fn assert_invalid_summary_options(
  max_sentences : Int,
  min_sentence_length : Int,
  position_weight : Double,
  redundancy_threshold : Double,
) -> Bool {
  match
    SummaryOptions::new(
      max_sentences, min_sentence_length, position_weight, redundancy_threshold,
    ) {
    Err(_) => true
    Ok(_) => false
  }
}

///|
test "summary options reject invalid limits and non-finite weights" {
  assert_true(assert_invalid_summary_options(-1, 0, 0.0, 0.8))
  assert_true(assert_invalid_summary_options(1, -1, 0.0, 0.8))
  assert_true(assert_invalid_summary_options(1, 0, -0.1, 0.8))
  assert_true(assert_invalid_summary_options(1, 0, 0.0 / 0.0, 0.8))
  assert_true(assert_invalid_summary_options(1, 0, 1.0 / 0.0, 0.8))
  assert_true(assert_invalid_summary_options(1, 0, 0.0, -0.1))
  assert_true(assert_invalid_summary_options(1, 0, 0.0, 1.1))
  assert_true(assert_invalid_summary_options(1, 0, 0.0, 0.0 / 0.0))
  assert_true(assert_invalid_summary_options(1, 0, 0.0, 1.0 / 0.0))
}

///|
test "configured summarizer handles zero empty and single sentence inputs" {
  let zero = SummaryOptions::new(0, 0, 0.0, 0.8).unwrap()
  let normal = SummaryOptions::new(3, 0, 0.0, 0.8).unwrap()
  let summarizer = TextSummarizer::new()
  assert_true(
    summarizer.summarize_with_options("甲。乙。", zero).unwrap() == [],
  )
  assert_true(summarizer.summarize_with_options("", normal).unwrap() == [])
  assert_true(
    summarizer.summarize_with_options("孤立主题。", normal).unwrap() ==
    ["孤立主题。"],
  )
}

///|
test "configured summarizer applies minimum content length" {
  let options = SummaryOptions::new(2, 4, 0.0, 0.8).unwrap()
  let summary = TextSummarizer::new()
    .summarize_with_options("短。这个句子足够长。", options)
    .unwrap()
  assert_true(summary == ["这个句子足够长。"])
}

///|
test "configured summarizer handles a graph without edges" {
  let options = SummaryOptions::new(1, 0, 0.0, 1.0).unwrap()
  let summary = TextSummarizer::new()
    .summarize_with_options("甲。乙。", options)
    .unwrap()
  assert_true(summary == ["甲。"])
}

///|
test "zero redundancy threshold keeps non-overlapping sentences" {
  let options = SummaryOptions::new(2, 0, 0.0, 0.0).unwrap()
  let summary = TextSummarizer::new()
    .summarize_with_options("甲。乙。", options)
    .unwrap()
  assert_true(summary == ["甲。", "乙。"])
}

///|
test "configured summarizer returns stable source ordered selections" {
  let options = SummaryOptions::new(3, 0, 1000.0, 0.8).unwrap()
  let text = "人工智能促进创新。天气晴朗。人工智能促进创新。科研成果持续涌现。"
  let expected = [
    "人工智能促进创新。", "天气晴朗。", "科研成果持续涌现。",
  ]
  let summarizer = TextSummarizer::new()
  let first = summarizer.summarize_with_options(text, options).unwrap()
  let second = summarizer.summarize_with_options(text, options).unwrap()
  assert_true(first == expected)
  assert_true(second == expected)
}

///|
test "legacy summary API keeps its signature limit and source order" {
  assert_true(
    extract_summary("第一句。第二句。", 1) == ["第一句。"],
  )
  assert_true(extract_summary("第一句。", 0) == [])
  assert_true(extract_summary("第一句。", -1) == [])
}
