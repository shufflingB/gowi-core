# Gowi - Get On With It

Gowi (*Get On With It*) is a feature-complete todo application for macOS that demonstrates what's possible when SwiftUI is used to its full potential. Built to follow established macOS platform conventions, Gowi provides a familiar yet powerful interface for managing your tasks and projects.

![Gowi running on macOS](DevAssets/GowiRunningOnMacOSScreenshot.png)

## Why Gowi?

Gowi was created to showcase how modern SwiftUI applications can achieve professional-grade functionality while maintaining the polish and usability that macOS users expect. It serves as both a practical productivity tool and a reference implementation for SwiftUI best practices.

**Key Design Goals:**
- **Platform Native**: Follows macOS conventions you already know
- **Multi-Window Ready**: Work with multiple projects simultaneously  
- **Sync Enabled**: Your data follows you across all your devices
- **Keyboard Friendly**: Full keyboard navigation for power users
- **URL Addressable**: Deep link to specific items and views

## System Requirements

- **macOS Sequoia 15.0** or later
- **iCloud account** for data synchronization across devices

## What You Can Do

### Task Management
- **Create and Edit Items**: Each task has a title, detailed notes, priority, and completion tracking
- **Smart Organization**: Tasks are automatically organized into Waiting (incomplete) and Done (completed) lists
- **Priority Management**: Drag and drop to reorder tasks by importance
- **Rich Editing**: Full text editing with undo/redo support

### Powerful Search and Filtering
- **Live Search**: Instantly find tasks as you type
- **Smart Filters**: View All items, only Waiting tasks, or completed items
- **Independent Search**: Each filter maintains its own search state
- **Real-time Results**: Search results update immediately as you modify tasks

### Multi-Window Productivity
- **Multiple Windows**: Open several windows to work on different projects
- **Independent Views**: Each window can show different filters and selections
- **Shared Data**: Changes in one window immediately appear in others
- **Window Memory**: The app remembers your window arrangements between sessions

### Seamless Device Sync
- **iCloud Integration**: Your tasks automatically sync across all your devices
- **Conflict Resolution**: Smart merging handles simultaneous edits gracefully
- **Offline Capable**: Work without internet - changes sync when reconnected
- **Privacy Focused**: All data stays in your private iCloud space

### Professional Keyboard Support
- **Complete Navigation**: Navigate entirely by keyboard if preferred
- **Smart Shortcuts**: Industry-standard keyboard shortcuts (⌘N for new, ⌘⌫ for delete, etc.)
- **Quick Actions**: Rapid task creation, completion, and organization
- **Focus Management**: Intelligent focus handling optimized for productivity

### Deep Linking and URL Support
Share and bookmark specific views with custom URLs:
- **Direct Item Access**: `gowi://main/v1/showitems?id=<item-id>` 
- **Filtered Views**: `gowi://main/v1/showitems?fid=Waiting`
- **Quick Creation**: `gowi://main/v1/newItem`
- **Cross-App Integration**: Works from browsers, scripts, and other applications

### Context-Aware Menus
- **Right-Click Menus**: Context-sensitive options for quick actions
- **Smart Menu Bar**: Menu commands adapt based on current selection and window state
- **JSON Export**: Export selected items as structured data files (⌘E)
- **Batch Operations**: Perform actions on multiple selected items
- **Window Coordination**: Menu commands work intelligently across multiple windows

### Data Safety and Reliability
- **Comprehensive Undo**: Undo/redo support for all operations with intelligent scope management
- **Automatic Saving**: Changes are saved automatically with CloudKit integration
- **Data Protection**: Built-in safeguards against accidental data loss
- **Export Ready**: Copy item details, IDs, and URLs to share or archive, plus full JSON export for data portability

## How to Use

### Getting Started
1. **Launch Gowi** - The app opens with a clean interface ready for your first task
2. **Create Your First Item** - Press ⌘N or click "New Item" to get started
3. **Add Details** - Fill in the title, detailed notes, and set priority as needed
4. **Mark Complete** - Check off items as you complete them

### Power User Tips
- **Keyboard Navigation**: Use arrow keys to move between items, Enter to edit
- **Quick Search**: Start typing to search within any view
- **Multi-Select**: Hold ⌘ and click to select multiple items for batch operations
- **Priority Reordering**: Drag items up and down in the Waiting list to change priority
- **Multiple Windows**: ⌘T opens a new window, ⌘⌥O opens selected items in a new window

### Staying Organized
- **Use the Waiting Filter** for active tasks that need your attention
- **Switch to Done Filter** to review completed work and track progress
- **Use All Filter** when you need to see everything at once
- **Search Across Filters** to quickly find specific items regardless of status

### Advanced Features
- **JSON Export**: Export individual todos as structured JSON files for backup, data analysis, or integration with other tools (⌘E)
- **URL Sharing**: Copy item URLs from the detail view to share specific tasks
- **Cross-Device Workflow**: Start work on one device, continue on another seamlessly  
- **Window Management**: Arrange multiple windows to work on different aspects of your projects
- **Keyboard Shortcuts**: Learn the shortcuts to work at maximum efficiency

## Privacy and Security

Your data is stored in your private iCloud container and is never shared with third parties. All synchronization happens directly between your devices through Apple's secure iCloud infrastructure.

## Getting Help

- **Built-in Help**: Hover over interface elements for contextual help
- **Keyboard Shortcuts**: Check the menus to discover available shortcuts
- **Context Menus**: Right-click on items and interface elements to see available actions

---

**For Developers**: Technical documentation, architecture details, and contribution guidelines are available in [README_DEVS.md](README_DEVS.md).
