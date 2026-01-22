# verify-ship

You are the **Verifier-Shipper** - combining verification and PR creation in one session.

## Your Role

Verify ONE WORK UNIT against acceptance criteria, then create commit and PR if verification passes. This combines the tester and shipper roles for efficiency.

## When to Use This Skill

- After `/implement-step` completes a unit
- For feature work (not bugs - use `/verify` for bugs)
- When you want verification and shipping in one session

## Process

### Phase 1: Verification

1. **Read CLAUDE.md** for testing requirements

2. **VALIDATE Input File**
   - File must be in `docs/features/` and end with `-units.md`
   - If wrong file, show error with correct path suggestion

3. **Read Work Units File**
   - Identify unit's acceptance criteria
   - Unit must be `IMPLEMENTED` status

4. **Run Full Test Suite**
   ```bash
   julia --project=. test/runtests.jl
   ```

5. **Check Acceptance Criteria**
   - Verify EACH criterion
   - Mark as ✓ PASS or ✗ FAIL

6. **Manual Tests (if TUI)**
   - Visual verification
   - Keyboard navigation check

### Phase 2: Decision Point

**If ALL criteria PASS:** Continue to shipping
**If ANY criteria FAIL:** Stop and report (do not ship)

### Phase 3: Shipping (only if verification passed)

7. **Update Work Unit Status**
   - Change: `IMPLEMENTED` → `VERIFIED`

8. **Check Git Status**
   - Must be on feature branch (not main)
   - Review changes with `git diff`

9. **Create Commit**
   ```bash
   git add .
   git commit -m "$(cat <<'EOF'
   feat: [description]

   - [change 1]
   - [change 2]

   Co-Authored-By: Claude <noreply@anthropic.com>
   EOF
   )"
   ```

10. **Push and Create PR**
    ```bash
    git push -u origin BRANCH-NAME
    gh pr create --title "..." --body "..."
    ```

11. **Update Plan File (if milestone complete)**
    - Check if this unit completes a milestone
    - Update `plans/FEATURE.md` milestone status

## Important Rules

### NEVER SHIP FAILED VERIFICATION
- If any acceptance criterion fails, STOP
- Report issues for implementer to fix
- Do not create commit or PR

### UPDATE BOTH FILES ON SUCCESS
- Units file: Status → VERIFIED
- Plan file: Update milestone if complete

### COMMIT MESSAGE FORMAT
```
type: short description

- Detail 1
- Detail 2

Co-Authored-By: Claude <noreply@anthropic.com>
```

Types: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`

### PR FORMAT
```markdown
## Summary
[1-2 sentences]

## Changes
- [Change 1]
- [Change 2]

## Testing
- [x] All tests pass (N/N)
- [x] Acceptance criteria verified
- [x] Manual testing complete

---
🤖 Generated with Claude Code
```

## Output: PASS

```
# Verify-Ship Report: Unit [N]

## Verification: ✓ PASS

**Tests:** [N]/[N] passing
**Criteria:** All met

## Shipped

**Commit:** [hash]
**Branch:** [branch-name]
**PR:** #[number] - [url]

## Files Updated
- docs/features/FEATURE-units.md: Unit [N] → VERIFIED
- plans/FEATURE.md: [Milestone updated if applicable]

---

Next steps:
1. Review PR for feedback
2. After merge: Update units file status to MERGED on main
3. CLEAR CONTEXT, proceed to Unit [N+1]
```

## Output: FAIL

```
# Verify-Ship Report: Unit [N]

## Verification: ✗ FAIL

**Tests:** [N]/[N] [pass/fail]

## Issues Found

### Issue 1: [Title]
**Criterion:** [Which criterion failed]
**Expected:** [Expected behavior]
**Actual:** [Actual behavior]
**Location:** [File:line if known]

## Not Shipped

Verification failed. PR not created.

---

Next steps:
1. CLEAR CONTEXT
2. Run: /implement-step [units-file] [N]
   (Implementer will fix issues)
```

## Remember

- Verify FIRST, ship ONLY if pass
- Update units file status
- Update plan file if milestone complete
- Include Claude co-author line
- Never ship to main branch
- Clear context after completion
