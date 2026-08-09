///|
priv enum TokenClass {
  Chinese
  Whitespace
  Punctuation
  AsciiAlphanumeric
  Other
}

///|
fn classify_char(c : Char) -> TokenClass {
  if @core.is_chinese(c) {
    Chinese
  } else if @core.is_whitespace(c) {
    Whitespace
  } else if @core.is_punctuation(c) {
    Punctuation
  } else if c is ('a'..='z' | 'A'..='Z' | '0'..='9') {
    AsciiAlphanumeric
  } else {
    Other
  }
}

///|
fn is_chinese_char(c : Char) -> Bool {
  classify_char(c) is Chinese
}

///|
fn text_chars(text : String) -> Array[Char] {
  let chars = []
  for c in text {
    chars.push(c)
  }
  chars
}

///|
fn contains_chinese(chars : Array[Char]) -> Bool {
  for c in chars {
    if is_chinese_char(c) {
      return true
    }
  }
  false
}

///|
fn scan_non_chinese(chars : Array[Char], start : Int) -> (String, Int) {
  let n = chars.length()
  let c = chars[start]
  match classify_char(c) {
    Whitespace => {
      let mut token = ""
      let mut i = start
      while i < n && classify_char(chars[i]) is Whitespace {
        token += chars[i].to_string()
        i += 1
      }
      (token, i)
    }
    AsciiAlphanumeric => {
      let mut token = ""
      let mut i = start
      while i < n && classify_char(chars[i]) is AsciiAlphanumeric {
        token += chars[i].to_string()
        i += 1
      }
      (token, i)
    }
    Chinese | Punctuation | Other => (c.to_string(), start + 1)
  }
}

///|
fn segment_non_chinese(chars : Array[Char]) -> Array[String] {
  let result = []
  let mut i = 0
  while i < chars.length() {
    let (token, next) = scan_non_chinese(chars, i)
    result.push(token)
    i = next
  }
  result
}
