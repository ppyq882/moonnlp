///|
pub struct TextRank {
  damping_factor : Double
  max_iterations : Int
  window_size : Int
}

///|
pub fn TextRank::new() -> TextRank {
  { damping_factor: 0.85, max_iterations: 30, window_size: 5 }
}

///|
pub fn TextRank::extract_keywords(
  self : TextRank,
  tokens : Array[String],
  top_k : Int,
) -> Array[(String, Double)] {
  let unique_words = Map([])
  for t in tokens {
    if t.length() > 1 { // skip punctuation and single character particles
      unique_words.set(t, ())
    }
  }

  let vertices = []
  let vert_to_idx = Map([])
  let mut idx = 0
  for w, _ in unique_words {
    vertices.push(w)
    vert_to_idx.set(w, idx)
    idx += 1
  }

  let v_count = vertices.length()
  if v_count == 0 {
    return []
  }

  // 1. Build adjacency matrix
  let edges = []
  for _ in 0..<v_count {
    edges.push(Array::make(v_count, 0.0))
  }

  let n = tokens.length()
  for i in 0..<n {
    let t1 = tokens[i]
    let idx1 = match vert_to_idx.get(t1) {
      Some(index) => index
      None => continue
    }

    // Slide window
    let limit = if i + self.window_size < n { i + self.window_size } else { n }
    for j in (i + 1)..<limit {
      let t2 = tokens[j]
      match vert_to_idx.get(t2) {
        Some(idx2) =>
          if idx1 != idx2 {
            edges[idx1][idx2] += 1.0
            edges[idx2][idx1] += 1.0
          }
        None => ()
      }
    }
  }

  // 2. Compute out-degrees
  let out_degrees = Array::make(v_count, 0.0)
  for i in 0..<v_count {
    let mut sum = 0.0
    for j in 0..<v_count {
      sum += edges[i][j]
    }
    out_degrees[i] = sum
  }

  // 3. PageRank iterations
  let mut scores = Array::make(v_count, 1.0 / v_count.to_double())
  for _ in 0..<self.max_iterations {
    let next_scores = Array::make(v_count, 0.0)
    for i in 0..<v_count {
      let mut sum = 0.0
      for j in 0..<v_count {
        if edges[j][i] > 0.0 && out_degrees[j] > 0.0 {
          sum += scores[j] * edges[j][i] / out_degrees[j]
        }
      }
      next_scores[i] = 1.0 - self.damping_factor + self.damping_factor * sum
    }
    scores = next_scores
  }

  // 4. Sort keywords
  let arr = []
  for i in 0..<v_count {
    arr.push((vertices[i], scores[i]))
  }

  let size = arr.length()
  for i in 0..<size {
    for j in (i + 1)..<size {
      let (_, s1) = arr[i]
      let (_, s2) = arr[j]
      if s2 > s1 {
        let temp = arr[i]
        arr[i] = arr[j]
        arr[j] = temp
      }
    }
  }

  let limit = if top_k < size { top_k } else { size }
  let result = []
  for i in 0..<limit {
    result.push(arr[i])
  }
  result
}
