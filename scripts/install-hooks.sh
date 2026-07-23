#!/bin/bash
# Install git hooks for Differ project

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GIT_DIR="$(git rev-parse --git-dir 2>/dev/null)"

if [ -z "$GIT_DIR" ]; then
  echo "❌ Error: Not in a git repository"
  exit 1
fi

HOOKS_DIR="$GIT_DIR/hooks"

echo "📦 Installing git hooks to $HOOKS_DIR"

# Install pre-commit hook
if [ -f "$HOOKS_DIR/pre-commit" ]; then
  echo "⚠️  pre-commit hook already exists, backing up to pre-commit.old"
  mv "$HOOKS_DIR/pre-commit" "$HOOKS_DIR/pre-commit.old"
fi

cp "$SCRIPT_DIR/pre-commit" "$HOOKS_DIR/pre-commit"
chmod +x "$HOOKS_DIR/pre-commit"
echo "✅ Installed pre-commit hook"

# Install pre-push hook
if [ -f "$HOOKS_DIR/pre-push" ]; then
  echo "⚠️  pre-push hook already exists, backing up to pre-push.old"
  mv "$HOOKS_DIR/pre-push" "$HOOKS_DIR/pre-push.old"
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
echo ""
echo "To bypass hooks (emergency only): git commit --no-verify"
