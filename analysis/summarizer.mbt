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
  let raw_sentences = split_sentences(text)
  let n = raw_sentences.length()
  if n <= max_sentences {
    return raw_sentences
  }

  // Segment sentences and extract word tokens
  let sentence_words : Array[Array[String]] = []
  for s in raw_sentences {
    let tokens = self.segmenter.segment(s)
    let words = []
    for tok in tokens {
      let trimmed = tok.to_string()
      let chars = []
      for c in trimmed {
        chars.push(c)
      }
      if chars.length() > 0 && @core.is_chinese(chars[0]) {
        words.push(trimmed)
      }
    }
    sentence_words.push(words)
  }

  // Calculate sentence scores using TF-IDF sum and position weights
  let scores = Array::make(n, 0.0)
  for i in 0..<n {
    let words = sentence_words[i]
    let mut score = 0.0
    for w in words {
      let mut freq = 0
      for j in 0..<n {
        for w2 in sentence_words[j] {
          if w == w2 {
            freq += 1
          }
        }
      }
      // Sentence word importance
      score += 1.0 / (1.0 + @math.log2(1.0 + freq.to_double()))
    }

    // Position weighting
    if i == 0 {
      score *= 1.3
    } else if i == n - 1 {
      score *= 1.15
    }

    scores[i] = score
  }

  // Select top N indices
  let selected_indices = []
  let k = if max_sentences < n { max_sentences } else { n }

  let used = Array::make(n, false)
  for _ in 0..<k {
    let mut max_val = -1.0
    let mut best_idx = -1
    for i in 0..<n {
      if !used[i] && scores[i] > max_val {
        max_val = scores[i]
        best_idx = i
      }
    }
    if best_idx >= 0 {
      used[best_idx] = true
      selected_indices.push(best_idx)
    }
  }

  // Sort selected indices to preserve original document order
  sort_int_array(selected_indices)

  let summary = []
  for idx in selected_indices {
    summary.push(raw_sentences[idx])
  }
  summary
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
  for c in text {
    if c == '。' || c == '！' || c == '？' || c == '\n' || c == '；' {
      current += c.to_string()
      let s = current
      if s.length() > 0 {
        sentences.push(s)
      }
      current = ""
    } else {
      current += c.to_string()
    }
  }
  if current.length() > 0 {
    sentences.push(current)
  }
  sentences
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
