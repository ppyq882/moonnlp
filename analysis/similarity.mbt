///|
/// Computes the Levenshtein distance between two strings, properly handling Unicode characters.
pub fn levenshtein_distance(s1 : String, s2 : String) -> Int {
  let chars1 = []
  for c in s1 {
    chars1.push(c)
  }
  let chars2 = []
  for c in s2 {
    chars2.push(c)
  }
  
  let len1 = chars1.length()
  let len2 = chars2.length()
  
  if len1 == 0 {
    return len2
  }
  if len2 == 0 {
    return len1
  }
  
  let dp = []
  for i in 0..=len1 {
    dp.push(Array::make(len2 + 1, 0))
    dp[i][0] = i
  }
  for j in 0..=len2 {
    dp[0][j] = j
  }
  
  for i in 1..=len1 {
    for j in 1..=len2 {
      let cost = if chars1[i - 1] == chars2[j - 1] { 0 } else { 1 }
      let val1 = dp[i - 1][j] + 1
      let val2 = dp[i][j - 1] + 1
      let val3 = dp[i - 1][j - 1] + cost
      
      let mut min_val = val1
      if val2 < min_val {
        min_val = val2
      }
      if val3 < min_val {
        min_val = val3
      }
      dp[i][j] = min_val
    }
  }
  
  dp[len1][len2]
}

///|
/// Computes the Cosine similarity between two frequency maps.
pub fn cosine_similarity(freq1 : Map[String, Int], freq2 : Map[String, Int]) -> Double {
  let mut dot_product = 0.0
  let mut norm1 = 0.0
  let mut norm2 = 0.0
  
  // Calculate norm1 and dot product
  for k, v1 in freq1 {
    let f1 = v1.to_double()
    norm1 += f1 * f1
    match freq2.get(k) {
      Some(v2) => {
        let f2 = v2.to_double()
        dot_product += f1 * f2
      }
      None => ()
    }
  }
  
  // Calculate norm2
  for _, v2 in freq2 {
    let f2 = v2.to_double()
    norm2 += f2 * f2
  }
  
  if norm1 == 0.0 || norm2 == 0.0 {
    return 0.0
  }
  
  dot_product / (norm1.sqrt() * norm2.sqrt())
}
