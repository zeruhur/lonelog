# Solo RPG Notation

An Obsidian plugin for recording and tracking solo tabletop RPG sessions using a standardized notation system.

## What is Solo RPG Notation?

Solo RPG Notation is a lightweight text-based system for documenting your solo TTRPG sessions. It lets you:

- Record actions, oracle questions, and dice rolls in a consistent format
- Tag NPCs, locations, and story threads as they appear
- Track progress with clocks, tracks, and timers
- Review your campaign history with powerful browsing tools

All notation lives in code blocks within your markdown files, keeping your narrative text clean and readable.

## Features

### 📊 Six Interactive Views

Access all views from the **left sidebar ribbon icons** or the **command palette**:

- **Campaign Dashboard** (🎲) - Overview of all campaigns with statistics
- **Tag Browser** (🏷️) - Browse NPCs, Locations, Threads, and References
- **Progress Tracker** (🕐) - Visual clocks, tracks, and timers
- **All Elements Reference** (🗄️) - Complete searchable reference
- **Random Events** (🎲🎲) - All table lookups and generator results
- **Meta Notes** (📝) - Out-of-character notes organized by category

### ⌨️ Quick Commands

- **Insert Campaign Template** - Start a new campaign file
- **Insert Session Template** - Add a new session
- **Insert Scene Template** - Add a new scene
- **Reindex Current Campaign** - Refresh the current file's data
- **Reindex All Campaigns** - Refresh all campaign data

### 🔍 Automatic Indexing

The plugin automatically tracks:
- NPCs and their mentions
- Locations visited
- Story threads (open/closed/abandoned)
- Progress trackers (clocks, tracks, timers, events)
- Table lookups and generator results
- Meta notes and reflections

## Getting Started

### 1. Create Your First Campaign

Use the command palette (Ctrl/Cmd + P) and select **"Insert Campaign Template"**. This creates:

```markdown
---
type: solo_campaign
ruleset: Your System
genre: Fantasy
created: 2025-12-31
last_update: 2025-12-31
---

# Campaign Title

Campaign description...

## Session 1
*Date: 2025-12-31 | Duration: 2h*

### S1 *Opening scene*

```
Your adventure begins...
```
```

### 2. Write Your First Scene

All notation goes inside code blocks (triple backticks). Outside the code blocks, write your narrative:

````markdown
### S1 *Dark alley, midnight*

```
> Sneak past the guards
d: Stealth d6=4 vs TN 5 => Fail
=> My foot kicks a barrel. [E:AlertClock 1/6]

? Do they see me?
-> No, but... (d6=3)
=> They're suspicious. [N:Guard|watchful]
```

The guard's torch sweeps across the alley. I press myself against the wall.

```
> Wait for them to pass
tbl: d100=42 => "A distant scream distracts them"
=> Perfect timing. [Thread:Investigation|Open]
```
````

### 3. Open the Views

Click the dice icon (🎲) in the left sidebar to open the Campaign Dashboard, or use the command palette to open any view.

## Notation Reference

### Core Symbols

| Symbol | Meaning | Example |
|--------|---------|---------|
| `>` | Player action | `> Attack the orc` |
| `?` | Oracle question | `? Is the door locked?` |
| `d:` | Mechanics/dice roll | `d: Attack d20=15 vs AC 14 => Hit` |
| `->` | Oracle result | `-> Yes, and... (d6=6)` |
| `=>` | Consequence/outcome | `=> The door splinters open` |

### Tags & Trackers

#### NPCs & Locations
```
[N:Name]              - First mention of an NPC
[N:Name|tags]         - NPC with descriptive tags
[#N:Name]             - Reference existing NPC
[#N:Name|tag]         - Reference with additional context

[L:Place]             - First mention of a location
[L:Place|tags]        - Location with tags
[#L:Place]            - Reference existing location
[#L:Place|tag]        - Reference with context
```

#### Story Threads
```
[Thread:Name|Open]        - New/active thread
[Thread:Name|Closed]      - Resolved thread
[Thread:Name|Abandoned]   - Dropped thread
```

#### Progress Trackers
```
[Clock:Name X/Y]      - Danger/pressure (fills up = bad)
[Track:Name X/Y]      - Progress (fills up = goal reached)
[Timer:Name X]        - Countdown (reaches 0 = trigger)
[E:Name X/Y]          - Event countdown
```

#### Player Characters
```
[PC:Name]                     - Simple PC mention
[PC:Name|HP:12|Armor:3]      - PC with current stats
```

### Random Generation

#### Table Lookups
```
tbl: d100=42 => "A merchant arrives"
tbl: Weather=Rain => "Heavy downpour begins"
```

#### Generators
```
gen: Mythic => "Gratify Fears"
gen: MUNE => "And also... (Positive)"
```

### Meta Notes

Meta notes are out-of-character observations that don't appear in References:

```
(note: Remember the shopkeeper's hint)
(reflection: This scene dragged, need more action)
(house rule: Using advantage on group checks)
(reminder: Follow up on the missing sword)
(question: Did I mark XP for this session?)
```

## Views Guide

### Campaign Dashboard

Shows all campaigns with:
- Session and scene counts
- NPC, location, and thread statistics
- Active vs closed threads
- Progress tracker counts
- Click any campaign to open its file

### Tag Browser

Four tabs for browsing game elements:

**NPCs Tab**
- All characters encountered
- Tags and descriptive labels
- Mention count and last appearance
- Click to jump to first mention

**Locations Tab**
- All places visited
- Geographic tags
- Visit history
- Click to navigate to location

**Threads Tab**
- Story threads by status (Open/Closed/Abandoned)
- Color-coded badges
- Timeline of mentions
- Click to jump to thread origin

**References Tab**
- All uses of `[#N:Name]` and `[#L:Name]`
- Shows reference type (NPC/Location)
- Mention count and context
- Click to jump to reference

### Progress Tracker

Visual representation of all progress elements:

**Clocks** - Fill as danger increases (e.g., Alert Clock, Enemy Reinforcements)
**Tracks** - Fill as progress is made (e.g., Quest Progress, Relationship Building)
**Timers** - Count down to zero (e.g., Time Until Dawn, Potion Duration)
**Events** - Special countdown trackers

Filter by type, search by name, and click any tracker to jump to its latest mention.

### All Elements Reference

Complete searchable database of everything in your campaigns:
- All NPCs, locations, threads, and trackers in one view
- Type filters (NPC, Location, Thread, Clock, Track, Timer)
- Full-text search
- Sort and browse by campaign

### Random Events

Chronological view of all randomization:
- Table lookups (`tbl:`)
- Generator results (`gen:`)
- Filter by type (Tables/Generators)
- Search by content
- Review your oracle consultation history

### Meta Notes

Your out-of-character notes organized by category:
- **Notes** - General observations
- **Reflections** - Session reviews
- **House Rules** - Custom mechanics
- **Reminders** - Things to follow up
- **Questions** - Unresolved queries

Filter by category and search across all notes.

## Configuration

Open **Settings → Solo RPG Notation** to configure:

### General
- Enable/disable automatic indexing
- Control when files are parsed

### Templates
- Use default templates or specify custom template files
- Customize campaign, session, and scene templates

### Display
- Choose progress bar style (bars, circles, or segments)
- Set theme (auto, light, or dark)

### Advanced
- Enable debug mode for troubleshooting
- View index statistics
- Force reindex all campaigns

## Tips & Best practices

### Organization

**One campaign per file** - Each campaign file should contain all sessions for that campaign.

**Consistent session numbering** - Use `## Session 1`, `## Session 2`, etc. (the plugin looks for this format).

**Scene IDs** - Use `### S1`, `### S2`, etc. for simple scenes, or `### S1a`, `### T2-S3` for more complex tracking.

### Notation

**Code blocks are required** - All notation MUST be inside triple backtick code blocks. Narrative text goes outside.

**First mention vs references** - Use `[N:Name]` when first introducing an NPC, then `[#N:Name]` for later mentions.

**Tags are optional** - `[N:Bob]` and `[N:Bob|merchant|friendly]` both work. Tags help you remember context.

**Update trackers** - When a clock advances, write a new line: `[Clock:Alert 2/6]`. The plugin tracks the latest value.

### Workflow

1. **Start each session** with the session template (date and duration)
2. **Write notation in code blocks** as you play
3. **Add narrative** outside code blocks after the scene
4. **Review the dashboard** to see campaign statistics
5. **Use the Tag Browser** to remember NPCs and locations
6. **Check Progress Tracker** to see active clocks and tracks

## Troubleshooting

### Elements not appearing in views?

- Make sure notation is inside code blocks (```)
- Check that session headers use `## Session N` format
- Use **Reindex Current Campaign** command to refresh
- Enable debug mode in settings to see parsing errors

### Views not updating?

- The plugin parses files on load and when modified
- Use the refresh button (↻) in any view
- Try **Reindex All Campaigns** from command palette

### Performance issues with large vaults?

- Disable automatic indexing in settings
- Manually index campaigns when needed
- Use the file explorer to isolate campaign files

## Support

- **Issues & Bugs**: [GitHub Issues](https://github.com/roberto-b/solorpgnotation/issues)
- **Notation Spec**: See `solo_notation.md` for complete specification
- **Examples**: Check the `examples/` folder for sample campaigns

## Credits

This plugin implements the [Solo TTRPG Notation](https://github.com/roberto-b/solorpgnotation) system (v2.0).

The notation system is inspired by the [Sigil Standard](https://alfredvalley.itch.io/the-sigil-standard).

## License

MIT License - Free to use and modify.

---

**Happy solo gaming!** 🎲

*For developer documentation, see CONTRIBUTING.md in the GitHub repository.*
