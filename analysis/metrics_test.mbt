///|
test "boundary metrics return zero for empty prediction and gold sets" {
  let metrics = evaluate_boundary_metrics([], [])

  assert_true(metrics.precision == 0.0)
  assert_true(metrics.recall == 0.0)
  assert_true(metrics.f1 == 0.0)
}

///|
test "boundary metrics measure exact partial and one-sided matches" {
  let exact = evaluate_boundary_metrics([2, 4], [2, 4])
  let partial = evaluate_boundary_metrics([2, 3], [2, 4])
  let empty_prediction = evaluate_boundary_metrics([], [2, 4])
  let empty_gold = evaluate_boundary_metrics([2, 4], [])

  assert_true(exact.precision == 1.0)
  assert_true(exact.recall == 1.0)
  assert_true(exact.f1 == 1.0)
  assert_true(partial.precision == 0.5)
  assert_true(partial.recall == 0.5)
  assert_true(partial.f1 == 0.5)
  assert_true(empty_prediction.precision == 0.0)
  assert_true(empty_prediction.recall == 0.0)
  assert_true(empty_prediction.f1 == 0.0)
  assert_true(empty_gold.precision == 0.0)
  assert_true(empty_gold.recall == 0.0)
  assert_true(empty_gold.f1 == 0.0)
}

///|
test "classification metrics report exact partial and unknown labels" {
  let exact = evaluate_classification(["spam", "ham"], ["spam", "ham"])
  let partial = evaluate_classification(["spam", "ham"], ["spam", "spam"])
  let unknown = evaluate_classification(["spam"], ["unknown"])

  match exact {
    Ok(metrics) => {
      assert_true(metrics.accuracy == 1.0)
      assert_true(metrics.precision == 1.0)
      assert_true(metrics.recall == 1.0)
      assert_true(metrics.f1 == 1.0)
      assert_true(metrics.confusion_matrix.count("spam", "spam") == 1)
    }
    Err(_) => assert_true(false)
  }
  match partial {
    Ok(metrics) => {
      assert_true(metrics.accuracy == 0.5)
      assert_true(metrics.precision == 0.25)
      assert_true(metrics.recall == 0.5)
      assert_true((metrics.f1 - 1.0 / 3.0).abs() < 1.0e-9)
      assert_true(metrics.confusion_matrix.count("ham", "spam") == 1)
    }
    Err(_) => assert_true(false)
  }
  match unknown {
    Ok(metrics) => {
      assert_true(metrics.accuracy == 0.0)
      assert_true(metrics.precision == 0.0)
      assert_true(metrics.recall == 0.0)
      assert_true(metrics.f1 == 0.0)
      assert_true(metrics.confusion_matrix.count("spam", "unknown") == 1)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "classification metrics reject mismatched input lengths" {
  let result = evaluate_classification(["spam"], [])

  match result {
    Err(message) =>
      assert_true(
        message == "actual and predicted labels must have equal length",
      )
    Ok(_) => assert_true(false)
  }
}

///|
test "classification metrics return zero values for empty labels" {
  let result = evaluate_classification([], [])

  match result {
    Ok(metrics) => {
      assert_true(metrics.accuracy == 0.0)
      assert_true(metrics.precision == 0.0)
      assert_true(metrics.recall == 0.0)
      assert_true(metrics.f1 == 0.0)
      assert_true(metrics.confusion_matrix.labels == [])
    }
    Err(_) => assert_true(false)
  }
}
