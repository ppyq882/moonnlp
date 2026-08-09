///|
fn tokenized_training_corpus() -> Array[Array[String]] {
  [["南京", "长江", "大桥"], ["南京", "长江"]]
}

///|
test "hmm model trains tokenized corpus and segments learned words" {
  match HMMModel::train(tokenized_training_corpus()) {
    Ok(model) => {
      let segmenter = HMMSegmenter::from_model(model)
      assert_true(segmenter.segment("南京长江") == ["南京", "长江"])
    }
    Err(_) => assert_true(false)
  }
}

///|
test "hmm model rejects empty corpus" {
  match HMMModel::train([]) {
    Ok(_) => assert_true(false)
    Err(_) => assert_true(true)
  }
}

///|
test "hmm model rejects empty token" {
  match HMMModel::train([["南京", ""]]) {
    Ok(_) => assert_true(false)
    Err(_) => assert_true(true)
  }
}

///|
test "hmm model rejects non-positive smoothing" {
  match HMMModel::try_train(tokenized_training_corpus(), 0.0) {
    Ok(_) => assert_true(false)
    Err(_) => assert_true(true)
  }
  match HMMModel::try_train(tokenized_training_corpus(), -1.0) {
    Ok(_) => assert_true(false)
    Err(_) => assert_true(true)
  }
}

///|
test "trained hmm handles empty input and unknown Chinese characters" {
  match HMMModel::train(tokenized_training_corpus()) {
    Ok(model) => {
      let segmenter = HMMSegmenter::from_model(model)
      assert_true(segmenter.segment("") == [])
      assert_true(segmenter.segment("火星").length() > 0)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "repeated hmm training is deterministic" {
  match
    (
      HMMModel::train(tokenized_training_corpus()),
      HMMModel::train(tokenized_training_corpus()),
    ) {
    (Ok(first), Ok(second)) => {
      let text = "南京长江大桥"
      let first_result = HMMSegmenter::from_model(first).segment(text)
      let second_result = HMMSegmenter::from_model(second).segment(text)
      assert_true(first_result == second_result)
    }
    _ => assert_true(false)
  }
}
