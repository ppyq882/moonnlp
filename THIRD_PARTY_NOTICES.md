# Third-party notices and references

## Code and runtime dependencies

This module's `moon.mod` contains no third-party package dependency declaration, and this review does not identify vendored third-party source code. The project uses the MoonBit standard toolchain and standard library as its build/runtime environment; those are not bundled into this repository by this change.

## Algorithmic references

- L. R. Rabiner, *A Tutorial on Hidden Markov Models and Selected Applications in Speech Recognition*, 1989. The HMM and Viterbi implementation is an independent MoonBit implementation informed by the algorithm, not a copied implementation. <https://doi.org/10.1109/5.18626>
- G. Salton and C. Buckley, *Term-Weighting Approaches in Automatic Text Retrieval*, 1988. TF-IDF design reference only. <https://doi.org/10.1016/0306-4573(88)90021-0>
- R. Mihalcea and P. Tarau, *TextRank: Bringing Order into Text*, 2004. Keyword-ranking design reference only. <https://aclanthology.org/W04-3252/>

## Bundled lexicon provenance limit

Comments in `segment/dict_data.mbt` describe the lexicon as curated from public-domain frequency corpora and CC-CEDICT. This repository currently has no pinned upstream snapshot, provenance manifest, demonstrable copied-data range, or license record for those entries. Therefore this document does not assert a specific upstream URL, license compatibility, public-domain status, or code/data reuse scope. A maintainer must establish that evidence before making stronger distribution or attribution claims.

## Acknowledgement

The references above acknowledge algorithmic prior work. They do not imply an endorsement by the cited authors or projects, and they do not claim that their source code was copied into MoonNLP.
