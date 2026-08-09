# Task 4 Report: Unified Unicode Token Policy and POS Boundaries

## Scope and plan

- Worktree: `D:\Users\gunter\Documents\ChatGPT\潘永权验收1\moonnlp\.worktrees\osc2026`
- Branch/base: `codex/osc2026` at `d6673792c730390b0e84248860f948dd8ddb73d5`
- In scope: the shared internal token policy, segmenter integration, POS behavior, and the tests named in Task 4.
- Out of scope: HMM training statistics, analysis, CLI, CI, README, dependencies, and all remote operations.

## Initial findings

- The checkout is a clean linked worktree on the requested branch and base.
- Task 3 public API was inspected through `moon ide outline segment`, `moon ide doc @segment`, and `segment/pkg.generated.mbti` before considering any HMM boundary change. The public `HMMModel::train`, `HMMModel::try_train`, `HMMSegmenter::from_model`, and all existing segmenter/POS entry points must remain compatible.
- Existing tests cover an HMM non-Chinese fallback and an emoji non-empty result, but not the required concrete mixed-Unicode token contract or POS empty/unknown/repeated-training behavior.
- `HMMModel` training and its corpus-derived probability behavior are isolated in `segment/hmm_model.mbt`; Task 4 will not modify that file.
- `DictSegmenter` and `HMMSegmenter` each duplicate non-Chinese scanning. Their loops already use a single-character fallback when a non-alphanumeric character cannot form a word; a shared internal helper can centralize that exact progress guarantee.
- `POSTagger::tag` already returns `[]` for empty input. Its initialization currently overwrites a repeated `(word, tag)` dictionary frequency rather than accumulating it, so repeated dictionary training entries need a regression and minimal repair.

## TDD evidence

### RED tests added before policy integration

- `segment/segment_test.mbt` adds public, exact-output coverage for:
  - mixed Chinese/ASCII/digits with the required ASCII/whitespace/emoji/punctuation suffix;
  - pure emoji termination and token output;
  - whitespace and punctuation token boundaries across Dict, HMM, and Hybrid.
- `segment/pos_tagger_test.mbt` adds public coverage for empty input, an unknown token, and repeated unknown tokens.

The first new mixed-input assertion deliberately used one common full token sequence. `moon test segment --target all` produced the same failure on every target: `segment/segment_test.mbt:73`, `23 passed: 22, failed: 1`. Inspection showed that DictSegmenter legitimately selected a longer corpus dictionary entry for the Chinese prefix. This was not a missing token-policy behavior; changing production code to satisfy it would have violated the binding requirement to preserve dictionary priority.

The test was narrowed to the required non-Chinese suffix contract while leaving the corpus-trained Chinese prefix unconstrained. The corrected behavior is a compatibility baseline, not a completion claim: it guards the public policy contract while preserving Task 3 and dictionary semantics.

### GREEN implementation

- Added private `segment/token_policy.mbt` as the sole character-classification and non-Chinese scanning policy. It classifies Chinese, whitespace, punctuation, ASCII letters/digits, and other characters. Whitespace and ASCII runs advance through their full run; every other class consumes exactly one `Char`.
- Updated DictSegmenter, HMMSegmenter, and HybridSegmenter to use this policy. HMM now delegates its non-Chinese fallback and mixed-input scanning to the shared policy without changing `HMMModel` or its trained probabilities.
- Updated POSTagger dictionary loading to add repeated `(word, tag)` frequencies instead of overwriting them. Existing default tags and public APIs are unchanged.
- A first GREEN compile failed with `partial_match` at `token_policy.mbt:53`, because the internal scanner match omitted `Chinese`. The minimal defensive `Chinese` single-character branch was added; it maintains the no-stall invariant even if the private helper is called outside its normal domain.

### Fresh GREEN evidence

- `moon test segment --target all`: exit 0; 23 passed, 0 failed on each of wasm, wasm-gc, js, and native.
- `moon check --deny-warn --target all`: exit 0; all four targets completed with no warnings.
- `moon fmt --check`: exit 0.
- `moon info --target all`: exit 0; generated public interface had no content diff.
- `git diff --check`: exit 0.

## Commands and results

| Command | Exit | Result |
| --- | ---: | --- |
| `git rev-parse --git-dir; git rev-parse --git-common-dir; git branch --show-current; git status --short; git rev-parse HEAD` | 0 | Confirmed clean linked worktree, `codex/osc2026`, requested base. |
| `moon ide outline segment; moon ide doc '@segment'` | 0 | Inspected public interfaces before HMM work. |
| `moon test segment --target all` (baseline) | 0 | 17 passed, 0 failed on each of wasm, wasm-gc, js, and native. |
| `moon test segment --target all` (initial RED) | 1 | 22 passed, 1 failed on each target at the over-constrained Dict prefix assertion; preserved dictionary priority required narrowing the assertion. |
| `moon check --target all` (partial implementation) | 0 | Compiled with five expected unfinished-helper warnings; completed integration removed them. |
| `moon test segment --target all` (first GREEN) | 1 | Compiler rejected a partial internal `TokenClass` match; root cause and minimal defensive branch documented above. |
| `moon test segment --target all` (fresh GREEN) | 0 | 23 passed, 0 failed on wasm, wasm-gc, js, and native. |
| `moon check --deny-warn --target all` | 0 | Warning-free on all targets. |
| `moon fmt --check` | 0 | Formatting check passed. |
| `moon info --target all` | 0 | Interface generation succeeded with no public API content change. |
| `git diff --check` | 0 | No whitespace errors. |

## Self-review

- Confirmed Task 3 interfaces before HMM changes and did not modify `segment/hmm_model.mbt` or `segment/pkg.generated.mbti`.
- Confirmed all three segmenters share the same non-Chinese classifier/scanner and that the scanner advances at least one character in all branches.
- Confirmed dictionary longest-prefix/BIMM logic and Hybrid dictionary-first flow remain intact; the mixed-input test protects the shared suffix while avoiding assumptions about trained Chinese segmentation.
- Confirmed POS empty, unknown, and repeated public calls do not panic and preserve the existing default tag set. Repeated lexicon entries are accumulated internally for future/default corpus data rather than overwritten.
- Confirmed no analysis, CLI, CI, README, dependency, or remote operation is included in the content diff.

## Commit

`a4a59f4 feat(segment): unify Unicode token policy` created locally with `ppyq882 <302063962+ppyq882@users.noreply.github.com>`. No remote operation was performed.

## Concerns

- The default lexicon currently contains no duplicated `(word, tag)` entries, so the repeated-entry accumulation is a defensive regression fix. Public tests cover repeated tagger input; direct duplicate-entry injection is unavailable without expanding the public API, which is intentionally out of scope.
- Scope incident: a bare `moon fmt` was run once from the repository root before the scope guard was added. On this Windows checkout it refreshed line-ending/index metadata in unrelated `analysis/`, `core/`, `cmd/`, `moon.mod`, and lexicon paths. The controller verified `git diff --name-only` and raw diff contain no unrelated content changes. No out-of-scope path has been edited, normalized, reset, staged, or committed; subsequent formatting verification uses only `moon fmt --check`.

## Review fix: duplicate lexicon accumulation regression

- Reviewer finding: the existing repeated-unknown-token test invokes `tag()` repeatedly, so it cannot exercise duplicate `(word, tag)` lexicon loading or prove that the accumulated frequency affects an emission decision.
- Added the focused whitebox test `segment/pos_tagger_wbtest.mbt`. Its synthetic internal lexicon contains `("pivot", 5, "v")` twice, one competing `("pivot", 7, "n")` row, and fillers for every default tag. The second `v` row must be accumulated: the resulting one-token Viterbi decision is `v`; overwrite semantics leave only frequency 5 and select `n` instead. This validates an emission-driven selection change, not repeated tagger input.
- RED: after writing the test against the intended internal fixture, `moon test segment --target all` exited 1 on wasm, wasm-gc, js, and native with `POSTagger has no method from_lexicon` at `segment/pos_tagger_test.mbt:34`. The missing construction path was the expected failure before the fixture existed.
- The first private extraction deliberately retained that blackbox-test diagnostic: private methods are not visible to `*_test.mbt`. The fixture was therefore moved unchanged to `segment/pos_tagger_wbtest.mbt`, MoonBit's package-whitebox convention, rather than widening the helper's visibility.
- GREEN: extracted the existing default-dictionary initialization loop into private `POSTagger::from_lexicon`. `POSTagger::new()` now delegates to it with `get_default_dict()`, so the default tag set, default data, and public generated interface remain unchanged. The whitebox filename gives the test package-private access without a new public API.
- Fresh GREEN evidence: `moon test segment --target all` exited 0 with 24 passed, 0 failed on each of wasm, wasm-gc, js, and native.
- Final verification: `moon check --deny-warn --target all` exited 0 (four targets, 0 warnings/errors); `moon fmt --check` exited 0; `git diff --check` exited 0. The fixture remains private to the package and compiles as `segment/pos_tagger_wbtest.mbt`.
