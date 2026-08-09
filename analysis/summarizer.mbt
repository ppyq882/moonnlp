///|
/// Configures `TextSummarizer::summarize_with_options`.
///
/// ```mbt check
/// test {
///   assert_true(
///     match SummaryOptions::new(2, 0, 0.2, 0.8) {
///       Ok(_) => true
///       Err(_) => false
///     },
///   )
/// }
/// ```
pub struct SummaryOptions {
  max_sentences : Int
  min_sentence_length : Int
  position_weight : Double
  redundancy_threshold : Double
}

///|
/// Creates validated summary options. `max_sentences` and
/// `min_sentence_length` must be non-negative, `position_weight` must be
/// finite and non-negative, and `redundancy_threshold` must be finite in
/// `[0.0, 1.0]`.
///
/// ```mbt check
/// test {
///   assert_true(
///     match SummaryOptions::new(1, 0, 0.0, 0.0) {
///       Ok(_) => true
///       Err(_) => false
///     },
///   )
/// }
/// ```
pub fn SummaryOptions::new(
  max_sentences : Int,
  min_sentence_length : Int,
  position_weight : Double,
  redundancy_threshold : Double,
) -> Result[SummaryOptions, String] {
  let options = {
    max_sentences,
    min_sentence_length,
    position_weight,
    redundancy_threshold,
  }
  match validate_summary_options(options) {
    Some(message) => Err(message)
    None => Ok(options)
  }
}

///|
fn validate_summary_options(options : SummaryOptions) -> String? {
  if options.max_sentences < 0 {
    return Some("max_sentences must be non-negative")
  }
  if options.min_sentence_length < 0 {
    return Some("min_sentence_length must be non-negative")
  }
  if options.position_weight < 0.0 ||
    options.position_weight.is_nan() ||
    options.position_weight.is_inf() {
    return Some("position_weight must be finite and non-negative")
  }
  if options.redundancy_threshold < 0.0 ||
    options.redundancy_threshold > 1.0 ||
    options.redundancy_threshold.is_nan() ||
    options.redundancy_threshold.is_inf() {
    return Some("redundancy_threshold must be finite and between 0 and 1")
  }
  None
}

///|
fn default_summary_options(max_sentences : Int) -> SummaryOptions {
  {
    max_sentences,
    min_sentence_length: 0,
    position_weight: 0.2,
    redundancy_threshold: 0.8,
  }
}

///|
pub struct TextSummarizer {
  segmenter : @segment.DictSegmenter
}

///|
pub fn TextSummarizer::new() -> TextSummarizer {
  { segmenter: @segment.DictSegmenter::new() }
}

///|
pub fn TextSummarizer::summarize(
  self : TextSummarizer,
  text : String,
  max_sentences : Int,
) -> Array[String] {
  if max_sentences < 0 {
    return []
  }
  let legacy_sentences = split_legacy_sentences(text)
  if legacy_sentences.length() <= max_sentences {
    return legacy_sentences
  }
  summarize_sentences(
    self,
    legacy_sentences,
    default_summary_options(max_sentences),
  )
}

///|
/// Summarizes text with validated options. A zero redundancy threshold rejects
/// only sentences with positive token overlap; thresholds above zero reject
/// sentences whose Jaccard similarity reaches that threshold.
///
/// ```mbt check
/// test {
///   let options = SummaryOptions::new(2, 0, 0.0, 0.8).unwrap()
///   let summary = TextSummarizer::new()
///     .summarize_with_options("第一句。第二句。", options)
///     .unwrap()
///   assert_true(summary.length() == 2)
/// }
/// ```
pub fn TextSummarizer::summarize_with_options(
  self : TextSummarizer,
  text : String,
  options : SummaryOptions,
) -> Result[Array[String], String] {
  match validate_summary_options(options) {
    Some(message) => Err(message)
    None => Ok(summarize_configured(self, text, options))
  }
}

///|
fn summarize_configured(
  summarizer : TextSummarizer,
  text : String,
  options : SummaryOptions,
) -> Array[String] {
  summarize_sentences(summarizer, split_sentences(text), options)
}

///|
fn summarize_sentences(
  summarizer : TextSummarizer,
  raw_sentences : Array[String],
  options : SummaryOptions,
) -> Array[String] {
  let sentence_count = raw_sentences.length()
  if sentence_count == 0 || options.max_sentences == 0 {
    return []
  }

  let sentence_words : Array[Array[String]] = []
  let all_words : Array[String] = []
  let tfidf = TFIDF::new()
  for sentence in raw_sentences {
    let words = summary_words(summarizer, sentence)
    sentence_words.push(words)
    tfidf.add_document(words)
    for word in words {
      all_words.push(word)
    }
  }

  let textrank_scores : Map[String, Double] = Map([])
  for
    keyword_score in TextRank::new().extract_keywords(
      all_words,
      all_words.length(),
    ) {
    let (word, score) = keyword_score
    textrank_scores.set(word, score)
  }

  let scores = Array::make(sentence_count, 0.0)
  let eligible = Array::make(sentence_count, false)
  for index in 0..<sentence_count {
    if sentence_content_length(raw_sentences[index]) >=
      options.min_sentence_length {
      eligible[index] = true
      let words = sentence_words[index]
      let mut tfidf_score = 0.0
      for _, score in tfidf.calculate(words) {
        tfidf_score += score
      }

      let mut textrank_score = 0.0
      for word in words {
        match textrank_scores.get(word) {
          Some(score) => textrank_score += score
          None => ()
        }
      }
      if words.length() > 0 {
        textrank_score /= words.length().to_double()
      }

      let position_score = options.position_weight / (index + 1).to_double()
      scores[index] = tfidf_score + textrank_score + position_score
    }
  }

  let selected_indices : Array[Int] = []
  let used = Array::make(sentence_count, false)
  let selection_limit = if options.max_sentences < sentence_count {
    options.max_sentences
  } else {
    sentence_count
  }
  for _ in 0..<selection_limit {
    let mut best_index = -1
    let mut best_score = -1.0e300
    for index in 0..<sentence_count {
      if !used[index] &&
        eligible[index] &&
        !is_redundant_sentence(
          index,
          selected_indices,
          raw_sentences,
          sentence_words,
          options.redundancy_threshold,
        ) &&
        scores[index] > best_score {
        best_index = index
        best_score = scores[index]
      }
    }
    if best_index >= 0 {
      used[best_index] = true
      selected_indices.push(best_index)
    }
  }

  sort_int_array(selected_indices)
  let summary = []
  for index in selected_indices {
    summary.push(raw_sentences[index])
  }
  summary
}

///|
fn summary_words(
  summarizer : TextSummarizer,
  sentence : String,
) -> Array[String] {
  let words = []
  for token in summarizer.segmenter.segment(sentence) {
    let word = token.to_string()
    let chars = []
    for character in word {
      chars.push(character)
    }
    if chars.length() > 0 && @core.is_chinese(chars[0]) {
      words.push(word)
    }
  }
  words
}

///|
fn is_redundant_sentence(
  candidate_index : Int,
  selected_indices : Array[Int],
  sentences : Array[String],
  sentence_words : Array[Array[String]],
  threshold : Double,
) -> Bool {
  for selected_index in selected_indices {
    let candidate_words = sentence_words[candidate_index]
    let selected_words = sentence_words[selected_index]
    let similarity = if candidate_words.length() == 0 &&
      selected_words.length() == 0 {
      if sentences[candidate_index] == sentences[selected_index] {
        1.0
      } else {
        0.0
      }
    } else {
      token_jaccard(candidate_words, selected_words)
    }
    if (threshold == 0.0 && similarity > 0.0) ||
      (threshold > 0.0 && similarity >= threshold) {
      return true
    }
  }
  false
}

///|
fn token_jaccard(left : Array[String], right : Array[String]) -> Double {
  let left_set : Map[String, Unit] = Map([])
  let right_set : Map[String, Unit] = Map([])
  for word in left {
    left_set.set(word, ())
  }
  for word in right {
    right_set.set(word, ())
  }

  let mut intersection = 0
  let mut union = 0
  for word, _ in left_set {
    union += 1
    match right_set.get(word) {
      Some(_) => intersection += 1
      None => ()
    }
  }
  for word, _ in right_set {
    match left_set.get(word) {
      Some(_) => ()
      None => union += 1
    }
  }
  if union == 0 {
    0.0
  } else {
    intersection.to_double() / union.to_double()
  }
}

///|
pub fn extract_summary(text : String, top_n : Int) -> Array[String] {
  let summarizer = TextSummarizer::new()
  summarizer.summarize(text, top_n)
}

///|
fn split_sentences(text : String) -> Array[String] {
  let sentences = []
  let mut current = ""
  let mut has_content = false
  for character in text {
    if is_summary_terminator(character) {
      if has_content {
        current += character.to_string()
        sentences.push(current)
      }
      current = ""
      has_content = false
    } else {
      current += character.to_string()
      if !is_summary_whitespace(character) {
        has_content = true
      }
    }
  }
  if has_content {
    sentences.push(current)
  }
  sentences
}

///|
fn split_legacy_sentences(text : String) -> Array[String] {
  let sentences = []
  let mut current = ""
  for character in text {
    if is_summary_terminator(character) {
      current += character.to_string()
      if current.length() > 0 {
        sentences.push(current)
      }
      current = ""
    } else {
      current += character.to_string()
    }
  }
  if current.length() > 0 {
    sentences.push(current)
  }
  sentences
}

///|
fn sentence_content_length(sentence : String) -> Int {
  let mut length = 0
  for character in sentence {
    if !is_summary_terminator(character) && !is_summary_whitespace(character) {
      length += 1
    }
  }
  length
}

///|
fn is_summary_terminator(character : Char) -> Bool {
  character == '。' ||
  character == '！' ||
  character == '？' ||
  character == '；' ||
  character == '\n'
}

///|
fn is_summary_whitespace(character : Char) -> Bool {
  character == ' ' ||
  character == '\n' ||
  character == '\r' ||
  character == '\t'
}

///|
fn sort_int_array(arr : Array[Int]) -> Unit {
  let n = arr.length()
  for i in 0..<n {
    for j in (i + 1)..<n {
      if arr[i] > arr[j] {
        let tmp = arr[i]
        arr[i] = arr[j]
        arr[j] = tmp
      }
    }
  }
}

///|
test "configured summarizer revalidates direct invalid options" {
  let invalid : SummaryOptions = {
    max_sentences: 1,
    min_sentence_length: 0,
    position_weight: 0.0 / 0.0,
    redundancy_threshold: 0.8,
  }
  let result = TextSummarizer::new().summarize_with_options(
    "第一句。", invalid,
  )
  assert_true(
    match result {
      Err(message) =>
        message == "position_weight must be finite and non-negative"
      Ok(_) => false
    },
  )
}
