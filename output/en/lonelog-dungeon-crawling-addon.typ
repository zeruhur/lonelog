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
  title: "Lonelog: Dungeon Crawling Add-on",
  subtitle: "Optional Room Tracking for Dungeon Exploration",
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

= Dungeon Crawling Add-on
<dungeon-crawling-add-on>
== Overview
<overview>
Lonelog was built for narrative-driven solo play---the kind where you care more about #emph[what happened and why] than #emph[where am I and what do I have left];. Dungeon crawling pulls in a different direction: spatial relationships matter, rooms accumulate state, and you're constantly asking "did I already loot that chest?"

That tension is real. Text notation is never going to replace a good map. But it #emph[can] help you track #strong[room state];---what you found, what you cleared, what's still waiting behind a locked door---alongside the narrative Lonelog already handles well.

This add-on introduces one new persistent element: the Room tag `[R:]`. That's it. Everything else---actions, rolls, oracle questions, consequences, threads, clocks---stays exactly the same. You're adding rooms to the vocabulary of things Lonelog can track.

If the dungeon is more narrative backdrop than mechanical challenge, or if you're moving through spaces quickly without tracking state, stick with core Lonelog. The `[L:]` location tag handles simple spatial context fine. This add-on earns its keep when rooms have meaningful state that changes over time.

#pagebreak()
=== What This Add-on Adds
<what-this-add-on-adds>
#table(
  columns: (35.71%, 32.14%, 32.14%),
  align: (auto,auto,auto,),
  table.header([Addition], [Purpose], [Example],),
  table.hline(),
  [`[R:ID\|status]`], [Track a room's current exploration state], [`[R:3\|cleared]`],
  [`[R:ID\|status\|desc]`], [Room tag with optional description], [`[R:3\|cleared\|library]`],
  [`exits DIR:ID`], [Record connections between rooms (optional)], [`exits N:R2, E:R3`],
  [`[#R:ID]`], [Reference a previously established room], [`[#R:3]`],
  [`[DUNGEON STATUS]` / `[/DUNGEON STATUS]`], [Session-opening snapshot of all room states], [Multiple `[R:]` tags grouped],
)
#strong[No new core symbols.] This add-on introduces no additions to `@`, `?`, `d:`, `->`, or `=>`.

#pagebreak()
=== Design Principles
<design-principles>
#strong[State over space.] A map handles spatial relationships better than text ever will. Room tags track what #emph[changed];---cleared, looted, locked---not where rooms sit relative to each other. Use the right tool for each job.

#strong[Minimal vocabulary.] One new tag covers the entire add-on. Every other element---scene headers, oracle questions, consequences, clocks---uses the core notation you already know. The cognitive overhead of adding dungeon crawling to a Lonelog session is one tag format.

#strong[Map-friendly by design.] Room tags are built to work alongside a visual map, not replace one. Room IDs connect your log to your map. Mark them on graph paper; reference the same IDs in your tags. The two systems reinforce each other.

#strong[Block tags follow the core convention.] Structural blocks use `[BLOCK]` / `[/BLOCK]` bracket syntax --- identical to `[COMBAT]` / `[/COMBAT]` in the Combat Add-on. For analog notebooks, use `--- BLOCK ---` / `--- END BLOCK ---` dashed separators instead.

#pagebreak()
== 1. The Room Tag
<the-room-tag>
The Room tag `[R:]` tracks a room's current state. It works like any other Lonelog persistent element: you tag it when something changes, update it as the situation evolves, and reference it later.

#strong[Format:]

```
[R:ID|status|description|exits DIR:ID, DIR:ID]
```

#strong[Fields:]

- `ID` --- unique identifier for the room, typically a number (`1`, `2`, `3`) matching your map
- `status` --- current exploration state (see below)
- `description` --- optional brief label to jog your memory
- `exits` --- optional connections to adjacent rooms

==== 1.1 Room Status
<room-status>
Status tells you the current state of a room at a glance. Use whatever terms fit your game:

```
[R:1|unexplored]          Haven't entered yet
[R:1|active]              Currently exploring
[R:1|cleared]             Enemies defeated or threats resolved
[R:1|cleared, looted]     Cleared and treasure taken
[R:1|locked]              Can't get in yet
[R:1|trapped]             Known hazard present
[R:1|safe]                Verified clear, usable as refuge
[R:1|collapsed]           No longer accessible
```

Combine statuses when it makes sense: `cleared, looted` tells you both that the fight is over #emph[and] there's nothing left to grab.

#strong[Example --- minimal:]

```
[R:4|active]
```

#strong[Example --- expanded:]

```
S5 *North corridor*

@ Open the door carefully
? Is it locked?
-> No (d6=5)
=> The door swings open easily.

[R:4|active|storage room, dusty shelves|exits S:R2, E:R5]

@ Search the shelves
d: Investigation d6=5 vs TN 4 -> Success
=> I find a rusty key behind a loose brick.
(note: might open R5?)

? Are there enemies?
-> No, and... (d6=6)
=> The room is completely undisturbed. Years of dust.

[R:4|cleared, looted]
```

==== 1.2 Updating Room Status
<updating-room-status>
When a room's state changes, restate the tag with the new status:

```
[R:1|unexplored]

... you enter and fight ...

[R:1|cleared]

... you search ...

[R:1|cleared, looted]
```

Or use inline shorthand for a single status addition:

```
[R:1|+looted]
```

==== 1.3 Room Descriptions
<room-descriptions>
The description field is optional and brief---just enough to jog your memory:

```
[R:1|cleared|guard room]
[R:2|active|library, candles still lit]
[R:3|unexplored|sounds of water]
```

For richer descriptions, use regular Lonelog narrative after the tag:

```
[R:4|active|ritual chamber]
=> The air hums with energy. A circle of runes glows faintly on the floor.
```

==== 1.4 Reference Tags
<reference-tags>
Use `#` to reference a room you've already described, exactly as with NPCs and locations in core Lonelog:

```
[R:3|cleared|armory|exits N:R2, W:R4]    (first mention)

... later ...

[#R:3]                                    (reference back to it)
```

#pagebreak()
== 2. Room Connections
<room-connections>
To record which rooms connect where, use the `exits` keyword inside the tag:

```
[R:1|cleared|guard room|exits N:R2, E:R3, S:R4]
```

Read this as: "Room 1 is cleared, it's a guard room, with exits north to Room 2, east to Room 3, and south to Room 4."

#strong[Directional shortcuts:] `N`, `S`, `E`, `W`, `NE`, `NW`, `SE`, `SW`, `U` (up), `D` (down).

If direction doesn't matter, just list the connections:

```
[R:5|unexplored|exits R4, R6, R7]
```

#strong[You don't have to record exits at all.] If you're keeping a visual map, the exits live there and you only need the Room tag for status. The `exits` keyword is for when you want a fully text-based record, or when you discover a specific connection mid-play:

```
=> I find a hidden passage behind the bookshelf!
[R:3|exits E:R7(secret)]
```

#strong[Example --- minimal:]

```
[R:6|unexplored|exits R5, R8]
```

#strong[Example --- expanded:]

```
@ Check the far wall for exits
d: Perception d6=6 vs TN 4 -> Success
=> A concealed door—well-disguised but not locked.
[R:6|active|crypt|exits W:R5, N:R8, E:R9(secret)]
(note: update map with R9)
```

#pagebreak()
== 3. The Dungeon Status Block
<the-dungeon-status-block>
When you sit down for a new session mid-dungeon, you need a snapshot: which rooms are cleared, where haven't you been, what's still locked. The #strong[Dungeon Status Block] gives you that at a glance.

#strong[Format:]

```
[DUNGEON STATUS]
[R:1|status|description]
[R:2|status|description]
...
[/DUNGEON STATUS]
```

#strong[When to open a block:] At the top of a session when resuming a dungeon crawl, before your first scene.

#strong[When to update it:] At session end, or at the start of the next session, to reflect what changed.

#strong[Example --- digital:]

```
[DUNGEON STATUS]
[R:1|cleared, looted|entry cave|exits N:R2, E:R3]
[R:2|cleared|guard room|exits S:R1, W:R5]
[R:3|active|library|exits W:R1]
[R:4|unexplored]
[R:5|locked|heavy door|exits E:R2]
[/DUNGEON STATUS]
```

#strong[Example --- analog:]

```
=== Session 3: The Orc Warren ===
[Date]        2025-10-15
[Duration]    1h30
[Recap]       Found the warren entrance. Need to recover the stolen relic.

--- DUNGEON STATUS ---
R1: cleared, looted (entry cave)
R2: cleared (guard room)
R3: active (library)
R4: unexplored
R5: locked (heavy door)
--- END STATUS ---
```

#strong[This is a convenience, not a requirement.] If your dungeon has three rooms, you don't need a status block---just tag rooms as you go. For larger dungeons, or when picking up a session after a break, it's a quick way to orient yourself.

#pagebreak()
== 4. Room Tags in Play
<room-tags-in-play>
==== 4.1 Rooms as Scene Headers
<rooms-as-scene-headers>
Use a Room tag directly in your scene header for compact context:

```
S5 [R:4|active] *Storage room, dusty shelves*
```

This tells you exactly where the scene takes place without a separate tag line. Some players prefer this to separate scene descriptions and room tags.

==== 4.2 Generated Dungeons
<generated-dungeons>
If you're generating the dungeon as you go (using random tables or an oracle), record the generation alongside the Room tag:

```
@ Open the east door
tbl: d20=14 -> "Large room, two exits"

? What's inside?
tbl: d100=67 -> "Library with a trapped chest"

[R:6|active|library, trapped chest|exits W:R3, N:R7]
```

The generation rolls tell you #emph[how] you discovered the room. The Room tag tells you #emph[what it is now];.

==== 4.3 Maps and Lonelog
<maps-and-lonelog>
Let's be direct: #strong[a visual map is almost always better than text for spatial relationships.] Graph paper, a digital tool, a quick sketch on a napkin---whatever works. The Room tag's job isn't to replace your map. It's to track state that a map handles poorly: whether a room is cleared, what you found there, how its status changed over play.

The recommended split:

- #strong[Map] handles layout, spatial relationships, and navigation
- #strong[Room tags] handle state, status changes, and narrative context
- #strong[Core Lonelog] handles everything else (actions, rolls, consequences, story)

Mark room numbers on your map. Use those same numbers in your Room tags. Your map and your log now reference each other seamlessly:

```
S7 [R:4] *Checking the altar*

@ Search the altar
d: Investigation d6=6 vs TN 4 -> Success
=> Secret compartment! [Thread:Cult Ritual|Open]
[R:4|cleared, looted]

(note: mark R4 as cleared on map)
```

If you want a #strong[fully text-based] dungeon log with no separate map, the `exits` keyword lets you reconstruct the layout from your notes. But this is the exception, not the recommendation.

#pagebreak()
== Cross-Add-on Interactions
<cross-add-on-interactions>
#table(
  columns: (26.19%, 35.71%, 38.1%),
  align: (auto,auto,auto,),
  table.header([Situation], [Add-on(s) Used], [Key Tags/Blocks],),
  table.hline(),
  [Combat breaks out in a room], [Dungeon Crawling + Combat], [`[R:]`, `[COMBAT]`, `[F:]`],
  [Tracking torches and rations per room], [Dungeon Crawling + Resource Tracking], [`[R:]`, `[Inv:Name\|#]`],
  [Combat while tracking resources], [All three add-ons], [`[R:]`, `[COMBAT]`, `[Inv:]`],
)
#strong[Combined example --- Dungeon Crawling + Combat:]

```
S6 *Approaching the barracks*

@ Move quietly down the corridor
d: Stealth d6=4 vs TN 4 -> Success
=> I creep forward unseen.

[R:5|active|barracks, stench of sweat|exits S:R3, W:R6, N:R7]

? How many guards?
tbl: d6=3 -> "Three enemies"
=> Two eating, one sharpening a blade.

[COMBAT]
[PC:Alex|HP 12|Engaged]
[F:Guard 1|HP 5|Close|eating]
[F:Guard 2|HP 5|Close|eating]
[F:Guard 3|HP 5|Close|alert]

@ Ambush the alert guard first
d: d20+4=18 vs AC 12 -> Hit, 1d8=7
=> [F:Guard 3|dead]

@(Guard 1) Grabs weapon and charges
d: d20+3=11 vs AC 14 -> Miss

R2
@ Sweep at both remaining guards
d: d20+4=15 vs AC 12 -> Hit, 1d8=5 => [F:Guard 1|dead]
d: d20+4=12 vs AC 12 -> Hit, 1d8=3 => [F:Guard 2|dead]

[/COMBAT]
=> Room clear before they could raise an alarm.
[R:5|cleared]

@ Search the barracks
tbl: d20=8 -> "Rations and a crude map"
=> A rough map scratched on hide. Shows rooms to the west!
[R:5|cleared, looted]
[R:6|unexplored|marked on orc map]
(note: update my map with R6)
```

#pagebreak()
== System Adaptations
<system-adaptations>
=== OSR Systems (Old School Essentials, Basic/Expert D&D)
<osr-systems-old-school-essentials-basicexpert-dd>
Classic dungeon crawl procedures map naturally to this add-on. Turn-based exploration, wandering monster checks, and the six-minute turn structure all generate natural tag update points. Use Room tags at the end of each turn or when something significant changes.

```
[DUNGEON STATUS]
[R:1|cleared, looted|entry hall|exits N:R2, E:R3]
[R:2|cleared|guard room|exits S:R1, W:R5]
[R:3|active|crypt|exits W:R1, D:R8]
[/DUNGEON STATUS]

S4 *R3 – Crypt, turn 3*

@ Search the sarcophagi
d: 1-in-6 secret door check: d6=2 -> None found
? Wandering monster check
-> No (d6=5)

@ Light the wall sconces and examine the inscriptions
d: INT check d20=8 vs DC 12 -> Fail
=> The script is too archaic—I can't make sense of it.
[R:3|cleared]
(note: torch supply -1 for this turn)
```

=== Ironsworn / Starforged
<ironsworn-starforged>
Ironsworn's Delve mechanic uses themed sectors rather than numbered rooms. Map sectors to Room IDs and use the `Delve the Depths` move result to determine what you find. Progress tracks work naturally alongside Room status.

```
[Track:Iron Barrow|Progress 2/10]

[DUNGEON STATUS]
[R:1|cleared|Threshold – rusted gate|exits N:R2]
[R:2|active|Shadow – collapsed corridor]
[/DUNGEON STATUS]

@ Delve the Depths (Shadow theme)
d: d6+2=7 vs d10=4, d10=9 -> Weak Hit
tbl: Shadow Feature: d100=44 -> "Symbols of a forsaken god"
=> I find ritual markings. Progress, but at a cost.
[Track:Iron Barrow|Progress+2|4/10]
[R:2|cleared|Shadow – forsaken markings|exits N:R3]
[R:3|unexplored]
[Thread:The Forsaken God|Open]
```

=== Dungeon World (PbtA)
<dungeon-world-pbta>
Dungeon World generates dungeon content through fictional framing and GM moves rather than room-by-room procedure. Use Room tags loosely---tag significant locations as you discover them, without worrying about exhaustive status tracking.

```
@ Discern Realities as I enter the chamber
d: 2d6+1=10 -> 10+ Hit: ask three questions

? What here is useful or valuable?
=> A sealed chest on the altar dais.
? What is about to happen?
=> The shadows in the corner are moving.
? Who made this place?
=> Cult sigils everywhere—same as the ones on the road.

[R:4|active|ritual chamber, living shadows]
[Thread:The Cult's Purpose|Open]
```

#pagebreak()
== Best Practices
<best-practices>
#strong[Do: Use Room tags for state, your map for space]

```
✔ [R:4|cleared, looted]
  (note: mark R4 cleared on map)
```

#strong[Don't: Try to replace your map with exit chains]

```
✗ [R:1|cleared|exits N:R2, E:R3]
  [R:2|cleared|exits S:R1, N:R4, E:R5]
  [R:3|active|exits W:R1, N:R6, E:R7, SE:R8]
  (This is harder to navigate than a sketch)

✔ Draw the map. Use Room tags only for state.
```

#strong[Do: Update status immediately when it changes]

```
✔ @ Search the room after the fight
  d: Investigation d6=5 vs TN 4 -> Success
  => I find a key and some coin.
  [R:3|cleared, looted]
```

#strong[Don't: Leave status ambiguous and reconstruct later]

```
✗ (Three scenes of exploration with no tag updates)
  (note: I think R3 and R4 are cleared? need to check)

✔ Tag each change as it happens.
```

#strong[Do: Open a Dungeon Status Block when resuming a session]

```
✔ === Session 4 ===
  [DUNGEON STATUS]
  [R:1|cleared, looted|entry]
  [R:2|cleared|barracks]
  [R:3|unexplored]
  [R:4|locked|iron door]
  [/DUNGEON STATUS]
```

#strong[Don't: Reconstruct dungeon state by scanning the whole log]

```
✗ (Scrolling back through two sessions of notes to figure out
   which rooms are cleared)

✔ Write the status block at session end. Start the next session
  with a current picture.
```

#strong[Do: Keep descriptions brief in the tag, expand in prose]

```
✔ [R:7|active|throne room]
  => The ceiling is forty feet high. A cracked obsidian throne
  dominates the far wall. Something has nested in it recently.
```

#strong[Don't: Overload the tag with narrative detail]

```
✗ [R:7|active|massive vaulted throne room, cracked obsidian throne
   on a raised dais, old nesting material and bones, forty-foot ceiling,
   faded tapestries depicting a forgotten dynasty, cold draft from the north]
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
  [`[R:ID\|status]`], [Room with status only], [`[R:3\|cleared]`],
  [`[R:ID\|status\|desc]`], [Room with description], [`[R:3\|cleared\|library]`],
  [`[R:ID\|status\|desc\|exits]`], [Room with connections], [`[R:3\|cleared\|library\|exits W:R1]`],
  [`[R:ID\|+status]`], [Add a status inline], [`[R:3\|+looted]`],
  [`[#R:ID]`], [Reference an established room], [`[#R:3]`],
)
=== Status Terms
<status-terms>
#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Status], [Meaning],),
  table.hline(),
  [`unexplored`], [Haven't entered yet],
  [`active`], [Currently exploring],
  [`cleared`], [Threats resolved],
  [`cleared, looted`], [Cleared and searched],
  [`locked`], [Cannot enter yet],
  [`trapped`], [Known hazard present],
  [`safe`], [Verified clear, usable as refuge],
  [`collapsed`], [No longer accessible],
)
=== Structural Blocks
<structural-blocks>
#table(
  columns: (22.58%, 35.48%, 41.94%),
  align: (auto,auto,auto,),
  table.header([Block], [Opens When], [Closes When],),
  table.hline(),
  [`[DUNGEON STATUS]` / `[/DUNGEON STATUS]`], [Session start when resuming a dungeon], [Replaced by updated block next session],
)
=== Directional Shortcuts
<directional-shortcuts>
`N` `S` `E` `W` `NE` `NW` `SE` `SW` `U` (up) `D` (down)

=== Complete Example
<complete-example>
```
[DUNGEON STATUS]
[R:1|cleared, looted|entry cave|exits N:R2, E:R3]
[R:2|unexplored] [R:3|unexplored]
[/DUNGEON STATUS]

S7 *North passage*

@ Approach R2 quietly
d: Stealth d6=4 vs TN 4 -> Success

[R:2|active|barracks|exits S:R1, W:R4]
? Enemies? -> Yes (d6=2) => Two guards, armed.
...combat...
[R:2|cleared, looted]
[R:4|unexplored|marked on guard's map]
```

#pagebreak()
== FAQ
<faq>
#strong[Q: Do I need a separate map, or can I use exits to track layout?] A: A visual map is almost always better for layout and navigation. Use exits in your Room tags only when you want a fully text-based record, or when you discover a specific connection (like a secret door) that's worth noting in the log. For everything else, draw the map.

#strong[Q: What Room ID system should I use?] A: Numbers are simplest (`R1`, `R2`, `R3`) and match naturally to a numbered map. You can also use codes that reflect structure (`R1-A`, `R1-B` for sub-rooms, or `L1-1`, `L1-2` for level-and-room). Use whatever helps you connect tags to your map at a glance.

#strong[Q: Can I use this alongside the Combat Add-on?] A: Yes---they're designed to work together. When combat breaks out in a room, open a `[COMBAT]` block inside the scene. When it ends, close it and update the Room tag status. The Cross-Add-on Interactions section has a full example.

#strong[Q: What if I'm using a published dungeon with its own room numbering?] A: Use the published room numbers as your IDs. `[R:12|cleared|Goblin Warrens p.4]` works perfectly---the published map handles layout, the tag handles state.

#strong[Q: How does the Dungeon Status Block work in an analog notebook?] A: Write it with dashed separators: `--- DUNGEON STATUS ---`. List one room per line with status and a brief label. Cross out or update entries as rooms change. At the start of each new session, write a fresh status block with current information rather than patching the old one.

#strong[Q: Do I need to tag every room I pass through?] A: Only rooms where something worth tracking happens. If you walk through an empty corridor, you don't need a tag---just describe it in prose. Tag rooms when their status has meaning: when you clear them, find something, lock them, or need to return later.

#strong[Q: What about dungeon features that aren't rooms---corridors, traps, doors?] A: Use core Lonelog notation. Doors and traps are events (`[E:]`) or temporary context in prose. Corridors usually don't need persistent tracking. The Room tag is specifically for spaces with ongoing state that matters across multiple scenes or sessions.

#pagebreak()
== Credits & License
<credits-license>
© 2025 Roberto Bisceglie

This add-on extends #link("https://zeruhur.itch.io/lonelog")[Lonelog] by Roberto Bisceglie.

Written to address the #link("https://www.reddit.com/r/Solo_Roleplaying/comments/1qxkee5/comment/o4v01rk/")[request] of u/Jollto13 on r/Solo\_Roleplaying.

#strong[Version History:]

- v 1.1.0: Block tags unified with `[BLOCK]`/`[/BLOCK]` convention; design principles updated
- v 1.0.0: Rewritten as a compliant add-on (previously "Dungeon Crawling Module")

This work is licensed under the #strong[Creative Commons Attribution-ShareAlike 4.0 International License];.

You are free to share and adapt this material, provided you give appropriate credit and distribute adaptations under the same license. Session logs and play records created using this add-on's notation are your own work and are not subject to this license.
