# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Quarto documentation project** for **Lonelog** — a standard notation system for solo RPG session logging. The project generates multi-format documentation (PDF, EPUB, ODT, Typst) in multiple languages (English, French, Italian).

## Building the Documentation

### Build Individual Files

To render a specific document in all configured formats:

```bash
quarto render lonelog.md
quarto render lonelog-it.md
quarto render lonelog-fr.md
```

To render a specific document to a single format:

```bash
quarto render lonelog.md --to typst
quarto render lonelog.md --to pdf
quarto render lonelog.md --to epub
quarto render lonelog.md --to odt
```

### Preview in Development

To preview with live reload during editing:

```bash
quarto preview lonelog.md
```

### Build All Documents

To render all documents in the project:

```bash
quarto render
```

## File Structure and Naming Conventions

### Core Documentation Files

- **`lonelog.md`** - Main English documentation
- **`lonelog-it.md`** - Italian translation
- **`lonelog-fr.md`** - French translation

### Module Files

Module files extend the core notation with optional systems:

- **`lonelog-combat-module.md`** - Tactical combat notation
- **`lonelog-dungeon-crawling-module.md`** - Dungeon exploration notation
- **`lonelog-resource-tracking-module.md`** - Resource management notation

These modules are separate documents that reference the core Lonelog system. They use `parent: Lonelog v1.0.0` in their frontmatter.

### Language Variants

Each language variant produces its own set of output files:
- `lonelog.pdf`, `lonelog.epub`, `lonelog.odt`, `lonelog.typ`
- `lonelog-it.pdf`, `lonelog-it.epub`, `lonelog-it.odt`, `lonelog-it.typ`
- `lonelog-fr.pdf`, `lonelog-fr.epub`, `lonelog-fr.odt`, `lonelog-fr.typ`

## Architecture

### Quarto Configuration (`_quarto.yml`)

The project uses a shared configuration file that defines:
- **Filters**: `pagebreak.lua` converts `---` to Typst pagebreaks
- **Cover images**: `logo.png` and `by-sa.png` (CC license stamp)
- **Format-specific settings**: Typst, HTML, and EPUB configurations
- **Custom templates**: Typst template partials for styling

### Custom Typst Templates

Located in `_extensions/`:

1. **`typst-template.typ`** - Main template defining the `worldbuilders()` function
   - Defines color palette and fonts (Montserrat, Lora, Consolas)
   - Handles multi-language TOC titles
   - Creates custom cover pages with logo and license
   - Formats headings, tables, code blocks, and quotes
   - Sets page dimensions to half-letter (5.5" × 8.5") for KDP publishing

2. **`typst-show.typ`** - Pandoc template partial that maps Quarto metadata to Typst template parameters

3. **`pagebreak.lua`** - Lua filter that converts horizontal rules (`---`) to `#pagebreak()` in Typst output

### Frontmatter Metadata

Each main document uses YAML frontmatter with these key fields:

```yaml
---
title: Lonelog
subtitle: "A Standard Notation for Solo RPG Session Logging"
author: Roberto Bisceglie
version: 1.0.0
license: CC BY-SA 4.0
lang: en  # or 'it', 'fr'
---
```

The language field (`lang`) controls:
- Text language settings in generated output
- TOC title localization (Contents, Sommario, Table des matières)
- Region-specific typography settings

### Output Formats

The project generates four output formats:

1. **Typst** (`.typ`) - Primary format, kept with `keep-typ: true` for debugging
2. **PDF** - Generated from Typst for print-ready output (KDP-compatible)
3. **EPUB** - E-book format with TOC
4. **ODT** - OpenDocument format for word processor editing

## Design System

### Typography

- **Titles**: Montserrat (Black 32pt for cover, Bold 16pt for headings)
- **Body**: Lora Medium 11pt
- **Code**: Consolas 11pt

### Color Palette

- **Text**: `#000000` (black)
- **Subtitles**: `#666666` (gray)
- **Code Text**: `#585260` (purple-gray)
- **Code Background**: `#efecf4` (light purple)
- **Inline Code**: `#188038` (green)

### Page Layout

- **Format**: Half-letter (5.5" × 8.5")
- **Margins**: 1.5cm top/left/right, 1.8cm bottom
- **Footer descent**: 0.25" (KDP requirement for page numbers)

## Working with Translations

When adding or updating translations:

1. **Maintain frontmatter consistency**: Ensure all three language files have matching structure (version, license, etc.)
2. **Update the `lang` field**: Set to `en`, `it`, or `fr` to ensure proper localization
3. **Test all formats**: Verify that PDF, EPUB, and ODT outputs render correctly for each language
4. **Check TOC titles**: The template automatically localizes TOC titles based on the `lang` field

## Working with Modules

Modules are standalone documents that extend the core notation. When creating or editing modules:

1. **Use descriptive titles**: e.g., "Lonelog: Combat Module"
2. **Set status**: Use `status: Draft` or `status: Final` in frontmatter
3. **Reference parent**: Include `parent: Lonelog v1.0.0` to indicate dependency
4. **Keep them optional**: Modules should be independently useful and not required for core notation

## Legacy Files

The `legacy/` directory contains previous versions of the notation documentation. These files are preserved for historical reference but are not actively maintained.
