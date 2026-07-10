# MoonNLP

**MoonNLP** 是一个使用纯 MoonBit 语言编写的高性能、面向 WebAssembly 原生、易于扩展的自然语言处理（NLP）核心库。它填补了 MoonBit 生态在文本分词、统计语言模型、文本分类及相似度计算等底层基础算法上的空白，为跨平台的网页端、云端及 Native 应用提供高效、开箱即用的自然语言处理基础设施。

**MoonNLP** is a high-performance, Wasm-native, extensible Natural Language Processing (NLP) library implemented in pure MoonBit. It fills the gap in the MoonBit ecosystem for text tokenization, statistical language models, text classification, and text similarity metrics.

---

## 项目特色 | Key Features

*   **多源中文分词 (Chinese Word Tokenizer)**:
    *   **基于 Trie 前缀树的字典匹配**: 支持前向最大匹配 (FMM)、后向最大匹配 (BMM) 和双向最大匹配 (BiMM) Heuristic 分词。
    *   **隐马尔可夫模型 (HMM)**: 基于 Viterbi 算法进行动态序列标注，有效解决未登录词 (OOV, Out-Of-Vocabulary) 识别难题。
    *   **混合分词器 (Hybrid Segmenter)**: 结合字典分词的高速性与 HMM 的未登录词识别能力，实现类似 Jieba 精确模式的高精度分词。
*   **关键字提取 (TF-IDF Vectorizer)**: 支持词频-逆文档频率计算，支持文本文档的向量空间表示与核心关键字提取。
*   **经典文本分类器 (Naive Bayes Classifier)**: 内置 Laplace 平滑的朴素贝叶斯多分类模型，适用于垃圾邮件拦截、文本分类和情感分析。
*   **文本相似度计算 (Text Similarity)**: 包含 Unicode 安全的编辑距离 (Levenshtein Distance) 和余弦相似度 (Cosine Similarity) 计算。
*   **Wasm-Native & Zero-FFI**: 100% 纯 MoonBit 原生代码实现，不依赖任何外部 C/C++ 库或 JS 环境，完全支持编译到 WebAssembly (wasm-gc)、JavaScript 及 Native 环境，且编译无任何 Warning。

---

## 项目结构 | Directory Structure

```
moonnlp/
├── moon.mod                  # 模块元数据定义
├── LICENSE                   # Apache License 2.0 授权文件
├── README.md                 # 项目详细说明文档
├── .github/workflows/ci.yml  # GitHub Actions 自动化流水线
├── core/                     # 核心通用包
│   ├── trie.mbt              # 前缀树（Trie Tree）结构与前缀搜索
│   └── utils.mbt             # Unicode 字符分类及半角全角判定
├── segment/                  # 分词算法包
│   ├── segment.mbt           # 分词器接口定义 (Segmenter Trait)
│   ├── dict_segmenter.mbt    # 前向、后向、双向最大匹配分词器
│   ├── hmm_segmenter.mbt     # HMM 维特比分词器 (用于 OOV 新词识别)
│   └── hybrid_segmenter.mbt  # 混合分词器 (类似 Jieba 精确分词模式)
├── analysis/                 # 文本分析与机器学习包
│   ├── tfidf.mbt             # TF-IDF 关键词提取
│   ├── similarity.mbt        # 余弦相似度与编辑距离
│   └── classifier.mbt        # 朴素贝叶斯文本分类器
└── cmd/
    └── main/
        └── main.mbt          # 交互式 CLI 演示入口
```

---

## 快速上手 | Quick Start

### 1. 中文分词 (Word Segmentation)

```moonbit
let text = "我在北京大学学习自然语言处理，蓝精灵是一个新词汇。"
let hybrid_seg = @segment.HybridSegmenter::new()
let tokens = hybrid_seg.segment(text)
// tokens: ["我", "在", "北京", "大学", "学", "习", "自然语言处理", "，", "蓝精灵", "是", "一", "个", "新词", "汇", "。"]
```

### 2. 关键词提取 (TF-IDF Keyword Extraction)

```moonbit
let tfidf = @analysis.TFIDF::new()

// 1. 模拟语料库训练
tfidf.add_document(["计算机", "编程", "语言", "自然语言", "处理"])
tfidf.add_document(["自然语言", "处理", "机器学习", "深度", "学习"])
tfidf.add_document(["开发", "开源", "生态", "大赛", "生态系统"])

// 2. 对目标文档提取 Top 3 关键词
let doc = ["自然语言", "处理", "开发", "自然语言", "大赛"]
let keywords = tfidf.get_keywords(doc, 3)
```

### 3. 朴素贝叶斯分类器 (Naive Bayes Classifier)

```moonbit
let nb = @analysis.NaiveBayesClassifier::new()

// 1. 模型训练 (模型为在线增量训练)
nb.train("垃圾邮件", ["恭喜", "中奖", "免费", "送", "大奖", "点击", "领取"])
nb.train("正常邮件", ["你好", "今天", "开会", "讨论", "项目", "进度"])

// 2. 模型预测
let pred = nb.predict(["免费", "领取", "点击", "中奖"]) // Some("垃圾邮件")
```

---

## 编译、运行与测试 | Build, Run and Test

本项目遵循 MoonBit 官方工具链标准：

```bash
# 1. 运行代码检查 (确保无任何警告或报错)
moon check --target js

# 2. 运行所有单元测试 (包含词典匹配、HMM 序列标注、朴素贝叶斯和 TF-IDF 的测试)
moon test --target js

# 3. 运行命令行演示程序
moon run cmd/main --target js
```

---

## 开源协议与合规声明 | Open Source License & Compliance

本项目采用 **Apache License 2.0** 授权许可协议。

### 人机协作开发回顾 (Human-AI Co-creation Retrospective)

本项目作为 2026 MoonBit 国产基础软件生态开源大赛 (OSC2026) 的参赛作品，完全由参赛开发者与 AI 编码助手 (Gemini/Antigravity) 合作完成。人机协作形式分工如下：
1. **架构与方案设计 (人类)**: 提出构建一款可移植的纯 MoonBit NLP 底座库，明确将分词拆分为字典与 HMM 分离设计，并在应用层加入 TF-IDF 与 Naive Bayes 分类器。
2. **代码编写与类型推导 (AI & 人类)**: AI 负责编写各个算法的核心细节，并严格遵循 MoonBit 最新的泛型与方法定义语法（如 `fn[T] Type::meth` 格式）；人类进行局部测试和边界微调。
3. **工程优化与零警告检验 (AI & 人类)**: AI 配合本地 MoonBit 编译器，在 tight-loop 中对不推荐语法（如 `size()`, `not()`, `f!(..)` 及 `a..b` 范围）进行修正，最终达成 100% 编译通过且 0 编译器警告的高标准工程目标。