# GitHub Actions Status Badge Configuration
# Add these badges to README.md

[![CI](https://github.com/dehcast/Differ/actions/workflows/ci.yml/badge.svg)](https://github.com/dehcast/Differ/actions/workflows/ci.yml)
[![Nightly](https://github.com/dehcast/Differ/actions/workflows/nightly.yml/badge.svg)](https://github.com/dehcast/Differ/actions/workflows/nightly.yml)
[![codecov](https://codecov.io/gh/dehcast/Differ/branch/main/graph/badge.svg)](https://codecov.io/gh/dehcast/Differ)

## Workflows

### CI (`ci.yml`)
Runs on every push to `main` and on all pull requests:
- **Test** - Runs all unit and snapshot tests in parallel
- **Build** - Builds in both debug and release configurations
- **Lint** - Runs SwiftLint for code quality
- **Check Compilation** - Verifies each module compiles independently

### Nightly (`nightly.yml`)
Runs at 2 AM UTC daily:
- **Nightly Tests** - Full test suite
- **Nightly Build** - Release build with artifacts
- **Notify** - Creates GitHub issue on failure

### PR Checks (`pr-checks.yml`)
Runs on all pull requests:
- **PR Title** - Validates conventional commit format
- **PR Size** - Warns on large PRs (>50 files or >1000 lines)
- **Test Coverage** - Reports coverage to Codecov
- **Compile Time** - Measures and reports build duration

### Release (`release.yml`)
Runs when a version tag is pushed (e.g., `v0.1.0`):
- Runs tests
- Builds release binary
- Creates GitHub release with artifacts
- Generates checksums

## Badge URLs

```markdown
[![CI](https://github.com/dehcast/Differ/actions/workflows/ci.yml/badge.svg)](https://github.com/dehcast/Differ/actions/workflows/ci.yml)
[![Nightly](https://github.com/dehcast/Differ/actions/workflows/nightly.yml/badge.svg)](https://github.com/dehcast/Differ/actions/workflows/nightly.yml)
```
