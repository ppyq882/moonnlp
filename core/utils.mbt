///|
pub fn is_chinese(c : Char) -> Bool {
  let val = c.to_int()
  (val >= 0x4E00 && val <= 0x9FFF) || 
  (val >= 0x3400 && val <= 0x4DBF) || 
  (val >= 0x20000 && val <= 0x2A6DF) ||
  (val >= 0xF900 && val <= 0xFAFF)
}

///|
pub fn is_alphanumeric(c : Char) -> Bool {
  (c >= 'a' && c <= 'z') || 
  (c >= 'A' && c <= 'Z') || 
  (c >= '0' && c <= '9')
}

///|
pub fn is_whitespace(c : Char) -> Bool {
  c == ' ' || c == '\t' || c == '\n' || c == '\r' || c == '\u00A0' || c == '\u3000'
}

///|
pub fn is_punctuation(c : Char) -> Bool {
  let val = c.to_int()
  // ASCII punctuation
  (val >= 33 && val <= 47) || 
  (val >= 58 && val <= 64) || 
  (val >= 91 && val <= 96) || 
  (val >= 123 && val <= 126) ||
  // Chinese and common Unicode punctuation
  is_chinese_punctuation(c)
}

///|
pub fn is_chinese_punctuation(c : Char) -> Bool {
  let val = c.to_int()
  val == 0x3002 || // 。
  val == 0xFF0C || // ，
  val == 0xFF01 || // ！
  val == 0xFF1F || // ？
  val == 0xFF1B || // ；
  val == 0xFF1A || // ：
  val == 0x3001 || // 、
  val == 0x201C || // “
  val == 0x201D || // ”
  val == 0x2018 || // ‘
  val == 0x2019 || // ’
  val == 0x300A || // 《
  val == 0x300B || // 》
  val == 0x3008 || // 〈
  val == 0x3009 || // 〉
  val == 0x3010 || // 【
  val == 0x3011 || // 】
  val == 0xFF08 || // （
  val == 0xFF09 || // ）
  val == 0x2014 || // —
  val == 0x2026    // …
}
