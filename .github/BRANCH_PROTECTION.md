# Branch Protection Configuration

This document describes the branch protection rules configured for the `main` branch.

## Main Branch Protection

### Required Status Checks ✅

All of these CI checks must pass before a PR can be merged:

- **Test (5.9)** - All unit tests in DifferCore module
- **Build (debug)** - Debug configuration build
- **Build (release)** - Release configuration build  
- **SwiftLint** - Code style and quality checks (strict mode)
- **Check Module Compilation** - Verify all modules compile independently
- **Test Coverage Report** - Run tests with coverage tracking
- **Compilation Time Check** - Monitor build performance

**Automated code review**: Copilot reviews PRs automatically when enabled in repository settings.

**Strict status checks**: ✅ Enabled  
PRs must be up-to-date with base branch before merging.

### Pull Request Reviews ✅

- **Required approving reviews**: 1
- **Required reviewer**: @dehcast
- **Dismiss stale reviews**: ✅ Yes (on new pushes)
- **Code owner review**: ❌ Not required

### Push Restrictions 🔒

- Direct pushes to `main` are **not allowed**
- All changes must go through pull requests
- Administrators can bypass (use sparingly)

### Other Settings

- **Require conversation resolution**: Recommended (not enforced)
- **Force push**: ❌ Not allowed
- **Branch deletion**: ❌ Not allowed

## Making Changes to Main

### Developer Workflow

1. Create feature branch from `main`
2. Make changes and commit
3. Push branch to GitHub
4. Create Pull Request
5. Wait for CI to pass (all required checks)
6. Request review from @dehcast
7. Address review feedback if needed
8. Wait for approval
9. PR can be merged (squash merge recommended)

### Emergency Hotfixes

For critical production issues only:

1. Create branch: `hotfix/description`
2. Make minimal fix
3. Create PR with "hotfix:" prefix in title
4. Request expedited review
5. All CI checks still required

## Updating Protection Rules

To modify these rules (maintainers only):

```bash
# Update required status checks
gh api -X PUT repos/dehcast/Differ/branches/main/protection/required_status_checks/contexts \
  -f contexts[]="Test (5.9)" \
  -f contexts[]="Build (debug)" \
  -f contexts[]="Build (release)" \
  -f contexts[]="SwiftLint" \
  -f contexts[]="Check Module Compilation" \
  -f contexts[]="Test Coverage Report" \
  -f contexts[]="Compilation Time Check"

# Update review requirements
gh api -X PATCH repos/dehcast/Differ/branches/main/protection/required_pull_request_reviews \
  --input - <<EOF
{
  "required_approving_review_count": 1,
  "dismiss_stale_reviews": true,
  "require_code_owner_reviews": false
}
EOF
```

## Why These Rules?

### Quality Assurance
- **Tests**: Catch regressions before they reach main
- **Builds**: Ensure code compiles in both debug and release modes
- **SwiftLint**: Maintain consistent code style and catch common issues
- **Module compilation**: Verify modular architecture stays intact

### Code Review Benefits
- Knowledge sharing across the team
- Catch logic errors and design issues
- Ensure architectural consistency
- Documentation and maintainability improvements

### Stability
- Main branch always deployable
- No broken builds in history
- Clear change attribution via PR history

## Troubleshooting

### PR Blocked Despite Green CI?

Check:
1. All required status checks are green
2. Branch is up-to-date with main
3. Required review has been given
4. All conversations are resolved

### Can't Push to Main?

This is intentional! Create a PR instead:
```bash
git checkout -b feature/my-change
git push origin feature/my-change
gh pr create
```

### Need to Bypass (Emergencies Only)?

Administrators can:
1. Temporarily disable branch protection
2. Make critical fix
3. Re-enable protection immediately
4. Document reason in commit message

**Use only for:**
- Security vulnerabilities requiring immediate patch
- Production outages blocking users
- Critical data loss prevention

## Related Documentation

- [CONTRIBUTING.md](CONTRIBUTING.md) - Development workflow
- [SWIFT_PROJECT.md](SWIFT_PROJECT.md) - Swift/SPM setup
- [../workflows/ci.yml](workflows/ci.yml) - CI configuration
