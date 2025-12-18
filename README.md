# Snipster

A powerful macOS menu bar application for managing and expanding text snippets with keyboard triggers, dynamic variables, and intelligent organization.

## Features

### Text Expansion
- **Instant text expansion** using clipboard-based insertion for maximum speed
- **Customizable triggers** with prefix + keyword system (e.g., `!email`, `!addr`)
- **Automatic permission monitoring** - detects accessibility changes in real-time
- **Refresh button** to restart monitoring if needed
- Direct link to System Settings for easy permission setup

### Dynamic Variables
Snippets support powerful variable substitution:
- **Date variables**: `{{DATE}}`, `{{DATE:LONG}}`, `{{DATE:MEDIUM}}`, `{{DATE:FULL}}`, `{{DATE:CUSTOM:yyyy-MM-dd}}`
- **Time variables**: `{{TIME}}`, `{{TIME:LONG}}`, `{{TIME:MEDIUM}}`, `{{TIME:24}}`
- **Clipboard**: `{{CLIPBOARD}}` - inserts current clipboard content
- **System info**: `{{USERNAME}}`, `{{USER}}`, `{{HOSTNAME}}`
- **Cursor positioning**: `{{CURSOR}}` - places cursor at specific position after expansion

### Snippet Management
- **Create, edit, and duplicate** text snippets
- **Favorites/starred snippets** - mark important snippets for quick access
- **Usage statistics** - track how often each snippet is used
- **Multi-level filtering** - search by text, filter by tag, and show favorites
- **Sort options** - by title, tag, color, date created, or date modified
- **Adjustable preview** - 0, 1, or 2 lines of content
- **Context menu actions** - Edit, Favorite, Duplicate, Copy, Delete
- **Quick access** from menu bar

### Backup & Restore
- **Export snippets** to JSON with formatted output
- **Import snippets** with intelligent conflict resolution:
  - **Merge mode** - keeps newer version based on modification date
  - **Replace mode** - always uses imported version
  - **Skip mode** - keeps existing version
- Import summary shows added, updated, and skipped counts
- Backward compatible with older snippet formats

### Tag Organization
- **Color-coded tag system** for visual categorization
- **Full color palette** support via ColorPicker
- **Tag filtering** with visual tag buttons
- **Inline tag management** in settings
- **Snippet count badges** on each tag
- **Tag truncation** for compact display (6 chars + "..")

### Storage Options
- **Local storage** - `~/Library/Application Support/Snipster/`
- **iCloud Drive** - `~/Library/Mobile Documents/iCloud~Snipster/`
- **Dropbox integration** - `~/Dropbox/Apps/Snipster/`
- **Easy location switching** from Settings

## System Requirements

- macOS 14.0 or later
- Accessibility permission for text expansion

## Installation

1. Clone this repository
2. Open `Snipster.xcodeproj` in Xcode
3. Build and run the project
4. Grant Accessibility permission when prompted

## Usage

### Creating a Snippet
1. Click the Snipster menu bar icon
2. Click the "+" (New Snippet) button
3. Enter:
   - **Title** - name for your snippet
   - **Content** - the text to expand (supports variables)
   - **Trigger** - prefix + keyword (e.g., `!email`)
   - **Tags** - organize with color-coded tags
   - **Favorite** - click star to mark as favorite
4. Click "Save"

### Using Variables in Snippets
Add dynamic content to your snippets:
```
Hello {{USERNAME}},

Today's date is {{DATE:LONG}}.
Current time: {{TIME}}.

Your clipboard content: {{CLIPBOARD}}

Best regards,{{CURSOR}}
```

When expanded, this becomes:
```
Hello John Doe,

Today's date is December 18, 2025.
Current time: 12:30 PM.

Your clipboard content: [whatever was in clipboard]

Best regards,[cursor positioned here]
```

### Text Expansion
1. Open Settings → Text Expansion
2. Click "Enable" if accessibility permission not granted
3. Type your trigger anywhere (e.g., `!email`)
4. Content instantly replaces the trigger
5. If {{CURSOR}} was used, cursor is positioned automatically

### Managing Favorites
- **Star icon** in snippet row - toggle favorite
- **Right-click menu** → "Add to Favorites" / "Remove from Favorites"
- **Edit view** - click star in header to mark as favorite
- **Filter button** - click star in toolbar to show only favorites

### Duplicating Snippets
- **Right-click** any snippet → "Duplicate"
- Creates a copy with " Copy" suffix
- Trigger is cleared (set new trigger to avoid conflicts)
- Edit the duplicate to customize

### Export & Import
**Export:**
1. Settings → Backup & Restore
2. Click "Export" button
3. Choose save location
4. All snippets saved to JSON file

**Import:**
1. Settings → Backup & Restore
2. Click "Import" button
3. Select JSON file
4. Automatic merge (keeps newer versions)
5. See summary of added/updated/skipped

### Managing Tags
1. Settings → Tags section
2. Click "+ Add Tag" to create
3. Click pencil icon to edit
4. Click trash icon to delete
5. Tags show snippet count
6. Tag filter buttons in main view

### Keyboard Shortcuts
- `Cmd+Return` - Save snippet
- `Esc` - Cancel editing
- Double-click snippet - Copy content to clipboard

## Architecture

### Core Components
- **SnippetStore**: Manages snippet data and persistence
- **TagStore**: Handles tag library and relationships
- **TextExpansionMonitor**: Monitors keyboard input for trigger detection
- **FileStorageManager**: Handles file-based storage with location options

### Views
- **MenuBarPopoverView**: Main interface with snippet list
- **SnippetDetailView**: Create/edit snippet interface
- **SettingsView**: Unified settings panel
- **TagSelectorView**: Visual tag selection component

## Storage Format

Snippets are stored in JSON format at the configured location:
- Local: `~/Library/Application Support/Snipster/`
- iCloud: `~/Library/Mobile Documents/iCloud~Snipster/`
- Dropbox: `~/Dropbox/Apps/Snipster/`

## License

Copyright 2025. All rights reserved.

## Contributing

This is a personal project. Feel free to fork and modify for your own use.
