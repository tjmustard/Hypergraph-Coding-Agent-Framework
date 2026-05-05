# SuperPRD: /hyper-update — Smart Framework Upgrade with Customization Preservation

**Status:** FINAL (Resolved by /hyper-resolve on 2026-05-04)  
**Confidence Score:** 9/10

---

## 1. Introduction & Goals

**Problem Statement:**
The existing `install.sh` upgrade mode performs a blind file replacement (`cp`) on all framework files. This destroys user customizations to `CLAUDE.md`, `AGENTS.md`, IDE rules files (`.clinerules/`, `.roo/rules/`, etc.), and other sensitive files. Users who have adapted the framework to their project's needs have no safe upgrade path and must choose between (a) losing customizations or (b) skipping the upgrade.

**Solution Overview:**
Introduce `/hyper-update`, an interactive Claude Code skill that fetches the latest upstream framework with GPG signature verification, auto-updates non-sensitive files (skill implementations, specs, tests), and guides users through a collaborative, section-by-section (`###`-level) merge of sensitive customizable files. All replaced/merged files are backed up before mutation, with strict mutex-based concurrency control and post-merge validation.

**Target Audience:**
Framework users who have customized their local CLAUDE.md, AGENTS.md, rules files, or command bridges, and want to pull upstream improvements without losing their project-specific configurations.

---

## 2. Scope

**In-Scope:**
- Fetching upstream repo with GPG tag signature verification (fail on invalid signatures)
- Detecting changes in sensitive files via diff comparison
- Three-way interaction for each changed sensitive file: Replace / Merge / Skip
- Section-by-section (###-level) collaborative merge with per-section approval gates
- Strict post-merge validation (YAML/markdown syntax checking; reject invalid files)
- Timestamped backup (.agents/.backup/YYYY-MM-DDTHH-MM-SSZ/) before any mutation
- Mutex-based concurrency control (prevent concurrent invocations)
- Interrupt recovery via `.merge-in-progress.lock` (resume or start fresh)
- Auto-cleanup of backups older than 30 days
- `/hyper-recover` command for manual backup restoration
- Summary report of all files processed

**Out-of-Scope:**
- Automatic three-way merge conflict resolution (user sees both versions, makes explicit choice)
- Downgrading framework versions
- Rolling back after a merge has been approved (user must use `/hyper-recover`)

---

## 3. User Stories (Atomic)

| ID | User Story | Acceptance Criteria | Priority |
|---|---|---|---|
| US-001 | As a framework user, I want to run `/hyper-update` and see if any changes are available upstream | 1. Command fetches upstream repo with GPG verification<br>2. User sees summary of changed files<br>3. No changes are made until user approves | High |
| US-002 | As a user with no customizations, I want `/hyper-update` to auto-apply framework updates without prompts | 1. Non-sensitive files auto-copy<br>2. Sensitive files with no local changes skipped silently<br>3. Report shows which files were updated | High |
| US-003 | As a user with a customized CLAUDE.md, I want to choose [Replace/Merge/Skip] for that file | 1. Diff summary shown<br>2. Three choices presented<br>3. User selection honored<br>4. File backed up before mutation | High |
| US-004 | As a user choosing [Merge], I want to review each ### section separately and approve it before moving to next | 1. Sections identified by ### heading<br>2. Upstream and local versions shown<br>3. User prompted per differing section<br>4. Next section not shown until current approved<br>5. Final merged file validated before write | High |
| US-005 | As a user, I want backups created before any file mutation so I can roll back if needed | 1. Backup dir `.agents/.backup/YYYY-MM-DDTHH-MM-SSZ/` created<br>2. Original file copied before replace/merge<br>3. Backup path shown in summary | High |
| US-006 | As a user, I want a clear summary of what was updated, merged, replaced, or skipped | 1. Summary lists all files processed<br>2. Backup location shown<br>3. Next steps suggested | High |
| US-007 | As a user interrupted mid-upgrade, I want to resume or restart the merge cleanly | 1. Detect `.merge-in-progress.lock` on next invocation<br>2. Offer "Resume merge?" or "Start fresh?"<br>3. Restore file to clean state on completion | High |
| US-008 | As a user, I want to restore a file from a previous upgrade without manually copying | 1. `/hyper-recover` command lists available backups<br>2. Restore via `--file=CLAUDE.md --date=2026-05-04`<br>3. Backup is verified before restore | High |

---

## 4. Technical Specifications

### 4.1 Architecture & Resolved Trade-offs

**Concurrency Control (Resolved TO-1):**
- **Decision:** Mutex lock (Option A)
- **Implementation:** Create `.agents/.hyper-update.lock` at start; delete at end
- **Behavior:** If lock exists, abort with "Another upgrade in progress. Wait and retry."
- **Rationale:** Zero data loss risk; prevents all concurrent scenarios; minimal code (<20 lines)

**Post-Merge Validation (Resolved TO-2):**
- **Decision:** Strict validation (Option A)
- **Implementation:** After assembly, validate merged file:
  - YAML sections: `yaml.safe_load()` check
  - Markdown: unmatched code block detection
- **Behavior:** Reject invalid files; prompt user to re-merge or keep original
- **Rationale:** Zero corruption risk; user catches syntax errors before commit

**Rollback & Recovery (Resolved TO-3):**
- **Decision:** Full recovery system (Option A)
- **Implementation:**
  - `.merge-in-progress.lock` tracks active merge state
  - On interrupt, next invocation detects lock and offers resume/fresh start
  - `/hyper-recover` command restores from timestamped backups
- **Rationale:** Maximum user control; handles interrupts gracefully; recovers from partial state

**Upstream Verification & Cleanup (Resolved TO-4):**
- **Decision:** Strict upstream verification + auto-cleanup (Option A)
- **Implementation:**
  - Verify GPG tag signature: `git verify-commit <commit-sha>`
  - Fail if signature invalid or missing (require signed commits)
  - Auto-cleanup: Remove backups older than 30 days
- **Rationale:** Upstream integrity guaranteed; no backup bloat; audit trail via commit SHAs

**File Categorization:**
- **Sensitive files** (subject to Replace/Merge/Skip):
  - CLAUDE.md, AGENTS.md, GEMINI.md
  - .claude/commands/*.md
  - .clinerules/*.md
  - .roo/rules/*.md, .roo/rules-code/*.md
  - .cursor/rules/*.mdc
  - .windsurf/rules/*.md
- **Non-sensitive files** (auto-updated):
  - .agents/skills/, .agents/scripts/, .agents/schemas/
  - spec/, tests/
  - .agentignore

**Merge Granularity:**
- Section-by-section at `###` heading level
- Files without `###` headings treated as single section
- Fallback for YAML files: key-level merge (Phase 2)

### 4.2 System Graph Blast Radius

**New Node:** `hyper_update` (Module dimension)

**Dependencies:**
- Depends on: `orchestration_layer`, `filesystem`, `git` CLI
- Inputs: upstream_repo_clone (with GPG verification), local_sensitive_files, command_trigger
- Outputs: updated_framework_files, backup_snapshot, merge_report

**Affected Existing Nodes:**
- `orchestration_layer` — routes `/hyper-update` command (no contract change)
- `filesystem` — read/write operations (protected by mutex)
- `user_interface` — merge prompts and summaries

**No Changes to:**
- Skill execution layer, specification compilation, memory system

### 4.3 Execution Checklist (MiniPRDs)

1. **MiniPRD: hyper-update-core-logic** — Fetch, diff, categorize, auto-update, mutex control
2. **MiniPRD: hyper-update-merge-engine** — Section parsing, diff display, approval loop, validation
3. **MiniPRD: hyper-update-recovery** — Backup management, `/hyper-recover` command, interrupt handling
4. **MiniPRD: hyper-update-upstream-verification** — GPG signature verification, backup cleanup
5. **MiniPRD: hyper-update-integration** — CLI bridge, AGENTS.md documentation, architecture.yml

### 4.4 API Contracts

**Input:**
- `/hyper-update` (no arguments)
- `/hyper-recover --file=CLAUDE.md --date=2026-05-04` (optional restore)

**Output (on success):**
```json
{
  "status": "success",
  "timestamp": "2026-05-04T14:30:45Z",
  "backup_dir": ".agents/.backup/2026-05-04T14-30-45Z/",
  "upstream_commit_sha": "abc123def456...",
  "upstream_gpg_signature": "verified",
  "summary": {
    "auto_updated": ["path1", "path2"],
    "replaced": ["CLAUDE.md"],
    "merged": ["AGENTS.md"],
    "skipped": ["GEMINI.md"],
    "validation_result": "pass"
  },
  "files_processed": 42
}
```

### 4.5 Dependencies

- **git** (already required by install.sh)
- **diff** utility (standard POSIX)
- **python3** with `pyyaml` (already installed by install.sh)
- **GPG** for signature verification (standard on Linux/macOS)

---

## 5. Negative Constraints (Resolved)

- **DO NOT** auto-update IDE command bridge files without user approval
- **DO NOT** mutate a file without backing it up first
- **DO NOT** skip the approval gate; each `###` section MUST be explicitly approved
- **DO NOT** perform merge at granularity other than `###` boundaries
- **DO NOT** allow concurrent invocations (mutex enforces this)
- **DO NOT** write syntactically invalid merged files (validation enforces this)
- **DO NOT** proceed if repo has uncommitted changes (warn user; require confirmation)
- **DO NOT** accumulate backups indefinitely (30-day auto-cleanup enforces this)

---

## 6. Risks & Mitigation (Resolved)

| Risk | Mitigation |
|---|---|
| **Merge fatigue** | Limit scope to most-customized files; approval batching (Phase 2) |
| **Merge conflicts** | Edit manually option with strict syntax validation; rejection on invalid |
| **Backup bloat** | 30-day auto-cleanup; `/hyper-recover` for manual restoration |
| **Partial upgrade** | `.merge-in-progress.lock` + resume/restart detection |
| **Concurrent mutations** | Mutex lock prevents parallel invocations |
| **Upstream compromise** | GPG signature verification fails on tampered repos |
| **Syntax corruption** | Post-merge validation rejects invalid files |
| **User confusion** | Clear approval gates; explicit per-section decisions |

---

## 7. Success Metrics

1. **User adoption:** Framework users run `/hyper-update` >5x/month (measured via telemetry)
2. **Customization preservation:** Zero reports of lost customizations over 6 months
3. **Merge accuracy:** Post-merge validation passes in >99% of merges
4. **Time to upgrade:** Approval time <3 minutes for typical user (median 5-10 sections)
5. **Zero data loss:** All mutations backed up; 100% backup creation success rate
6. **Recovery success:** `/hyper-recover` restores 100% of backups correctly
7. **Upstream integrity:** 100% of upstream fetches verified via GPG

---

## 8. Appendix: Example User Flows

### Scenario 1: First-Time User, No Customizations

```
User: /hyper-update

Agent: ✅ GPG signature verified (commit abc123)
       Upstream fetched successfully. Scanning for changes...
       
       ✅ Auto-updated: .agents/skills/, .agents/scripts/, spec/, tests/
       ⏭️  Skipped: CLAUDE.md, AGENTS.md (no local changes)
       
       📊 Upgrade complete!
       Backup: .agents/.backup/2026-05-04T14-30-45Z/
       Commit with: git commit -m "chore: update Hypergraph framework"
```

### Scenario 2: User with Customized CLAUDE.md, Interrupted Mid-Merge

```
User: /hyper-update

Agent: ✅ GPG signature verified
       Scanning for changes...
       
       📝 File: CLAUDE.md (8 differing sections)
       [R]eplace / [M]erge / [S]kip?

User: M

Agent: ### For Claude Code: System Mandates
       Upstream: [new content about /hyper-update]
       Your version: [customized text]
       Keep local / Accept upstream / Edit manually?

User: [hits Ctrl+C — process killed]

---

[User runs /hyper-update again]

Agent: ⚠️  Merge in progress from 2026-05-04T14-30-00Z
       Resume merge of CLAUDE.md? [Y/n]

User: Y

Agent: [Resumes at section 2 of 8; user previously approved section 1]
       
       ### Tool Names
       Upstream: [updated table]
       Your version: [unchanged]
       Keep local / Accept upstream / Edit manually?

User: Accept upstream

Agent: [continues with sections 3-8...]
       
       ✅ Merged CLAUDE.md (validated syntax)
       🔐 Backup: .agents/.backup/2026-05-04T14-30-45Z/CLAUDE.md
       ✅ Upgrade complete!
```

### Scenario 3: User Needs to Recover Old Backup

```
User: /hyper-recover --list

Agent: Available backups:
       - .agents/.backup/2026-04-27T09-15-30Z/ (7 days old)
       - .agents/.backup/2026-04-20T11-22-45Z/ (14 days old)
       - .agents/.backup/2026-05-04T14-30-45Z/ (today)

User: /hyper-recover --file=CLAUDE.md --date=2026-04-27

Agent: ✅ Restoring CLAUDE.md from 2026-04-27T09-15-30Z
       Original backed up to: .agents/.backup/2026-05-04T15-00-00Z/CLAUDE.md
       Restore complete. Commit with: git commit -m "chore: recover CLAUDE.md"
```

---

## Trade-Off Log

| Trade-Off | Decision | Rationale |
|---|---|---|
| **TO-1: Concurrent Invocation Protection** | Mutex Lock | Zero risk; minimal implementation |
| **TO-2: Post-Merge Validation** | Strict Validation | Zero corruption risk; fail-fast behavior |
| **TO-3: Rollback & Recovery** | Full Recovery System | Maximum user control; handles interrupts |
| **TO-4: Upstream Verification & Cleanup** | GPG + Auto-Cleanup | Upstream integrity; prevents bloat |

---

**Status:** Ready for implementation (MiniPRDs compiled below).
