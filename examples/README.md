# Solo RPG Notation - Example Campaigns

This directory contains complete example campaigns demonstrating the Solo RPG Notation system in action. Use these as templates, learning resources, or inspiration for your own campaigns!

## 📚 Example Files

### 🎯 quick-start.md
**Perfect for:** Absolute beginners
**Length:** 2 scenes (5 minutes)
**System:** Any

A minimal example showing just the core notation:
- Actions (`>`)
- Dice rolls (`d:`)
- Oracle questions (`?`)
- Oracle answers (`->`)
- Consequences (`=>`)
- Basic tags

**Start here if you're new to Solo RPG Notation!**

---

### 🔍 clearview-mystery.md
**Perfect for:** Learning all features
**Length:** 2 sessions, 7 scenes (comprehensive)
**System:** Loner + Mythic GME

A complete teen mystery campaign featuring:
- ✅ YAML frontmatter with full metadata
- ✅ Multiple sessions with proper headers
- ✅ Scene structure (S1-S7)
- ✅ All core symbols and notation
- ✅ NPCs with evolving states
- ✅ Location tags
- ✅ Story threads (Open/Closed)
- ✅ Clocks progressing to completion
- ✅ Tracks showing gradual progress
- ✅ PC stats and stress tracking
- ✅ Dialogue integration
- ✅ Meta notes
- ✅ Random table rolls
- ✅ Complete story arc with resolution

**Use this to see how everything works together in a real campaign!**

---

### 🚀 star-hauler.md
**Perfect for:** Different system mechanics
**Length:** 1 session, 8 scenes (one-shot)
**System:** Ironsworn Starforged

A sci-fi horror one-shot demonstrating:
- ✅ Different dice mechanics (Ironsworn system)
- ✅ Timers counting down (Oxygen Supply)
- ✅ Events and danger clocks
- ✅ Flashback scenes (S5a, S5b)
- ✅ Parallel timeline narrative
- ✅ Tracks for mission progress
- ✅ Different PC stats (Health, Supply, Spirit)
- ✅ Vows and moral choices
- ✅ Tension and horror genre
- ✅ Open-ended conclusion

**Use this to see how the notation adapts to different systems and genres!**

---

## 🎮 How to Use These Examples

### In Obsidian (Recommended)

1. **Install the Solo RPG Notation plugin** (if you haven't already)
2. **Copy example files to your vault:**
   - Copy any example file to a folder in your vault
   - Or keep them in the plugin's `examples/` folder
3. **Open the file in Obsidian**
4. **Try the plugin features:**
   - Open **Campaign Dashboard** to see the campaign indexed
   - Open **Tag Browser** to browse NPCs, locations, and threads
   - Open **Progress Tracker** to see clocks, tracks, and timers visualized
   - Click on elements to navigate to their locations in the file

### As Templates

1. **Start with quick-start.md** to understand the basics
2. **Copy the structure** of clearview-mystery.md for campaign setup
3. **Adapt the YAML frontmatter** to your campaign
4. **Use the scene structure** as a template
5. **Refer to examples** when you forget syntax

### As Learning Resources

Each example includes:
- **Comments** explaining design decisions
- **Variety** showing different notation patterns
- **Progression** from simple to complex
- **Complete arcs** showing how stories develop

---

## 📖 Notation Quick Reference

### Core Symbols
```
> Action              - Player-facing action
? Question           - Oracle question
d: Roll => Outcome   - Mechanics resolution
-> Answer            - Oracle answer
=> Consequence       - What happens next
```

### Tags
```
[N:Name|tags]           - NPCs
[L:Name|tags]           - Locations
[Thread:Name|state]     - Story threads
[Clock:Name X/Y]        - Danger accumulating
[Track:Name X/Y]        - Progress toward goal
[Timer:Name X]          - Countdown
[E:Name X/Y]            - Events
[PC:Name|stats]         - Player character
[#N:Name]               - Reference to earlier tag
```

### Structure
```
---
YAML frontmatter
---

# Campaign Title

## Session N
*Date: YYYY-MM-DD | Duration: XhYm*

### S# *Scene context*

Code block with notation...
```

Narrative prose between code blocks...

````

---

## 🎯 What to Try Next

After reviewing the examples:

1. **Create your own campaign:**
   - Use "Insert Campaign Template" command
   - Fill in your own metadata
   - Start playing!

2. **Experiment with notation:**
   - Try different oracle systems
   - Mix notation with narrative
   - Track your own custom elements

3. **Explore the plugin features:**
   - Search for NPCs across campaigns
   - Track progress on multiple threads
   - Navigate between related elements

4. **Read the full notation spec:**
   - See `solo_notation.md` for complete documentation
   - Learn advanced features like flashbacks, parallel threads, montages

---

## 💡 Tips for Your Own Campaigns

### Getting Started
- Start simple—use just core symbols at first
- Add tags and progress tracking as needed
- Don't feel obligated to use every feature

### Keeping Notation Clean
- All notation goes in code blocks (```)
- Narrative and dialogue stay outside code blocks
- Be consistent with your tag format

### Finding Your Style
- **Minimal:** Mostly shorthand, little narrative (like quick-start)
- **Hybrid:** Mix of notation and narrative (like clearview-mystery)
- **Rich:** Detailed narrative with notation for mechanics (like star-hauler)

### Organizing Long Campaigns
- One file per campaign (recommended)
- Or one file per session (if you prefer)
- Use session headers to mark boundaries
- Reference earlier threads with `[#Thread:Name]`

---

## 🔗 Resources

- **Notation Specification:** `/solo_notation.md`
- **Plugin Documentation:** `/README.md`
- **Issue Reports:** [GitHub Issues](https://github.com/roberto-b/solorpgnotation/issues)
- **Community:** Share your campaigns and get help!

---

**Ready to play?** Open one of the examples and start exploring. Or jump right in with "Insert Campaign Template" and create your own adventure!

Happy solo gaming! 🎲
