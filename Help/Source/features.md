# Features

Gowi is packed with powerful features designed to make todo management effortless and efficient.

## Core Features

### Smart Lists
Gowi automatically organizes your todos into intelligent lists:

- **All** - Complete overview of every todo
- **Waiting** - Active todos that need your attention  
- **Done** - Completed todos for reference and review

### CloudKit Sync
Your todos sync seamlessly across all your Apple devices using iCloud:

- Automatic background sync
- Conflict resolution
- Works offline - syncs when connection returns
- No additional accounts or subscriptions required

### Advanced Search
Find what you need instantly:

- **Real-time search** - Results update as you type
- **Content search** - Searches both titles and notes
- **Case-insensitive** - Find items regardless of capitalization
- **Instant filtering** - No delays or loading times

## Productivity Features

### Multi-Window Support
Work on multiple projects simultaneously:

- Open different lists in separate windows
- Each window maintains independent state
- Deep linking support with custom URLs
- Window-specific undo stacks

### Smart Undo System (UWFA)
Advanced undo management that understands your workflow:

- **Context-aware undo** - Groups related changes
- **Area isolation** - Prevents cross-contamination between work areas
- **Granular control** - Undo at the right level of detail
- **Multi-window support** - Independent undo stacks per window

### Keyboard-First Design
Comprehensive keyboard shortcuts for maximum productivity:

| Category | Shortcut | Action |
|----------|----------|--------|
| **Creation** | <kbd>⌘N</kbd> | New todo |
| **Navigation** | <kbd>⌘1</kbd> | All list |
| **Navigation** | <kbd>⌘2</kbd> | Waiting list |
| **Navigation** | <kbd>⌘3</kbd> | Done list |
| **Editing** | <kbd>⌘⌫</kbd> | Delete selected |
| **Files** | <kbd>⌘S</kbd> | Save changes |
| **Windows** | <kbd>⇧⌘N</kbd> | New window |
| **Search** | <kbd>⌘F</kbd> | Focus search |

## Data Management

### Flexible Todo Structure
Each todo supports:

- **Rich titles** - Primary task description
- **Detailed notes** - Additional context, links, subtasks
- **Completion dates** - Optional due dates and scheduling
- **Hierarchical organization** - Parent-child relationships

### Robust Data Persistence
Your data is protected:

- **CoreData backend** - Reliable local storage
- **CloudKit integration** - Secure cloud backup
- **Conflict resolution** - Handles simultaneous edits
- **Data integrity** - Prevents corruption and loss

### Export and Sharing
Share your todos and collaborate:

- **Deep linking** - Share specific todos with custom URLs
- **Multi-format support** - Copy data in various formats
- **Cross-device access** - Open shared links on any device

## Interface Features

### Adaptive Layout
The interface responds to your needs:

- **Responsive design** - Adapts to different window sizes
- **Sidebar toggle** - Show/hide sidebar as needed
- **Detail panel** - Context-sensitive information display
- **Toolbar customization** - Access frequently used actions

### Visual Indicators
Stay informed at a glance:

- **Status badges** - Quick visual status identification
- **Progress indicators** - See completion status
- **Change indicators** - Know when data needs saving
- **Search highlighting** - See matching terms in results

### Accessibility
Designed for everyone:

- **Full keyboard navigation** - Use without a mouse
- **VoiceOver support** - Screen reader compatibility
- **High contrast support** - Clear visibility options
- **Focus management** - Logical navigation flow

## Developer Features

### URL Scheme Support
Gowi supports custom URLs for automation:

```
gowi://main/v1/newItem
gowi://main/v1/showitems?fid=All
gowi://main/v1/showitems?fid=Waiting&id=<UUID>
```

### AppleScript Integration
Automate common tasks:

- Create todos from other applications
- Extract data for reporting
- Integrate with other productivity tools

---

*Want to learn advanced techniques? Check out [Tips & Tricks](tips-and-tricks.html) for power user workflows.*