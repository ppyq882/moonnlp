# Contributing to MoonNLP

Keep changes focused, add behavior-level tests before production changes, and avoid modifying unrelated generated or line-ending-only paths. Every public API change requires generated-interface review after `moon info --target all`.

Before requesting review, run the commands in [docs/acceptance-checklist.md](docs/acceptance-checklist.md). Include the exact commands and outcomes in the change description. Examples and README snippets must be runnable from the repository root.

Do not add third-party code, corpus data, assets, licenses, benchmarks, or attributions without evidence of source, version or snapshot, license, and the scope of reuse. Do not turn unknown provenance into a factual notice.

Release and package publication require explicit maintainer authorization and valid platform secrets outside source control. A normal pull request must not depend on publication credentials. Update the changelog, rerun the full local gates, review generated interfaces, and verify the target remote before an authorized tag or publication action.
