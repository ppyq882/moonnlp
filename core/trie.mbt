///|
pub struct TrieNode[T] {
  children : Map[Char, TrieNode[T]]
  mut value : T?
}

///|
pub fn[T] TrieNode::new() -> TrieNode[T] {
  { children: Map([]), value: None }
}

///|
pub struct Trie[T] {
  root : TrieNode[T]
}

///|
pub fn[T] Trie::new() -> Trie[T] {
  { root: TrieNode::new() }
}

///|
pub fn[T] Trie::insert(self : Trie[T], key : String, value : T) -> Unit {
  let mut curr = self.root
  for c in key {
    match curr.children.get(c) {
      Some(next) => curr = next
      None => {
        let next = TrieNode::new()
        curr.children.set(c, next)
        curr = next
      }
    }
  }
  curr.value = Some(value)
}

///|
pub fn[T] Trie::get(self : Trie[T], key : String) -> T? {
  let mut curr = self.root
  for c in key {
    match curr.children.get(c) {
      Some(next) => curr = next
      None => return None
    }
  }
  curr.value
}

///|
pub fn[T] Trie::contains(self : Trie[T], key : String) -> Bool {
  match self.get(key) {
    Some(_) => true
    None => false
  }
}

///|
/// Returns the length of the longest matching prefix starting at `start_idx`.
/// Returns 0 if no match is found.
pub fn[T] Trie::longest_prefix(
  self : Trie[T],
  chars : Array[Char],
  start_idx : Int,
) -> Int {
  let mut curr = self.root
  let mut longest_len = 0
  let mut current_len = 0

  for i in start_idx..<chars.length() {
    let c = chars[i]
    match curr.children.get(c) {
      Some(next) => {
        curr = next
        current_len += 1
        match curr.value {
          Some(_) => longest_len = current_len
          None => ()
        }
      }
      None => break
    }
  }

  longest_len
}

///|
/// Returns all matching prefix lengths starting at `start_idx`.
pub fn[T] Trie::all_prefixes(
  self : Trie[T],
  chars : Array[Char],
  start_idx : Int,
) -> Array[Int] {
  let result = []
  let mut curr = self.root
  let mut current_len = 0

  for i in start_idx..<chars.length() {
    let c = chars[i]
    match curr.children.get(c) {
      Some(next) => {
        curr = next
        current_len += 1
        match curr.value {
          Some(_) => result.push(current_len)
          None => ()
        }
      }
      None => break
    }
  }

  result
}
