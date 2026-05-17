# Development Notes

Hypergraph Coding Agent Framework is built to handle specific workflows safely and efficiently. This document is a starting point for developers modifying the project, providing a compact orientation to the key project documents and repository organization.

**Essential project documents:**

| Document | Role |
| --- | --- |
| [README.md](README.md) | Primary user-facing overview of the tool and installation. |
| [DEVELOPMENT.md](DEVELOPMENT.md) | This document. |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Contribution process, testing requirements, and AI disclosure rules. |

**Main repository components:**

| Directory | Role |
| --- | --- |
| `.agents/` | Core framework logic including skills, schemas, rules, and scripts. |
| `tests/` | Pytest fixtures and integration tests. |
| `docs/` | User-facing documentation and tutorials. |
| `spec/` | Hypergraph specifications (MiniPRDs and `architecture.yml`) used by the AI coding agent framework. |

**Development Workflow:**

This project utilizes `uv` as its strict package manager. 
- Use `uv add <package>` to modify dependencies.
- Use `uv run pytest` to execute the test suite.
