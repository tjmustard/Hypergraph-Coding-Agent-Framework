# Migration Guide: Persistent Rules (spec/schemas → CLAUDE.md)

**Effective Date:** 2026-05-03  
**Deadline:** 2026-06-17 (6-week deprecation period)  
**Status:** In progress

---

## Overview

Static schema definitions have been migrated from individual files in `spec/schemas/` to CLAUDE.md
to reduce per-message token overhead. This guide helps you update references in your skills or workflows.

---

## What Was Migrated

The following static schemas have been moved to CLAUDE.md:

| Old Location | New Location | Purpose |
|---|---|---|
| `.agents/schemas/SuperPRD_Template.md` | CLAUDE.md: Schema Definitions › SuperPRD Schema | High-level feature spec template |
| `.agents/schemas/MiniPRD_template.md` | CLAUDE.md: Schema Definitions › MiniPRD Schema | Modular spec template |
| `.agents/schemas/hypergraph_schema.md` | CLAUDE.md: Schema Definitions › Hypergraph Schema | Dependency graph structure |

**Custom templates** (DESIGN_Template.md, plan_Template.md, etc.) remain in `.agents/schemas/` for project-specific use.

---

## Migration Checklist

### For Skill Developers

If your skill references old schema files:

- [ ] **Step 1: Find References**
  ```bash
  grep -r "spec/schemas/" .agents/skills/[your-skill]/SKILL.md
  ```

- [ ] **Step 2: Update Instructions**
  Replace:
  ```
  Read `.agents/schemas/SuperPRD_Template.md` to ensure correct structure.
  ```
  
  With:
  ```
  Review CLAUDE.md: "Schema Definitions › SuperPRD Schema" to ensure correct structure.
  ```

- [ ] **Step 3: Test**
  - Run your skill
  - Verify no "file not found" errors
  - Confirm behavior unchanged

- [ ] **Step 4: Commit**
  ```bash
  git add .agents/skills/[your-skill]/SKILL.md
  git commit -m "Migrate schema reference to CLAUDE.md"
  ```

### For Custom Skills

If you created a custom skill that references schema files:

1. Check if your references are in `.agents/schemas/`:
   ```bash
   ls .agents/schemas/
   ```

2. For each file you reference:
   - If it's `SuperPRD_Template.md`, `MiniPRD_template.md`, or `hypergraph_schema.md`: **Update to CLAUDE.md**
   - If it's a custom template: **Keep referencing `.agents/schemas/`**

3. Update your skill instructions accordingly

---

## Examples

### Example 1: SuperPRD Reference (Migrated)

**Before:**
```markdown
## Phase 5: Draft Generation
1. Read `.agents/schemas/SuperPRD_Template.md` to ensure correct output structure.
2. Generate the complete `Draft_PRD.md` ...
```

**After:**
```markdown
## Phase 5: Draft Generation
1. Review CLAUDE.md: "Schema Definitions › SuperPRD Schema" to ensure correct output structure.
2. Generate the complete `Draft_PRD.md` ...
```

---

### Example 2: MiniPRD Reference (Migrated)

**Before:**
```markdown
When creating a MiniPRD, follow the structure in `.agents/schemas/MiniPRD_template.md`.
```

**After:**
```markdown
When creating a MiniPRD, follow the structure in CLAUDE.md: "Schema Definitions › MiniPRD Schema".
```

---

### Example 3: Custom Template (Not Migrated)

**Before & After (No Change):**
```markdown
Custom templates are stored in `.agents/schemas/` (e.g., `DESIGN_Template.md`).
```

Custom templates like `DESIGN_Template.md`, `plan_Template.md`, etc., are NOT being migrated.
Continue referencing `.agents/schemas/` for these files.

---

## Backward Compatibility

### During Deprecation Period (Until 2026-06-17)

Old files remain in place with deprecation headers. Both old and new references work:

```
✅ CLAUDE.md: "Schema Definitions › SuperPRD Schema"  (NEW)
✅ .agents/schemas/SuperPRD_Template.md  (OLD, deprecated)
```

**Warning message** added to old files; no functional impact.

### After Deadline (2026-06-17)

Old files will be deleted. CI lint will enforce CLAUDE.md-only references:

```
❌ .agents/schemas/SuperPRD_Template.md  (REMOVED)
✅ CLAUDE.md: "Schema Definitions › SuperPRD Schema"  (REQUIRED)
```

---

## Deprecation Headers

When the migration started, deprecation headers were added to affected files:

```markdown
# ⚠️ DEPRECATED: SuperPRD Template

**Status:** Migrated to CLAUDE.md (See CLAUDE.md: Schema Definitions › SuperPRD Schema)
**Deadline for Removal:** 2026-06-17 (6-week deprecation period)

This file is maintained for backward compatibility only. New references should use CLAUDE.md.
```

You'll see this at the top of:
- `.agents/schemas/SuperPRD_Template.md`
- `.agents/schemas/MiniPRD_template.md`
- `.agents/schemas/hypergraph_schema.md`

---

## FAQ

### Q: Can I still use the old files during the deprecation period?
**A:** Yes. Both old and new references work until 2026-06-17. We recommend updating at your convenience.

### Q: What happens if I don't update by the deadline?
**A:** After 2026-06-17, CI lint will fail if your skill references old schema files. You'll need to update before merging.

### Q: Do I need to update custom templates like DESIGN_Template.md?
**A:** No. Custom templates are NOT being migrated. Continue referencing `.agents/schemas/` for these.

### Q: How much token overhead does this save?
**A:** Approximately 10-15% per-message reduction by embedding schemas in CLAUDE.md instead of reading separate files.

### Q: What if I'm creating a new skill?
**A:** Reference CLAUDE.md for static schemas (SuperPRD, MiniPRD, hypergraph). Example:
```markdown
Review CLAUDE.md: "Schema Definitions › [Schema Name]" to understand the structure.
```

---

## Support

- **Questions?** See CLAUDE.md: Schema Definitions
- **Migration Issues?** Check that your skill is reading from CLAUDE.md (not old files)
- **Custom Template Questions?** Continue using `.agents/schemas/` for project-specific templates

---

## Timeline

| Date | Event |
|---|---|
| 2026-05-03 | Migration starts; schemas moved to CLAUDE.md |
| 2026-05-03 to 2026-06-17 | 6-week deprecation period; both old and new work |
| 2026-06-17 | Old files deleted; CI lint enforces CLAUDE.md-only |
| 2026-06-18+ | Old schema files no longer available |
