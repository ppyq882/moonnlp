///|
pub struct HMMSegmenter {
  pi : Array[Double]
  trans : Array[Array[Double]]
  emit : Map[Char, Array[Double]]
  unknown_emit : Array[Double]
}

///|
pub fn HMMSegmenter::new() -> HMMSegmenter {
  HMMSegmenter::from_model(default_hmm_model())
}

///|
pub fn HMMSegmenter::from_model(model : HMMModel) -> HMMSegmenter {
  {
    pi: model.pi,
    trans: model.trans,
    emit: model.emit,
    unknown_emit: model.unknown_emit,
  }
}

///|
pub fn HMMSegmenter::segment(
  self : HMMSegmenter,
  text : String,
) -> Array[String] {
  let chars = text_chars(text)

  let n = chars.length()
  if n == 0 {
    return []
  }

  // 1. Check if the string contains Chinese.
  // If it's English or whitespace, HMM doesn't apply well, so we handle it similarly to FMM.
  let has_chinese = contains_chinese(chars)
  if !has_chinese {
    return segment_non_chinese(chars)
  }

  // 2. Viterbi algorithm
  let v = []
  let path = []
  for _ in 0..<n {
    v.push([0.0, 0.0, 0.0, 0.0])
    path.push([0, 0, 0, 0])
  }

  // Initialization (t = 0)
  for y in 0..<4 {
    let emit_p = self.get_emission(chars[0], y)
    v[0][y] = self.pi[y] + emit_p
    path[0][y] = y
  }

  // DP steps (t > 0)
  for t in 1..<n {
    for y in 0..<4 {
      let emit_p = self.get_emission(chars[t], y)
      let mut max_val = -1.0e300
      let mut best_y0 = 0
      for y0 in 0..<4 {
        let val = v[t - 1][y0] + self.trans[y0][y]
        if val > max_val {
          max_val = val
          best_y0 = y0
        }
      }
      v[t][y] = max_val + emit_p
      path[t][y] = best_y0
    }
  }

  // A valid word sequence can only end in E or S.
  let mut best_last_state = 2
  if v[n - 1][3] > v[n - 1][2] {
    best_last_state = 3
  }

  // Backtrack
  let states = Array::make(n, 0)
  let mut state = best_last_state
  states[n - 1] = state
  let mut t = n - 2
  while t >= 0 {
    state = path[t + 1][state]
    states[t] = state
    t -= 1
  }

  // Segment text based on states (B=0, M=1, E=2, S=3)
  let result = []
  let mut i = 0
  while i < n {
    let c = chars[i]
    if !is_chinese_char(c) {
      let (token, next) = scan_non_chinese(chars, i)
      result.push(token)
      i = next
    } else {
      let st = states[i]
      if st == 3 { // S
        result.push(c.to_string())
        i += 1
      } else if st == 0 { // B
        let mut word = c.to_string()
        let mut j = i + 1
        while j < n {
          let next_c = chars[j]
          if !is_chinese_char(next_c) {
            break
          }
          let next_st = states[j]
          word += next_c.to_string()
          if next_st == 2 { // E
            j += 1
            break
          }
          if next_st == 0 || next_st == 3 { // B or S (early stop)
            break
          }
          j += 1
        }
        result.push(word)
        i = j
      } else {
        // Fallback for isolated M or E state
        result.push(c.to_string())
        i += 1
      }
    }
  }

  result
}

///|
fn HMMSegmenter::get_emission(
  self : HMMSegmenter,
  c : Char,
  state : Int,
) -> Double {
  match self.emit.get(c) {
    Some(probs) => probs[state]
    None => self.unknown_emit[state]
  }
}
