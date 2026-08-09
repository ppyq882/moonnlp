///|
pub struct HybridSegmenter {
  dict_seg : DictSegmenter
  hmm_seg : HMMSegmenter
}

///|
pub fn HybridSegmenter::new() -> HybridSegmenter {
  { dict_seg: DictSegmenter::new(), hmm_seg: HMMSegmenter::new() }
}

///|
pub fn HybridSegmenter::segment(
  self : HybridSegmenter,
  text : String,
) -> Array[String] {
  let initial_tokens = self.dict_seg.segment(text)
  let result = []

  let mut i = 0
  let n = initial_tokens.length()

  while i < n {
    let tok = initial_tokens[i]
    let chars = []
    for c in tok {
      chars.push(c)
    }

    // Check if the current token is a single Chinese character
    if chars.length() == 1 && is_chinese_char(chars[0]) {
      // Find the range of consecutive single Chinese characters
      let temp_chars = [chars[0]]
      let mut j = i + 1
      while j < n {
        let next_tok = initial_tokens[j]
        let next_chars = []
        for c in next_tok {
          next_chars.push(c)
        }
        if next_chars.length() == 1 && is_chinese_char(next_chars[0]) {
          temp_chars.push(next_chars[0])
          j += 1
        } else {
          break
        }
      }

      let len = temp_chars.length()
      if len > 1 {
        // Re-segment the joined single characters using HMM
        let mut joined = ""
        for c in temp_chars {
          joined += c.to_string()
        }
        let hmm_tokens = self.hmm_seg.segment(joined)
        for t in hmm_tokens {
          result.push(t)
        }
      } else {
        result.push(tok)
      }
      i = j
    } else {
      result.push(tok)
      i += 1
    }
  }

  result
}
