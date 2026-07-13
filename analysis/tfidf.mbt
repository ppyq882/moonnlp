///|
pub struct TFIDF {
  mut doc_count : Int
  doc_freq : Map[String, Int]
}

///|
pub fn TFIDF::new() -> TFIDF {
  { doc_count: 0, doc_freq: Map([]) }
}

///|
pub fn TFIDF::add_document(self : TFIDF, tokens : Array[String]) -> Unit {
  let unique_tokens = Map([])
  for t in tokens {
    unique_tokens.set(t, ())
  }

  for t, _ in unique_tokens {
    match self.doc_freq.get(t) {
      Some(count) => self.doc_freq.set(t, count + 1)
      None => self.doc_freq.set(t, 1)
    }
  }
  self.doc_count += 1
}

///|
pub fn TFIDF::calculate(
  self : TFIDF,
  tokens : Array[String],
) -> Map[String, Double] {
  let result = Map([])
  let total_tokens = tokens.length()
  if total_tokens == 0 {
    return result
  }

  let term_counts = Map([])
  for t in tokens {
    match term_counts.get(t) {
      Some(count) => term_counts.set(t, count + 1)
      None => term_counts.set(t, 1)
    }
  }

  for t, count in term_counts {
    let tf = count.to_double() / total_tokens.to_double()
    let df = match self.doc_freq.get(t) {
      Some(df_val) => df_val
      None => 0
    }

    // Smooth it: use df + 1 in denominator, doc_count + 1 in numerator
    let idf = @math.ln(
      (self.doc_count.to_double() + 1.0) / (df.to_double() + 1.0),
    )
    let tfidf = tf * idf
    result.set(t, tfidf)
  }

  result
}

///|
pub fn TFIDF::get_keywords(
  self : TFIDF,
  tokens : Array[String],
  top_k : Int,
) -> Array[(String, Double)] {
  let scores = self.calculate(tokens)
  let arr = []
  for k, v in scores {
    arr.push((k, v))
  }

  let n = arr.length()
  for i in 0..<n {
    for j in (i + 1)..<n {
      let (_, s1) = arr[i]
      let (_, s2) = arr[j]
      if s2 > s1 {
        let temp = arr[i]
        arr[i] = arr[j]
        arr[j] = temp
      }
    }
  }

  let limit = if top_k < n { top_k } else { n }
  let result = []
  for i in 0..<limit {
    result.push(arr[i])
  }
  result
}
