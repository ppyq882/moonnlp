///|
fn main {
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
      println("sentences=" + analysis.sentences.length().to_string())
      println("tokens=" + analysis.tokens.length().to_string())
      println("keywords=" + format_keywords(analysis.keywords))
      println("summary=" + format_strings(analysis.summary))
      println(
        "classification=" + format_classification(analysis.classification),
      )
    }
    Err(message) => println("document analysis error=" + message)
  }
}

///|
fn format_keywords(values : Array[(String, Double)]) -> String {
  let result = StringBuilder()
  for index in 0..<values.length() {
    let (word, _) = values[index]
    if index > 0 {
      result.write_string(", ")
    }
    result.write_string(word)
  }
  result.to_string()
}

///|
fn format_strings(values : Array[String]) -> String {
  let result = StringBuilder()
  for index in 0..<values.length() {
    if index > 0 {
      result.write_string(" | ")
    }
    result.write_string(values[index])
  }
  result.to_string()
}

///|
fn format_classification(value : String?) -> String {
  match value {
    Some(label) => label
    None => "none"
  }
}
