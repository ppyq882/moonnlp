///|
fn main {
  println("=============================================")
  println("    MoonNLP 自然语言处理库 (CCF OSC2026) 演示    ")
  println("=============================================")

  // 1. 分词展示与新词识别
  println("\n--- 1. 中文分词算法与未登录词识别 ---")
  let text = "我在北京大学学习自然语言处理，蓝精灵是一个新词汇。"
  println("输入文本: " + text)

  let dict_seg = @segment.DictSegmenter::new()
  let hmm_seg = @segment.HMMSegmenter::new()
  let hybrid_seg = @segment.HybridSegmenter::new()

  let dict_res = dict_seg.segment(text)
  let hmm_res = hmm_seg.segment(text)
  let hybrid_res = hybrid_seg.segment(text)

  println("字典匹配分词 (BiMM): " + format_tokens(dict_res))
  println("隐马尔可夫分词 (HMM): " + format_tokens(hmm_res))
  println("混合精密分词 (Hybrid): " + format_tokens(hybrid_res))

  // 2. 词性标注 (POS Tagger)
  println("\n--- 2. HMM 词性标注 (Part-of-Speech Tagging) ---")
  let pos_tagger = @segment.POSTagger::new()
  let sample_sentence = [
    "我", "在", "北京", "大学", "学习", "自然语言", "处理",
  ]
  let tags = pos_tagger.tag(sample_sentence)
  println("输入分词序列: " + format_tokens(sample_sentence))
  println("词性标注结果: " + format_tokens(tags))
  println("说明: r=代词, p=介词, n=名词, v=动词")

  // 3. 双数组前缀树 (Double Array Trie)
  println("\n--- 3. 双数组前缀树 (Double Array Trie) 检索 ---")
  let trie = @core.Trie::new()
  trie.insert("中华", 100)
  trie.insert("中华人民共和国", 200)
  let dat = @core.DoubleArrayTrie::build(trie)
  println(
    "DAT 检索 [中华]: " + format_option_int(dat.exact_match("中华")),
  )
  println(
    "DAT 检索 [中华人民共和国]: " +
    format_option_int(dat.exact_match("中华人民共和国")),
  )
  println(
    "DAT 检索 [中华人民]: " +
    format_option_int(dat.exact_match("中华人民")),
  )

  // 4. TF-IDF 与 TextRank 关键字对比
  println(
    "\n--- 4. 统计 (TF-IDF) 与 图排序 (TextRank) 关键词提取 ---",
  )
  let tfidf = @analysis.TFIDF::new()
  tfidf.add_document(["计算机", "编程", "语言", "自然语言", "处理"])
  tfidf.add_document([
    "自然语言", "处理", "机器学习", "深度", "学习",
  ])
  tfidf.add_document(["开发", "开源", "生态", "大赛", "生态系统"])

  let test_doc = [
    "自然语言", "处理", "开发", "自然语言", "大赛", "北京", "大学",
    "自然语言", "处理",
  ]
  println("当前文档: " + format_tokens(test_doc))

  let tfidf_keywords = tfidf.get_keywords(test_doc, 3)
  println("TF-IDF 提取 Top 3 关键词:")
  for i in 0..<tfidf_keywords.length() {
    let (word, score) = tfidf_keywords[i]
    println("  - " + word + ": " + score.to_string())
  }

  let tr = @analysis.TextRank::new()
  let tr_keywords = tr.extract_keywords(test_doc, 3)
  println("TextRank 提取 Top 3 关键词:")
  for i in 0..<tr_keywords.length() {
    let (word, score) = tr_keywords[i]
    println("  - " + word + ": " + score.to_string())
  }

  // 5. 文本编辑距离
  let s1 = "我在北京学习自然语言处理"
  let s2 = "我在上海学习自然语言处理"
  let lev_dist = @analysis.levenshtein_distance(s1, s2)
  println("\n文本1: " + s1)
  println("文本2: " + s2)
  println("编辑距离 (Levenshtein Distance): " + lev_dist.to_string())

  // 6. 朴素贝叶斯分类器
  println(
    "\n--- 5. 朴素贝叶斯文本分类器 (垃圾邮件/情感分类) ---",
  )
  let nb = @analysis.NaiveBayesClassifier::new()
  nb.train("垃圾邮件", [
    "恭喜", "中奖", "免费", "送", "大奖", "点击", "领取",
  ])
  nb.train("垃圾邮件", [
    "特价", "优惠", "买一送一", "点击", "链接", "免费",
  ])
  nb.train("正常邮件", [
    "你好", "今天", "开会", "讨论", "项目", "进度",
  ])
  nb.train("正常邮件", [
    "朋友", "一起", "吃饭", "学习", "编程", "谢谢",
  ])

  let test_mail1 = ["免费", "领取", "点击", "中奖"]
  let test_mail2 = ["今天", "开会", "讨论", "进度"]

  let pred1 = nb.predict(test_mail1)
  let pred2 = nb.predict(test_mail2)

  println(
    "邮件 1: [免费, 领取, 点击, 中奖] -> 预测: " +
    format_option_string(pred1),
  )
  println(
    "邮件 2: [今天, 开会, 讨论, 进度] -> 预测: " +
    format_option_string(pred2),
  )

  println("\n=============================================")
  println("             演示结束，运行一切正常！             ")
  println("=============================================")
}

// 辅助格式化函数

///|
fn format_tokens(tokens : Array[String]) -> String {
  let mut s = "["
  for i in 0..<tokens.length() {
    s += tokens[i]
    if i < tokens.length() - 1 {
      s += ", "
    }
  }
  s += "]"
  s
}

///|
fn format_option_string(opt : String?) -> String {
  match opt {
    Some(s) => s
    None => "None"
  }
}

///|
fn format_option_int(opt : Int?) -> String {
  match opt {
    Some(i) => i.to_string()
    None => "None"
  }
}
