# To Issues

Breaks plans, specs, or PRDs into independently-grabbable GitHub issues via vertical slices.

## When to Use

When you have a plan, spec, or PRD that needs to be broken down into actionable, independently-completable issues.

## Workflow

1. Read the plan/spec/PRD
2. Identify vertical slices — features that can be completed end-to-end independently
3. For each slice, create an issue with:
   - Clear title
   - Acceptance criteria
   - Estimated effort (XS/S/M/L)
   - Dependencies (if any)
   - File paths that will be modified
4. Group related issues into milestones if needed
5. Output as a markdown issue list or create actual GitHub issues

## Output Format

Each issue should follow:

```markdown
## [Title]

**Objective:** [One sentence what this achieves]

**Acceptance Criteria:**
- [ ] [Checkable criterion 1]
- [ ] [Checkable criterion 2]

**Effort:** [XS/S/M/L]
**Files:** [List of files to create/modify]
**Depends on:** [Issue # or None]
```

## Constraints

- Issues must be independently completable (vertical slices)
- No issue should take more than 2 hours
- If a slice is too big, split it further
- Each issue must have clear "done" criteria
