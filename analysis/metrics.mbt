///|
pub struct BoundaryMetrics {
  precision : Double
  recall : Double
  f1 : Double
}

///|
pub struct ConfusionMatrix {
  labels : Array[String]
  counts : Map[String, Map[String, Int]]
  mut total : Int
  mut correct : Int
}

///|
pub fn ConfusionMatrix::new(labels : Array[String]) -> ConfusionMatrix {
  { labels, counts: Map([]), total: 0, correct: 0 }
}

///|
pub fn ConfusionMatrix::add(
  self : ConfusionMatrix,
  actual : String,
  predicted : String,
) -> Unit {
  if !self.labels.contains(actual) {
    self.labels.push(actual)
  }
  if !self.labels.contains(predicted) {
    self.labels.push(predicted)
  }
  let predictions = match self.counts.get(actual) {
    Some(existing) => existing
    None => {
      let created = Map([])
      self.counts.set(actual, created)
      created
    }
  }
  let count = match predictions.get(predicted) {
    Some(existing) => existing + 1
    None => 1
  }
  predictions.set(predicted, count)
  self.total += 1
  if actual == predicted {
    self.correct += 1
  }
}

///|
pub fn ConfusionMatrix::count(
  self : ConfusionMatrix,
  actual : String,
  predicted : String,
) -> Int {
  match self.counts.get(actual) {
    Some(predictions) =>
      match predictions.get(predicted) {
        Some(count) => count
        None => 0
      }
    None => 0
  }
}

///|
pub struct ClassificationMetrics {
  accuracy : Double
  precision : Double
  recall : Double
  f1 : Double
  confusion_matrix : ConfusionMatrix
}

///|
/// Computes set-style precision, recall, and F1 for unique boundaries. A
/// zero predicted or gold boundary count produces `0.0` for its corresponding
/// metric, so empty inputs never produce `NaN` or infinity.
pub fn evaluate_boundary_metrics(
  predicted : Array[Int],
  gold : Array[Int],
) -> BoundaryMetrics {
  let predicted_unique = unique_boundaries(predicted)
  let gold_unique = unique_boundaries(gold)
  let mut true_positive = 0

  for boundary in predicted_unique {
    if gold_unique.contains(boundary) {
      true_positive += 1
    }
  }

  let precision = safe_ratio(true_positive, predicted_unique.length())
  let recall = safe_ratio(true_positive, gold_unique.length())
  { precision, recall, f1: harmonic_mean(precision, recall) }
}

///|
/// Computes macro-averaged precision, recall, and F1 over every observed
/// actual or predicted label. Every zero denominator is reported as `0.0`.
pub fn evaluate_classification(
  actual : Array[String],
  predicted : Array[String],
) -> Result[ClassificationMetrics, String] {
  if actual.length() != predicted.length() {
    return Err("actual and predicted labels must have equal length")
  }

  let labels = collect_labels(actual, predicted)
  let matrix = ConfusionMatrix::new(labels)
  for index in 0..<actual.length() {
    matrix.add(actual[index], predicted[index])
  }

  let mut precision_total = 0.0
  let mut recall_total = 0.0
  let mut f1_total = 0.0
  for label in matrix.labels {
    let true_positive = matrix.count(label, label)
    let mut predicted_total = 0
    let mut actual_total = 0
    for other_label in matrix.labels {
      predicted_total += matrix.count(other_label, label)
      actual_total += matrix.count(label, other_label)
    }
    let precision = safe_ratio(true_positive, predicted_total)
    let recall = safe_ratio(true_positive, actual_total)
    precision_total += precision
    recall_total += recall
    f1_total += harmonic_mean(precision, recall)
  }

  Ok({
    accuracy: safe_ratio(matrix.correct, matrix.total),
    precision: safe_average(precision_total, matrix.labels.length()),
    recall: safe_average(recall_total, matrix.labels.length()),
    f1: safe_average(f1_total, matrix.labels.length()),
    confusion_matrix: matrix,
  })
}

///|
fn unique_boundaries(boundaries : Array[Int]) -> Array[Int] {
  let unique = []
  for boundary in boundaries {
    if !unique.contains(boundary) {
      unique.push(boundary)
    }
  }
  unique
}

///|
fn safe_ratio(numerator : Int, denominator : Int) -> Double {
  if denominator == 0 {
    0.0
  } else {
    numerator.to_double() / denominator.to_double()
  }
}

///|
fn safe_average(total : Double, count : Int) -> Double {
  if count == 0 {
    0.0
  } else {
    total / count.to_double()
  }
}

///|
fn harmonic_mean(precision : Double, recall : Double) -> Double {
  let denominator = precision + recall
  if denominator == 0.0 {
    0.0
  } else {
    2.0 * precision * recall / denominator
  }
}

///|
fn collect_labels(
  actual : Array[String],
  predicted : Array[String],
) -> Array[String] {
  let labels = []
  for label in actual {
    if !labels.contains(label) {
      labels.push(label)
    }
  }
  for label in predicted {
    if !labels.contains(label) {
      labels.push(label)
    }
  }
  labels
}
