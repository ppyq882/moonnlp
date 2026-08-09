///|
pub struct DocumentAnalysis {
  text : String
  sentences : Array[String]
  tokens : Array[String]
  keywords : Array[(String, Double)]
  summary : Array[String]
  classification : String?
}

///|
pub struct DocumentPipeline {
  segmenter : @segment.DictSegmenter
  classifier : NaiveBayesClassifier?
}

///|
pub fn DocumentPipeline::new() -> DocumentPipeline {
  { segmenter: @segment.DictSegmenter::new(), classifier: None }
}

///|
pub fn DocumentPipeline::with_classifier(
  classifier : NaiveBayesClassifier,
) -> DocumentPipeline {
  { segmenter: @segment.DictSegmenter::new(), classifier: Some(classifier) }
}

///|
pub fn DocumentPipeline::analyze(
  self : DocumentPipeline,
  text : String,
  keyword_limit : Int,
  summary_limit : Int,
) -> Result[DocumentAnalysis, String] {
  if keyword_limit < 0 {
    return Err("keyword_limit must be non-negative")
  }
  if summary_limit < 0 {
    return Err("summary_limit must be non-negative")
  }

  let sentences = SentenceSplitter::new().split(text)
  let tokens = self.segmenter.segment(text)
  let keywords = TextRank::new().extract_keywords(tokens, keyword_limit)
  let summary = TextSummarizer::new().summarize(text, summary_limit)
  let classification = match self.classifier {
    Some(classifier) => classifier.predict(tokens)
    None => None
  }

  Ok({ text, sentences, tokens, keywords, summary, classification })
}
