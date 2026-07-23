# Development Scripts

This directory contains development and automation scripts for the Differ project.

## Available Scripts

### `install-hooks.sh`

Installs git hooks for automated quality checks.

**Usage**:
```bash
./scripts/install-hooks.sh
```

**What it does**:
- Installs `pre-commit` hook (runs SwiftLint)
- Installs `pre-push` hook (runs tests)
- Backs up existing hooks if present

**When to use**: Run once after cloning the repository

### Git Hooks

These are installed by `install-hooks.sh` and run automatically:

#### `pre-commit`

Runs before every `git commit`.

**Checks**:
- SwiftLint in strict mode
- Catches style violations before they reach CI

#### `pre-push`

Runs before every `git push`.

**Checks**:
- DifferCore module tests
- Ensures no broken tests reach remote

## Adding New Scripts

When adding scripts:

1. **Use descriptive names**: `verb-noun.sh` (e.g., `generate-docs.sh`)
2. **Add shebang**: `#!/bin/bash` at the top
3. **Make executable**: `chmod +x scripts/your-script.sh`
4. **Add to this README**: Document what it does
5. **Add error handling**: Check exit codes, validate inputs
6. **Print feedback**: Use emoji for status (✅ ❌ ⚠️ 🔍)

### Script Template

```bash
#!/bin/bash
# Description of what this script does

set -e  # Exit on error

# Set up error trap for friendly messages
trap 'echo "❌ Task failed"' ERR

echo "🔍 Starting task..."

# Your script logic here

echo "✅ Task completed"
exit 0
```

## Best Practices

- **Test locally**: Run scripts before committing
- **Handle failures gracefully**: Clear error messages
- **Don't require sudo**: Unless absolutely necessary
- **Be cross-platform aware**: Test on different macOS versions
- **Document dependencies**: List required tools (swiftlint, gh, etc.)
