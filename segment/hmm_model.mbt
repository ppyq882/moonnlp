///|
pub struct HMMModel {
  pi : Array[Double]
  trans : Array[Array[Double]]
  emit : Map[Char, Array[Double]]
  unknown_emit : Array[Double]
}

///|
pub fn HMMModel::train(
  corpus : Array[Array[String]],
) -> Result[HMMModel, String] {
  HMMModel::try_train(corpus, 1.0)
}

///|
pub fn HMMModel::try_train(
  corpus : Array[Array[String]],
  smoothing : Double,
) -> Result[HMMModel, String] {
  if corpus.length() == 0 {
    return Err("HMM training corpus must not be empty")
  }
  if smoothing <= 0.0 || smoothing.is_nan() || smoothing.is_inf() {
    return Err("HMM smoothing must be positive")
  }
  for sentence in corpus {
    if sentence.length() == 0 {
      return Err("HMM training sentence must not be empty")
    }
    for token in sentence {
      let mut has_char = false
      for _ in token {
        has_char = true
        break
      }
      if !has_char {
        return Err("HMM training token must not be empty")
      }
    }
  }
  Ok(train_hmm_model(corpus, smoothing))
}

///|
fn train_hmm_model(
  corpus : Array[Array[String]],
  smoothing : Double,
) -> HMMModel {
  let initial_counts = Array::make(4, 0)
  let transition_counts = []
  for _ in 0..<4 {
    transition_counts.push(Array::make(4, 0))
  }
  let transition_totals = Array::make(4, 0)
  let emission_counts : Map[Char, Array[Int]] = Map([])
  let emission_totals = Array::make(4, 0)
  let vocabulary_seen : Map[Char, Unit] = Map([])
  let vocabulary = []

  for sentence in corpus {
    let sentence_chars = []
    let sentence_states = []
    for token in sentence {
      let token_chars = []
      for c in token {
        token_chars.push(c)
      }
      let token_length = token_chars.length()
      for i in 0..<token_length {
        sentence_chars.push(token_chars[i])
        if token_length == 1 {
          sentence_states.push(3)
        } else if i == 0 {
          sentence_states.push(0)
        } else if i == token_length - 1 {
          sentence_states.push(2)
        } else {
          sentence_states.push(1)
        }
      }
    }

    initial_counts[sentence_states[0]] += 1
    for i in 0..<sentence_chars.length() {
      let c = sentence_chars[i]
      let state = sentence_states[i]
      emission_totals[state] += 1
      let counts = match emission_counts.get(c) {
        Some(existing) => existing
        None => {
          let created = Array::make(4, 0)
          emission_counts.set(c, created)
          created
        }
      }
      counts[state] += 1
      match vocabulary_seen.get(c) {
        Some(_) => ()
        None => {
          vocabulary_seen.set(c, ())
          vocabulary.push(c)
        }
      }

      if i > 0 {
        let previous = sentence_states[i - 1]
        transition_counts[previous][state] += 1
        transition_totals[previous] += 1
      }
    }
  }

  let impossible = -1.0e300
  let pi = Array::make(4, impossible)
  let initial_denominator = corpus.length().to_double() + smoothing * 2.0
  pi[0] = @math.ln(
    (initial_counts[0].to_double() + smoothing) / initial_denominator,
  )
  pi[3] = @math.ln(
    (initial_counts[3].to_double() + smoothing) / initial_denominator,
  )

  let trans = []
  for state in 0..<4 {
    let row = Array::make(4, impossible)
    let denominator = transition_totals[state].to_double() + smoothing * 2.0
    if state == 0 || state == 1 {
      row[1] = @math.ln(
        (transition_counts[state][1].to_double() + smoothing) / denominator,
      )
      row[2] = @math.ln(
        (transition_counts[state][2].to_double() + smoothing) / denominator,
      )
    } else {
      row[0] = @math.ln(
        (transition_counts[state][0].to_double() + smoothing) / denominator,
      )
      row[3] = @math.ln(
        (transition_counts[state][3].to_double() + smoothing) / denominator,
      )
    }
    trans.push(row)
  }

  let emit : Map[Char, Array[Double]] = Map([])
  let unknown_emit = Array::make(4, 0.0)
  let emission_denominators = Array::make(4, 0.0)
  let smoothed_vocabulary_size = vocabulary.length().to_double() + 1.0
  for state in 0..<4 {
    let denominator = emission_totals[state].to_double() +
      smoothing * smoothed_vocabulary_size
    emission_denominators[state] = denominator
    unknown_emit[state] = @math.ln(smoothing / denominator)
  }
  for c in vocabulary {
    let counts = match emission_counts.get(c) {
      Some(existing) => existing
      None => Array::make(4, 0)
    }
    let probabilities = Array::make(4, 0.0)
    for state in 0..<4 {
      probabilities[state] = @math.ln(
        (counts[state].to_double() + smoothing) / emission_denominators[state],
      )
    }
    emit.set(c, probabilities)
  }

  { pi, trans, emit, unknown_emit }
}

///|
// The library entry point deliberately uses a neutral BMES prior.  Callers
// should train HMMModel with domain data when vocabulary-sensitive behaviour
// is required; the default must not encode a named example or lexicon.
fn default_hmm_model() -> HMMModel {
  let impossible = -1.0e300
  let pi = [@math.ln(0.99), impossible, impossible, @math.ln(0.01)]
  let trans = [
    [impossible, @math.ln(0.95), @math.ln(0.05), impossible],
    [impossible, @math.ln(0.95), @math.ln(0.05), impossible],
    [@math.ln(0.5), impossible, impossible, @math.ln(0.5)],
    [impossible, impossible, impossible, @math.ln(1.0)],
  ]
  let emit : Map[Char, Array[Double]] = Map([])
  let unknown_emit = [0.0, 0.0, 0.0, 0.0]
  { pi, trans, emit, unknown_emit }
}
