# Known Patterns

_Recurring findings promoted from /retro pattern detection. Read by @dev (preservation) and @security (elevated attention)._

| Pattern | Severity | Cycles | Description | Detected |
|---------|----------|--------|-------------|----------|
| ADR-spec drift on parameterized artifacts | WARNING | v1.2, v2.0 (C8/B2/A3), v2.0.2 (S1) | When a spec, ADR, or release artifact describes a parameterized list (category count, feature checklist, CHANGELOG entry), implementations ship with placeholder values or subsets instead of the final computed value. Mitigation strengthened (v2.0.x): byte-comparison of frozen list text against live source file required at Phase 5, not cardinality check alone. | 2026-05-07 |
| Cumulative-feature shipping with external-trigger workflow gating produces post-merge layer-onions | WARNING | v2.0.0 (1-cycle, watch v2.1+) | When a feature includes a new long-running workflow (cron + workflow_dispatch + multi-step), each post-merge BLOCKER masks the next layer because all prior layers must be fixed before the next one is visible. v2.0.x produced a 5-layer onion: YAML structure → hallucinated SHA → missing auth → repo permission → subshell scope. Mitigation: any cycle adding a new external-trigger workflow MUST include a dry-run job at the same PR exercising ≥2 representative e2e paths before Phase 7 APPROVED. | 2026-05-06 |
