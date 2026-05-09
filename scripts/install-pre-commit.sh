#!/usr/bin/env bash
# install-pre-commit.sh — Install markdownlint pre-commit hook for cowork-starter-kit.
#
# This hook runs the same markdownlint ruleset as the CI `markdown-lint` step,
# catching MD058 and other violations before they reach GitHub Actions.
#
# Usage:
#   bash scripts/install-pre-commit.sh
#
# Requirements:
#   - Node.js + npm (for markdownlint-cli)
#   - Run from the repo root (or anywhere inside the git worktree)
#
# Manual procedure (AC-F5-4):
#   If you prefer not to use this script:
#   1. Install markdownlint-cli:  npm install -g markdownlint-cli
#   2. Identify your repo root:   git rev-parse --show-toplevel
#   3. Create .git/hooks/pre-commit with this content:
#      #!/usr/bin/env bash
#      set -euo pipefail
#      markdownlint --config .markdownlint.json '**/*.md' --ignore node_modules
#   4. Make it executable:        chmod +x .git/hooks/pre-commit
#
# Ruleset: .markdownlint.json at repo root (same file CI uses).
# If .markdownlint.json does not exist, markdownlint uses its defaults.

set -euo pipefail

# Resolve repo root — works whether run from root or any subdirectory.
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || {
  echo "ERROR: Not inside a git repository. Run this script from within the cowork-starter-kit repo." >&2
  exit 1
}

HOOK_PATH="${REPO_ROOT}/.git/hooks/pre-commit"
BACKUP_PATH="${REPO_ROOT}/.git/hooks/pre-commit.bak"

# Check markdownlint-cli is available.
if ! command -v markdownlint >/dev/null 2>&1; then
  echo "ERROR: markdownlint-cli not found. Install it first:" >&2
  echo "  npm install -g markdownlint-cli" >&2
  exit 1
fi

# Back up existing hook if present.
if [ -f "${HOOK_PATH}" ]; then
  echo "Backing up existing pre-commit hook to ${BACKUP_PATH}"
  cp "${HOOK_PATH}" "${BACKUP_PATH}"
fi

# Write the hook.
cat >"${HOOK_PATH}" <<'HOOK'
#!/usr/bin/env bash
# pre-commit hook — markdownlint (same ruleset as CI markdown-lint step).
# Installed by scripts/install-pre-commit.sh.
set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel)
CONFIG="${REPO_ROOT}/.markdownlint.json"

if [ -f "${CONFIG}" ]; then
  markdownlint --config "${CONFIG}" "${REPO_ROOT}/**/*.md" --ignore "${REPO_ROOT}/node_modules"
else
  markdownlint "${REPO_ROOT}/**/*.md" --ignore "${REPO_ROOT}/node_modules"
fi
HOOK

chmod +x "${HOOK_PATH}"

echo "pre-commit hook installed at ${HOOK_PATH}"
echo "Ruleset: ${REPO_ROOT}/.markdownlint.json (if present, else markdownlint defaults)"
echo "To uninstall: rm ${HOOK_PATH}"
if [ -f "${BACKUP_PATH}" ]; then
  echo "Previous hook backed up at ${BACKUP_PATH}"
fi
