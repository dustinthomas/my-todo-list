# commit-push-pr

> **Note:** For feature work, prefer `/verify-ship` which combines verification + shipping.
> This skill remains available for bug fixes after `/verify` or standalone use.

You are in **Ship Mode** - preparing to create a commit and pull request.

## Your Role

Create a descriptive commit, push the branch, and create a well-formatted pull request.

## Process

1. **Check Git Status**
   - Run `git status` to see changes
   - Verify you're on a feature branch (not main)

2. **Review Changes**
   - Run `git diff` to see what changed
   - Ensure changes are intentional
   - Check for sensitive data (.env, secrets)

3. **Create Commit Message**
   - Follow conventional commits format
   - Be descriptive but concise
   - Include co-author line for Claude

4. **Push Branch**
   - Push with `-u origin BRANCH-NAME`
   - Ensure branch is tracked

5. **Create Pull Request**
   - Use `gh pr create` if available
   - Or provide PR template for manual creation
   - Include summary, changes, testing notes

## Important Rules

### NEVER COMMIT TO MAIN
- Must be on a feature branch
- Branch naming: `feature/NAME`, `bugfix/NAME`, `refactor/NAME`, `test/NAME`
- If on main, ERROR and tell user to create branch

### NEVER COMMIT SECRETS
- Check for .env files
- Check for API keys, passwords
- Warn user if suspicious files staged

### ALWAYS CO-AUTHOR
- Include Claude co-author line in commit
- Format: `Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>`

### NEVER MERGE DIRECTLY
- Create PR for review
- Never push to main
- Never merge without approval

## Commit Message Format

```
type: short description

- Detail 1
- Detail 2
- Detail 3

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

### Types
- `feat:` New feature
- `fix:` Bug fix
- `refactor:` Code improvement (no behavior change)
- `docs:` Documentation only
- `test:` Adding tests
- `chore:` Maintenance, dependencies
- `style:` Formatting, no code change

### Example Commit Messages

**Feature:**
```
feat: add todo list view with navigation

- Implement TodoTable component using Term.jl
- Add render_list_screen with arrow key navigation
- Create keyboard input handling
- Add full test coverage

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

**Bug Fix:**
```
fix: resolve status filter KeyError

- Fix filter_todos_by_status function in queries.jl
- Add validation for status parameter
- Add test case for invalid status

Closes #42

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

**Refactor:**
```
refactor: simplify TUI component rendering

- Extract render_header helper function
- Extract render_help_bar helper function
- Reduce render_list_screen from 150 to 15 lines
- No behavior changes

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

## Pull Request Format

### PR Title
Use commit message format:
```
feat: Add Todo List View with Navigation
```

### PR Description Template

```markdown
## Summary
[1-2 sentences describing what this PR does]

## Changes
- [Change 1]
- [Change 2]
- [Change 3]

## Testing
- [ ] All tests pass ([N]/[N] tests)
- [ ] Manually verified [specific behavior]
- [ ] Docker build succeeds
- [ ] No breaking changes

## Related
- Closes #[issue-number]
- Related to #[issue-number]
- Part of [feature-name]

## Screenshots (if TUI changes)
[ASCII art or description of visual changes]

## Checklist
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] CLAUDE.md followed
- [ ] No secrets committed
- [ ] Branch up to date with main

---

Built with Claude Code 🤖
```

## Git Workflow Steps

### 1. Check Branch
```bash
git branch --show-current
```

If on `main`:
```
ERROR: Cannot commit to main branch!

Please create a feature branch:
git checkout -b feature/YOUR-FEATURE-NAME

Then try again.
```

### 2. Check Status
```bash
git status
```

Verify changes look correct.

### 3. Stage Changes
```bash
git add .
```

Or for specific files:
```bash
git add src/file1.jl test/file2.jl
```

### 4. Create Commit
```bash
git commit -m "$(cat <<'EOF'
feat: add todo list view with navigation

- Implement TodoTable component using Term.jl
- Add render_list_screen with arrow key navigation
- Create keyboard input handling
- Add full test coverage

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)"
```

### 5. Push Branch
```bash
git push -u origin feature/YOUR-FEATURE-NAME
```

### 6. Create PR

**With GitHub CLI:**
```bash
gh pr create --title "feat: Add Todo List View" --body "$(cat <<'EOF'
## Summary
Implements styled todo list table with keyboard navigation

## Changes
- TodoTable component for rendering
- List screen with arrow key navigation
- Full test coverage (12/12 tests pass)

## Testing
- [x] All tests pass (12/12)
- [x] Manually verified navigation
- [x] Docker build succeeds

Closes #42
EOF
)"
```

**Without GitHub CLI:**
```
PR created! Next steps:

1. Go to: https://github.com/USERNAME/REPO/pull/new/BRANCH-NAME
2. Use this title: feat: Add Todo List View
3. Use this description:

---
[PR description from template above]
---
```

## Safety Checks

Before committing, check for:

### Sensitive Data
```bash
# Check for .env files
git diff --name-only | grep -E '\.(env|secret|key)'

# Check for API keys in code
git diff | grep -i -E '(api_key|password|secret|token)'
```

If found:
```
WARNING: Possible sensitive data detected!

Files:
- .env

Please review and remove before committing.

To unstage:
git reset HEAD .env
```

### Test Status
```bash
# Verify tests pass
./scripts/docker-test
```

If tests fail:
```
ERROR: Tests failing!

Cannot create commit with failing tests. Please fix:
[Test failure details]

After fixing, run tests again and try committing.
```

### Uncommitted Changes
```bash
git status --short
```

If unstaged changes:
```
WARNING: You have unstaged changes:
M src/file1.jl
M src/file2.jl

Stage them with:
git add src/file1.jl src/file2.jl

Or stage all with:
git add .
```

## Example Full Workflow

```
User: I'm ready to commit and create PR

You: Checking current state...

$ git branch --show-current
feature/todo-list-view

✓ On feature branch

$ git status
On branch feature/todo-list-view
Changes to be committed:
  new file:   src/tui/components.jl
  new file:   src/tui/screens.jl
  new file:   test/test_tui.jl

✓ Changes staged

$ ./scripts/docker-test
Test Summary: | Pass  Total
TUI Tests     |   12     12

✓ All tests pass

Creating commit...

$ git commit -m "..."
[feature/todo-list-view abc1234] feat: add todo list view
 3 files changed, 150 insertions(+)

✓ Commit created

Pushing to remote...

$ git push -u origin feature/todo-list-view
Branch 'feature/todo-list-view' set up to track remote branch.

✓ Branch pushed

Creating pull request...

$ gh pr create --title "feat: Add Todo List View" --body "..."

https://github.com/username/my-todo-list/pull/42

✓ Pull request created!

---

Summary:
- Commit: abc1234
- Branch: feature/todo-list-view
- PR: #42

Next steps:
- Review PR for any feedback
- Wait for approval
- Merge after approval (never merge directly)
```

## Error Handling

### On Main Branch
```
ERROR: Cannot commit to main!

Current branch: main
Required: feature/bugfix/refactor branch

Create branch:
git checkout -b feature/YOUR-FEATURE-NAME
```

### No Changes Staged
```
ERROR: No changes to commit

Run:
git add .

Or stage specific files:
git add src/file.jl
```

### Tests Failing
```
ERROR: Tests must pass before committing

Failing tests:
- test_database.jl: test_create_todo
- test_queries.jl: test_filter_by_status

Fix tests, then try again.
```

### Merge Conflicts
```
ERROR: Merge conflicts detected

Files with conflicts:
- src/database.jl

Resolve conflicts:
1. Edit files and resolve conflicts
2. git add [resolved-files]
3. Try committing again
```

## Post-Merge: Update Units File Status

**IMPORTANT:** After a PR is merged, the units file must be updated to reflect MERGED status.

This is the ONE exception to the "never commit to main" rule - status updates to the units file.

### Steps After PR Merge

1. **Checkout main and pull**
   ```bash
   git checkout main && git pull
   ```

2. **Update units file**
   - Change status from IMPLEMENTED/VERIFIED to `⬜ MERGED`
   - Add PR number to the PR column
   - Update individual unit sections with `**Status:** ⬜ MERGED (PR #N)`

3. **Commit directly to main** (exception allowed)
   ```bash
   git add docs/features/FEATURE-units.md
   git commit -m "docs: update units status to MERGED (PR #N)"
   git push
   ```

### Example Units File Update

**Before merge:**
```markdown
| 1 | TUI Foundation | ✅ VERIFIED | 1-3 | - |
```

**After merge:**
```markdown
| 1 | TUI Foundation | ⬜ MERGED | 1-3 | #5 |
```

### Why This Exception?

- PR numbers aren't known until the PR is created
- Creating a new branch just for status update is overkill
- Status updates don't change code behavior
- This keeps the units file as accurate source of truth

## Remember

- Check branch (must be feature branch)
- Review changes (git diff)
- Run tests (must pass)
- Create descriptive commit message
- Include Claude co-author line
- Push with -u origin
- Create PR (never merge directly)
- No secrets committed
- **After merge: Update units file status on main**

Your focus: Safe, clean, well-documented commits and PRs ready for review.
