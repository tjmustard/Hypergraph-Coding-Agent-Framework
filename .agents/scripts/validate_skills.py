#!/usr/bin/env python3
"""Validate HCAF skills and their harness bridge files.

Checks:
    * SKILL.md frontmatter: ``name`` equals the skill directory name and follows the
      Agent Skills naming rules (Pi and Gemini CLI identify skills by ``name``);
      ``description`` is present and at most 1024 characters.
    * Skill bodies use harness-neutral capability names (see AGENTS.md -> Harness
      Capability Map) instead of one harness's tool names.
    * Claude Code and Windsurf bridge gaps: missing, orphaned, or broken bridge files
      (warnings only).

Pi and Gemini CLI need no bridge files: they load ``.agents/skills/`` directly (Pi's
``/hyper-<name>`` alias comes from ``.pi/extensions/hcaf-commands.ts``). Bridge
directories that do not exist in the project are skipped, so the script also works in
projects that installed only some harnesses.

Usage:
    python .agents/scripts/validate_skills.py [project_root]

Exits 0 when there are no errors (warnings are allowed), 1 otherwise.
"""

import re
import sys
from dataclasses import dataclass
from pathlib import Path

NAME_PATTERN = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")
MAX_NAME_LENGTH = 64
MAX_DESCRIPTION_LENGTH = 1024

# Harness-specific tool names that skills must express as capabilities instead.
FORBIDDEN_TOOL_NAMES = {
    "AskUserQuestion": "use **ask-user**",
    "Agent tool": "use **sub-agent**",
    "TaskCreate": "describe the task list in plain terms",
    "TodoWrite": "describe the task list in plain terms",
    "WebSearch": "describe the web research step in plain terms",
    "WebFetch": "describe the web research step in plain terms",
}

# Bridge directory -> severity of a missing, orphaned, or broken bridge.
BRIDGE_DIRS = {
    ".claude/commands": "warning",
    ".windsurf/workflows": "warning",
}


@dataclass(frozen=True)
class Finding:
    """A single validation result.

    Attributes:
        severity: Either "error" or "warning".
        path: File or directory the finding refers to, relative to the project root.
        message: Human-readable description of the problem.
    """

    severity: str
    path: str
    message: str


def parse_frontmatter(text: str) -> dict[str, str] | None:
    """Parse the top-level scalar keys of a YAML frontmatter block.

    Args:
        text: Full Markdown file contents.

    Returns:
        Mapping of frontmatter keys to unquoted string values, or None when the file
        does not start with a ``---`` delimited frontmatter block.
    """
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return None
    try:
        end = next(i for i in range(1, len(lines)) if lines[i].strip() == "---")
    except StopIteration:
        return None

    fields: dict[str, str] = {}
    key = None
    for line in lines[1:end]:
        match = re.match(r"^([A-Za-z0-9_-]+):\s*(.*)$", line)
        if match:
            key, value = match.group(1), match.group(2).strip()
            if value in (">", "|", ">-", "|-"):
                value = ""
            if len(value) >= 2 and value[0] == value[-1] and value[0] in "\"'":
                value = value[1:-1]
            fields[key] = value
        elif key and line.startswith((" ", "\t")):
            fields[key] = f"{fields[key]} {line.strip()}".strip()
    return fields


def check_skill(skill_dir: Path, root: Path) -> list[Finding]:
    """Validate one skill directory's SKILL.md.

    Args:
        skill_dir: Directory containing SKILL.md.
        root: Project root, used to report relative paths.

    Returns:
        Findings for this skill.
    """
    skill_md = skill_dir / "SKILL.md"
    rel = str(skill_md.relative_to(root))
    text = skill_md.read_text(encoding="utf-8")
    fields = parse_frontmatter(text)
    if fields is None:
        return [Finding("error", rel, "missing YAML frontmatter")]

    findings = []
    name = fields.get("name", "")
    if name != skill_dir.name:
        findings.append(
            Finding("error", rel, f"name '{name}' must equal directory name '{skill_dir.name}'")
        )
    if len(skill_dir.name) > MAX_NAME_LENGTH or not NAME_PATTERN.match(skill_dir.name):
        findings.append(
            Finding(
                "error",
                rel,
                "directory name must be lowercase letters, digits, and single hyphens "
                f"(max {MAX_NAME_LENGTH} characters)",
            )
        )

    description = fields.get("description", "")
    if not description:
        findings.append(Finding("error", rel, "description is required"))
    elif len(description) > MAX_DESCRIPTION_LENGTH:
        findings.append(
            Finding(
                "error",
                rel,
                f"description is {len(description)} characters (max {MAX_DESCRIPTION_LENGTH})",
            )
        )

    for line_no, line in enumerate(text.splitlines(), start=1):
        for tool, fix in FORBIDDEN_TOOL_NAMES.items():
            if tool in line:
                findings.append(
                    Finding("error", f"{rel}:{line_no}", f"harness-specific '{tool}': {fix}")
                )
    return findings


def check_bridges(skill_names: set[str], root: Path) -> list[Finding]:
    """Validate slash-command bridge files for every harness directory present.

    Args:
        skill_names: Names of all skill directories.
        root: Project root.

    Returns:
        Findings for missing, orphaned, or broken bridges.
    """
    findings = []
    for bridge_dir, severity in BRIDGE_DIRS.items():
        directory = root / bridge_dir
        if not directory.is_dir():
            continue
        bridges = {path.stem: path for path in directory.glob("*.md")}
        for name in sorted(skill_names - bridges.keys()):
            findings.append(Finding(severity, f"{bridge_dir}/{name}.md", "missing bridge"))
        for name in sorted(bridges.keys() - skill_names):
            findings.append(
                Finding(severity, f"{bridge_dir}/{name}.md", "bridge has no matching skill")
            )
        for name in sorted(bridges.keys() & skill_names):
            path = bridges[name]
            text = path.read_text(encoding="utf-8")
            rel = str(path.relative_to(root))
            if f".agents/skills/{name}/SKILL.md" not in text:
                findings.append(
                    Finding(severity, rel, f"does not reference .agents/skills/{name}/SKILL.md")
                )
            fields = parse_frontmatter(text)
            if not fields or not fields.get("description"):
                findings.append(Finding(severity, rel, "missing frontmatter description"))
    return findings


def validate(root: Path) -> list[Finding]:
    """Run all checks against a project.

    Args:
        root: Project root containing ``.agents/skills/``.

    Returns:
        All findings, errors and warnings.
    """
    skills_dir = root / ".agents" / "skills"
    if not skills_dir.is_dir():
        return [Finding("error", ".agents/skills", "directory not found")]
    skill_dirs = sorted(p for p in skills_dir.iterdir() if (p / "SKILL.md").is_file())
    findings = [finding for skill_dir in skill_dirs for finding in check_skill(skill_dir, root)]
    findings.extend(check_bridges({p.name for p in skill_dirs}, root))
    return findings


def main(argv: list[str]) -> int:
    """Validate the project and print a report.

    Args:
        argv: Command-line arguments; the optional first argument is the project root.

    Returns:
        Process exit code: 0 without errors, 1 otherwise.
    """
    root = Path(argv[1]).resolve() if len(argv) > 1 else Path(__file__).resolve().parents[2]
    findings = validate(root)
    for finding in findings:
        print(f"{finding.severity.upper()}: {finding.path}: {finding.message}")
    errors = sum(f.severity == "error" for f in findings)
    warnings = len(findings) - errors
    print(f"validate_skills: {errors} error(s), {warnings} warning(s)")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
