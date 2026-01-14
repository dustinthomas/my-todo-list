# TodoTUI - Terminal User Interface Todo List Manager

A simple, maintainable todo list manager with an interactive Terminal User Interface (TUI), built with Julia and Claude Code.

**Current Status:** 🚧 In Development (Phases 1-3: Foundation, Docker, Database)

**TUI Implementation:** Coming soon (Phases 4-13)

## Features

### Current (After Phase 3)
- ✅ SQLite database with projects, categories, and todos
- ✅ Full CRUD operations for all entities
- ✅ Docker development environment
- ✅ Comprehensive test suite
- ✅ Boris Cherny "Plant" workflow for parallel development

### Upcoming (Phases 4-13)
- 🔜 Interactive TUI with Term.jl rendering
- 🔜 Keyboard navigation (arrow keys, shortcuts)
- 🔜 Multiple screens (list, detail, edit, filter, stats)
- 🔜 Color-coded status and priority indicators
- 🔜 Project and category management
- 🔜 Statistics dashboard

### Future
- 📋 Wafer tracking extension with Rasters.jl

## Requirements

- **Julia 1.9+**
- **Docker** (required for work project isolation)
- **Git**

## Quick Start

### 1. Clone Repository

```bash
git clone https://github.com/YOUR-USERNAME/my-todo-list.git
cd my-todo-list
```

### 2. Start Docker Environment

```bash
./scripts/docker-start
```

### 3. Initialize Database

```bash
# Inside Docker container
julia --project=. scripts/install.jl
```

### 4. Generate Demo Data (Optional)

```bash
julia --project=. scripts/demo.jl
```

### 5. Run Tests

```bash
./scripts/docker-test
```

## Project Structure

```
my-todo-list/
├── .claude/
│   └── commands/          # Slash commands for specialized Claude sessions
├── plans/                 # Version-controlled implementation plans
├── docs/
│   └── features/         # Feature specifications
├── scripts/
│   ├── docker-*          # Docker helper scripts
│   ├── install.jl        # Database initialization
│   └── demo.jl           # Sample data generation
├── src/
│   ├── TodoTUI.jl        # Main module
│   ├── models.jl         # Data structures
│   ├── database.jl       # Schema and connections
│   ├── queries.jl        # CRUD operations
│   └── tui/              # TUI components (Phase 4+)
├── test/
│   ├── runtests.jl       # Test entry point
│   ├── test_database.jl  # Database tests
│   └── test_queries.jl   # Query tests
├── CLAUDE.md             # Development rulebook
├── CLAUDE-WORKFLOW.md    # Boris Cherny workflow guide
└── README.md             # This file
```

## Development Workflow

This project follows the **Boris Cherny "Plant" workflow** with specialized Claude Code sessions:

| Role | Command | Purpose |
|------|---------|---------|
| Planner | `/plan-feature` | Create detailed plans (read-only) |
| Implementer | `/implement-step` | Execute one step at a time |
| Tester | `/verify-feature` | Run tests and verify criteria |
| Refactorer | `/simplify` | Improve code quality |
| Docs | `/update-rules` | Update CLAUDE.md with lessons |

See [CLAUDE-WORKFLOW.md](CLAUDE-WORKFLOW.md) for complete workflow documentation.

## Database Schema

### projects
- id, name, description, color, created_at, updated_at

### categories
- id, name, color, created_at

### todos
- id, title, description, status, priority, project_id, category_id
- start_date, due_date, completed_at, created_at, updated_at

**Status values:** pending, in_progress, completed, blocked
**Priority values:** 1 (high), 2 (medium), 3 (low)

## Docker Commands

```bash
# Start environment
./scripts/docker-start

# Stop environment
./scripts/docker-stop

# Run tests
./scripts/docker-test

# View logs
./scripts/docker-logs

# Restart backend (after Julia changes)
./scripts/docker-restart-backend

# Clean containers and volumes
./scripts/docker-clean
```

## Testing

### Run All Tests

```bash
./scripts/docker-test
```

### Run Specific Test File

```bash
# Inside Docker container
julia --project=. test/test_database.jl
```

### Test Coverage

- **Database tests**: Schema creation, constraints, foreign keys
- **Query tests**: CRUD operations, filtering, edge cases
- **TUI tests** (Phase 4+): Component rendering, navigation

## Contributing

### Branching Strategy

ALL code changes require feature branches:

```bash
# Create branch before any changes
git checkout -b feature/YOUR-FEATURE-NAME

# Make changes, test, commit
git add .
git commit -m "feat: your feature description"

# Push and create PR
git push -u origin feature/YOUR-FEATURE-NAME
gh pr create
```

**Exception:** Updating CLAUDE.md can be done on main with approval.

### Development Phases

Current implementation is divided into phases:

**Phase 1: Foundation** ✅
- Project structure
- CLAUDE.md and workflow documentation
- Slash commands

**Phase 2: Docker Setup** 🔜
- Dockerfile and docker-compose
- Helper scripts
- Container configuration

**Phase 3: Database Layer** 🔜
- Schema and models
- CRUD operations
- Test suite

**Phases 4-13: TUI Implementation** 📋
- TUI framework (Phase 4)
- Screens: list, detail, edit, filter (Phases 5-9)
- Management: projects, categories (Phases 10-11)
- Statistics dashboard (Phase 12)
- Polish and documentation (Phase 13)

See [Implementation Plan](plans/cozy-stargazing-cosmos.md) for complete details.

## Documentation

- **[CLAUDE.md](CLAUDE.md)**: Development rulebook and guidelines
- **[CLAUDE-WORKFLOW.md](CLAUDE-WORKFLOW.md)**: Workflow documentation
- **[plans/README.md](plans/README.md)**: How to use implementation plans
- **[docs/features/_TEMPLATE.md](docs/features/_TEMPLATE.md)**: Feature specification template

## Technology Stack

- **Language**: Julia 1.9+
- **TUI**: Term.jl (rendering) + TerminalMenus.jl (navigation)
- **Database**: SQLite.jl + DBInterface.jl
- **Testing**: Julia Test stdlib
- **Containerization**: Docker + docker-compose

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Acknowledgments

Built with [Claude Code](https://claude.com/claude-code) following the Boris Cherny "Plant" workflow.

---

**Note:** This project is in active development. TUI implementation (Phases 4-13) is upcoming. Current phases (1-3) establish the foundation: project structure, Docker environment, and database layer.

For questions or issues, see [CLAUDE.md](CLAUDE.md) or create an issue on GitHub.
