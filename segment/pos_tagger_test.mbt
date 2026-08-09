///|
test "pos tagger returns no tags for empty input" {
  assert_true(POSTagger::new().tag([]) == [])
}

///|
test "pos tagger labels an unknown token as x" {
  assert_true(POSTagger::new().tag(["MoonBit"]) == ["x"])
}

///|
test "pos tagger labels repeated unknown tokens as x" {
  assert_true(POSTagger::new().tag(["MoonBit", "MoonBit"]) == ["x", "x"])
}
