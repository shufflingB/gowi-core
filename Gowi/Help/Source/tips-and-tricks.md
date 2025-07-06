# Tips & Tricks

Master Gowi with these power user techniques and advanced workflows.

## Productivity Workflows

### Quick Capture Workflow
For rapid todo entry:

1. Use <kbd>⌘N</kbd> to create a new todo
2. Type the essential information quickly
3. Press <kbd>Enter</kbd> to confirm
4. Use <kbd>⌘N</kbd> again for the next item

**Pro tip**: Don't worry about perfect formatting initially - you can always add details later.

### GTD (Getting Things Done) Setup
Organize todos using the Getting Things Done methodology:

- Use **Waiting** for "Next Actions"
- Add detailed notes for "Project Support Material"  
- Use completion dates for "Tickler File" items
- Search to create custom "Context" views

### Weekly Review Process
1. Open the **Done** list to review completed work
2. Use search to find todos by project keywords
3. Archive completed projects by deleting old todos
4. Plan the next week by setting completion dates

## Advanced Search Techniques

### Search Operators
- **Exact phrases**: Use quotes - `"important meeting"`
- **Multiple terms**: All terms must match - `project deadline`
- **Partial matching**: Find fragments - `proj` matches "project"

### Search Shortcuts
- <kbd>⌘F</kbd> instantly focuses the search box
- <kbd>Escape</kbd> clears the current search
- Search is case-insensitive by default

### Creating Virtual Lists
Use search to create custom "lists":

- Search `@home` for location-based todos
- Search `urgent` for priority items
- Search `2025` for year-specific goals

## Multi-Window Mastery

### Project Windows
Open separate windows for different projects:

1. Use <kbd>⇧⌘N</kbd> to create a new window
2. Search for project-specific terms in each window
3. Keep windows organized on different desktop spaces

### Reference Windows
Keep a "Done" window open for reference:

1. Open a new window with <kbd>⇧⌘N</kbd>
2. Switch to the **Done** list
3. Use this for checking completed work

### Comparison Windows
Compare different time periods:

- One window showing current month's todos
- Another showing last month's completed items
- Use search with dates for temporal filtering

## Keyboard Shortcuts Mastery

### Navigation Shortcuts
| Shortcut | Action |
|----------|--------|
| <kbd>⌘1</kbd> | Switch to All list |
| <kbd>⌘2</kbd> | Switch to Waiting list |
| <kbd>⌘3</kbd> | Switch to Done list |
| <kbd>⌘F</kbd> | Focus search field |
| <kbd>Tab</kbd> | Move between interface areas |

### Editing Shortcuts
| Shortcut | Action |
|----------|--------|
| <kbd>⌘N</kbd> | New todo |
| <kbd>⌘⌫</kbd> | Delete selected todo |
| <kbd>⌘Z</kbd> | Undo last action |
| <kbd>⇧⌘Z</kbd> | Redo last undone action |
| <kbd>⌘S</kbd> | Save pending changes |
| <kbd>⌘E</kbd> | Export selected todo as JSON |

### Window Management
| Shortcut | Action |
|----------|--------|
| <kbd>⇧⌘N</kbd> | New window |
| <kbd>⌘W</kbd> | Close current window |
| <kbd>⌘M</kbd> | Minimize window |
| <kbd>⌘`</kbd> | Cycle between Gowi windows |

## Data Organization Strategies

### Hierarchical Organization
Use indentation and grouping in notes:

```
Project: Website Redesign
  - Research competitor sites
  - Create wireframes
  - Design mockups
  - Implement frontend
  - Test and deploy
```

### Tagging System
Create a consistent tagging system in notes:

- `#work` - Work-related todos
- `#personal` - Personal todos
- `#urgent` - High priority items
- `#waiting` - Blocked or waiting for others

### Date-Based Organization
Use completion dates strategically:

- **This week**: Set specific dates for immediate todos
- **This month**: Set end-of-month dates for larger goals
- **Someday**: Leave completion date empty for "someday/maybe" items

## CloudKit Sync Tips

### Conflict Resolution
When the same todo is edited on multiple devices:

- Gowi automatically merges non-conflicting changes
- For conflicts, the most recent change wins
- Keep important devices connected to iCloud

### Offline Work
Working without internet:

- All editing continues normally offline
- Changes sync automatically when connection returns
- No data loss occurs during offline periods

### Multi-Device Workflows
Optimize for multiple devices:

- Use iPhone for quick capture on the go
- Use Mac for detailed planning and organization
- Use iPad for review and processing

## Automation and Integration

### URL Schemes
Automate todo creation from other apps:

```bash
# Create a new todo
open "gowi://main/v1/newItem"

# Open specific list
open "gowi://main/v1/showitems?fid=Waiting"
```

### Text Expansion
Use text expansion tools for common patterns:

- `;meet` → "Meeting with [person] about [topic]"
- `;proj` → "Project: [name] - [description]"
- `;call` → "Call [person] regarding [topic]"

### Data Export Workflows
Export your todos for backup and integration:

**JSON Export for Analysis**:
1. Select any todo item in your list
2. Use <kbd>⌘E</kbd> or File → Export JSON
3. Choose a descriptive filename (e.g., `project-todos-2025.json`)
4. Import into spreadsheets, databases, or analysis tools

**Backup Important Projects**:
- Export key project todos as JSON before major changes
- Create periodic exports for project documentation
- Use JSON exports to share specific todos with team members

**Data Migration Workflow**:
- Export completed todos before archiving
- Create JSON backups before major app updates
- Use structured JSON for importing into other task management systems

### Backup Strategies
Protect your data:

- CloudKit provides automatic backup
- Export important todos as JSON periodically
- Keep devices regularly synced with iCloud
- Create manual JSON exports for critical projects

## Troubleshooting Tips

### Sync Issues
If todos aren't syncing:

1. Check iCloud settings in System Preferences
2. Ensure you're signed into the same iCloud account
3. Check internet connection on all devices
4. Force quit and restart Gowi

### Performance Optimization
For large todo collections:

- Use search instead of browsing all todos
- Regularly archive completed todos
- Keep individual notes reasonably sized

### Undo Problems
If undo isn't working as expected:

- Remember that undo is context-sensitive
- Switching between areas clears the undo stack
- Use <kbd>⌘S</kbd> to save important changes

---

*These techniques will help you get the most out of Gowi. Experiment with different approaches to find what works best for your workflow!*