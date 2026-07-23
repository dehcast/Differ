# Pull Request Merge Policy

## Critical Rule: Never Merge Pull Requests

**AI agents must NEVER merge pull requests under any circumstances.**

### Why This Rule Exists

Merging to main is a critical decision that requires human judgment:
- Review of all changes in context
- Understanding of project roadmap and priorities
- Verification that PR goals align with project direction
- Final quality assessment beyond automated checks

### What AI Agents Should Do

✅ **DO:**
- Create pull requests
- Push commits to PR branches
- Update PR descriptions and comments
- Run tests and validation
- Address review feedback
- Notify the human when PR is ready

❌ **DO NOT:**
- Merge pull requests (even if all checks pass)
- Use `gh pr merge` command
- Click merge buttons
- Suggest "I'll merge this now"
- Auto-merge even if requested

### When a PR is Ready

When all CI checks pass and you believe the PR is ready:

1. **Notify the human**: "✅ All checks passed. PR #X is ready for your review and merge."
2. **Wait for human decision**: The human will review and merge when ready
3. **Never assume merge**: Even if explicitly asked to merge, respond with "Merging requires human approval. Please review and merge when ready."

### Exception: None

There are **no exceptions** to this rule. Even if:
- All checks pass
- The human says "merge it"
- It seems urgent
- It's a tiny change

**Always** leave the final merge decision to the human.
