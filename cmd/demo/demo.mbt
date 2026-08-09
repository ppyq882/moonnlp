///|
/// Renders the deterministic report printed by the no-argument MoonNLP demo.
///
/// The executable deliberately accepts no arguments. It is a reproducible
/// demonstration of the public analysis APIs, rather than a command-line text
/// processing interface.
pub fn report() -> String {
  let training_segmenter = @segment.DictSegmenter::new()
  let classifier = @analysis.NaiveBayesClassifier::new()
  classifier.train(
    "technology",
    training_segmenter.segment("MoonBit 自然语言处理 分词 关键词"),
  )
  classifier.train(
    "everyday",
    training_segmenter.segment("天气 公园 散步"),
  )

  let text = "MoonBit 支持高效的自然语言处理。MoonNLP 提供分词和关键词提取。"
  let pipeline = @analysis.DocumentPipeline::with_classifier(classifier)
  match pipeline.analyze(text, 3, 2) {
    Ok(analysis) => {
      let rendered = StringBuilder()
      rendered.write_string("MoonNLP demo report\n")
      rendered.write_string("sentences=")
      rendered.write_string(analysis.sentences.length().to_string())
      rendered.write_string("\ntokens=")
      rendered.write_string(format_strings(analysis.tokens))
      rendered.write_string("\nkeywords=")
      rendered.write_string(format_keywords(analysis.keywords))
      rendered.write_string("\nsummary=")
      rendered.write_string(format_strings(analysis.summary))
      rendered.write_string("\nclassification=")
      rendered.write_string(format_classification(analysis.classification))
      rendered.to_string()
    }
    Err(message) => "MoonNLP demo report\nerror=" + message
  }
}

///|
fn format_strings(values : Array[String]) -> String {
  let rendered = StringBuilder()
  for index in 0..<values.length() {
    if index > 0 {
      rendered.write_string(", ")
    }
    rendered.write_string(values[index])
  }
  rendered.to_string()
}

///|
fn format_keywords(values : Array[(String, Double)]) -> String {
  let rendered = StringBuilder()
  for index in 0..<values.length() {
    let (word, _) = values[index]
    if index > 0 {
      rendered.write_string(", ")
    }
    rendered.write_string(word)
  }
  rendered.to_string()
}

///|
fn format_classification(value : String?) -> String {
  match value {
    Some(label) => label
    None => "none"
  }
}
