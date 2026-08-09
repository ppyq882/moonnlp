///|
fn chars_of(text : String) -> Array[Char] {
  let chars = []
  for char in text {
    chars.push(char)
  }
  chars
}

///|
test "double array trie preserves empty, duplicate, and unicode keys" {
  let trie : Trie[Int] = Trie::new()
  trie.insert("", 1)
  trie.insert("月亮", 5)
  trie.insert("月亮", 7)

  let dat = DoubleArrayTrie::build(trie)
  assert_true(dat.exact_match("") == Some(1))
  assert_true(dat.exact_match("月亮") == Some(7))
}

///|
test "double array trie returns empty matches for absent keys and invalid starts" {
  let trie : Trie[Int] = Trie::new()
  trie.insert("月亮", 7)
  let dat = DoubleArrayTrie::build(trie)
  let chars = chars_of("月亮光")

  assert_true(dat.exact_match("月光") == None)
  assert_true(dat.longest_prefix(chars, -1) == 0)
  assert_true(dat.longest_prefix(chars, chars.length()) == 0)
  assert_true(dat.longest_prefix(chars, chars.length() + 1) == 0)
}

///|
test "double array trie agrees with trie for unicode prefix matching" {
  let trie : Trie[Int] = Trie::new()
  trie.insert("月", 1)
  trie.insert("月亮", 7)
  let dat = DoubleArrayTrie::build(trie)
  let chars = chars_of("月亮光")

  assert_true(dat.longest_prefix(chars, 0) == trie.longest_prefix(chars, 0))
  assert_true(dat.longest_prefix(chars, 1) == trie.longest_prefix(chars, 1))
}
