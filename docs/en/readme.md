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

- [PDF](downloads/en/lonelog.pdf) - Print-ready version
- [EPUB](downloads/en/lonelog.epub) - E-reader format
- [ODT](downloads/en/lonelog.odt) - LibreOffice/Word format

### Italian (Italiano)

- [PDF](downloads/it/lonelog-it.pdf) - Versione per la stampa
- [EPUB](downloads/it/lonelog-it.epub) - Formato e-reader
- [ODT](downloads/it/lonelog-it.odt) - Formato LibreOffice/Word

### French (Français)

- [PDF](downloads/fr/lonelog-fr.pdf) - Version imprimable
- [EPUB](downloads/fr/lonelog-fr.epub) - Format e-reader
- [ODT](downloads/fr/lonelog-fr.odt) - Format LibreOffice/Word

### Optional Add-ons

Extended notation for specific gameplay needs:

- [Combat Add-on](docs/en/lonelog-combat-addon.md) - Tactical encounter notation
- [Dungeon Crawling Add-on](docs/en/lonelog-dungeon-crawling-addon.md) - Exploration notation
- [Resource Tracking Add-on](docs/en/lonelog-resource-tracking-addon.md) - Inventory and supplies
- [Add-on Guidelines](docs/en/lonelog-addon-guidelines.md) - How to write your own add-on
- [Add-on Template](docs/en/lonelog-addon-template.md) - Starter template

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

Render all languages:

```bash
for lang in en it fr; do
  quarto render docs/$lang/lonelog*.md --output-dir output/$lang/
done
```

Render a specific language:

```bash
quarto render docs/en/lonelog.md --output-dir output/en/      # English
quarto render docs/it/lonelog-it.md --output-dir output/it/   # Italian
quarto render docs/fr/lonelog-fr.md --output-dir output/fr/   # French
```

Render to a specific format:

```bash
quarto render docs/en/lonelog.md --to pdf --output-dir output/en/
quarto render docs/en/lonelog.md --to epub --output-dir output/en/
```

Preview with live reload:

```bash
quarto preview docs/en/lonelog.md
```

## Project Structure

```
/
├── index.html                              # Docsify entry point
├── _quarto.yml                             # Quarto configuration
├── docs/                                   # Markdown source files
│   ├── README.md                           # Site home (language selector)
│   ├── en/                                 # English documentation
│   │   ├── lonelog.md                      # Main specification
│   │   ├── lonelog-addon-guidelines.md     # Add-on guidelines
│   │   ├── lonelog-addon-template.md       # Add-on template
│   │   ├── lonelog-combat-addon.md         # Combat add-on
│   │   ├── lonelog-dungeon-crawling-addon.md # Dungeon crawling add-on
│   │   ├── lonelog-resource-tracking-addon.md # Resource tracking add-on
│   │   └── _sidebar.md                     # Docsify sidebar (EN)
│   ├── it/                                 # Italian translation
│   │   ├── lonelog-it.md
│   │   └── _sidebar.md
│   └── fr/                                 # French translation
│       ├── lonelog-fr.md
│       └── _sidebar.md
├── output/                                 # Rendered documents (Quarto)
│   ├── en/                                 # English renders
│   ├── it/                                 # Italian renders
│   └── fr/                                 # French renders
├── _extensions/                            # Custom templates and filters
│   ├── typst-template.typ                  # Custom Typst styling
│   ├── typst-show.typ                      # Template partial
│   └── pagebreak.lua                       # Pagebreak filter
├── assets/                                 # Shared assets (images, fonts)
├── legacy/                                 # Previous versions
└── .readthedocs.yaml                       # Read the Docs build config
```

## Contributing

Contributions are welcome! Here's how you can help:

### Translations

Help translate Lonelog into additional languages. Use `docs/en/lonelog.md` as the source and maintain the same frontmatter structure.

### Improvements

Found a typo or unclear explanation? Open an issue or submit a pull request.

### Module Extensions

Created an optional add-on for a specific type of play? Share it with the community!

### Examples

Real session logs using Lonelog are valuable for demonstrating the notation. Consider sharing anonymized examples.

## Version History

- **v1.5.0** (Current) - `d:` is now the preferred notation for oracle dice rolls; clarified when to use `d:`, `tbl:`, and `gen:` for oracle resolution
- **v1.4.1** - Indentation clarified as optional and a readability aid, not structural
- **v1.4.0** - `@(Name)` convention for multi-PC and companion play, promoted from the Combat Add-on
- **v1.3.0** - Tag category syntax, multi-line tag form, and roll context blocks inside `d:`
- **v1.2.0** - Add-on ecosystem introduced
- **v1.1.0** - License clarification; inline table definitions, filtered option sets, multi-line result blocks
- **v1.0.0** - Renamed from "Solo TTRPG Notation" to "Lonelog"

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
