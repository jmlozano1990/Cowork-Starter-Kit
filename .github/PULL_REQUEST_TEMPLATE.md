## Summary

<!-- One-paragraph description of what this PR changes and why. -->

## Test plan

<!-- Steps to verify the changes work as expected. For CI-only changes, describe which jobs cover the change. -->

## Agency-Sync Checklist

<!-- Complete this section ONLY if this PR has the `agency-sync` label. Skip entirely for other PRs. -->

<details>
<summary>Agency-Sync Review Checklist (required when <code>agency-sync</code> label is present)</summary>

- [ ] Reviewed `cowork.lock.json` diff — verified no unexpected files added
- [ ] Sample-audited ≥3 files per allowed category against S1 regex set (`docs/security/upstream-content-scan-rules.md`)
- [ ] Verified `nexus-strategy.md` is absent from updated lock file
- [ ] Verified no SPDX changes (or: if `legal-review-required` label is present, @compliance has signed off and label has been removed)
- [ ] 24h soak rule: PR has been open ≥24h before merge (or a documented security exception is noted below)

**Security exception (if soak rule waived):**

<!-- If merging before 24h, state the reason here. Requires explicit maintainer acknowledgment. -->

</details>
