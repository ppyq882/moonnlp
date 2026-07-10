///|
pub struct NaiveBayesClassifier {
  classes : Map[String, Unit]
  class_counts : Map[String, Int]
  vocab : Map[String, Unit]
  word_counts : Map[String, Map[String, Int]]
  total_word_counts : Map[String, Int]
  mut total_docs : Int
}

///|
pub fn NaiveBayesClassifier::new() -> NaiveBayesClassifier {
  {
    classes: Map([]),
    class_counts: Map([]),
    vocab: Map([]),
    word_counts: Map([]),
    total_word_counts: Map([]),
    total_docs: 0
  }
}

///|
pub fn NaiveBayesClassifier::train(self : NaiveBayesClassifier, class_name : String, tokens : Array[String]) -> Unit {
  self.total_docs += 1
  
  // Increment class document count
  let class_count = match self.class_counts.get(class_name) {
    Some(cnt) => cnt + 1
    None => 1
  }
  self.class_counts.set(class_name, class_count)
  self.classes.set(class_name, ())
  
  // Get or create class word count map
  let class_word_map = match self.word_counts.get(class_name) {
    Some(m) => m
    None => {
      let m = Map([])
      self.word_counts.set(class_name, m)
      m
    }
  }
  
  // Update token counts
  let mut new_words = 0
  for t in tokens {
    self.vocab.set(t, ())
    
    let count = match class_word_map.get(t) {
      Some(cnt) => cnt + 1
      None => 1
    }
    class_word_map.set(t, count)
    new_words += 1
  }
  
  // Update total words count for the class
  let total_words = match self.total_word_counts.get(class_name) {
    Some(cnt) => cnt + new_words
    None => new_words
  }
  self.total_word_counts.set(class_name, total_words)
}

///|
pub fn NaiveBayesClassifier::predict(self : NaiveBayesClassifier, tokens : Array[String]) -> Option[String] {
  if self.total_docs == 0 || self.classes.length() == 0 {
    return None
  }
  
  let vocab_size = self.vocab.length().to_double()
  let mut best_class = None
  let mut max_score = -1.0e300
  
  for class_name, _ in self.classes {
    let class_doc_count = match self.class_counts.get(class_name) {
      Some(cnt) => cnt.to_double()
      None => 0.0
    }
    
    // Class prior: log P(C)
    let prior = @math.ln(class_doc_count / self.total_docs.to_double())
    let mut score = prior
    
    let class_word_map = match self.word_counts.get(class_name) {
      Some(m) => m
      None => Map([])
    }
    
    let total_words = match self.total_word_counts.get(class_name) {
      Some(cnt) => cnt.to_double()
      None => 0.0
    }
    
    // Word conditional probability with Laplace smoothing
    for t in tokens {
      let count = match class_word_map.get(t) {
        Some(cnt) => cnt.to_double()
        None => 0.0
      }
      
      let word_prob = (count + 1.0) / (total_words + vocab_size)
      score += @math.ln(word_prob)
    }
    
    if score > max_score {
      max_score = score
      best_class = Some(class_name)
    }
  }
  
  best_class
}
