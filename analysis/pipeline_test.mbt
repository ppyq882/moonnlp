///|
test "document pipeline returns explicit empty and single-sentence analyses" {
  let pipeline = DocumentPipeline::new()

  match pipeline.analyze("", 3, 2) {
    Ok(analysis) => {
      assert_true(analysis.sentences == [])
      assert_true(analysis.tokens == [])
      assert_true(analysis.keywords == [])
      assert_true(analysis.summary == [])
      assert_true(analysis.classification == None)
    }
    Err(_) => assert_true(false)
  }
  match pipeline.analyze("MoonBit", 3, 2) {
    Ok(analysis) => {
      assert_true(analysis.sentences == ["MoonBit"])
      assert_true(analysis.summary == ["MoonBit"])
      assert_true(analysis.classification == None)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "document pipeline classifies with an optional trained classifier" {
  let segmenter = @segment.DictSegmenter::new()
  let classifier = NaiveBayesClassifier::new()
  classifier.train("tech", segmenter.segment("MoonBit"))
  let pipeline = DocumentPipeline::with_classifier(classifier)

  match pipeline.analyze("MoonBit", 3, 1) {
    Ok(analysis) => assert_true(analysis.classification == Some("tech"))
    Err(_) => assert_true(false)
  }
}

///|
test "document pipeline returns invalid limits as explicit errors" {
  let pipeline = DocumentPipeline::new()

  match pipeline.analyze("text", -1, 1) {
    Err(message) => assert_true(message == "keyword_limit must be non-negative")
    Ok(_) => assert_true(false)
  }
  match pipeline.analyze("text", 1, -1) {
    Err(message) => assert_true(message == "summary_limit must be non-negative")
    Ok(_) => assert_true(false)
  }
}
