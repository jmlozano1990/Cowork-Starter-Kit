# Registry Column Reorder Fixture (AC-F4-5)
#
# This fixture tests that MF-2 awk column-name lookup finds goal_tags by header name,
# not by positional index. The goal_tags column is moved from position 6 to position 3.
# When MF-2 uses structural header scan, it still finds goal_tags and fires on BAD_TOKEN.
# If MF-2 uses positional $7, it reads the wrong column and the gate passes silently.

---

| name | description | goal_tags | source_url | vetting_date | tier |
|------|-------------|-----------|------------|--------------|------|
| test-skill | A test skill | meeting, notes | builtin | 2026-05-09 | 1 |
| bad-skill | A bad skill | BAD_TOKEN! | builtin | 2026-05-09 | 1 |
