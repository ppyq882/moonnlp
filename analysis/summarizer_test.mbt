///|
test "text summarizer basic extraction" {
  let doc =
    #|自然语言处理是计算机科学与人工智能领域的重要方向。
    #|它研究能实现人与计算机之间用自然语言进行有效通信的各种理论和方法。
    #|主要应用包括文本分类、机器翻译、信息检索和自动摘要。
    #|MoonBit 是专为 WebAssembly 打造的高性能现代编程语言。

  let summary = extract_summary(doc, 2)
  assert_true(summary.length() == 2)
}

///|
test "text summarizer suppresses duplicate sentences" {
  let summary = extract_summary(
    "人工智能推动产业升级。人工智能推动产业升级。科研团队发布新成果。",
    3,
  )
  assert_true(
    summary ==
    ["人工智能推动产业升级。", "科研团队发布新成果。"],
  )
}
