///|
test "sentence splitter handles empty and punctuation-only input" {
  let splitter = SentenceSplitter::new()

  assert_true(splitter.split("") == [])
  assert_true(splitter.split("。！？") == [])
}

///|
test "sentence splitter preserves normal and contiguous sentence punctuation" {
  let splitter = SentenceSplitter::new()

  assert_true(
    splitter.split("第一句。第二句！第三句？") ==
    ["第一句。", "第二句！", "第三句？"],
  )
  assert_true(
    splitter.split("真的吗？！太好了。") ==
    ["真的吗？！", "太好了。"],
  )
}

///|
test "sentence splitter retains an unterminated sentence" {
  let splitter = SentenceSplitter::new()

  assert_true(splitter.split("没有句末标点") == ["没有句末标点"])
}
