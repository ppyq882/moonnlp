///|
fn main {
  let iterations = 50
  let trie = @core.Trie::new()
  trie.insert("自然语言", 1)
  trie.insert("MoonBit", 2)
  let dat = @core.DoubleArrayTrie::build(trie)
  let segmenter = @segment.DictSegmenter::new()
  let summarizer = @analysis.TextSummarizer::new()
  let textrank = @analysis.TextRank::new()
  let text = "MoonBit 支持自然语言处理。MoonNLP 提供分词和关键词提取。"
  let tokens = segmenter.segment(text)
  let mut checksum = 0

  for _ in 0..<iterations {
    match dat.exact_match("自然语言") {
      Some(value) => checksum += value
      None => ()
    }
    checksum += segmenter.segment(text).length()
    checksum += textrank.extract_keywords(tokens, 3).length()
    checksum += summarizer.summarize(text, 2).length()
  }

  println("MoonNLP workload smoke harness")
  println("timer=unavailable; no elapsed-time result is reported")
  println("iterations=" + iterations.to_string())
  println("workloads=DAT lookup, segmentation, keyword extraction, summary")
  println("checksum=" + checksum.to_string())
}
