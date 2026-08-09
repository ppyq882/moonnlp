///|
test "dict segmenter fmm and bmm differences" {
  let seg = DictSegmenter::new()

  seg.add_word("研究生")

  let fmm_res = seg.fmm("研究生命起源")
  let bmm_res = seg.bmm("研究生命起源")
  let bimm_res = seg.segment("研究生命起源")

  assert_true(fmm_res == ["研究生", "命", "起源"])
  assert_true(bmm_res == ["研究", "生命", "起源"])
  assert_true(bimm_res == ["研究", "生命", "起源"])
}

///|
test "hmm segmenter oov recognition" {
  let seg = HMMSegmenter::new()
  let res = seg.segment("蓝精灵")
  assert_true(res == ["蓝精灵"])
}

///|
test "hybrid segmenter integration" {
  let seg = HybridSegmenter::new()
  let res = seg.segment("北京的蓝精灵")
  assert_true(res == ["北京", "的", "蓝精灵"])
}

///|
test "pos tagger basic mapping and tagging" {
  let tagger = POSTagger::new()
  let words = ["我", "在", "北京", "大学", "学习"]
  let tags = tagger.tag(words)

  assert_true(tags.length() == 5)
  assert_true(tags[0] == "r") // "我" -> pronoun (r)
  assert_true(tags[1] == "p") // "在" -> preposition (p)
  assert_true(tags[4] == "n") // "学习" -> noun (n) in our default dict
}

///|
test "dict segmenter emoji non-infinite-loop" {
  let seg = DictSegmenter::new()
  let res = seg.segment("我喜欢自然语言处理😀🚀！")
  assert_true(res.length() > 0)
}

///|
test "hmm segmenter emoji non-infinite-loop" {
  let seg = HMMSegmenter::new()
  let res = seg.segment("自然语言处理😀🚀")
  assert_true(res.length() > 0)
}

///|
test "hmm segmenter preserves non-Chinese fallback" {
  let seg = HMMSegmenter::new()
  let res = seg.segment("MoonBit 2026!😀")
  assert_true(res == ["MoonBit", " ", "2026", "!", "😀"])
}

///|
test "hmm segmenter empty input stays empty" {
  assert_true(HMMSegmenter::new().segment("") == [])
}
