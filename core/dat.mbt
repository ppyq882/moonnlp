///|
pub struct DoubleArrayTrie[T] {
  base : Array[Int]
  check : Array[Int]
  values : Array[T?]
}

///|
pub fn[T] DoubleArrayTrie::new() -> DoubleArrayTrie[T] {
  {
    base: Array::make(10, 0),
    check: Array::make(10, -1),
    values: Array::make(10, None),
  }
}

///|
pub fn[T] DoubleArrayTrie::exact_match(
  self : DoubleArrayTrie[T],
  key : String,
) -> T? {
  let mut state = 0
  for c in key {
    let code = c.to_int()
    let next = self.base[state] + code
    if next >= 0 && next < self.check.length() && self.check[next] == state {
      state = next
    } else {
      return None
    }
  }
  if state >= 0 && state < self.values.length() {
    self.values[state]
  } else {
    None
  }
}

///|
pub fn[T] DoubleArrayTrie::longest_prefix(
  self : DoubleArrayTrie[T],
  chars : Array[Char],
  start_idx : Int,
) -> Int {
  let mut state = 0
  let mut longest_len = 0
  let mut current_len = 0

  for i in start_idx..<chars.length() {
    let c = chars[i]
    let code = c.to_int()
    let next = self.base[state] + code
    if next >= 0 && next < self.check.length() && self.check[next] == state {
      state = next
      current_len += 1
      if state < self.values.length() {
        match self.values[state] {
          Some(_) => longest_len = current_len
          None => ()
        }
      }
    } else {
      break
    }
  }

  longest_len
}

///|
priv struct QueueEntry[T] {
  node : TrieNode[T]
  dat_idx : Int
}

///|
/// Compiles a standard Trie into a Double Array Trie.
pub fn[T] DoubleArrayTrie::build(trie : Trie[T]) -> DoubleArrayTrie[T] {
  let mut base = Array::make(1024, 0)
  let mut check = Array::make(1024, -1)
  let mut values : Array[T?] = Array::make(1024, None)

  let queue = []
  queue.push({ node: trie.root, dat_idx: 0 })

  let mut head = 0
  while head < queue.length() {
    let entry = queue[head]
    head += 1

    let parent = entry.node
    let p_idx = entry.dat_idx

    // Find all children and their char codes
    let children_chars = []
    for c, _ in parent.children {
      children_chars.push(c)
    }

    if children_chars.length() == 0 {
      continue
    }

    // Find a suitable base value
    let mut base_val = 1
    let mut found = false
    while !found {
      let mut ok = true
      for c in children_chars {
        let code = c.to_int()
        let next_idx = base_val + code

        // Resize arrays if index is out of bounds
        if next_idx >= check.length() {
          let new_len = next_idx * 2
          base = resize_int_array(base, new_len, 0)
          check = resize_int_array(check, new_len, -1)
          values = resize_val_array(values, new_len)
        }

        if check[next_idx] != -1 {
          ok = false
          break
        }
      }

      if ok {
        found = true
      } else {
        base_val += 1
      }
    }

    // Set base for parent
    base[p_idx] = base_val

    // Set check and value for children, and push them to queue
    for c in children_chars {
      let code = c.to_int()
      let next_idx = base_val + code
      let child_node = parent.children.get(c).unwrap()

      check[next_idx] = p_idx
      values[next_idx] = child_node.value

      queue.push({ node: child_node, dat_idx: next_idx })
    }
  }

  { base, check, values }
}

///|
fn resize_int_array(
  arr : Array[Int],
  new_len : Int,
  default : Int,
) -> Array[Int] {
  let new_arr = Array::make(new_len, default)
  for i in 0..<arr.length() {
    new_arr[i] = arr[i]
  }
  new_arr
}

///|
fn[T] resize_val_array(arr : Array[T?], new_len : Int) -> Array[T?] {
  let new_arr = Array::make(new_len, None)
  for i in 0..<arr.length() {
    new_arr[i] = arr[i]
  }
  new_arr
}
