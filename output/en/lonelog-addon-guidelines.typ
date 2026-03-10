// Some definitions presupposed by pandoc's typst output.
#let blockquote(body) = [
  #set text( size: 0.92em )
  #block(inset: (left: 1.5em, top: 0.2em, bottom: 0.2em))[#body]
]

#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

// Some quarto-specific definitions.

#show raw.where(block: true): set block(
    fill: luma(230),
    width: 100%,
    inset: 8pt,
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let d = (:)
  let fields = old_block.fields()
  fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.abs
  }
  return block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == str {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == content {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subrefnumbering: "1a",
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => numbering(subrefnumbering, n-super, quartosubfloatcounter.get().first() + 1))
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => {
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          }

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != str {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let old_title = old_title_block.body.body.children.at(2)

  // TODO use custom separator if available
  let new_title = if empty(old_title) {
    [#kind #it.counter.display()]
  } else {
    [#kind #it.counter.display(): #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block, 
    block_with_new_content(
      old_title_block.body, 
      old_title_block.body.body.children.at(0) +
      old_title_block.body.body.children.at(1) +
      new_title))

  block_with_new_content(old_callout,
    block(below: 0pt, new_title_block) +
    old_callout.body.children.at(1))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black, body_background_color: white) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color, 
        width: 100%, 
        inset: 8pt)[#text(icon_color, weight: 900)[#icon] #title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: body_background_color, width: 100%, inset: 8pt, body))
      }
    )
}



#let article(
  title: none,
  subtitle: none,
  authors: none,
  date: none,
  abstract: none,
  abstract-title: none,
  cols: 1,
  lang: "en",
  region: "US",
  font: "libertinus serif",
  fontsize: 11pt,
  title-size: 1.5em,
  subtitle-size: 1.25em,
  heading-family: "libertinus serif",
  heading-weight: "bold",
  heading-style: "normal",
  heading-color: black,
  heading-line-height: 0.65em,
  sectionnumbering: none,
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,
  doc,
) = {
  set par(justify: true)
  set text(lang: lang,
           region: region,
           font: font,
           size: fontsize)
  set heading(numbering: sectionnumbering)
  if title != none {
    align(center)[#block(inset: 2em)[
      #set par(leading: heading-line-height)
      #if (heading-family != none or heading-weight != "bold" or heading-style != "normal"
           or heading-color != black) {
        set text(font: heading-family, weight: heading-weight, style: heading-style, fill: heading-color)
        text(size: title-size)[#title]
        if subtitle != none {
          parbreak()
          text(size: subtitle-size)[#subtitle]
        }
      } else {
        text(weight: "bold", size: title-size)[#title]
        if subtitle != none {
          parbreak()
          text(weight: "bold", size: subtitle-size)[#subtitle]
        }
      }
    ]]
  }

  if authors != none {
    let count = authors.len()
    let ncols = calc.min(count, 3)
    grid(
      columns: (1fr,) * ncols,
      row-gutter: 1.5em,
      ..authors.map(author =>
          align(center)[
            #author.name \
            #author.affiliation \
            #author.email
          ]
      )
    )
  }

  if date != none {
    align(center)[#block(inset: 1em)[
      #date
    ]]
  }

  if abstract != none {
    block(inset: 2em)[
    #text(weight: "semibold")[#abstract-title] #h(1em) #abstract
    ]
  }

  if toc {
    let title = if toc_title == none {
      auto
    } else {
      toc_title
    }
    block(above: 0em, below: 2em)[
    #outline(
      title: toc_title,
      depth: toc_depth,
      indent: toc_indent
    );
    ]
  }

  if cols == 1 {
    doc
  } else {
    columns(cols, doc)
  }
}

#set table(
  inset: 6pt,
  stroke: none
)
// 0. DEFINE HELPER FUNCTIONS (accessible from markdown)
// These must be defined BEFORE the template function

// Color Palette - Solo RPG Notation
#let color-black = rgb("#000000")
#let color-subtitle = rgb("#666666")
#let color-code-text = rgb("#585260")
#let color-code-bg = rgb("#efecf4")
#let color-inline-code = rgb("#188038")
#let color-white = rgb("#FFFFFF")

// Font System
#let font-title = "Montserrat"
#let font-body = "Lora"
#let font-code = "Consolas"

// Multilingual TOC titles
#let toc-titles = (
  "en": "Contents",
  "fr": "Table des matières",
  "de": "Inhaltsverzeichnis",
  "es": "Índice",
  "it": "Sommario",
  "pt": "Sumário",
  "nl": "Inhoud",
  "pl": "Spis treści",
  "ru": "Содержание",
  "ja": "目次",
  "zh": "目录",
)

// Custom callout box function
#let callout(title: none, body) = {
  v(0.8em)
  rect(
    width: 100%,
    //fill: color-code-bg,
    stroke: 0.5pt + color-subtitle,
    radius: 2pt,
    inset: (x: 12pt, y: 10pt)
  )[
    #if title != none {
      text(
        font: font-title,
        size: 10pt,
        weight: "semibold",
        fill: color-black
      )[#title]
      v(0.4em)
    }
    #set text(size: 11pt, fill: color-black, font: font-body)
    #body
  ]
  v(0.8em)
}

// 1. DEFINE THE TEMPLATE FUNCTION
// This function takes all the metadata Quarto sends
#let worldbuilders(
  title: none,
  subtitle: none,
  version: none,
  authors: none,
  date: none,
  abstract: none,
  cols: 1,
  margin: (x: 1.5cm, y: 1.5cm),
  paper: "us-letter",
  lang: "en",
  region: "US",
  font: (),
  fontsize: 11pt,
  section-numbering: none,
  toc: false,
  toc_title: none,
  toc_depth: none,
  logo-image: none,      // Path to logo image
  license-image: none,   // Path to CC license stamp
  doc, // This is the actual content (body)
) = {

  // 2. CONFIGURATION
  // Colors and fonts are defined globally above, accessible here via closure

  // Half-letter format (5.5 x 8.5 in) with margins for KDP
  set page(
    width: 5.5in,
    height: 8.5in,
    margin: (top: 1.5cm, bottom: 1.8cm, left: 1.5cm, right: 1.5cm),
    fill: color-white
  )

  // SANITIZE LANGUAGE INPUT
  // Simple fallback: if lang is none or empty, use "en"
  let safe-lang = if lang == none or lang == "" { "en" } else { lang }
  let safe-region = if region == none or region == "" { "US" } else { region }


  // Apply text settings - Body text: Lora Medium 11pt
  set text(
    font: font-body,
    size: 11pt,
    weight: "medium",
    fill: color-black,
    lang: safe-lang,
    region: safe-region
  )

  // Paragraph settings
  set par(
    leading: 0.65em,
    justify: true,
    linebreaks: "simple"
  )

  // 3. CUSTOM SHOW RULES - Heading Hierarchy
  // Note: Markdown ## becomes Typst level 1, ### becomes level 2, etc.

  // HEADING LEVEL 1 (markdown ##) - Montserrat Bold 16pt, black
  show heading.where(level: 1): it => {
    v(1.5em)
    set text(
      font: font-title,
      size: 16pt,
      weight: "bold",
      fill: color-black
    )
    it
    v(0.8em)
  }

  // HEADING LEVEL 2 (markdown ###) - Montserrat Semi Bold 14pt, black
  show heading.where(level: 2): it => {
    v(1em)
    set text(
      font: font-title,
      size: 14pt,
      weight: "semibold",
      fill: color-black
    )
    it
    v(0.5em)
  }

  // HEADING LEVEL 3 (markdown ####) - Montserrat Semi Bold 12pt, black
  show heading.where(level: 3): it => {
    v(0.8em)
    set text(
      font: font-title,
      size: 12pt,
      weight: "semibold",
      fill: color-black
    )
    it
    v(0.4em)
  }
  
  // Table styling
  set table(
    stroke: (x, y) => {
      if y == 0 {
        (bottom: 0.5pt + color-subtitle)  // Underline header
      } else {
        none
      }
    },
    fill: (col, row) => {
      if row == 0 {
        none  // Headers no background
      } else if calc.odd(row) {
        color-code-bg  // Alternating rows
      } else {
        none
      }
    },
    inset: (x: 8pt, y: 6pt)
  )

  // Header cells - Montserrat
  show table.cell.where(y: 0): set text(
    font: font-title,
    size: 10pt,
    weight: "semibold",
    fill: color-black
  )

  // Body cells - Lora
  show table.cell: set text(
    font: font-body,
    size: 10pt,
    fill: color-black
  )

  show figure.where(kind: table): set block(
    width: 100%,
    breakable: true
  )

  // Code block styling - Consolas 11pt, #585260 text, #efecf4 background
  show raw.where(block: true): it => {
    set text(
      font: font-code,
      size: 11pt,
      fill: color-code-text
    )
    block(
      width: 100%,
      //fill: color-code-bg,
      inset: 10pt,
      radius: 2pt,
      it
    )
  }

  // Inline code styling - Consolas 11pt, #188038 highlight
  show raw.where(block: false): it => {
    text(
      font: font-code,
      size: 11pt,
      fill: color-inline-code
    )[#it]
  }

  // Block Quote Styling
  show quote.where(block: true): it => {
    set text(
      font: font-body,
      style: "italic",
      size: 10pt,
      fill: color-subtitle
    )
    set par(leading: 0.65em)
    v(1em)
    pad(left: 1.5em, right: 1.5em)[#it.body]
    v(1em)
  }

  // 4. COVER PAGE
  if title != none {
    set page(
      numbering: none,
      footer: none,
      fill: color-white,
      margin: 1.5cm
    )

    // Everything aligned right
    align(right)[
      #v(5cm)
      // Logo
      #if logo-image != none {
        v(0.5cm)
        image(logo-image, width: 60%)
        v(-0.5em)
      } else {
        v(3cm)
      }

      // Main title - Montserrat Black 26pt, black (no extra space)
      #text(
        font: font-title,
        size: 32pt,
        weight: "black",
        fill: color-black
      )[#title]

      #v(0.5em)

      // Subtitle - Montserrat Semi Bold 12pt, #666666
      #if subtitle != none {
        text(
          font: font-title,
          size: 11pt,
          weight: "semibold",
          fill: color-subtitle
        )[#subtitle]
      }

      #v(0.3em)

      // Version with "Version" prefix
      #if version != none {
        text(
          font: font-title,
          size: 11pt,
          weight: "medium",
          fill: color-subtitle
        )[Version #version]
      }
    ]

    // CC License stamp at the bottom
    if license-image != none {
      place(
        bottom + center,
        dy: -1.5cm,
        image(license-image, width: 25%)
      )
    }

    pagebreak(weak: true, to: "odd")
  }

  // 5. TABLE OF CONTENTS
  if toc {
    set page(
      numbering: "i",
      fill: color-white,
      // KDP requires 0.25" (6.35mm) minimum from edge EXCLUDING page numbers
      // Bottom margin = 0.25" safe zone + ~11pt for page number + spacing to content
      margin: (top: 1.5cm, bottom: 1.8cm, left: 1.5cm, right: 1.5cm),
      footer-descent: 0.25in,  // Page number sits 0.25" from bottom edge
      footer: context [
        #set text(
          font: font-body,
          size: 11pt,
          fill: color-black
        )
        #align(if calc.odd(here().page()) { right } else { left })[
          #counter(page).display("i")
        ]
      ]
    )
    counter(page).update(1)

    // TOC title styling
    show outline: it => {
      v(2em)
      text(
        font: font-title,
        size: 16pt,
        weight: "bold",
        fill: color-black
      )[#if toc_title != none { toc_title } else { toc-titles.at(safe-lang, default: "Contents") }]
      v(1.5em)
      it
    }

    // Level 1 entries - bold
    show outline.entry.where(level: 1): it => {
      set text(
        font: font-title,
        weight: "semibold",
        fill: color-black
      )
      it
    }

    // Level 2+ entries - regular
    show outline.entry: it => {
      set text(
        font: font-body,
        size: 10pt,
        fill: color-black
      )
      it
    }

    outline(title: none, depth: toc_depth, indent: 1.2em)

    pagebreak(weak: true, to: "odd")
  }

  // 6. MAIN BODY
  set page(
    numbering: "1",
    fill: color-white,
    // KDP requires 0.25" (6.35mm) minimum from edge EXCLUDING page numbers
    margin: (top: 1.5cm, bottom: 1.8cm, left: 1.5cm, right: 1.5cm),
    footer-descent: 0.25in,  // Page number sits 0.25" from bottom edge
    footer: context [
      #set text(
        font: font-body,
        size: 11pt,
        fill: color-black
      )
      #align(if calc.odd(here().page()) { right } else { left })[
        #counter(page).display()
      ]
    ]
  )
  counter(page).update(1)

  // Render the body content
  doc
}

#set page(
  paper: "us-letter",
  margin: (x: 1.25in, y: 1.25in),
  numbering: "1",
)

#show: doc => worldbuilders(
  title: "Lonelog: Community Add-on Guidelines",
  subtitle: "How to Write Add-ons That Work with the Core",
  version: "1.1.0",
  authors: ("Roberto Bisceglie", ),
  date: none,
  abstract: none,
  cols: 1,
  lang: "en",
  region: "US",
  section-numbering: none,
  toc: true,
  toc_title: "Table of contents",
  toc_depth: 2,
  logo-image: "logo.png",
  license-image: "by-sa.png",
  doc,
)

= Lonelog Community Add-on Guidelines
<lonelog-community-add-on-guidelines>
These guidelines exist so that any Lonelog add-on --- whether written for personal use, shared on Reddit, or published on itch.io --- reads consistently alongside the core system and other add-ons. If a player knows Lonelog, they should be able to pick up a compliant add-on and understand it immediately.

This isn't a list of rules imposed from outside. It's the distilled reasoning behind how the official add-ons were designed. Understanding the #emph[why] makes the constraints easy to follow, and easy to apply to situations the guidelines don't explicitly cover.

#pagebreak()
== 1. The Non-Negotiables
<the-non-negotiables>
These are the constraints that define a Lonelog add-on as distinct from a fork or a separate system. Violating any of them produces something that may be excellent, but isn't a Lonelog add-on.

=== 1.1 Do Not Replace Core Symbols
<do-not-replace-core-symbols>
The five core symbols are the shared language of all Lonelog logs:

#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Symbol], [Role],),
  table.hline(),
  [`@`], [Player action],
  [`?`], [Oracle question],
  [`d:`], [Mechanics roll],
  [`->`], [Resolution outcome],
  [`=>`], [Consequence],
)
An add-on may introduce new #strong[tags];, #strong[structural blocks];, and #strong[formatting conventions];. It may not introduce a new symbol that duplicates, overrides, or conflicts with any of the five above.

#strong[Compliant:] Introducing `[F:Enemy|HP 8]` to tag foes in combat. \
#strong[Non-compliant:] Introducing `!` as a new symbol for attacks, bypassing `@` and `d:`.

If you find yourself wanting a sixth core symbol, that's a signal to reconsider the design. The existing five are almost always sufficient when used with new tags or structural conventions.

=== 1.2 Do Not Conflict with Existing Tags
<do-not-conflict-with-existing-tags>
The core spec defines these tag prefixes:

- `N:` --- NPCs
- `L:` --- Locations
- `E:` --- Events
- `PC:` --- Player character
- `Thread:` --- Story threads
- `Clock:`, `Track:`, `Timer:` --- Progress elements
- `#` prefix --- Reference tags
- `Inv:`, `Wealth:` --- Resource tracking (Resource Add-on)

Do not reuse these prefixes for different purposes. If you need a new tag type, use a prefix that isn't in this list and document it clearly in your add-on's quick reference.

#strong[Compliant:] `[R:Room4|active]` for room states (Dungeon Crawling Add-on). \
#strong[Non-compliant:] `[L:Room4|active]` --- this repurposes the Location tag for a different semantic meaning.

When uncertain whether a prefix conflicts, check the full add-on ecosystem before finalizing your choice.

=== 1.3 Include Required Metadata
<include-required-metadata>
Every add-on must open with a YAML front matter block that includes these fields:

```yaml
---
title: "Lonelog: [Add-on Name] Add-on"
subtitle: "[Short description]"
author: [Your name or handle]
version: [Semantic version, e.g. 1.0.0]
license: CC BY-SA 4.0
lang: en
parent: Lonelog [version this add-on targets, e.g. v1.1.0]
requires: Core Notation (§3)
---
```

The `requires` field must list the core sections your add-on depends on. If you also depend on another add-on, list it: `requires: Core Notation (§3), Resource Tracking Add-on (§1–§3)`.

The `parent` field pins your add-on to a specific core version. When the core updates, add-on authors can assess whether their add-on needs updating.

=== 1.4 Use CC BY-SA 4.0 (or Compatible)
<use-cc-by-sa-4.0-or-compatible>
Official and community add-ons should use the same license as the core: #strong[Creative Commons Attribution-ShareAlike 4.0 International];. This keeps the ecosystem open --- anyone can use, adapt, and share add-ons as long as they attribute and share alike.

If you have a specific reason to use a different license, ensure it is compatible with CC BY-SA 4.0. Do not use licenses that would restrict derivative works or require proprietary terms.

#pagebreak()
== 2. Strong Recommendations
<strong-recommendations>
These aren't absolute requirements, but they distinguish a well-designed add-on from a merely functional one. The official add-ons follow all of them.

=== 2.1 Extend, Don't Invent
<extend-dont-invent>
Before adding anything new, ask: can an existing mechanism handle this?

- Need to track enemy health? The `[N:]` tag already takes freeform properties: `[N:Goblin|HP 4]`.
- Need a countdown? `[Timer:]` already exists.
- Need to record a roll? `d:` is already there.

The best add-ons add as little as possible to achieve their goal. Every new tag or convention is something players have to learn and remember. Earn that cognitive load.

=== 2.2 Write for Both Digital and Analog
<write-for-both-digital-and-analog>
Lonelog is explicitly format-agnostic. Your add-on should be too. Whenever you introduce a structural block or notation pattern, show how it works in both digital markdown and analog notebook formats.

If a convention genuinely doesn't translate to analog (e.g., it depends on hyperlinking), say so explicitly and provide an analog alternative if possible.

=== 2.3 Scale from Compact to Detailed
<scale-from-compact-to-detailed>
Core Lonelog works at multiple levels of detail --- from ultra-compact single-line shorthand to rich narrative logs. Add-ons should respect this range.

For every significant notation feature, provide at least two examples: one minimal (fast play, high-information-density) and one expanded (narrative-rich, exploratory). Players should be able to adopt your add-on at whatever detail level matches their play style.

=== 2.4 Show Integration Examples
<show-integration-examples>
At least one example in your add-on should demonstrate the add-on being used #emph[alongside] core Lonelog in a realistic play sequence --- not just the new features in isolation. Players need to see how the pieces fit together in actual log entries.

If your add-on is designed to work alongside another add-on, include a combined example.

=== 2.5 Provide a Quick Reference
<provide-a-quick-reference>
Every add-on should end with a quick reference section: a table or compact list of every new tag, symbol convention, and structural block introduced. This is the first thing an experienced player will check after reading the add-on once, and the thing they'll return to during actual play.

#pagebreak()
== 3. Structural Guidelines
<structural-guidelines>
=== 3.1 Recommended Document Structure
<recommended-document-structure>
Follow this section order for consistency across the add-on library:

+ #strong[Overview] --- What problem does this add-on solve? When should players use it? (2--4 paragraphs)
+ #strong[What This Add-on Adds] --- A table: new tags, new conventions, new structural blocks
+ #strong[Design Principles] --- 3--5 principles that explain the #emph[why] behind the design choices
+ #strong[Core sections] --- One section per major feature, each with format, examples, and guidance
+ #strong[Cross-Add-on Interactions] --- How this add-on works alongside others (omit if not applicable)
+ #strong[System Adaptations] --- How the add-on adapts to specific RPG systems (PbtA, OSR, etc.)
+ #strong[Best Practices] --- Do/Don't examples in the style of Lonelog §7
+ #strong[Quick Reference] --- Tables of all new notation elements
+ #strong[FAQ] --- Anticipated questions about edge cases and design choices

You don't have to use all nine sections if some don't apply. The overview, what's added, core sections, best practices, and quick reference are the minimum for a useful add-on.

=== 3.2 Writing Tone
<writing-tone>
Lonelog's documentation has a specific voice: direct, practical, encouraging, non-prescriptive. It explains #emph[why] conventions exist, not just #emph[what] they are. It treats readers as capable adults who will adapt the notation to their needs.

When writing your add-on, match this tone. Avoid: - Prescriptive language like "you must" or "you should always" (use "do" and "consider") - Assumptions about which RPG system the reader uses - Implying that players who don't use the add-on are playing incorrectly

=== 3.3 Structural Block Syntax
<structural-block-syntax>
When your add-on introduces a structural block --- a delimited region that wraps a mode of play (like combat, a dungeon session status, or a resource snapshot) --- use the bracket tag convention:

```
[BLOCK NAME]
...contents...
[/BLOCK NAME]
```

This is the same pattern as `[COMBAT]` / `[/COMBAT]` in the Combat Add-on. It keeps structural blocks visually consistent with ordinary tags and makes them grep-friendly.

For #strong[analog notebook] equivalents, use dashed separators:

```
--- BLOCK NAME ---
...contents...
--- END BLOCK NAME ---
```

#strong[Do not use] `=== ... ===` or `--- ... ---` as the primary (digital) block delimiter. Reserve those for analog alternatives only.

#strong[Compliant:]

```
[DUNGEON STATUS]
[R:1|cleared|entry hall]
[/DUNGEON STATUS]
```

#strong[Non-compliant:]

```
=== Dungeon Status ===
[R:1|cleared|entry hall]
```

Every structural block must have an explicit closing tag. Open-ended blocks (no closing delimiter) are not compliant.

=== 3.4 Example Quality
<example-quality>
Examples are the most important part of any add-on. They should:

- Show #strong[complete sequences];, not isolated lines (action → roll → consequence → tags)
- Use #strong[realistic fiction];, not abstract placeholders (`@ Attack the goblin`, not `@ ACTION`)
- #strong[Progress logically] --- the reader should feel they're seeing a real moment of play
- #strong[Demonstrate edge cases] as well as the common case

Avoid examples that are so simple they don't reveal anything about how the notation behaves under real conditions.

#pagebreak()
== 4. Community Practices
<community-practices>
=== 4.1 Versioning
<versioning>
Use semantic versioning: `major.minor.patch`.

- #strong[Patch] (1.0.0 → 1.0.1): Typo fixes, clarifications that don't change behavior
- #strong[Minor] (1.0.0 → 1.1.0): New optional features, expanded examples, backward-compatible additions
- #strong[Major] (1.0.0 → 2.0.0): Changes that break compatibility with previous versions of the add-on

When your add-on's `parent` version changes (e.g., Lonelog updates from v1.1.0 to v1.2.0), review your add-on and update the `parent` field. If the core change affects your add-on's behavior, treat it as at least a minor version bump.

=== 4.2 Naming
<naming>
Add-on file names should follow the pattern: `lonelog-[name]-addon.md` or simply `[name]-addon.md` within a Lonelog-specific repository. This makes the origin clear when files are shared outside their folder context.

Add-on titles in the YAML front matter should follow: `"Lonelog: [Name] Add-on"`.

=== 4.3 Attribution and Derivatives
<attribution-and-derivatives>
If you build on someone else's community add-on, credit them in your document and respect their license terms. CC BY-SA 4.0 requires attribution and that derivatives carry the same license.

If you publish an add-on that substantially incorporates another, note the original author and version in your metadata:

```yaml
based-on: "[Original Add-on Name] by [Author]"
```

=== 4.4 Sharing
<sharing>
When sharing add-ons on Reddit, itch.io, or other platforms: - Link to the core Lonelog document so new readers have context - State which core version your add-on targets - Note any add-on dependencies - Invite feedback --- the community's collective use improves add-ons faster than solo development

#pagebreak()
== 5. Quick Compliance Checklist
<quick-compliance-checklist>
Before publishing or sharing your add-on, verify:

#strong[Non-negotiables:] - \[ \] No new symbols that conflict with `@`, `?`, `d:`, `->`, `=>` - \[ \] No tag prefixes that conflict with existing core or add-on tags - \[ \] YAML front matter present with all required fields - \[ \] `parent` field specifies the core version targeted - \[ \] License is CC BY-SA 4.0 (or compatible)

#strong[Strong recommendations:] - \[ \] Shows both digital and analog examples - \[ \] Includes at least one integration example with core Lonelog - \[ \] Provides compact and expanded variants for major features - \[ \] Ends with a quick reference table - \[ \] Writing tone matches Lonelog's voice (practical, non-prescriptive, explanatory)

#strong[Structure:] - \[ \] Overview explains the problem and when to use the add-on - \[ \] "What This Add-on Adds" table present - \[ \] Best practices section with Do/Don't examples - \[ \] FAQ addresses likely edge case questions - \[ \] Structural blocks use `[BLOCK]` / `[/BLOCK]` syntax (not `===` or `---` as primary format)
