# MoonNLP OSC2026 Acceptance Closeout Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Align the current MoonNLP repository, generated interfaces, documentation, and next Mooncakes version so the project has reproducible acceptance evidence without fabricating provenance or rewriting GitHub history.

**Architecture:** Keep the existing `core`, `segment`, and `analysis` package boundaries unchanged. Update only module/release metadata, provenance documentation, and compiler-generated interface files; then validate the full multi-target toolchain and an external consumer module.

**Tech Stack:** Moon 0.1.20260713, Moonc v0.10.4, MoonBit packages, GitHub Actions, GitLink mirror, Mooncakes registry.

## Global Constraints

- Preserve the real Git history and do not rewrite GitHub commits.
- Do not invent lexicon sources, licenses, benchmarks, contributors, or release results.
- Do not add third-party dependencies or meaningless code.
- Keep `moon.mod` namespace `ppyq882/moonnlp` and Apache-2.0 licensing.
- Treat Mooncakes `0.2.0` as immutable; the current repository uses `0.3.0` as the next package version.
- If external credentials are unavailable, report the exact failure and do not claim publication or synchronization.

---

### Task 1: Align release metadata and provenance documentation

**Files:**
- Modify: `moon.mod`
- Modify: `README.md`
- Modify: `CHANGELOG.md`
- Modify: `segment/dict_data.mbt`
- Modify: `THIRD_PARTY_NOTICES.md`

**Interfaces:**
- Produces module version `0.3.0` and honest installation/release instructions for later publication and consumer checks.

- [ ] Change only the module version from `0.2.0` to `0.3.0`.
- [ ] Update README package wording so it identifies `0.2.0` as historical and gives `moon add ppyq882/moonnlp` as the install command for the latest registry version without claiming an unpublished version is already available.
- [ ] Add a dated `0.3.0` changelog entry covering the already-present HMM, summary, pipeline, examples, CI, and documentation work.
- [ ] Replace the dictionary comment's unverified public-domain/CC-CEDICT attribution with a conservative pointer to `THIRD_PARTY_NOTICES.md`.
- [ ] Make `THIRD_PARTY_NOTICES.md` explicitly state what is and is not proven about the bundled lexicon, and list the exact provenance evidence required before making stronger redistribution claims.
- [ ] Run `moon check --deny-warn --target all` and `moon test --deny-warn --target all`; expected result is 65 passed on each target and no failures.
- [ ] Commit as `docs: align MoonNLP 0.3.0 acceptance metadata`.

### Task 2: Regenerate and review public interface files

**Files:**
- Modify as generated: `analysis/pkg.generated.mbti`
- Modify as generated: `benchmarks/pkg.generated.mbti`
- Modify as generated: `cmd/demo/pkg.generated.mbti`
- Modify as generated: `cmd/main/pkg.generated.mbti`
- Modify as generated: `examples/document_pipeline/pkg.generated.mbti`
- Modify as generated: `examples/train_hmm/pkg.generated.mbti`
- Modify as generated: `core/pkg.generated.mbti`
- Modify as generated: `segment/pkg.generated.mbti`

**Interfaces:**
- Consumes the public APIs from Tasks 1 and existing source files.
- Produces interfaces matching `moon info --target all` under Moonc v0.10.4.

- [ ] Run `moon info --target all` from the repository root.
- [ ] Review the generated diff and confirm changes are generated formatting/API output only.
- [ ] Run `git diff --check`; expected result is no whitespace errors after the generated files are staged.
- [ ] Commit generated output as `chore: refresh MoonBit generated interfaces`.

### Task 3: Run the complete local acceptance gates

**Files:**
- Verify: all repository files; do not hand-edit generated output during this task.

**Interfaces:**
- Consumes the committed repository from Tasks 1 and 2.
- Produces command logs for the final acceptance matrix.

- [ ] Run `moon version --all`.
- [ ] Run `moon fmt --check`.
- [ ] Run `moon check --deny-warn --target all`.
- [ ] Run `moon build --target all` and `moon build --target native`.
- [ ] Run `moon test --deny-warn --target all` and `moon test --deny-warn --target native`.
- [ ] Run `moon run cmd/main`, `moon run examples/train_hmm`, `moon run examples/document_pipeline`, and `moon run benchmarks`.
- [ ] Run `git diff --check` and verify the worktree is clean.
- [ ] Commit no code during this task; record results in the final report.

### Task 4: Verify package consumption and authorized publication readiness

**Files:**
- Create outside the repository: disposable consumer module under the audit workspace.
- Verify: `moon.mod` and `README.md` package instructions.

**Interfaces:**
- Consumes `ppyq882/moonnlp@0.3.0` if published, or reports registry/authentication failure without claiming success.

- [ ] Create a disposable consumer module and run `moon add ppyq882/moonnlp --dry-run`.
- [ ] Import `ppyq882/moonnlp/segment` and run a small consumer program with `moon check --target native` and `moon run .`.
- [ ] If the authorized Mooncakes credential is available, publish the immutable `0.3.0` package; otherwise stop at readiness and report the blocker.
- [ ] Re-check GitHub/GitLink refs and the published package version after any authorized external action.
- [ ] Do not rewrite GitHub history or create virtual contributors.
