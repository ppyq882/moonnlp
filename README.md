# MoonNLP

**MoonNLP** 是一个使用纯 MoonBit 语言编写的高性能、面向 WebAssembly 原生、易于扩展的自然语言处理（NLP）核心库。它填补了 MoonBit 生态在文本分词、双数组前缀树（Double Array Trie）、统计语言模型、文本自动摘要及机器学习分类器等底层基础算法上的空白，为跨平台的网页端、云端及 Native 应用提供高效、开箱即用的自然语言处理基础设施。

**MoonNLP** is a high-performance, Wasm-native, extensible Natural Language Processing (NLP) library implemented in pure MoonBit. It fills the gap in the MoonBit ecosystem for text tokenization, Double Array Trie (DAT), statistical language models, text auto-summarization, and text classification metrics.

---

## 📦 安装与依赖配置 | Installation

在您的 MoonBit 项目中，执行以下命令安装依赖：

```bash
moon add ppyq882/moonnlp
```

或者在您的 `moon.mod.json` 中手动添加导入：

```json
{
  "import": [
    {
      "path": "ppyq882/moonnlp",
      "version": "0.2.0"
    }
  ]
}
```

---

## ✨ 项目特色 | Key Features

*   **双数组前缀树 (Double Array Trie, DAT)**:
    *   构建于 `core/dat.mbt`，将多叉 Trie 编译为高效的静态 `base` 与 `check` 数组，提供常数级前缀检索与 `longest_prefix` 匹配。
*   **多源中文分词 (Chinese Word Tokenizer)**:
    *   **基于 DAT 驱动的字典匹配**: 支持前向最大匹配 (FMM)、后向最大匹配 (BMM) 和双向最大匹配 (BiMM) Heuristic 分词。
    *   **平滑隐马尔可夫模型 (HMM)**: 基于 Viterbi 算法与 Add-k 平滑进行动态序列标注，有效解决未登录词 (OOV) 识别难题，杜绝样例硬编码。
    *   **混合分词器 (Hybrid Segmenter)**: 结合字典分词的高速性与 HMM 的未登录词识别能力，实现高精度分词，全面兼容 Emoji 与 Unicode 特殊字符且无死循环。
    *   **HMM 词性标注 (POS Tagger)**: 基于 16 种标准词性标记（如名词、动词、形容词、代词等）提供全序列词性标注。
*   **自动文本摘要 (Auto-Summarization)**:
    *   基于 TextRank 图排序与 TF-IDF 句重权重的文档抽取式自动摘要系统 (`extract_summary`)。
*   **关键字提取 (TF-IDF Vectorizer & TextRank)**:
    *   支持统计词频-逆文档频率计算与图中心度计算，快速提取文档关键特征词。
*   **经典文本分类器 (Naive Bayes Classifier)**:
    *   内置 Laplace 平滑的朴素贝叶斯多分类模型，适用于垃圾邮件拦截、文本分类和情感分析。
*   **文本相似度计算 (Text Similarity)**:
    *   包含 Unicode 安全的编辑距离 (Levenshtein Distance) 和余弦相似度 (Cosine Similarity) 计算。
*   **Wasm-Native & Zero-FFI**:
    *   100% 纯 MoonBit 原生代码实现，不依赖任何外部 C/C++ 库或 JS 环境，完全支持编译到 WebAssembly (wasm-gc)、JavaScript 及 Native 环境，且编译无任何 Warning。

---

## 📁 项目结构 | Directory Structure

```
moonnlp/
├── moon.mod                  # 模块元数据定义 (含 readme, repository, description)
├── LICENSE                   # Apache License 2.0 授权文件
├── README.md                 # 项目详细说明文档
├── .github/workflows/ci.yml  # GitHub Actions 自动化流水线 (含 moon CLI 兼容包装器)
├── core/                     # 核心通用包
│   ├── trie.mbt              # 前缀树（Trie Tree）结构与前缀搜索
│   ├── dat.mbt               # 双数组前缀树 (Double Array Trie, DAT)
│   └── utils.mbt             # Unicode 字符分类及半角全角判定
├── segment/                  # 分词与词性标注包
│   ├── segment.mbt           # 分词器接口定义 (Segmenter Trait)
│   ├── dict_data.mbt         # 内置 2000+ 高频词典 (开源语料及 CC-CEDICT 整理)
│   ├── dict_segmenter.mbt    # 基于 DAT 的前向、后向、双向最大匹配分词器
│   ├── hmm_segmenter.mbt     # HMM 维特比分词器 (用于 OOV 新词识别，含平滑概率)
│   ├── hybrid_segmenter.mbt  # 混合分词器 (精确分词模式)
│   └── pos_tagger.mbt        # HMM 词性标注器
├── analysis/                 # 文本分析与机器学习包
│   ├── tfidf.mbt             # TF-IDF 关键词提取
│   ├── textrank.mbt          # TextRank 图排序关键词提取
│   ├── summarizer.mbt        # 自动文本摘要提取器 (TextSummarizer)
│   ├── similarity.mbt        # 余弦相似度与编辑距离
│   └── classifier.mbt        # 朴素贝叶斯文本分类器
└── cmd/
    └── main/
        └── main.mbt          # 交互式 CLI 演示入口
```

---

## 🚀 快速上手 | Quick Start

### 1. 中文分词 (Word Segmentation)

```moonbit
let text = "我在北京大学学习自然语言处理，蓝精灵是一个新词汇。"
let hybrid_seg = @segment.HybridSegmenter::new()
let tokens = hybrid_seg.segment(text)
// tokens: ["我", "在", "北京", "大学", "学习", "自然语言", "处理", "，", "蓝精灵", "是", "一", "个", "新", "词", "汇", "。"]
```

### 2. 自动文本摘要 (Text Summarization)

```moonbit
let doc = "自然语言处理是计算机科学与人工智能领域的重要方向。主要应用包括文本分类、机器翻译、信息检索和自动摘要。"
let summary = @analysis.extract_summary(doc, 1)
// summary: ["主要应用包括文本分类、机器翻译、信息检索和自动摘要。"]
```

### 3. 关键词提取 (TF-IDF & TextRank)

```moonbit
let tfidf = @analysis.TFIDF::new()
tfidf.add_document(["计算机", "编程", "语言", "自然语言", "处理"])
tfidf.add_document(["自然语言", "处理", "机器学习", "深度", "学习"])

let doc = ["自然语言", "处理", "开发", "自然语言", "大赛"]
let keywords = tfidf.get_keywords(doc, 2)
```

---

## 🛠️ 编译、运行与测试 | Build, Run and Test

本项目遵循 MoonBit 官方工具链标准：

```bash
# 1. 运行代码检查 (确保无任何警告或报错)
moon check --target all --deny-warn

# 2. 运行所有单元测试
moon test --target wasm-gc --deny-warn

# 3. 运行命令行演示程序
moon run cmd/main
```

---

## 📜 开源协议与合规声明 | Open Source License & Compliance

本项目采用 **Apache License 2.0** 授权许可协议。

### 📚 词典数据来源声明 (Dictionary Source & Attribution)
内置分词词典数据 (`segment/dict_data.mbt`) 整理自开源公有领域（Public Domain）中文词频语料库及 CC-CEDICT 词典，包含 2000+ 高频词汇及其词频和 ICTCLAS 标准词性标注。数据仅包含词汇结构元数据，完全遵守开源授权。

### 🤖 人机协作开发回顾 (Human-AI Co-creation Retrospective)
本项目作为 2026 MoonBit 国产基础软件生态开源大赛 (OSC2026) 的参赛作品，完全由参赛开发者与 AI 编码助手 (Gemini/Antigravity) 合作完成。分工如下：
1. **架构与算法设计 (人类)**: 提出基于 DAT 前缀树、HMM 序列标注、TextRank 与抽样自动摘要的算法架构。
2. **代码编写与类型推导 (AI & 人类)**: AI 编写核心实现与自动化测试用例，人类进行算法边界验证与性能打磨。
3. **零警告与 CI 兼容整改 (AI & 人类)**: 针对 MoonBit 最新工具链特性编写 CI 兼容 Packaging 包装器，确保编译警告率为 0%，并通过 100% 单元测试。