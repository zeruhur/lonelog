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
  title: "Lonelog: Combat Add-on",
  subtitle: "Optional Notation for Tactical Encounters",
  version: "1.0.0",
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

= Combat Add-on
<combat-add-on>
== Overview
<overview>
Combat is where solo play gets dense. Dice fly, hit points drop, positions shift---and you're running both sides. Without structure, your log turns into a wall of text where you can't tell who hit whom or when things went wrong.

This add-on gives you optional notation for tactical encounters. It layers on top of core Lonelog---using the same `@`, `d:`, `->`, `=>` symbols---and adds just enough structure to keep fights readable without turning your session into a spreadsheet.

Not every solo game has tactical combat. #emph[Thousand Year Old Vampire] doesn't need round tracking. A #emph[Mythic GME];-driven investigation might resolve a bar fight in a single oracle question. If your system resolves combat with a single roll, core notation handles it fine:

```
@ Fight the bandits
d: Combat 2d6=9 -> Strong Hit
=> I cut through them and escape into the alley.
```

This add-on is for everything more involved than that---games where you're tracking rounds, multiple combatants, ranges, and changing hit points.

#pagebreak()
=== What This Add-on Adds
<what-this-add-on-adds>
#table(
  columns: (35.71%, 32.14%, 32.14%),
  align: (auto,auto,auto,),
  table.header([Addition], [Purpose], [Example],),
  table.hline(),
  [`[F:Name\|stats]`], [Track combatant stats and status], [`[F:Thug\|HP 6\|Close]`],
  [`[COMBAT]` / `[/COMBAT]`], [Delimit a tactical encounter within a scene], [`[COMBAT] ... [/COMBAT]`],
  [`R#` round markers], [Separate initiative rounds within a combat block], [`R1`, `R2`, `R3`],
  [`@(Name) Action`], [Attribute actions to non-PC actors], [`@(Thug A) Lunges at me`],
  [`R# Roster: [tags]`], [Snapshot all combatant states at a round boundary], [`R3 Roster: [PC:HP 3] [F:Boss\|HP 4]`],
)
#strong[No new core symbols.] This add-on introduces no additions to `@`, `?`, `d:`, `->`, or `=>`.

#pagebreak()
=== Design Principles
<design-principles>
#strong[No new core symbols.] Combat uses `@`, `d:`, `->`, `=>` exactly as defined in core Lonelog. New elements are structural markers and formatting conventions only---not symbolic shortcuts.

#strong[Scale to complexity.] A quick skirmish needs less notation than a five-round battle with six combatants. Use only as much structure as the encounter demands. The add-on supports both extremes.

#strong[Actor clarity first.] The central problem of combat logging is knowing who is doing what. Every addition here serves that goal---round markers separate turns, the `@(Name)` prefix identifies non-PC actors, foe tags track changing states.

#pagebreak()
== 1. Combat Blocks
<combat-blocks>
Some encounters benefit from a structural boundary that signals a change in mode---denser notation, round-by-round tracking, mechanical state changes. The `[COMBAT]` block provides that boundary.

#strong[Format:]

```
[COMBAT]
...combat notation...
[/COMBAT]
```

==== 1.1 In Scene Headers
<in-scene-headers>
When the entire scene is a fight, place `[COMBAT]` in the scene header:

```
S5 *Warehouse ambush* [COMBAT]
```

No closing tag is needed---the next scene marker ends the encounter.

==== 1.2 Inline During a Scene
<inline-during-a-scene>
When combat starts mid-scene, open and close the block around the tactical section:

```
S5 *Warehouse, midnight*
@ Search the crates for evidence
d: Investigation d6=5 vs TN 4 -> Success
=> I find shipping manifests—but hear footsteps behind me.

[COMBAT]
...combat notation here...
[/COMBAT]

=> With the thugs unconscious, I grab the manifests and run.
```

The `[COMBAT]` / `[/COMBAT]` delimiters let you visually separate the tactical section from the narrative, find combat encounters when scanning a log, and signal to future-you that denser notation follows.

==== 1.3 Analog Format
<analog-format>
For paper notebooks, use dashed separators:

```
--- COMBAT ---
...combat notation...
--- END COMBAT ---
```

Or skip delimiters entirely---the round markers below already signal combat.

#strong[When to skip the block:] If combat resolves in one or two rolls, core notation handles it without any block structure.

#pagebreak()
== 2. Round Tracking
<round-tracking>
Discrete combat rounds get `R#` markers. Think of them as mini-scenes within the fight.

#strong[Format:]

```
R1
...actions...

R2
...actions...
```

#strong[Numbering:] Start at `R1` each combat. Rounds are local to the encounter, not the session.

#strong[Example --- minimal:]

```
R1 @ Slash d:17≥12 Hit HP-5 @(Thug) d:9≥15 Miss
R2 @ Finish him d:20≥12 Hit => [F:Thug|dead]
```

#strong[Example --- expanded:]

```
R1
@ Draw sword and attack Thug A
d: d20+5=17 vs AC 12 -> Hit
d: 1d8=5 damage
=> [F:Thug A|HP-5|HP 1|staggered]

@(Thug A) Wild swing back
d: d20+3=9 vs AC 15 -> Miss
=> He's off-balance—I press the advantage.

R2
@ Strike again
d: d20+5=14 vs AC 12 -> Hit
d: 1d8=6 damage
=> [F:Thug A|dead]
```

#strong[When to skip round markers:] If combat is fast (one or two rolls) or your system doesn't use discrete rounds, log actions sequentially without markers.

#pagebreak()
== 3. Tracking Combatants
<tracking-combatants>
Core Lonelog tracks NPCs with `[N:Name|tags]`. In combat, you often need tighter tracking---hit points, position, status effects that change every round. The #strong[foe tag] `[F:Name|stats]` is a combat-specific variant designed for this.

#strong[Format:]

```
[F:Name|key stats|position|status]
```

#strong[Fields:]

- `Name` --- combatant identifier; use A/B suffixes to distinguish individuals of the same type
- `key stats` --- mechanical values: `HP 6`, `AC 12`, `ATK +3`
- `position` --- range or zone: `Close`, `Medium`, `Far`, `Engaged`, `Zone:Alley`
- `status` --- conditions: `wounded`, `staggered`, `dead`, `fled`

==== 3.1 Individual Foes
<individual-foes>
```
[F:Thug A|HP 6|Close|armed]
[F:Cultist Leader|HP 12|Far|spellcaster]
```

Update foe tags as stats change---either on a new line or inline:

```
[F:Thug A|HP 6|Close]
...Thug A takes 3 damage...
[F:Thug A|HP 3|Close|wounded]

...or shorthand:
[F:Thug A|HP-3]
```

==== 3.2 Grouped Foes
<grouped-foes>
When individuals don't need separate tracking, group them:

```
[F:Goblins×4|HP 3 each|Close]
...one dies...
[F:Goblins×3|Close]
```

Split groups when they diverge in position or status:

```
[F:Pirate 1|Close|wounded]
[F:Pirate 2|Medium|crossbow]
```

==== 3.3 Position and Movement
<position-and-movement>
Track range as a tag attribute. Common range bands:

```
[F:Archer|HP 5|Far]
[F:Thug|HP 6|Close]
[F:Wolf|HP 4|Engaged]     (in melee)
```

Show movement with an arrow notation:

```
@(Thug A) Rushes in [Far->Close]
[F:Thug A|Close]
```

For grid or zone-based systems:

```
[F:Thug A|HP 6|Zone:Alley]
[F:Thug B|HP 4|Zone:Rooftop]
[PC:Alex|Zone:Street]
```

#strong[Why `[F:]` instead of `[N:]`?] `[N:]` is for persistent NPCs who matter to your story. `[F:]` is for combatants---often disposable, defined by mechanical stats rather than narrative tags. The distinction keeps your NPC index clean. A recurring villain might be `[N:Viktor|ambitious|ruthless]` in narrative scenes and gain a `[F:Viktor|HP 15|Far|armored]` when the swords come out.

#strong[When to skip foe tags:] For simple fights (one enemy, no position tracking), `[N:]` or naming the enemy in prose works fine. Foe tags earn their keep when you need to track multiple combatants with changing stats.

#pagebreak()
== 4. Actor Actions
<actor-actions>
In normal play, `@` always means "I, the player character, do something." In combat, enemies and allies act too. #strong[`@` stays as the PC action. For other actors, prefix the action with the actor's name in parentheses.]

#table(
  columns: 3,
  align: (auto,auto,auto,),
  table.header([Actor], [Format], [Example],),
  table.hline(),
  [PC (default)], [`@ Action`], [`@ Swing at Thug A`],
  [Named foe], [`@(Name) Action`], [`@(Thug A) Slash at PC`],
  [Group], [`@(Group) Action`], [`@(Goblins) Swarm attack`],
  [Ally NPC], [`@(Name) Action`], [`@(Jordan) Cover fire`],
)
#strong[Example --- minimal:]

```
R1
@ Slash d:18≥12 Hit HP-6 => [F:Thug A|dead]
@(Thug B) Stab d:14≥15 Miss
```

#strong[Example --- expanded:]

```
R1
@ Draw sword and attack Thug A
d: d20+5=18 vs AC 12 -> Hit
d: 1d8=6 damage
=> [F:Thug A|HP-6|dead]

@(Thug B) Lunges at me with a knife
d: d20+3=14 vs AC 15 -> Miss
=> The knife whistles past my ear.
```

#strong[Why not a new symbol for foe actions?] Because `@` already means "action taken." The parenthetical prefix identifies who---that's all the disambiguation needed. Adding a symbol (like `!` or `>>`) would break the Lonelog principle of minimal core symbols and add one more thing to remember mid-fight.

#strong[Reactions and interrupts:] Log them where they happen with a parenthetical note:

```
@(Alex) Riposte (reaction)
@ Opportunity attack (interrupt)
```

#strong[Shorthand for fast combats:] When speed matters more than readability, go chronological within each round and let the foe tags provide context:

```
R1
[F:Thug A|Close] @(A) Slash -> d:14≥15 Miss
[PC] @ Riposte -> d:18≥12 Hit => [F:Thug A|HP-6|dead]
[F:Thug B|Close] @(B) Stab -> d:11≥15 Miss
```

#strong[Roll context:] When a combatant's tags or status directly affect the mechanics of a roll, note them inline using roll context (core Lonelog §4.1.9):

```
@(Pirate Captain) Presses the attack
d: d20+6 [against: staggered] = 11 vs AC 14 -> Miss

@ Strike at the weakened Captain
d: d20+5 [+flanking, +high ground] = 18 vs AC 13 -> Hit
```

This is most useful in tag-heavy systems (City of Mist, Fate) where named tags mechanically modify rolls. In traditional d20 systems, the roll line alone is usually sufficient.

#pagebreak()
== 5. Complex Encounters
<complex-encounters>
When more than two sides clash, structure matters most.

==== 5.1 Encounter Setup
<encounter-setup>
Before R1, establish the battlefield with a combat snapshot listing all combatants with initial positions and key stats:

```
S9 *Dockside ambush* [COMBAT]
[PC:Alex|HP 12|Engaged]
[N:Jordan|ally|HP 8|Close]
[F:Pirate Captain|HP 10|Close|armed|sword]
[F:Pirate×2|HP 4 each|Medium|armed|crossbow]
[F:Dock Rat|HP 2|Engaged|knife]
```

This is your combat snapshot---the state of the field when initiative starts.

==== 5.2 Round Rosters
<round-rosters>
For fights with many combatants and fast-changing stats, open each round with a roster line:

```
R3 Roster: [PC:Alex|HP 3] [N:Jordan|HP 4] [F:Captain|HP 4] [F:Pirate×1|HP 4]
```

This gives you a snapshot at each round without hunting back through the log.

#strong[Scaling tips:]

- #strong[Group identical foes.] `[F:Pirate×2]` beats tracking Pirate A and Pirate B separately---unless they're in different positions or have different status.
- #strong[Split groups when needed.] If one pirate moves and the other doesn't: `[F:Pirate 1|Close]` `[F:Pirate 2|Medium]`.
- #strong[Kill the tags, keep the story.] Don't track HP for mooks if one hit kills them. Just note `[F:Rat|dead]`.
- #strong[Use rosters] when you have 5+ combatants or stats are changing fast enough that you'd lose track without a summary.

#pagebreak()
== 6. Combat Aftermath
<combat-aftermath>
When combat ends, bridge back to the narrative with `=>`, update persistent tags, and open any new threads:

```
[/COMBAT]
=> Two pirates dead, the captain fled into the fog. Jordan is wounded.
[N:Jordan|wounded|HP 4]
[Thread:Pirate Captain's Revenge|Open]
[PC:Alex|HP 5|Stress+1]
```

This reconnects the mechanical combat to your ongoing story.

#strong[Loot and rewards:]

```
=> I search the bodies.
tbl: d100=67 -> "Captain's sea chart"
=> A map showing a hidden cove. [E:PirateCove 1/4]
[PC:Alex|Gear+Sea Chart]
```

#pagebreak()
== 7. Putting It All Together
<putting-it-all-together>
Here's the same encounter at three levels of detail---find your comfort zone.

==== Ultra-compact
<ultra-compact>
```
S9 *Dock ambush* [COMBAT]
[PC:HP 12] [F:Captain|HP 10] [F:Pirate×2|HP 4] [F:Rat|HP 2]
R1 @Rat d:17≥10 Hit =>dead @(Cap) d:19≥14 Hit HP-7 @(Pir×2) d:15,9 vs11 1Hit [N:Jordan HP-4]
R2 @Cap d:20≥13 Hit =>HP-6 @(Pir) d:8≥14 Miss @(Jordan) d:16≥11 Hit =>Pir dead
R3 @Cap d:15≥13 Hit =>Cap HP-4, flees
[/COMBAT] =>Captain escapes
```

==== Standard
<standard>
```
S9 *Dockside ambush* [COMBAT]
[PC:Alex|HP 12] [N:Jordan|ally|HP 8]
[F:Pirate Captain|HP 10|Close] [F:Pirate×2|HP 4|Medium] [F:Dock Rat|HP 2|Engaged]

R1
@ Slash at Dock Rat
d: d20+4=17 vs AC 10 -> Hit => [F:Dock Rat|dead]

@(Captain) Charges, swings cutlass [Close->Engaged]
d: d20+6=19 vs AC 14 -> Hit, 7 dmg => [PC:Alex|HP 5]

@(Jordan) Crossbow at Captain
d: d20+3=12 vs AC 13 -> Miss

@(Pirate×2) Crossbows at Jordan
d: d20+2=15,9 vs AC 11 -> 1 Hit, 4 dmg => [N:Jordan|HP 4]

R2
@ Power attack on Captain
d: d20+4=20 vs AC 13 -> Hit, 8 dmg => [F:Captain|HP 2|wounded]

@(Captain) Desperate slash
d: d20+6=11 vs AC 14 -> Miss

@(Jordan) Second shot at remaining Pirate
d: d20+3=16 vs AC 11 -> Hit => [F:Pirate×1|dead]

@(Pirate) Drops crossbow, flees => [F:Pirate×1|fled]

R3
@ Chase the Captain
d: Athletics d6=3 vs TN 5 -> Fail
=> He leaps off the dock into a rowboat and vanishes into the fog.

[/COMBAT]
=> Two pirates dead, one fled, Captain escaped by sea.
[N:Jordan|wounded] [PC:Alex|HP 5|Stress+1]
[Thread:Pirate Captain's Revenge|Open]
```

==== Narrative-rich
<narrative-rich>
```
S9 *Dockside, fog rolling in off the harbor*

The crates provide cover, but not for long. A rat-faced man with a
knife lunges from behind a barrel. Behind him, the Pirate Captain
draws his cutlass with a grin. Two crossbowmen take position on the
cargo stack.

[COMBAT]
[PC:Alex|HP 12|Engaged] [N:Jordan|ally|HP 8|Close]
[F:Pirate Captain|HP 10|Close|cutlass]
[F:Pirate×2|HP 4 each|Medium|crossbow]
[F:Dock Rat|HP 2|Engaged|knife]

R1
@ Sidestep the Dock Rat and slash
d: d20+4=17 vs AC 10 -> Hit, 1d8=5
=> The rat-faced man crumples. [F:Dock Rat|dead]

But I've left my flank open.

@(Pirate Captain) Charges across the dock, cutlass high [Close->Engaged]
d: d20+6=19 vs AC 14 -> Hit, 1d8+2=7
=> His blade bites deep across my ribs. I stagger back. [PC:Alex|HP 5|wounded]

PC: "Jordan—the crossbows!"

@(Jordan) Snaps off a shot at the Captain
d: d20+3=12 vs AC 13 -> Miss
=> The bolt sparks off a mooring chain.

@(Pirate×2) Fire at Jordan from the cargo stack
d: d20+2=15, d20+2=9 vs AC 11 -> 1 Hit, 1 Miss
d: 1d6=4
=> A bolt punches through Jordan's shoulder. [N:Jordan|HP 4|wounded]

N (Jordan): "I'm hit—still in it!"

R2
The Captain is close, bleeding confidence. I press the advantage.

@ Power attack on Captain
d: d20+4=20 vs AC 13 -> Critical Hit, 1d8×2=8
=> My sword catches him across the chest. He stumbles. [F:Captain|HP 2|staggered]

@(Captain) Wild swing in desperation
d: d20+6=11 vs AC 14 -> Miss
=> His cutlass sweeps wide—I duck under it.

@(Jordan) Pivots and fires at the crossbowmen
d: d20+3=16 vs AC 11 -> Hit, 1d6=5
=> One pirate tumbles off the cargo stack. [F:Pirate×1|dead]

The surviving pirate drops his crossbow and bolts into the fog.
[F:Pirate×1|fled]

R3
@ Chase the Captain before he escapes
d: Athletics d6=3 vs TN 5 -> Fail
=> He's too fast—vaults the dock railing and drops into a hidden
rowboat. The fog swallows him in seconds.

[/COMBAT]

I press a hand to my ribs, breathing hard. Jordan limps over,
shoulder dark with blood. The dock is quiet except for lapping water
and the creak of ropes.

PC (Alex): "He'll be back."
N (Jordan): "Then we'd better be ready."

=> Two pirates dead, one fled, Captain escaped by sea.
[N:Jordan|wounded|HP 4] [PC:Alex|HP 5|Stress+1]
[Thread:Pirate Captain's Revenge|Open]
```

#pagebreak()
== Cross-Add-on Interactions
<cross-add-on-interactions>
#table(
  columns: (26.19%, 35.71%, 38.1%),
  align: (auto,auto,auto,),
  table.header([Situation], [Add-on(s) Used], [Key Tags/Blocks],),
  table.hline(),
  [Tracking consumables used during combat], [Combat + Resource Tracking], [`[F:]`, `[Inv:Name\|#]`],
  [Combat in an explored dungeon room], [Combat + Dungeon Crawling], [`[COMBAT]`, `[R:Room\|state]`],
)
#strong[Combined example --- Combat + Resource Tracking:]

```
S7 *Guard room* [COMBAT]
[PC:Alex|HP 10|Engaged] [Inv:Health Potion|2]
[F:Guard×2|HP 5 each|Close|armed]

R1
@ Strike Guard 1
d: d20+4=19 vs AC 12 -> Hit, 1d8=7
=> [F:Guard 1|dead]

@(Guard 2) Counterattack
d: d20+3=16 vs AC 14 -> Hit, 1d6=4
=> [PC:Alex|HP-4|HP 6]

R2
@ Drink healing potion (action)
=> [PC:Alex|HP+4|HP 10] [Inv:Health Potion|1]

@(Guard 2) Retreats and raises alarm
=> [F:Guard 2|fled]

[/COMBAT]
=> Guard room clear, one potion used, alarm raised.
[Thread:Alarm Raised|Open]
```

#pagebreak()
== System Adaptations
<system-adaptations>
=== D&D 5e / OSR Systems
<dd-5e-osr-systems>
These systems use AC, d20 attack rolls, and explicit damage dice---the combat add-on maps naturally. Use the `vs AC #` convention in `d:` lines and include damage on the same line or the next.

```
[F:Skeleton|HP 13|AC 13|Close]

R1
@ Attack with shortsword
d: d20+4=17 vs AC 13 -> Hit
d: 1d6+2=7 damage
=> [F:Skeleton|HP-7|HP 6|damaged]

@(Skeleton) Claw swipe
d: d20+4=11 vs AC 15 -> Miss
```

=== Ironsworn / Starforged
<ironsworn-starforged>
These systems use move-based resolution without traditional initiative. Round markers are optional---each move generates its own outcome. Focus on move names as action labels and use foe tags for tracking enemy harm and threat state.

```
[COMBAT]
[F:Broken|Threat 3|Engaged]

@ Strike
d: d6+3=8 vs d10=5, d10=3 -> Strong Hit
=> +1 momentum. [F:Broken|Threat-2|Threat 1|staggered]

@(Broken) Counters
d: d10=7 -> Endure Harm
d: d6+2=6 vs d10=8, d10=4 -> Weak Hit
=> -1 health, press on.
[PC:Alex|health-1]

[/COMBAT]
```

=== Powered by the Apocalypse (PbtA)
<powered-by-the-apocalypse-pbta>
PbtA games rarely use discrete rounds---moves resolve fiction, not turns. Use `[COMBAT]` only for extended conflicts where tracking harm or threat levels adds value. Log moves with their names and results as normal.

```
[COMBAT]
[F:Gang×6|Threat 3|Close]

@ Seize by Force — throw myself into them
d: 2d6+2=9 -> 7–9 Weak Hit
=> I take definite harm: choose one of their tags.
[PC:Alex|harm-1] [F:Gang×6|Threat-1|Threat 2]

[/COMBAT]
```

#pagebreak()
== Best Practices
<best-practices>
#strong[Do: Scale notation to encounter complexity]

```
✔ Simple fight:
@ Slash at the guard
d: d20+4=15 vs AC 12 -> Hit, 1d8=5
=> He drops. Clear.

✔ Complex fight:
S5 *Warehouse ambush* [COMBAT]
[F:Captain|HP 10|Close] [F:Guard×2|HP 4 each|Medium]
R1
@ Charge at Captain...
```

#strong[Don't: Over-engineer simple encounters]

```
✗ [COMBAT]
  R1 Roster: [PC:Alex|HP 10] [F:Guard|HP 4|Close|armed|alert]
  @ Attack Guard
  d: d20+4=15 vs AC 10 -> Hit
  => [F:Guard|HP-6|dead]
  [/COMBAT]

✔ @ Cut down the lone guard before he can shout.
  d: d20+4=15 -> Hit, 6 dmg. Dead.
```

#strong[Do: Use `@(Name)` for all non-PC actors]

```
✔ @(Thug B) Flanks me
  d: d20+3=17 vs AC 15 -> Hit, 1d6=4
  => [PC:Alex|HP-4]

✔ @(Jordan) Returns fire
  d: d20+3=14 vs AC 11 -> Hit
  => [F:Pirate 1|dead]
```

#strong[Don't: Invent new symbols for enemy actions]

```
✗ ! Thug attacks: d20+3=17 -> Hit => PC HP-4
✗ >> Guard lunges: d20+2=12 -> Miss

✔ @(Thug) Attacks
  d: d20+3=17 -> Hit => [PC:Alex|HP-4]
```

#strong[Do: Update foe tags as stats change mid-encounter]

```
✔ [F:Captain|HP 10|Close]
  ...after 7 damage...
  [F:Captain|HP 3|staggered]
```

#strong[Don't: Reconstruct state retroactively]

```
✗ (Five rounds with no intermediate updates)
  => Captain is at HP 3 somehow.

✔ Track changes in-round: [F:Captain|HP-7|HP 3|staggered]
```

#strong[Do: Write aftermath as narrative, not just tags]

```
✔ [/COMBAT]
  => Two pirates dead, one fled, the captain escaped by sea.
  Jordan is wounded but walking. I have questions about that ship.
  [N:Jordan|wounded|HP 4] [Thread:Pirate Captain's Revenge|Open]
```

#strong[Don't: End combat with only tag updates]

```
✗ [/COMBAT]
  [N:Jordan|wounded|HP 4]
  [PC:Alex|HP 5]
```

#pagebreak()
== Quick Reference
<quick-reference>
=== New Tags
<new-tags>
#table(
  columns: (21.74%, 39.13%, 39.13%),
  align: (auto,auto,auto,),
  table.header([Tag], [Purpose], [Example],),
  table.hline(),
  [`[F:Name\|stats]`], [Track individual combatant state], [`[F:Thug A\|HP 6\|Close\|armed]`],
  [`[F:Name×#\|stats]`], [Track a group of identical combatants], [`[F:Goblin×3\|HP 3 each\|Close]`],
  [`[F:Name\|HP-#]`], [Inline damage shorthand], [`[F:Thug A\|HP-3]`],
  [`[F:Name\|dead]`], [Mark a combatant as eliminated], [`[F:Thug A\|dead]`],
  [`[F:Name\|fled]`], [Mark a combatant as escaped], [`[F:Captain\|fled]`],
)
=== Structural Blocks
<structural-blocks>
#table(
  columns: (22.58%, 35.48%, 41.94%),
  align: (auto,auto,auto,),
  table.header([Block], [Opens When], [Closes When],),
  table.hline(),
  [`[COMBAT]`], [Initiative is declared or combat begins], [All combatants are resolved or combat ends],
  [`[/COMBAT]`], [---], [Closes the open `[COMBAT]` block],
)
=== Conventions
<conventions>
#table(
  columns: (41.38%, 27.59%, 31.03%),
  align: (auto,auto,auto,),
  table.header([Convention], [Format], [Example],),
  table.hline(),
  [Round marker], [`R#`], [`R1`, `R2`, `R3`],
  [Actor prefix], [`@(Name) Action`], [`@(Thug A) Slash at PC`],
  [Movement], [`[Range->Range]`], [`[Far->Close]`],
  [Round roster], [`R# Roster: [tags]`], [`R3 Roster: [PC:HP 3] [F:Boss\|HP 4]`],
  [Initiative note], [`R1 (Init: Name #, …)`], [`R1 (Init: Captain 18, Alex 15)`],
)
=== Complete Example
<complete-example>
```
S9 *Dockside ambush* [COMBAT]
[PC:Alex|HP 12] [N:Jordan|ally|HP 8] [F:Pirate Captain|HP 10|Close] [F:Pirate×2|HP 4|Medium]

R1
@ Slash Captain d:19≥13 Hit 7dmg => [F:Captain|HP 3|staggered]
@(Captain) Desperate swing d:11≥14 Miss
@(Jordan) Fires at Pirate d:16≥11 Hit => [F:Pirate×1|dead]
@(Pirate) Drops crossbow, flees => [F:Pirate×1|fled]

[/COMBAT]
=> Captain fled by sea. Jordan wounded. Two pirates down.
[N:Jordan|wounded|HP 4] [Thread:Pirate Captain's Revenge|Open]
```

#pagebreak()
== FAQ
<faq>
#strong[Q: When should I use this add-on instead of core notation?] A: When combat lasts three or more rounds, when multiple combatants act each round, or when turn order and position matter to the story. For single-roll fights, core notation is sufficient.

#strong[Q: Should I track initiative order?] A: Only if your system uses it and it matters. Most solo players go in logical order (threats first, then PC, then allies) or follow their system's rules. To note it: `R1 (Init: Captain 18, Alex 15, Jordan 12, Pirates 8)`.

#strong[Q: Do I need `[F:]` tags, or can I just use `[N:]`?] A: Either works. `[F:]` is a convenience for separating combat stats from narrative NPC tags---it keeps your NPC index cleaner in long campaigns. For simple fights, `[N:]` is fine.

#strong[Q: What about reactions, interrupts, or out-of-turn actions?] A: Log them where they happen with a parenthetical note: `@(Alex) Riposte (reaction)` or `@ Opportunity attack (interrupt)`.

#strong[Q: How do I handle area effects or multi-target attacks?] A: List the targets and roll for each, or roll once and apply to all:

```
@ Fireball targeting Goblin×3
d: 8d6=28, DC 14 Dex save
d: Goblin 1: 12≤14 Fail, Goblin 2: 17≥14 Success, Goblin 3: 8≤14 Fail
=> Two goblins incinerated. One dodged, half damage. [F:Goblin×1|HP 2|singed]
```

#strong[Q: What about vehicle combat, chase scenes, or mass battles?] A: This add-on covers personal-scale combat. Those scenarios may warrant their own add-ons---but the principles here (round markers, actor prefixes, position tracking) will apply.

#strong[Q: How does this work in an analog notebook?] A: Use `--- COMBAT ---` and `--- END COMBAT ---` as delimiters. Round markers (`R1`, `R2`) work as-is. For foe tags, write them in the margin or in a column beside the round text. Update HP with strikethroughs: #strike[HP 6] HP 3.

#strong[Q: When should I use round rosters?] A: When you have five or more combatants and stats are changing fast enough that you'd lose track without a summary. For smaller fights, tracking changes inline with foe tags is sufficient.

#pagebreak()
== Credits & License
<credits-license>
© 2026 Roberto Bisceglie

This add-on extends #link("https://zeruhur.itch.io/lonelog")[Lonelog] by Roberto Bisceglie.

Written to address clarifications raised by u/Electorcountdonut, built upon examples contributed by u/AvernusIsAFurnace.

#strong[Version History:]

- v 1.0.0: First version

This work is licensed under the #strong[Creative Commons Attribution-ShareAlike 4.0 International License];.

You are free to share and adapt this material, provided you give appropriate credit and distribute adaptations under the same license. Session logs and play records created using this add-on's notation are your own work and are not subject to this license.
