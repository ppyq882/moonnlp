///|
test "default hmm uses generic unknown emissions" {
  let model = default_hmm_model()
  match model.emit.get('中') {
    Some(_) => assert_true(false)
    None => assert_true(true)
  }
}
