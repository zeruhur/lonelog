# Changelog

All notable changes to the Solo RPG Notation plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-12-30

### Added

#### Core Features
- **Template System**
  - Campaign template with YAML frontmatter and initial session/scene structure
  - Session template with metadata fields (date, duration, scenes)
  - Scene template with code block for notation
  - Variable substitution system for customization
  - Support for custom template paths in settings

- **Snippet Library**
  - 20+ quick-insert snippets for common notation patterns
  - Core snippets: Action, Oracle, Combined action+oracle
  - Tag snippets: NPC, Location, Thread, Player Character
  - Progress snippets: Clock, Track, Timer, Event
  - Structure snippets: Scene, Session, Dialogue, Narrative, Note
  - Random generation snippets: Table, Generator

- **Vault-Wide Indexing**
  - Automatic campaign detection via YAML frontmatter
  - Parse and index all campaigns on startup
  - Real-time file watchers for automatic reindexing
  - Support for create, modify, delete, and rename operations
  - In-memory caching for fast queries
  - Statistics tracking across all campaigns

- **Campaign Dashboard**
  - Overview of all campaigns in vault
  - Campaign cards with title, stats, and metadata
  - Click-to-open campaign files
  - Vault summary statistics (campaigns, NPCs, locations, threads, trackers)
  - Refresh button for manual updates
  - Helpful empty state with notation hints
  - Reference to example files

- **Tag Browser**
  - Tabbed interface for NPCs, Locations, and Threads
  - Live search and filter by name or tags
  - Element cards showing:
    - Name and tags
    - Mention count
    - Last seen (session and scene)
  - Click-to-navigate to first mention in file
  - Thread state color coding (Open: blue, Closed: green, Abandoned: gray)
  - Contextual empty states with notation examples

- **Progress Tracker**
  - Tabbed interface for Clocks, Tracks, and Timers
  - Visual progress indicators:
    - Circle progress (segmented)
    - Horizontal progress bars
    - Segment blocks
  - Configurable display style in settings
  - Status indicators:
    - Complete (✅)
    - Near complete (⚠️)
    - Percentage display
    - Timer urgency warnings (⏰ ⚠️)
  - Click-to-navigate to element location
  - Contextual empty states with notation examples

#### Commands
1. Insert Campaign Template
2. Insert Session Template
3. Insert Scene Template
4. Insert Action Snippet
5. Insert Oracle Snippet
6. Insert NPC Tag
7. Insert Location Tag
8. Insert Thread Tag
9. Insert Clock
10. Insert Track
11. Insert Timer
12. List All Snippets
13. Reindex Current Campaign
14. Reindex All Campaigns
15. Show Index Statistics
16. Open Campaign Dashboard
17. Open Tag Browser
18. Open Progress Tracker

#### Settings
- **General Settings**
  - Enable/disable auto-completion
  - Enable/disable automatic indexing
- **Template Settings**
  - Custom campaign template path
  - Custom session template path
  - Custom scene template path
- **Parsing Settings**
  - Parse on file save (toggle)
  - Parse on file open (toggle)
- **View Settings**
  - Dashboard auto-refresh interval
  - Default view on startup
- **Display Settings**
  - Show/hide progress bars
  - Clock display style (circle/bar/segments)
  - Theme preferences
- **Advanced Settings**
  - Debug mode for console logging
  - Custom snippet definitions

#### Parser & Type System
- Complete type definitions for all notation elements
- YAML frontmatter parser
- Session and scene extractor
- Code block parser for notation
- Tag extraction with regex patterns
- Progress element validation and merging
- Type guards for runtime type checking
- Location tracking for all elements

#### UI/UX Polish
- Improved empty states with helpful notation hints
- Better error messages with specific details
- Enhanced navigation feedback for missing files/lines
- Success notifications with checkmark (✓)
- Consistent styling across all views
- Professional empty state CSS
- Monospaced font for notation examples

#### Documentation & Examples
- Complete notation specification (v2.0)
- Comprehensive README with:
  - Feature list
  - Installation instructions
  - Usage guide
  - Command reference
  - Configuration documentation
- Example campaign files:
  - `quick-start.md` - Minimal beginner example
  - `clearview-mystery.md` - Complete teen mystery campaign
  - `star-hauler.md` - Sci-fi one-shot with different mechanics
  - `examples/README.md` - Guide to examples
- Session handoff documentation
- CHANGELOG (this file)

### Features in Detail

#### Notation Support
- Parse notation from code blocks only (per specification)
- Track persistent elements:
  - NPCs with tags and mention tracking
  - Locations with descriptive tags
  - Story threads with states (Open/Closed/Abandoned)
  - Player characters with stats
- Progress tracking:
  - Clocks (danger accumulating, X/Y format)
  - Tracks (progress toward goals, X/Y format)
  - Timers (countdown, single value)
  - Events (X/Y format, similar to clocks)
- Core symbols:
  - `>` Player action
  - `?` Oracle question
  - `d:` Mechanics roll
  - `->` Oracle result
  - `=>` Consequence
- Tag patterns:
  - `[N:Name|tags]` - NPCs
  - `[L:Name|tags]` - Locations
  - `[Thread:Name|state]` - Story threads
  - `[Clock:Name X/Y]` - Clocks
  - `[Track:Name X/Y]` - Tracks
  - `[Timer:Name X]` - Timers
  - `[E:Name X/Y]` - Events
  - `[PC:Name|stats]` - Player character
  - `[#N:Name]` - References

#### Search & Navigation
- Full-text search across all elements
- Filter by name or tags in Tag Browser
- Click any element to navigate to its first mention
- Automatic scrolling to line number
- Error handling for missing files or invalid locations

#### Visual Feedback
- Progress visualization with multiple styles
- Color-coded thread states
- Status badges for completion/urgency
- Responsive grid layouts
- Smooth transitions and hover effects

### Technical Details
- Built with TypeScript in strict mode
- ES2022 target for modern JavaScript features
- ESBuild for fast compilation
- ESLint for code quality
- Obsidian API 1.4.0+
- Not desktop-only (mobile-compatible)

### Project Structure
```
solorpgnotation/
├── examples/           # Example campaign files
├── src/
│   ├── main.ts        # Plugin entry point
│   ├── settings.ts    # Settings management
│   ├── types/         # TypeScript type definitions
│   ├── parser/        # Notation parsing system
│   ├── indexer/       # Game element indexing
│   ├── templates/     # Template management
│   ├── views/         # UI views (Dashboard, Browser, Tracker)
│   └── commands/      # Plugin commands
├── styles.css         # Plugin stylesheet
├── manifest.json      # Plugin metadata
├── package.json       # Dependencies
├── tsconfig.json      # TypeScript config
└── esbuild.config.mjs # Build configuration
```

### Known Limitations
- Notation must be in code blocks (fenced with ```)
- Requires YAML frontmatter for campaign detection
- No real-time dice rolling or oracle automation
- No inline notation outside code blocks

### Credits
- Implements the Solo TTRPG Notation v2.0 by Roberto Bisceglie
- Inspired by the [Valley Standard](https://alfredvalley.itch.io/the-valley-standard)

---

## [Unreleased]

### Planned Features
- Loading indicators for long operations
- Keyboard shortcuts for common commands
- More comprehensive error handling
- Additional view customization options
- Export functionality

---

**For full documentation, see README.md**
**For notation specification, see solo_notation.md**
