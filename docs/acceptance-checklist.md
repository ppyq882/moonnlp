# Local acceptance checklist

Run from the repository root before requesting review or an authorized release.

```powershell
moon version
moon fmt --check
moon check --deny-warn --target all
moon build --target all
moon test --deny-warn --target all
moon run cmd/main
moon run examples/train_hmm
moon run examples/document_pipeline
moon run benchmarks
moon info --target all
git diff --check
```

Review generated `pkg.generated.mbti` changes after `moon info`. Confirm that README commands, examples, limits, license notices, and changelog entries match the checked worktree. This checklist is local evidence only; it does not claim that a remote CI run, tag, GitHub/GitLink synchronization, Mooncakes publication, or release exists.
