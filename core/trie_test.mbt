///|
test "trie basic insert and get" {
  let trie : Trie[Int] = Trie::new()
  trie.insert("中华", 1)
  trie.insert("中华人民共和国", 2)
  
  assert_true(trie.get("中华") == Some(1))
  assert_true(trie.get("中华人民共和国") == Some(2))
  assert_true(trie.get("中华人民") == None)
}

///|
test "trie prefix search" {
  let trie : Trie[Int] = Trie::new()
  trie.insert("中华", 1)
  trie.insert("中华人民共和国", 2)
  trie.insert("人民", 3)
  
  let chars = []
  for c in "中华人民共和国" {
    chars.push(c)
  }
  
  assert_true(trie.longest_prefix(chars, 0) == 7) // "中华人民共和国"
  assert_true(trie.all_prefixes(chars, 0) == [2, 7]) // "中华" (2) and "中华人民共和国" (7)
  assert_true(trie.longest_prefix(chars, 2) == 2) // "人民" starting at index 2
}

///|
test "unicode utilities" {
  assert_true(is_chinese('中') == true)
  assert_true(is_chinese('a') == false)
  assert_true(is_alphanumeric('z') == true)
  assert_true(is_alphanumeric('9') == true)
  assert_true(is_alphanumeric('中') == false)
  assert_true(is_whitespace(' ') == true)
  assert_true(is_whitespace('\u3000') == true)
  assert_true(is_punctuation('，') == true)
  assert_true(is_punctuation('!') == true)
}

///|
test "double array trie exact match and prefix lookup" {
  let trie : Trie[Int] = Trie::new()
  trie.insert("中华", 1)
  trie.insert("中华人民共和国", 2)
  trie.insert("人民", 3)
  
  let dat = DoubleArrayTrie::build(trie)
  assert_true(dat.exact_match("中华") == Some(1))
  assert_true(dat.exact_match("中华人民共和国") == Some(2))
  assert_true(dat.exact_match("中华人民") == None)
  
  let chars = []
  for c in "中华人民共和国" {
    chars.push(c)
  }
  assert_true(dat.longest_prefix(chars, 0) == 7)
}
