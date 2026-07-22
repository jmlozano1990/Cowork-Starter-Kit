<!-- Fixture: F3-2 — workspace-side re-scan-on-edit (MF-S-4, AC-F3-2/F3-3).
     Drives the concrete, reachable invocation point ADR-068/MF-S-4 requires:
     skills/self-apply/SKILL.md's turn-two step 1 (re-derive from CURRENT
     bytes), which now also compares the target's on-disk content hash against
     that slug's `installed_content_sha256` entry in `cowork.install.json`
     before rendering the diff.

     Walkthrough this fixture represents (a maintainer or @qa dry-run, not
     itself executable CI):

     1. INSTALL (clean). A workspace installs `flashcard-generation` from the
        pool. `cowork.install.json` records:
          "slug": "flashcard-generation",
          "installed_content_sha256": "<sha256 of skills/flashcard-generation/SKILL.md at install time>"
        At this point, sha256(on-disk file) == installed_content_sha256. No
        forbidden token present (the shipped pool file is clean — confirmed by
        the standing canonicalize-scan-check CI job).

     2. HAND-EDIT (post-install, no re-installation). The user or an agent
        edits the installed `.claude/skills/flashcard-generation/SKILL.md`
        directly — NOT through the apply flow — inserting a forbidden
        imperative token into the `## Example` section (the same class of
        content this fixture set intentionally avoids spelling out in prose;
        see the canonicalization fixtures' authoring note). This step
        deliberately bypasses self-apply's turn-two write path entirely —
        AC-F3-2 requires the re-scan to fire on a hand-edit, not only on an
        edit self-apply itself performed.

     3. NEXT APPLY REACHES THE FILE (the reachable hook). The next time
        self-apply's turn two is invoked with this file as ITS target — for
        example, a later, unrelated confirmed change to the same
        `flashcard-generation/SKILL.md` — step 1's "re-derive from CURRENT
        bytes" now also runs: sha256(on-disk file) != installed_content_sha256
        recorded in `cowork.install.json`. That mismatch is the AC-F3-3
        trigger condition (content-hash-triggered, never a blind re-scan on
        every read).

     4. RE-SCAN FIRES. Per the bound step in skills/self-apply/SKILL.md
        ("Turn two" §1), `scripts/canonicalize-scan.sh` runs against the
        file's current bytes BEFORE the turn-two diff renders. The forbidden
        token inserted in step 2 is caught (exit 1) and surfaced inline in the
        render — flagged, never silently swallowed, and never itself a reason
        to skip or alter the confirmation flow (the same "data, not
        instruction" discipline this skill already applies to ledger Notes).

     5. HONEST LIMIT (stated, not hidden). This re-scan is inspection-class:
        it fires only when self-apply's turn two NEXT reaches that exact file
        for some OTHER confirmed change. A hand-edited file that self-apply
        never revisits is not re-scanned by this mechanism alone — the pool/PR
        side `canonicalize-scan-check` CI job is the mechanical, always-on
        layer; this workspace-side step is defense-in-depth beneath it, not a
        replacement for it (OI-v2.18-S6a, MF-S-4).

     Machine-checkable proxy for this fixture (what @qa/@security actually run
     — the walkthrough above is the narrative behind the check):
       grep -nE 'installed_content_sha256|content.hash|re-scan|re-run the canonicaliz' skills/self-apply/SKILL.md
     must show the bound step inside "Turn two — the apply-specific
     confirmation" §1, not a dangling/unbound description elsewhere in the
     file. -->
