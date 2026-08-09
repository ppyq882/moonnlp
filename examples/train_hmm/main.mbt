///|
fn main {
  let corpus = [
    ["南京", "长江", "大桥"],
    ["南京", "长江"],
    ["MoonBit", "处理", "文本"],
  ]
  match @segment.HMMModel::train(corpus) {
    Ok(model) => {
      let segmenter = @segment.HMMSegmenter::from_model(model)
      let tokens = segmenter.segment("南京长江大桥")
      println("trained HMM tokens=" + format_tokens(tokens))
    }
    Err(message) => println("HMM training error=" + message)
  }
}

///|
fn format_tokens(tokens : Array[String]) -> String {
  let result = StringBuilder()
  for index in 0..<tokens.length() {
    if index > 0 {
      result.write_string(", ")
    }
    result.write_string(tokens[index])
  }
  result.to_string()
}
