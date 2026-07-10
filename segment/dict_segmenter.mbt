///|
pub struct DictSegmenter {
  trie : @core.Trie[Unit]
  trie_rev : @core.Trie[Unit]
}

///|
pub fn DictSegmenter::new() -> DictSegmenter {
  let seg = {
    trie: @core.Trie::new(),
    trie_rev: @core.Trie::new()
  }
  
  let default_dict = get_default_dict()
  for item in default_dict {
    let (w, _, _) = item
    seg.add_word(w)
  }
  
  seg
}

///|
pub fn DictSegmenter::add_word(self : DictSegmenter, word : String) -> Unit {
  self.trie.insert(word, ())
  // Reverse the word
  let mut rev_word = ""
  for c in word {
    rev_word = c.to_string() + rev_word
  }
  self.trie_rev.insert(rev_word, ())
}

///|
pub fn DictSegmenter::fmm(self : DictSegmenter, text : String) -> Array[String] {
  let chars = []
  for c in text {
    chars.push(c)
  }
  fmm_chars(self.trie, chars)
}

///|
pub fn DictSegmenter::bmm(self : DictSegmenter, text : String) -> Array[String] {
  let chars = []
  for c in text {
    chars.push(c)
  }
  let rev_chars = []
  for i in 0..<chars.length() {
    rev_chars.push(chars[chars.length() - 1 - i])
  }
  
  let rev_tokens = fmm_chars(self.trie_rev, rev_chars)
  let result = []
  for i in 0..<rev_tokens.length() {
    let tok = rev_tokens[rev_tokens.length() - 1 - i]
    let mut rev_tok = ""
    for c in tok {
      rev_tok = c.to_string() + rev_tok
    }
    result.push(rev_tok)
  }
  result
}

///|
pub fn DictSegmenter::bimm(self : DictSegmenter, text : String) -> Array[String] {
  let fmm_res = self.fmm(text)
  let bmm_res = self.bmm(text)
  
  if fmm_res == bmm_res {
    return fmm_res
  }
  
  // Heuristic: compare word counts
  if fmm_res.length() < bmm_res.length() {
    return fmm_res
  } else if bmm_res.length() < fmm_res.length() {
    return bmm_res
  }
  
  // Heuristic: compare single character counts
  let fmm_single_count = count_single_chars(fmm_res)
  let bmm_single_count = count_single_chars(bmm_res)
  
  if fmm_single_count < bmm_single_count {
    fmm_res
  } else {
    bmm_res
  }
}

///|
pub fn DictSegmenter::segment(self : DictSegmenter, text : String) -> Array[String] {
  self.bimm(text)
}

///|
fn count_single_chars(tokens : Array[String]) -> Int {
  let mut count = 0
  for t in tokens {
    let chars = []
    for c in t {
      chars.push(c)
    }
    if chars.length() == 1 && @core.is_chinese(chars[0]) {
      count += 1
    }
  }
  count
}

///|
fn fmm_chars(trie : @core.Trie[Unit], chars : Array[Char]) -> Array[String] {
  let result = []
  let mut i = 0
  let n = chars.length()
  
  while i < n {
    let c = chars[i]
    if @core.is_chinese(c) {
      let len = trie.longest_prefix(chars, i)
      if len > 0 {
        let mut word = ""
        for j in 0..<len {
          word += chars[i + j].to_string()
        }
        result.push(word)
        i += len
      } else {
        result.push(c.to_string())
        i += 1
      }
    } else if @core.is_whitespace(c) {
      let mut ws = ""
      let mut j = i
      while j < n && @core.is_whitespace(chars[j]) {
        ws += chars[j].to_string()
        j += 1
      }
      result.push(ws)
      i = j
    } else if @core.is_punctuation(c) {
      result.push(c.to_string())
      i += 1
    } else {
      let mut word = ""
      let mut j = i
      while j < n && @core.is_alphanumeric(chars[j]) {
        word += chars[j].to_string()
        j += 1
      }
      result.push(word)
      i = j
    }
  }
  
  result
}
