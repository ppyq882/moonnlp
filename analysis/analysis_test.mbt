///|
test "levenshtein distance" {
  assert_true(levenshtein_distance("kitten", "sitting") == 3)
  assert_true(
    levenshtein_distance("中华人民共和国", "中华人民") == 3,
  )
  assert_true(levenshtein_distance("", "abc") == 3)
  assert_true(levenshtein_distance("abc", "") == 3)
  assert_true(levenshtein_distance("same", "same") == 0)
}

///|
test "cosine similarity" {
  let freq1 = Map([])
  freq1.set("apple", 2)
  freq1.set("banana", 1)

  let freq2 = Map([])
  freq2.set("apple", 1)
  freq2.set("banana", 2)

  let sim = cosine_similarity(freq1, freq2)
  assert_true((sim - 0.8).abs() < 1.0e-9)
}

///|
test "tfidf keyword extraction" {
  let tfidf = TFIDF::new()
  tfidf.add_document(["china", "economy", "growth"])
  tfidf.add_document(["economy", "finance"])

  let doc = ["china", "economy", "growth", "china"]
  let keywords = tfidf.get_keywords(doc, 2)

  assert_true(keywords.length() == 2)
  let (kw1, _) = keywords[0]
  assert_true(kw1 == "china")
}

///|
test "naive bayes classifier spam detection" {
  let nb = NaiveBayesClassifier::new()

  nb.train("spam", ["buy", "free", "money", "now"])
  nb.train("spam", ["free", "offer", "click", "now"])
  nb.train("ham", ["hello", "friend", "how", "are", "you"])
  nb.train("ham", ["meeting", "project", "deadline", "today"])

  let pred1 = nb.predict(["free", "money"])
  let pred2 = nb.predict(["project", "meeting"])

  assert_true(pred1 == Some("spam"))
  assert_true(pred2 == Some("ham"))
}

///|
test "textrank keyword extraction" {
  let tr = TextRank::new()
  let doc = [
    "北京", "大学", "计算机", "科学", "北京", "大学", "语言", "处理",
  ]
  let keywords = tr.extract_keywords(doc, 2)

  assert_true(keywords.length() == 2)
  let (kw1, _) = keywords[0]
  assert_true(kw1 == "北京" || kw1 == "大学")
}
