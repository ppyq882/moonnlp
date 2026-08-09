///|
pub struct SentenceSplitter {}

///|
pub fn SentenceSplitter::new() -> SentenceSplitter {
  SentenceSplitter::{  }
}

///|
pub fn SentenceSplitter::split(
  _self : SentenceSplitter,
  text : String,
) -> Array[String] {
  let sentences = []
  let mut current = ""
  let mut has_content = false
  let mut ends_sentence = false

  for character in text {
    if ends_sentence && !is_sentence_terminator(character) {
      add_sentence(sentences, current, has_content)
      current = ""
      has_content = false
      ends_sentence = false
    }

    if is_sentence_terminator(character) {
      if has_content {
        current += character.to_string()
        ends_sentence = true
      }
    } else {
      current += character.to_string()
      if !is_whitespace(character) {
        has_content = true
      }
    }
  }

  add_sentence(sentences, current, has_content)
  sentences
}

///|
fn is_sentence_terminator(character : Char) -> Bool {
  character == '。' ||
  character == '！' ||
  character == '？' ||
  character == '.' ||
  character == '!' ||
  character == '?'
}

///|
fn is_whitespace(character : Char) -> Bool {
  character == ' ' ||
  character == '\n' ||
  character == '\r' ||
  character == '\t'
}

///|
fn add_sentence(
  sentences : Array[String],
  current : String,
  has_content : Bool,
) -> Unit {
  if has_content {
    let sentence = current.trim().to_owned()
    if sentence.length() > 0 {
      sentences.push(sentence)
    }
  }
}
