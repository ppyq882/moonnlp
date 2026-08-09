///|
test "pos tagger accumulates duplicate lexicon rows when choosing an emission" {
  let lexicon = [
    ("pivot", 7, "n"),
    ("noun_filler", 13, "n"),
    ("pivot", 5, "v"),
    ("pivot", 5, "v"),
    ("a_filler", 20, "a"),
    ("r_filler", 20, "r"),
    ("p_filler", 20, "p"),
    ("c_filler", 20, "c"),
    ("d_filler", 20, "d"),
    ("q_filler", 20, "q"),
    ("uj_filler", 20, "uj"),
    ("ul_filler", 20, "ul"),
    ("x_filler", 20, "x"),
  ]

  assert_true(POSTagger::from_lexicon(lexicon).tag(["pivot"]) == ["v"])
}
