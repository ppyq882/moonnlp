///|
pub struct POSTagger {
  tags : Array[String]
  tag_to_idx : Map[String, Int]
  pi : Array[Double]
  trans : Array[Array[Double]]
  word_tag_freq : Map[String, Map[String, Int]]
  tag_totals : Array[Int]
  vocab_size : Int
}

///|
pub fn POSTagger::new() -> POSTagger {
  let tags = ["n", "v", "a", "r", "p", "c", "d", "q", "uj", "ul", "x"]
  let tag_to_idx = Map([])
  for i in 0..<tags.length() {
    tag_to_idx.set(tags[i], i)
  }

  let pi = [-1.0, -1.5, -2.0, -1.8, -2.5, -3.0, -2.0, -2.5, -2.0, -3.0, -4.0]

  let trans = []
  for _ in 0..<11 {
    let row = Array::make(11, -2.5)
    trans.push(row)
  }

  // Custom transition settings
  trans[0][1] = -1.0 // n -> v
  trans[1][0] = -1.2 // v -> n
  trans[2][0] = -0.8 // a -> n
  trans[3][1] = -1.0 // r -> v
  trans[4][0] = -1.0 // p -> n
  trans[6][1] = -0.8 // d -> v

  let word_tag_freq = Map([])
  let tag_totals = Array::make(11, 0)
  let vocab = Map([])

  let dict = get_default_dict()
  for item in dict {
    let (word, freq, tag) = item
    vocab.set(word, ())

    let tag_idx = match tag_to_idx.get(tag) {
      Some(idx) => idx
      None => 10 // fallback to "x"
    }

    tag_totals[tag_idx] += freq

    let m = match word_tag_freq.get(word) {
      Some(inner_map) => inner_map
      None => {
        let inner_map = Map([])
        word_tag_freq.set(word, inner_map)
        inner_map
      }
    }
    m.set(tag, freq)
  }

  {
    tags,
    tag_to_idx,
    pi,
    trans,
    word_tag_freq,
    tag_totals,
    vocab_size: vocab.length(),
  }
}

///|
fn POSTagger::get_emission(
  self : POSTagger,
  word : String,
  tag_idx : Int,
) -> Double {
  let tag = self.tags[tag_idx]
  let count = match self.word_tag_freq.get(word) {
    Some(inner_map) =>
      match inner_map.get(tag) {
        Some(freq) => freq.to_double()
        None => 0.0
      }
    None => 0.0
  }
  let total_tag_words = self.tag_totals[tag_idx].to_double()
  let vocab_s = self.vocab_size.to_double()

  let prob = (count + 1.0) / (total_tag_words + vocab_s)
  @math.ln(prob)
}

///|
pub fn POSTagger::tag(self : POSTagger, words : Array[String]) -> Array[String] {
  let n = words.length()
  if n == 0 {
    return []
  }

  let v = []
  let path = []
  for _ in 0..<n {
    v.push(Array::make(11, 0.0))
    path.push(Array::make(11, 0))
  }

  // Init (t = 0)
  for y in 0..<11 {
    let emit_p = self.get_emission(words[0], y)
    v[0][y] = self.pi[y] + emit_p
    path[0][y] = y
  }

  // DP steps
  for t in 1..<n {
    for y in 0..<11 {
      let emit_p = self.get_emission(words[t], y)
      let mut max_val = -1.0e300
      let mut best_y0 = 0
      for y0 in 0..<11 {
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

  // Find best last tag
  let mut max_last_val = -1.0e300
  let mut best_last_tag = 0
  for y in 0..<11 {
    if v[n - 1][y] > max_last_val {
      max_last_val = v[n - 1][y]
      best_last_tag = y
    }
  }

  // Backtrack
  let states = Array::make(n, 0)
  let mut state = best_last_tag
  states[n - 1] = state
  let mut t = n - 2
  while t >= 0 {
    state = path[t + 1][state]
    states[t] = state
    t -= 1
  }

  let result = []
  for i in 0..<n {
    result.push(self.tags[states[i]])
  }
  result
}
