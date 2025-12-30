# Solo RPG Notation - Obsidian Plugin

An Obsidian plugin that implements the Solo TTRPG Notation system for recording and tracking solo role-playing game sessions.

## Features

- **Templates**: Ready-to-use templates for campaigns, sessions, and scenes
- **Auto-completion**: Snippets for common notation patterns (actions, oracle questions, tags, etc.)
- **Parsing & Indexing**: Automatically parse and index game elements (NPCs, Locations, Threads, Clocks, Tracks, Timers)
- **Campaign Dashboard**: Overview of all campaigns with statistics
- **Tag Browser**: Browse and search NPCs, Locations, and Story Threads
- **Progress Tracker**: Visual representation of Clocks, Tracks, and Timers

## Installation

### From GitHub Releases (Recommended)

1. Download the latest release from the [Releases](https://github.com/roberto-b/solorpgnotation/releases) page
2. Extract the files to your Obsidian vault's plugins folder: `<vault>/.obsidian/plugins/solo-rpg-notation/`
3. Reload Obsidian
4. Enable the plugin in Settings → Community Plugins

### Manual Installation (Development)

1. Clone this repository into your vault's plugins folder:
   ```bash
   cd <vault>/.obsidian/plugins
   git clone https://github.com/roberto-b/solorpgnotation solo-rpg-notation
   cd solo-rpg-notation
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Build the plugin:
   ```bash
   npm run build
   ```

4. Reload Obsidian and enable the plugin in Settings → Community Plugins

### Development Mode

To develop the plugin with live reloading:

```bash
npm run dev
```

This will watch for file changes and automatically rebuild the plugin.

## Usage

### Quick Start

1. Open the Solo RPG Notation settings (Settings → Solo RPG Notation)
2. Configure your preferences
3. Use commands (Ctrl/Cmd + P) to insert templates:
   - "Insert Campaign Template"
   - "Insert Session Template"
   - "Insert Scene Template"
4. Open views from the command palette:
   - "Open Campaign Dashboard"
   - "Open Tag Browser"
   - "Open Progress Tracker"

### Notation Format

The plugin uses the Solo TTRPG Notation system (v2.0). All notation must be in code blocks:

````markdown
## Session 1
*Date: 2025-12-30 | Duration: 2h*

### S1 *Dark alley, midnight*

```
> Sneak past the guards
d: Stealth d6=4 vs TN 5 => Fail
=> My foot kicks a barrel. [E:AlertClock 1/6]

? Do they see me?
-> No, but... (d6=3)
=> They're suspicious. [N:Guard|watchful]
```

The guard's torch sweeps across the alley.
````

### Core Notation Symbols

- `>` - Player action
- `?` - Oracle question
- `d:` - Mechanics roll
- `->` - Oracle result
- `=>` - Consequence

### Tags

- `[N:Name|tags]` - NPCs
- `[L:Name|tags]` - Locations
- `[Thread:Name|state]` - Story threads
- `[Clock:Name X/Y]` - Clocks (danger accumulating)
- `[Track:Name X/Y]` - Progress tracks
- `[Timer:Name X]` - Countdown timers

## Configuration

Configure the plugin in Settings → Solo RPG Notation:

- **General**: Enable/disable auto-completion and indexing
- **Templates**: Use default templates or specify custom paths
- **Parsing**: Control when files are parsed
- **Views**: Dashboard and refresh settings
- **Display**: Progress bar styles and theme
- **Advanced**: Debug mode and custom snippets

## Development

### Project Structure

```
src/
├── main.ts                  # Plugin entry point
├── settings.ts              # Settings management
├── types/                   # TypeScript type definitions
├── parser/                  # Notation parsing system
├── indexer/                 # Game element indexing
├── templates/               # Template management
├── views/                   # UI views (dashboard, browser, tracker)
└── commands/                # Plugin commands
```

### Building

```bash
npm run build    # Production build
npm run dev      # Development build with watch mode
npm run lint     # Run ESLint
npm run lint:fix # Auto-fix linting issues
```

### Testing

Test the plugin in your vault by:

1. Creating example campaign files using the notation
2. Using the templates and snippets
3. Opening the views to verify parsing and indexing
4. Checking the console for errors (if debug mode is enabled)

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE) for details

## Credits

This plugin implements the [Solo TTRPG Notation](https://github.com/roberto-b/solorpgnotation) system (v2.0) by Roberto Bisceglie.

The notation system is inspired by the [Valley Standard](https://alfredvalley.itch.io/the-valley-standard).

## Support

- **Issues**: [GitHub Issues](https://github.com/roberto-b/solorpgnotation/issues)
- **Documentation**: See `solo_notation.md` for the complete notation specification

## Roadmap

- [ ] Phase 1: Project infrastructure ✓
- [ ] Phase 2: Type definitions
- [ ] Phase 3: Template system
- [ ] Phase 4: Parser system
- [ ] Phase 5: Indexer system
- [ ] Phase 6: Dashboard view
- [ ] Phase 7: Tag browser view
- [ ] Phase 8: Progress tracker view
- [ ] Phase 9: Polish & documentation

---

Happy solo gaming! 🎲
