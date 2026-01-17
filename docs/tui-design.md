# TUI Design Document

This document contains wireframes and interaction design for the TodoList TUI.

## Design Decisions

Based on review, the following decisions were made:

1. **List View**: Scrolling (continuous scroll through all items)
2. **Complete Key**: Toggle behavior ('c' toggles between completed and pending)
3. **Filters**: Combined with AND logic (multiple filters can be active simultaneously)
4. **Project/Category Management**: Full CRUD (includes edit functionality)

---

## Screen Inventory

1. **Main List View** - Primary screen showing todos with status, priority, title (scrolling)
2. **Todo Detail View** - Full details of a single todo
3. **Add Todo Form** - Create new todo with all fields
4. **Edit Todo Form** - Modify existing todo
5. **Filter Menu** - Select filter criteria (status, project, category) - combinable
6. **Project List** - View/manage projects
7. **Project Add Form** - Create new project
8. **Project Edit Form** - Modify existing project
9. **Category List** - View/manage categories
10. **Category Add Form** - Create new category
11. **Category Edit Form** - Modify existing category
12. **Delete Confirmation** - Confirm destructive actions

---

## ASCII Wireframes

### 1. Main List View

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              Todo List                                      │
│                     [Filter: All] [4 items]                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ID   Status       Priority   Title                          Due          │
│  ───────────────────────────────────────────────────────────────────────    │
│   1    pending      HIGH       Fix authentication bug         2026-01-20   │
│ > 2    in_progress  MEDIUM     Add user dashboard             2026-01-25   │
│   3    completed    LOW        Update documentation           -            │
│   4    blocked      HIGH       Deploy to production           2026-01-18   │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│ [j/k] Navigate  [Enter] View  [a] Add  [c] Complete  [d] Delete  [f] Filter│
│ [p] Projects    [g] Categories                                   [q] Quit  │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Elements:**
- Header with title and filter indicator
- Table with ID, Status (color-coded), Priority (color-coded), Title, Due date
- Selected row marked with `>` and highlighted
- Footer with keyboard shortcuts
- Status colors: pending=yellow, in_progress=blue, completed=green, blocked=red
- Priority colors: HIGH=red, MEDIUM=yellow, LOW=dim

**Empty State:**
```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              Todo List                                      │
│                     [Filter: All] [0 items]                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│                                                                             │
│                         No todos yet!                                       │
│                    Press 'a' to add your first todo                         │
│                                                                             │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│ [a] Add Todo    [p] Projects    [g] Categories                   [q] Quit  │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

### 2. Todo Detail View

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            Todo Details                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Title:       Add user dashboard                                            │
│  ID:          2                                                             │
│  Status:      in_progress                                                   │
│  Priority:    MEDIUM                                                        │
│                                                                             │
│  Description:                                                               │
│  ─────────────────────────────────────────────────────────────              │
│  Create a dashboard showing user statistics, recent activity,               │
│  and quick actions for common tasks.                                        │
│                                                                             │
│  Project:     Web App                                                       │
│  Category:    Feature                                                       │
│                                                                             │
│  Start Date:  2026-01-15                                                    │
│  Due Date:    2026-01-25                                                    │
│  Created:     2026-01-10 14:30:00                                           │
│  Updated:     2026-01-16 09:15:00                                           │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│ [b] Back    [e] Edit    [c] Complete    [d] Delete                          │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Elements:**
- All todo fields displayed with labels
- Description in a separate section with full text
- Project and category names (not IDs)
- Timestamps in readable format

---

### 3. Add Todo Form

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                             Add New Todo                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Title*:      [_________________________________]                           │
│                                                                             │
│  Description: [_________________________________]                           │
│               [_________________________________]                           │
│                                                                             │
│  Status:      ( ) pending   ( ) in_progress   ( ) blocked                   │
│                                                                             │
│  Priority:    ( ) HIGH      (•) MEDIUM        ( ) LOW                       │
│                                                                             │
│  Project:     [None                          ▼]                             │
│                                                                             │
│  Category:    [None                          ▼]                             │
│                                                                             │
│  Start Date:  [YYYY-MM-DD   ]                                               │
│                                                                             │
│  Due Date:    [YYYY-MM-DD   ]                                               │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│ [Tab] Next field    [Shift+Tab] Previous    [Enter] Save    [Esc] Cancel   │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Elements:**
- Title is required (marked with *)
- Description allows multi-line (simplified to single for TUI)
- Status and Priority as radio button groups
- Project/Category as dropdown selectors (using TerminalMenus)
- Date fields with format hint

**Input Flow:**
1. Title (text input)
2. Description (text input, optional)
3. Status (radio selection, default: pending)
4. Priority (radio selection, default: MEDIUM)
5. Project (menu selection, default: None)
6. Category (menu selection, default: None)
7. Start Date (text input, optional)
8. Due Date (text input, optional)
9. Confirm or Cancel

---

### 4. Edit Todo Form

Same layout as Add Todo Form but:
- Title shows "Edit Todo" instead of "Add New Todo"
- All fields pre-populated with existing values
- Shows todo ID in header or as read-only field

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          Edit Todo #2                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Title*:      [Add user dashboard_____________]                             │
│  ...                                                                        │
```

---

### 5. Filter Menu

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                             Filter Todos                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Current filters:                                                           │
│    Status: all                                                              │
│    Project: all                                                             │
│    Category: all                                                            │
│                                                                             │
│  ─────────────────────────────────────────────────────────────              │
│                                                                             │
│  Select filter to change:                                                   │
│                                                                             │
│  > Filter by Status                                                         │
│    Filter by Project                                                        │
│    Filter by Category                                                       │
│    Clear All Filters                                                        │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│ [j/k] Navigate    [Enter] Select    [Esc/b] Back                            │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Sub-menu Example (Filter by Status):**
```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          Filter by Status                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  > All (clear filter)                                                       │
│    pending                                                                  │
│    in_progress                                                              │
│    completed                                                                │
│    blocked                                                                  │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│ [j/k] Navigate    [Enter] Select    [Esc/b] Back                            │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

### 6. Project List

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              Projects                                       │
│                           [3 projects]                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ID   Name             Description                      Todos  Color       │
│  ───────────────────────────────────────────────────────────────────────    │
│   1    Web App          Main web application             12     #FF6B6B     │
│ > 2    Mobile App       iOS and Android apps              5     #4ECDC4     │
│   3    Infrastructure   DevOps and deployment             3     #45B7D1     │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│ [j/k] Navigate  [a] Add  [e] Edit  [d] Delete                    [b] Back  │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Empty State:**
```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              Projects                                       │
│                           [0 projects]                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│                         No projects yet!                                    │
│                    Press 'a' to add your first project                      │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│ [a] Add Project    [b] Back                                                 │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

### 7. Project Add Form

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           Add New Project                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Name*:        [_________________________________]                          │
│                                                                             │
│  Description:  [_________________________________]                          │
│                                                                             │
│  Color:        [#FF6B6B  ] (hex code, e.g., #FF6B6B)                        │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│ [Tab] Next field    [Enter] Save    [Esc] Cancel                            │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

### 8. Project Edit Form

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         Edit Project #2                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Name*:        [Mobile App_________________________]                        │
│                                                                             │
│  Description:  [iOS and Android apps_______________]                        │
│                                                                             │
│  Color:        [#4ECDC4  ] (hex code, e.g., #FF6B6B)                        │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│ [Tab] Next field    [Enter] Save    [Esc] Cancel                            │
└─────────────────────────────────────────────────────────────────────────────┘
```

Same layout as Add Project Form but:
- Title shows "Edit Project #N"
- Fields pre-populated with existing values

---

### 9. Category List

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                             Categories                                      │
│                           [4 categories]                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ID   Name             Todos  Color                                        │
│  ───────────────────────────────────────────────────────────────────────    │
│   1    Bug               8     #E74C3C                                      │
│   2    Feature           7     #27AE60                                      │
│ > 3    Documentation     3     #3498DB                                      │
│   4    Refactor          2     #9B59B6                                      │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│ [j/k] Navigate  [a] Add  [e] Edit  [d] Delete                    [b] Back  │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

### 10. Category Add Form

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          Add New Category                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Name*:   [_________________________________]                               │
│                                                                             │
│  Color:   [#E74C3C  ] (hex code, e.g., #E74C3C)                             │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│ [Tab] Next field    [Enter] Save    [Esc] Cancel                            │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

### 11. Category Edit Form

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        Edit Category #3                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Name*:   [Documentation_______________________]                            │
│                                                                             │
│  Color:   [#3498DB  ] (hex code, e.g., #E74C3C)                             │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│ [Tab] Next field    [Enter] Save    [Esc] Cancel                            │
└─────────────────────────────────────────────────────────────────────────────┘
```

Same layout as Add Category Form but:
- Title shows "Edit Category #N"
- Fields pre-populated with existing values

---

### 12. Delete Confirmation Dialog

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          Confirm Delete                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│     Are you sure you want to delete this todo?                              │
│                                                                             │
│     "Add user dashboard"                                                    │
│                                                                             │
│     This action cannot be undone.                                           │
│                                                                             │
│               [ Yes, Delete ]     [ Cancel ]                                │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

### 13. Message/Feedback Display

Success and error messages appear at the top of the current screen:

**Success Message:**
```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ✓ Todo created successfully                                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                              Todo List                                      │
│  ...                                                                        │
```

**Error Message:**
```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ✗ Error: Title cannot be empty                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                             Add New Todo                                    │
│  ...                                                                        │
```

---

## Interaction Flow

```
                              ┌──────────┐
                              │  Start   │
                              └────┬─────┘
                                   │
                                   ▼
                    ┌──────────────────────────────┐
           ┌───────│       Main List View         │───────┐
           │       └──────────────────────────────┘       │
           │         │   │   │   │   │                    │
           │    [a]  │   │   │   │   │ [Enter]            │ [q]
           │         │   │   │   │   │                    │
           ▼         │   │   │   │   ▼                    ▼
  ┌────────────────┐ │   │   │   │  ┌────────────────┐  ┌──────┐
  │  Add Todo Form │ │   │   │   │  │ Todo Detail    │  │ Exit │
  └────────────────┘ │   │   │   │  │ View           │  └──────┘
           │         │   │   │   │  └────────────────┘
           │ [Esc]   │   │   │   │       │  │  │
           │ [Enter] │   │   │   │  [e]  │  │  │ [b]
           └─────────┼───┼───┼───┼───────┘  │  └────────────────┐
                     │   │   │   │          │                   │
                [c]  │   │   │   │ [d]      ▼                   │
                     │   │   │   │    ┌────────────────┐        │
                     │   │   │   │    │ Edit Todo Form │        │
                     │   │   │   │    └────────────────┘        │
                     │   │   │   │          │ [Esc]/[Enter]     │
                     │   │   │   │          └───────────────────┤
                     │   │   │   │                              │
                     │   │   │   ▼                              │
                     │   │   │  ┌────────────────┐              │
                     │   │   │  │ Delete Confirm │              │
                     │   │   │  └────────────────┘              │
                     │   │   │       │ [y]/[n]                  │
                     │   │   │       └──────────────────────────┤
                     │   │   │                                  │
                     │   │   ▼                                  │
                     │   │  ┌────────────────┐                  │
                     │   │  │ Filter Menu    │◄─────────────────┤
                     │   │  └────────────────┘                  │
                     │   │       │ [Esc]/selection              │
                     │   │       └──────────────────────────────┤
                     │   │                                      │
                     │   ▼                                      │
                     │  ┌────────────────┐                      │
                     │  │ Project List   │◄─────────────────────┤
                     │  └────────────────┘                      │
                     │       │ [a]    │ [b]                     │
                     │       ▼        └─────────────────────────┤
                     │  ┌────────────────┐                      │
                     │  │ Project Add    │                      │
                     │  └────────────────┘                      │
                     │       │ [Esc]/[Enter]                    │
                     │       └──────────────────────────────────┤
                     │                                          │
                     ▼                                          │
                ┌────────────────┐                              │
                │ Category List  │◄─────────────────────────────┤
                └────────────────┘                              │
                     │ [a]    │ [b]                             │
                     ▼        └─────────────────────────────────┘
                ┌────────────────┐
                │ Category Add   │
                └────────────────┘
                     │ [Esc]/[Enter]
                     └──────────────────────────────────────────┘
```

---

## Keyboard Shortcuts Reference

### Global (all screens)
| Key | Action |
|-----|--------|
| q | Quit application (from main list only) |
| Esc | Cancel/Back |
| Ctrl+C | Force quit |

### Navigation (list screens)
| Key | Action |
|-----|--------|
| j / ↓ | Move selection down |
| k / ↑ | Move selection up |
| Enter | Select/View |
| g / Home | Jump to first item |
| G / End | Jump to last item |

### Main List View
| Key | Action |
|-----|--------|
| a | Add new todo |
| c | Complete selected todo (toggle) |
| d | Delete selected todo (with confirmation) |
| e | Edit selected todo |
| f | Open filter menu |
| p | Open projects |
| g | Open categories |
| / | Search (future feature) |

### Detail View
| Key | Action |
|-----|--------|
| b | Back to list |
| e | Edit this todo |
| c | Complete this todo |
| d | Delete this todo |

### Form Screens
| Key | Action |
|-----|--------|
| Tab | Next field |
| Shift+Tab | Previous field |
| Enter | Save (when on submit) or confirm selection |
| Esc | Cancel and go back |

### Delete Confirmation
| Key | Action |
|-----|--------|
| y / Enter | Confirm delete |
| n / Esc | Cancel |

---

## Color Scheme

### Status Colors
| Status | Color | Term.jl Style |
|--------|-------|---------------|
| pending | Yellow | `{yellow}pending{/yellow}` |
| in_progress | Blue | `{blue}in_progress{/blue}` |
| completed | Green | `{green}completed{/green}` |
| blocked | Red | `{red}blocked{/red}` |

### Priority Colors
| Priority | Display | Color | Style |
|----------|---------|-------|-------|
| 1 | HIGH | Red | `{bold red}HIGH{/bold red}` |
| 2 | MEDIUM | Yellow | `{yellow}MEDIUM{/yellow}` |
| 3 | LOW | Dim | `{dim}LOW{/dim}` |

### UI Elements
| Element | Style |
|---------|-------|
| Selected row | Reverse/highlight background |
| Headers | Bold |
| Borders | Default |
| Success messages | Green |
| Error messages | Red |
| Warnings | Yellow |

---

## Implementation Notes

### Term.jl Components to Use
- `Panel` - For main screen frames
- `Table` - For todo/project/category lists (with fixed column widths)
- `tprint` / styled text - For colored status/priority
- `clear()` - Screen clearing between renders

### TerminalMenus.jl for
- Status/Priority radio selections in forms
- Project/Category dropdowns
- Filter sub-menus

### Terminal Considerations
- Minimum terminal size: 80x24
- Handle terminal resize gracefully
- Ensure clean exit (restore terminal state)
- Support for non-256-color terminals (fallback colors)

---

## Approval Status

**Approved: 2026-01-17**

Design decisions confirmed:
- Scrolling list view (no pagination)
- 'c' key toggles completion status
- Filters combinable with AND logic
- Full CRUD for projects and categories
