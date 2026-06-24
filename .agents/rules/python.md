---
trigger: always_on
glob: "**/*.py"
description: Python standards for [Project Name]
---

# Python Standards ([Project Name])

## Tech Stack
- **Language**: Python 3.10+
- **Manager**: `uv` (Strict).
- **Linter**: `ruff` (Strict).
- **Core Libs**: `typer` (CLI), `pydantic` (Data Validation). # Example libraries

## Code Style
- **Type Hints**: REQUIRED for ALL function arguments and return values.
  - `def func(x: List[float]) -> List[float]:`
- **Docstrings**: Google Style required.
- **Paths**: `pathlib.Path` ONLY. No string concatenation for paths.

## Linting Configuration

Every project must have a `pyproject.toml` with the following ruff configuration:

```toml
[tool.ruff]
line-length = 88

[tool.ruff.lint]
select = ["E", "F", "W", "I", "D"]
ignore = ["D100", "D104"]  # public module / package docstrings optional

[tool.ruff.lint.pydocstyle]
convention = "google"

[tool.ruff.lint.isort]
known-first-party = ["<package_name>"]

[tool.ruff.format]
quote-style = "double"
```

Install as a dev dependency: `uv add --dev ruff`

Both must exit 0 before every PR:
- `uv run ruff check .`
- `uv run ruff format --check .`

## Architectural Constraints
- **Functions**: Pure functions. No side effects. Deterministic where possible.
- **Dependency Isolation**:
  - `core/` should NOT import from implementation details.
  - `utils/` should remain generic.

## Anti-Patterns
- **Global State**: Mutable global variables are FORBIDDEN.
- **Print Debugging**: Use `logging` or return structured errors.
- **Bare Exceptions**: Never use `except:`. Catch specific errors (`ValueError`, `ImportError`).
