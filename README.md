# Lonelog

**A Standard Notation for Solo RPG Session Logging**

[![License: CC BY-SA 4.0](https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-sa/4.0/)

Lonelog is a lightweight notation system for recording solo tabletop RPG sessions. It provides a standardized way to capture game mechanics, oracle questions, and narrative outcomes—keeping your session logs readable, searchable, and shareable.

## What is Lonelog?

If you've played solo RPGs, you know the challenge: you're deep in an exciting scene, dice are rolling, oracles are answering questions, and you need to capture it all without breaking the flow.

Lonelog offers a **modular shorthand** that:

- Separates mechanics from narrative
- Works across any RPG system (Ironsworn, Mythic GME, Thousand Year Old Vampire, etc.)
- Scales from quick one-shots to long campaigns
- Functions in both digital markdown files and paper notebooks

### Core Notation (5 symbols)

```
@ Player action
? Oracle question
d: Dice/mechanics roll
-> Result/answer
=> Consequence/outcome
```

### Quick Example

```
S1 *Dark alley, midnight*
@ Sneak past the guard
d: Stealth 4 vs TN 5 -> Fail
=> The guard spots me and shouts an alarm

? Does backup arrive? (Likely)
-> Yes, and they have dogs
=> I need to run—fast
```

That's the entire core system. Everything else (scenes, threads, progress clocks, etc.) is optional.

## Available Documentation

The documentation is available in multiple formats and languages:

### English

- [PDF](lonelog.pdf) - Print-ready version
- [EPUB](lonelog.epub) - E-reader format
- [ODT](lonelog.odt) - LibreOffice/Word format

### Italian (Italiano)

- [PDF](lonelog-it.pdf) - Versione per la stampa
- [EPUB](lonelog-it.epub) - Formato e-reader
- [ODT](lonelog-it.odt) - Formato LibreOffice/Word

### French (Français)

- [PDF](lonelog-fr.pdf) - Version imprimable
- [EPUB](lonelog-fr.epub) - Format e-reader
- [ODT](lonelog-fr.odt) - Format LibreOffice/Word

### Optional Modules

Extended notation for specific gameplay needs:

- [Combat Module](lonelog-combat-module.md) - Tactical encounter notation
- [Dungeon Crawling Module](lonelog-dungeon-crawling-module.md) - Exploration notation
- [Resource Tracking Module](lonelog-resource-tracking-module.md) - Inventory and supplies

## Features

- **System-agnostic** - Works with any solo RPG system
- **Modular** - Use only what you need
- **Markdown-compatible** - Digital tools and plain text notebooks
- **Searchable** - Tags and symbols make finding past events easy
- **Shareable** - Standard notation means others can read your session logs
- **Multi-language** - Documentation available in English, Italian, and French

## Building the Documentation

This repository uses [Quarto](https://quarto.org/) to generate documentation from Markdown source files.

### Prerequisites

Install Quarto:

- **Windows**: `choco install quarto` (via Chocolatey)
- **macOS**: `brew install quarto`
- **Linux**: Download from [quarto.org](https://quarto.org/docs/get-started/)

### Build Commands

Render all documents:

```bash
quarto render
```

Render a specific language:

```bash
quarto render lonelog.md      # English
quarto render lonelog-it.md   # Italian
quarto render lonelog-fr.md   # French
```

Render to a specific format:

```bash
quarto render lonelog.md --to pdf
quarto render lonelog.md --to epub
quarto render lonelog.md --to typst
```

Preview with live reload:

```bash
quarto preview lonelog.md
```

## Project Structure

```
/
├── lonelog.md                              # Main English documentation
├── lonelog-it.md                           # Italian translation
├── lonelog-fr.md                           # French translation
├── lonelog-combat-module.md                # Optional combat notation
├── lonelog-dungeon-crawling-module.md      # Optional dungeon notation
├── lonelog-resource-tracking-module.md     # Optional resource notation
├── _quarto.yml                             # Quarto configuration
├── _extensions/                            # Custom templates and filters
│   ├── typst-template.typ                  # Custom Typst styling
│   ├── typst-show.typ                      # Template partial
│   └── pagebreak.lua                       # Pagebreak filter
├── logo.png                                # Cover logo
├── by-sa.png                               # CC BY-SA license badge
└── legacy/                                 # Previous versions
```

## Contributing

Contributions are welcome! Here's how you can help:

### Translations

Help translate Lonelog into additional languages. Use `lonelog.md` as the source and maintain the same frontmatter structure.

### Improvements

Found a typo or unclear explanation? Open an issue or submit a pull request.

### Module Extensions

Created an optional module for a specific type of play? Share it with the community!

### Examples

Real session logs using Lonelog are valuable for demonstrating the notation. Consider sharing anonymized examples.

## Version History

- **v1.0.0** (Current) - Renamed from "Solo TTRPG Notation" to "Lonelog" with refined notation and expanded documentation

## License

This work is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-sa/4.0/).

You are free to:

- **Share** - Copy and redistribute the material
- **Adapt** - Remix, transform, and build upon the material

Under the following terms:

- **Attribution** - Give appropriate credit
- **ShareAlike** - Distribute under the same license

## Author

**Roberto Bisceglie**

## Community

- Share your session logs with the `#lonelog` hashtag
- Ask questions or suggest improvements via GitHub Issues
- Join discussions about solo RPG notation and best practices

## Acknowledgments

Thanks to the solo RPG community for feedback, suggestions, and real-world usage that shaped this notation system from its origins as "Solo TTRPG Notation" to Lonelog v1.0.0.

---

*Made with [Quarto](https://quarto.org/) • Styled with [Typst](https://typst.app/)*
