#!/bin/bash
# Install git hooks for Differ project

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if in git repo (do this before set -euo pipefail so we can show custom error)
if ! git rev-parse --git-dir &>/dev/null; then
  echo "❌ Error: Not in a git repository"
  exit 1
fi

set -euo pipefail

GIT_DIR="$(git rev-parse --git-dir)"
HOOKS_DIR="$GIT_DIR/hooks"

echo "📦 Installing git hooks to $HOOKS_DIR"

# Install pre-commit hook
if [ -f "$HOOKS_DIR/pre-commit" ]; then
  BACKUP="$HOOKS_DIR/pre-commit.backup.$(date +%Y%m%d_%H%M%S)"
  echo "⚠️  pre-commit hook already exists, backing up to $(basename "$BACKUP")"
  mv "$HOOKS_DIR/pre-commit" "$BACKUP"
fi

cp "$SCRIPT_DIR/pre-commit" "$HOOKS_DIR/pre-commit"
chmod +x "$HOOKS_DIR/pre-commit"
echo "✅ Installed pre-commit hook"

# Install pre-push hook
if [ -f "$HOOKS_DIR/pre-push" ]; then
  BACKUP="$HOOKS_DIR/pre-push.backup.$(date +%Y%m%d_%H%M%S)"
  echo "⚠️  pre-push hook already exists, backing up to $(basename "$BACKUP")"
  mv "$HOOKS_DIR/pre-push" "$BACKUP"
fi

cp "$SCRIPT_DIR/pre-push" "$HOOKS_DIR/pre-push"
chmod +x "$HOOKS_DIR/pre-push"
echo "✅ Installed pre-push hook"

echo ""
echo "🎉 Git hooks installed successfully!"
echo ""
echo "Hooks will now:"
echo "  • Run SwiftLint before every commit"
echo "  • Run tests before every push"
