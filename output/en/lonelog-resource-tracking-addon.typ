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
  title: "Lonelog: Resource Tracking Add-on",
  subtitle: "Inventory, Supplies, and Wealth Notation",
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

= Resource Tracking Add-on
<resource-tracking-add-on>
== Overview
<overview>
Some games don't care what's in your pack. Others treat every torch, every ration, every last arrow as a decision that matters. This add-on is for the second kind.

Core Lonelog already handles light resource tracking --- you can put `Gear:Flashlight,Notebook` inside a `[PC:]` tag and call it a day. That works fine when resources are flavor. But when your game makes resource management a #emph[mechanic] --- when running out of torches in a dungeon means something, when the Usage Die ticking down creates real tension, when you need to know exactly how many silver pieces you have left --- you need more structure.

That's what this add-on provides: a dedicated notation layer for tracking resources as they flow in and out of your game.

If your system handwaves supplies or resolves resource scarcity with a single oracle question, you don't need this add-on. Core Lonelog's `[PC:]` tag with a `Gear:` field is more than enough.

#pagebreak()
=== What This Add-on Adds
<what-this-add-on-adds>
#table(
  columns: (35.71%, 32.14%, 32.14%),
  align: (auto,auto,auto,),
  table.header([Addition], [Purpose], [Example],),
  table.hline(),
  [`[Inv:Item\|qty\|props]`], [Track individual items with quantity and properties], [`[Inv:Torch\|3]`],
  [Supply notation], [Abstract resource levels inside `[PC:]`], [`[PC:Kael\|Supply d8]`],
  [`[Wealth:Currency N]`], [Currency and trade tracking], [`[Wealth:Gold 45\|Silver 12]`],
  [`[RESOURCES]` / `[/RESOURCES]` block], [Snapshot of current resources at session boundaries], [See §5],
)
#strong[No new core symbols.] This add-on introduces no additions to `@`, `?`, `d:`, `->`, or `=>`.

#pagebreak()
=== Design Principles
<design-principles>
#strong[Track what the game tracks.] If your system uses Usage Dice, use the Usage Die notation. If it counts individual arrows, count individual arrows. If it handwaves supplies, don't invent tracking that isn't there.

#strong[Separate what you carry from who you are.] The `[PC:]` tag describes your character --- HP, stress, conditions, abstract resources that feel like stats. The `[Inv:]` tag describes your stuff --- concrete, countable things that come and go. This separation keeps both tags readable as your campaign grows.

#strong[Record changes at the point of fiction.] Don't maintain a separate inventory spreadsheet you update silently. Show resources changing #emph[when they change];, inline with the actions and consequences that cause it. Your log should tell the story of your resources, not just their current state.

#strong[Block tags follow the core convention.] Structural blocks use `[BLOCK]` / `[/BLOCK]` bracket syntax --- identical to `[COMBAT]` / `[/COMBAT]` in the Combat Add-on. For analog notebooks, use `--- BLOCK ---` / `--- END BLOCK ---` dashed separators instead.

#pagebreak()
== 1. The Inventory Tag
<the-inventory-tag>
The `[Inv:]` tag tracks a specific, concrete item or resource. It's the thing you can pick up, use, drop, trade, or lose.

#strong[Format:]

```
[Inv:Item|quantity|properties]
```

#strong[Fields:]

- `Item` --- the item name, unique enough to search for in a log
- `quantity` --- a plain number; omit for unique or singular items
- `properties` --- freeform; use for weight, condition, magical status, ammunition type, or anything else your game cares about

#strong[Examples:]

```
[Inv:Torch|3]
[Inv:Rope|1|50ft]
[Inv:Healing Potion|2|magical|restores d8 HP]
[Inv:Rations|5|days]
[Inv:Arrow|12]
```

#strong[Unique or singular items] (no quantity needed):

```
[Inv:Skeleton Key|unique]
[Inv:Father's Compass|quest]
[Inv:Map to the Ruins]
```

==== 1.1 Gaining Items
<gaining-items>
When you acquire something, introduce it with a full `[Inv:]` tag, just as you introduce an NPC with `[N:]`:

#strong[Example --- minimal:]

```
=> I find supplies! [Inv:Torch|4] [Inv:Rope|1|50ft] [Inv:Gold|25]
```

#strong[Example --- expanded:]

```
@ Search the chest
d: Investigation d6=5 vs TN 4 -> Success
=> Inside: torches, rope, some coin.
[Inv:Torch|4] [Inv:Rope|1|50ft] [Inv:Gold|25]

@ Loot the fallen guard
=> [Inv:Short Sword|1|rusty] [Inv:Rations|2|days]

tbl: d100=67 -> "A strange amulet"
=> [Inv:Bone Amulet|1|unknown|magical?]
```

#strong[Multiple items at once] --- list them; no special syntax needed:

```
=> The merchant's pack contains:
   [Inv:Torch|6] [Inv:Rope|2|50ft each] [Inv:Rations|10|days]
   [Inv:Flint & Steel|1] [Inv:Waterskin|1|full]
```

==== 1.2 Consuming and Losing Items
<consuming-and-losing-items>
Two approaches, same result --- choose what fits your flow.

#strong[Approach A: Inline with consequences]

Depletion happens inside the `=>` line, as part of the fiction:

```
=> The tunnel is pitch dark. I light a torch. [Inv:Torch|3→2]
=> I bandage the wound with my last healing potion. [Inv:Healing Potion|0|depleted]
=> Arrow flies true. [Inv:Arrow|12→11]
```

#strong[Approach B: Standalone update]

Depletion gets its own line, separate from narrative:

```
=> The tunnel is pitch dark. I light a torch.
[Inv:Torch-1]

=> I bandage the wound.
[Inv:Healing Potion-1]
```

#strong[Which to use?] Approach A is more compact and keeps resource flow visible within the fiction. Approach B is clearer when multiple things change at once, or when you want to visually separate narrative from bookkeeping. Many players mix both depending on context.

#strong[Shorthand for quantity changes:]

```
[Inv:Torch-1]         (consumed one)
[Inv:Torch+2]         (found two more)
[Inv:Torch|0]         (explicit: none left)
[Inv:Torch|3→1]       (explicit: was 3, now 1)
[Inv:Torch|depleted]  (out — marks the item as gone)
```

==== 1.3 Item State Changes
<item-state-changes>
Items don't just appear and disappear --- they break, get repaired, become cursed, run out of charges. Use properties to track this:

```
[Inv:Short Sword|1|rusty]              (initial state)
[Inv:Short Sword|1|rusty→repaired]     (state change with arrow)
[Inv:Short Sword|1|+enchanted]         (added property)
[Inv:Short Sword|1|-rusty|+sharpened]  (removed and added)
```

#strong[Condition shorthand:]

```
[Inv:Lantern|1|broken]
[Inv:Shield|1|cracked]
[Inv:Rations|3|spoiled]
[Inv:Wand|1|charges 2/5]
```

This mirrors the `+`/`-` convention already used for NPC status updates in core Lonelog.

==== 1.4 Reference Tags for Items
<reference-tags-for-items>
Just like NPCs, use `#` for items already established:

```
[Inv:Bone Amulet|1|unknown|magical?]   (first mention — full details)

... later in the log ...

@ Examine the amulet more closely
d: Arcana d6=6 vs TN 5 -> Success
=> [#Inv:Bone Amulet] — it's a ward against undead!
[Inv:Bone Amulet|1|Ward of the Dead|+identified]
```

==== 1.5 Grouped and Bulk Items
<grouped-and-bulk-items>
Some games track bundles rather than individual items. Use the `×` multiplier or descriptive grouping:

```
[Inv:Arrow×20]                    (bundle notation)
[Inv:Adventuring Kit|1|contains: rope, pitons, torch×2, rations×3]
[Inv:Quiver|1|Arrow×15]          (container with contents)
```

For slot-based inventory systems:

```
[Inv:Slot 1|Short Sword]
[Inv:Slot 2|Shield|cracked]
[Inv:Slot 3|Torch×3]
[Inv:Slot 4|empty]
```

#pagebreak()
== 2. Abstract Supply Tracking
<abstract-supply-tracking>
Not every game counts individual items. Many solo systems use abstract mechanics to represent "how well-supplied are you?"---Usage Dice (Black Hack, Macchiato Monsters), Supply tracks (Ironsworn), or simple qualitative levels. These feel more like character stats than inventory, so they live in the `[PC:]` tag alongside HP, Stress, and other abstract attributes.

==== 2.1 Usage Dice
<usage-dice>
The Usage Die is a staple of OSR-adjacent solo play. You have a die representing supply level---roll it when you use a resource. On a 1--2, the die steps down. When it steps below d4, the resource is gone.

#strong[Format:]

```
[PC:Kael|Supply d8]
[PC:Kael|Torchlight d6]
[PC:Kael|Ammo d10]
```

#strong[Example --- minimal:]

```
d: Supply d8=2 -> Step down!
=> [PC:Kael|Supply d8→d6]
```

#strong[Example --- expanded:]

```
@ Make camp, use supplies
d: Supply d8=2 -> Step down!
=> Supplies dwindling. [PC:Kael|Supply d8→d6]

@ Fire another volley
d: Ammo d6=1 -> Step down!
=> Running low on arrows. [PC:Kael|Ammo d6→d4]

@ Light another torch
d: Torchlight d4=2 -> Depleted!
=> Last torch sputters out. [PC:Kael|Torchlight depleted]
```

#strong[The step-down chain:] `d12 → d10 → d8 → d6 → d4 → depleted`

==== 2.2 Supply Tracks
<supply-tracks>
Some systems use numbered tracks for supply---similar to progress tracks but counting down as resources are spent.

#strong[Format:]

```
[PC:Kael|Supply 5/5]
```

#strong[Example --- minimal:]

```
=> I make camp and eat. [PC:Kael|Supply 5→4]
```

#strong[Example --- expanded:]

```
=> I make camp and eat. [PC:Kael|Supply 5→4]
=> I forage successfully. [PC:Kael|Supply 4→5]
=> Desperate — I eat the last of it. [PC:Kael|Supply 1→0|starving]
```

This is functionally the same as core Lonelog's `[Timer:]` used for resources. The difference is semantic: a Timer is a narrative pressure device, while a Supply track inside `[PC:]` is a character stat. Use whichever framing matches your game.

==== 2.3 Qualitative Levels
<qualitative-levels>
For games that don't use numbers at all --- or when you want to track a resource loosely:

```
[PC:Kael|Supplies:abundant]
[PC:Kael|Supplies:adequate]
[PC:Kael|Supplies:low]
[PC:Kael|Supplies:critical]
[PC:Kael|Supplies:depleted]
```

#strong[Updating:]

```
=> After three days in the wastes, food is scarce.
[PC:Kael|Supplies:abundant→low]
```

You can define your own levels. These aren't hard-coded --- use whatever vocabulary your game provides or that feels right.

#pagebreak()
== 3. Wealth and Currency
<wealth-and-currency>
Money behaves differently from gear. You don't usually track each coin as an "item" --- you track totals, and those totals change through spending, earning, looting, and trading.

==== 3.1 The Wealth Tag
<the-wealth-tag>
For games with concrete currency, use the `[Wealth:]` tag:

#strong[Format:]

```
[Wealth:Gold 45|Silver 12|Copper 30]
[Wealth:Credits 1500]
[Wealth:Caps 87]
```

#strong[Example --- minimal:]

```
=> Good price! [Wealth:Gold+15]
=> [Wealth:Gold-8] [Inv:Rations|5|days] [Inv:Rope|1|50ft]
```

#strong[Example --- expanded:]

```
@ Sell the jeweled dagger to the merchant
d: Persuasion d6=5 vs TN 4 -> Success
=> Good price! [Wealth:Gold+15]

@ Buy rations and a new rope
=> [Wealth:Gold-8] [Inv:Rations|5|days] [Inv:Rope|1|50ft]
```

#strong[Full state vs.~delta updates:]

```
[Wealth:Gold 45]       (explicit total)
[Wealth:Gold+15]       (earned 15)
[Wealth:Gold-8]        (spent 8)
[Wealth:Gold 45→52]    (was 45, now 52)
```

==== 3.2 Abstract Wealth
<abstract-wealth>
Some games don't count coins --- they use wealth levels or resource rolls:

```
[PC:Kael|Wealth:comfortable]
[PC:Kael|Wealth d8]               (Usage Die for wealth)
[PC:Kael|Resources 3/5]           (track-based)
```

These live in `[PC:]` rather than `[Wealth:]`, because abstract wealth feels more like a stat than a ledger.

==== 3.3 Trade and Barter
<trade-and-barter>
For transactions, record both sides:

```
@ Trade the amulet for passage
=> [Inv:Bone Amulet|depleted] -> [Thread:Passage to Northport|Open]

@ Barter rations for information
=> [Inv:Rations-2] The fisherman tells me about the sea caves.
```

No special syntax needed --- the existing consequence notation handles trades naturally. The key is recording #emph[what left] and #emph[what arrived];.

#pagebreak()
== 4. Resource Events
<resource-events>
Resources interact with the rest of your game. These patterns show how resources connect to actions, oracle questions, and ongoing pressures.

==== 4.1 Resource Checks
<resource-checks>
When the game asks "do you have enough?":

```
@ Cross the frozen river
? Do I have enough rope?
-> Yes (checking: [#Inv:Rope] 50ft — river is ~30ft wide)
=> I anchor the rope and cross safely. [Inv:Rope|1|50ft|frayed]

@ Camp in the wilderness
d: Supply d8=1 -> Step down!
=> Food's running low. [PC:Kael|Supply d8→d6]
? Do I find water nearby?
-> No, but...
=> A dry streambed — if I follow it, maybe tomorrow.
[Timer:Dehydration 2]
```

==== 4.2 Scarcity as Oracle Modifier
<scarcity-as-oracle-modifier>
Some systems modify oracle likelihood based on resource state. Note it:

```
? Can I find more arrows in the ruins? (Likelihood: Unlikely — remote area)
-> Yes, but... (d6=4)
=> I find a quiver with only 3 usable arrows. [Inv:Arrow+3]

? Is there food in this abandoned camp? (Likelihood: Very Unlikely — old camp)
-> No, and... (d6=1)
=> The food is rotted and the smell attracts something. [Clock:Predator 1/4]
```

==== 4.3 Resources in Combat
<resources-in-combat>
When the Combat Add-on is in use, resource consumption integrates naturally:

```
[COMBAT]
R1
@ Fire bow at Orc 1
d: Ranged d6=5 vs TN 4 -> Success
=> Arrow hits! [F:Orc 1|HP-3] [Inv:Arrow-1]

R2
@ Throw last flask of oil
d: Ranged d6=3 vs TN 4 -> Fail
=> Missed! The oil splatters uselessly. [Inv:Oil Flask|depleted]
[/COMBAT]
```

==== 4.4 Resources in Dungeon Crawling
<resources-in-dungeon-crawling>
When the Dungeon Crawling Add-on is in use, resource depletion tracks alongside room exploration:

```
[R:4|active|Fungal cavern|exits E:R5, W:R2]

@ Navigate the cavern carefully
d: Survival d6=4 vs TN 4 -> Success
=> I find a path through. Torch is getting low.
[Inv:Torch|2→1] [Timer:Torchlight 3]

@ Search for useful fungi
tbl: d6=5 -> "Glowing moss — edible"
=> [Inv:Edible Moss|3|restores 1 HP each]
[R:4|cleared, looted]
```

#pagebreak()
== 5. The Resource Status Block
<the-resource-status-block>
For long sessions or campaigns where resources matter, a snapshot at session boundaries helps you pick up where you left off.

#strong[Format:]

```
[RESOURCES]
[PC:Name|stats]
[Wealth:currencies]
[Inv:items...]
[/RESOURCES]
```

#strong[Example --- digital:]

```
[RESOURCES]
[PC:Kael|HP 12/15|Supply d6|Stress 2]
[Wealth:Gold 52|Silver 8]
[Inv:Short Sword|1|sharpened]
[Inv:Shield|1|cracked]
[Inv:Torch|2]
[Inv:Rations|3|days]
[Inv:Rope|1|50ft|frayed]
[Inv:Healing Potion|1|restores d8 HP]
[Inv:Arrow|9]
[Inv:Bone Amulet|1|Ward of the Dead]
[/RESOURCES]
```

#strong[Example --- analog:]

```
--- RESOURCES ---
PC:  Kael | HP 12/15 | Supply d6 | Stress 2
Wealth: Gold 52 | Silver 8
Inv: Short Sword (sharpened), Shield (cracked)
     Torch ×2, Rations ×3 days
     Rope 50ft (frayed), Healing Potion ×1
     Arrow ×9, Bone Amulet (Ward of the Dead)
--- END RESOURCES ---
```

#strong[When to use it:]

- At the #strong[end of a session] to freeze state
- At the #strong[start of next session] as a recap
- #strong[Before a major expedition] (dungeon dive, long journey, dangerous mission)
- After #strong[significant loot or loss] --- a natural checkpoint

#strong[When to skip it:]

- Resources aren't mechanically important in your game
- The session is short and changes are minimal
- You can reconstruct state easily from the log

#pagebreak()
== Cross-Add-on Interactions
<cross-add-on-interactions>
#table(
  columns: (26.19%, 35.71%, 38.1%),
  align: (auto,auto,auto,),
  table.header([Situation], [Add-on(s) Used], [Key Tags/Blocks],),
  table.hline(),
  [Dungeon exploration with supply pressure], [Dungeon Crawling + Resource Tracking], [`[R:]`, `[Inv:]`, `[Timer:]`],
  [Combat with ammunition tracking], [Combat + Resource Tracking], [`[F:]`, `[COMBAT]`, `[Inv:]`],
  [Trading in a settlement], [Resource Tracking only], [`[Inv:]`, `[Wealth:]`, `[N:]`],
  [Full dungeon crawl with fights], [All three add-ons], [`[R:]`, `[COMBAT]`, `[Inv:]`, `[Wealth:]`],
)
#strong[Combined example --- all three add-ons:]

```
[RESOURCES]
[PC:Kael|HP 12/15|Supply d6]
[Inv:Torch|2] [Inv:Arrow|9] [Inv:Healing Potion|1]
[Wealth:Gold 52]
[/RESOURCES]

S5 *Entering the crypt*
[R:1|active|Entry hall, bones everywhere|exits N:R2, E:R3]

@ Light a torch and move in
[Inv:Torch-1] [Timer:Torchlight 6]

? Are there enemies?
-> Yes, and... (d6=6)
=> Skeletons rise from the bone piles!

[COMBAT]
[F:Skeleton×3|HP 3 each|Close]

R1
@ Fire at the nearest skeleton
d: Ranged d6=5 vs TN 4 -> Success
=> Arrow shatters its skull! [F:Skeleton×3→2] [Inv:Arrow-1]

@(Skeleton) Charge at me
d: Attack d6=3 vs TN 4 -> Fail
=> Clumsy swing, I dodge.

R2
@ Draw sword, press the attack
d: Melee d6=6 vs TN 4 -> Success
=> Cut clean through! [F:Skeleton×2→1]

@ Finish the last one
d: Melee d6=4 vs TN 4 -> Success
=> The crypt goes quiet. [F:Skeleton×0]
[/COMBAT]

@ Search the room
tbl: d20=14 -> "A locked chest"
? Can I pick the lock?
d: Lockpicking d6=5 vs TN 5 -> Success
=> Inside: [Inv:Gold Bracelet|1|valuable] [Wealth:Gold+10]
[R:1|cleared, looted]
[Timer:Torchlight-1]

@ Move north toward R2
[R:2|active|Ritual chamber|exits S:R1, D:R3]
```

#pagebreak()
== System Adaptations
<system-adaptations>
=== The Black Hack / Usage Dice Systems
<the-black-hack-usage-dice-systems>
Usage Dice are the primary resource mechanic. Track them in `[PC:]`:

```
[PC:Varn|Torches d8|Rations d6|Ammo d10|HP 14/18]

@ Set up camp
d: Rations d6=2 -> Step down!
=> [PC:Varn|Rations d6→d4]
(note: one more step-down and they're gone)
```

=== Ironsworn / Supply Track
<ironsworn-supply-track>
Supply is a single stat from 0--5:

```
[PC:Kael|Supply 4/5|Health 4/5|Spirit 3/5|Momentum 6/10]

@ Sojourn at the settlement
d: Action=5+Heart=2=7 vs Challenge=3,8 -> Weak Hit
=> I resupply but time passes. [PC:Kael|Supply+2|Momentum-1]
```

=== OSR / Encumbrance Systems
<osr-encumbrance-systems>
Slot-based inventory is common in OSR games:

```
[Inv:Slot 1|Sword]
[Inv:Slot 2|Shield]
[Inv:Slot 3|Torch×3]
[Inv:Slot 4|Rations×4]
[Inv:Slot 5|Rope 50ft]
[Inv:Slot 6-10|empty]
(note: 10 slots max, STR-based encumbrance)

@ Pick up the golden idol
=> [Inv:Slot 6|Golden Idol|heavy|occupies 2 slots]
[Inv:Slot 7|occupied]
(note: at 7/10 slots — movement penalty at 8+)
```

=== Fate / Narrative-First Systems
<fate-narrative-first-systems>
Resources are aspects or stress tracks, not inventories:

```
[PC:Sable|Aspect:Well-Provisioned]
[PC:Sable|Aspect:Well-Provisioned→Running Low]
[PC:Sable|Aspect:Running Low|invoked against me]
```

Or simply note it in prose and skip `[Inv:]` entirely. If your game doesn't mechanize resources, neither should your notation.

=== Survival Horror / Scarcity Games
<survival-horror-scarcity-games>
When every bullet counts:

```
[Inv:9mm Round|7]
[Inv:First Aid Kit|1|uses 2/3]
[Inv:Flashlight|1|battery d4]

@ Fire at the creature
d: Firearms d6=4 vs TN 4 -> Success
=> Hit! [Inv:9mm Round-1]

@ Patch up the wound
=> [Inv:First Aid Kit|1|uses 2→1] [PC:Casey|HP+3]

@ Check the flashlight
d: Battery d4=1 -> Step down!
=> Flickering badly. [Inv:Flashlight|1|battery d4→depleted]
=> Darkness. [Clock:Panic 1/4]
```

#pagebreak()
== Best Practices
<best-practices>
#strong[Do: Record resource changes at the point of fiction]

```
✔ @ Light a torch to see
  => The cavern reveals a narrow passage. [Inv:Torch-1]
```

#strong[Don't: Silently update resources outside the log]

```
✗ (I subtracted 3 arrows but didn't write it down anywhere)

✔ Show the change, even briefly: [Inv:Arrow-3]
```

#strong[Do: Use the Resource Status Block at session boundaries]

```
✔ [RESOURCES]
  [PC:Kael|HP 12/15|Supply d6]
  [Inv:Torch|2] [Inv:Arrow|9]
  [/RESOURCES]
```

#strong[Don't: Let bookkeeping overwhelm the fiction]

```
✗ => I fight the orc.
  [Inv:Arrow-1] [Inv:Arrow|11] [PC:HP-2] [PC:HP 13]
  [F:Orc|HP-4] [Clock:Alert+1] [Timer:Torch-1]
  (This is a spreadsheet, not a story)

✔ => Arrow finds its mark — the orc staggers.
  [Inv:Arrow-1] [F:Orc|HP-4]
  (Track what matters this beat. Batch the rest in a status block.)
```

#strong[Do: Match your notation to your system's resource model]

```
✔ Usage Die game:    [PC:Kael|Supply d8]
✔ Counting game:     [Inv:Arrow|12]
✔ Narrative game:    [PC:Sable|Aspect:Well-Provisioned]
```

#strong[Don't: Track resources the game doesn't care about]

```
✗ [Inv:Bootlaces|2|leather]     (unless your game literally tracks this)

✔ Only track what creates meaningful decisions or tension.
```

#strong[Do: Separate concrete items from abstract stats]

```
✔ [Inv:Healing Potion|2]        (concrete, countable item)
✔ [PC:Kael|Supply d6]           (abstract supply level)
```

#strong[Don't: Mix the two in the same place for different reasons]

```
✗ [PC:Kael|HP 12|Torch 3|Arrow 9|Rations 5]
  (inventory list inside a character stat tag)

✔ [PC:Kael|HP 12|Supply d6]
  [Inv:Torch|3] [Inv:Arrow|9] [Inv:Rations|5]
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
  [`[Inv:Item\|qty\|props]`], [Concrete inventory item], [`[Inv:Torch\|3]`],
  [`[#Inv:Item]`], [Reference previously established item], [`[#Inv:Bone Amulet]`],
  [`[Inv:Item+N]` / `[Inv:Item-N]`], [Quantity change (gain/lose)], [`[Inv:Arrow-1]`],
  [`[Inv:Item\|qty→qty]`], [Explicit quantity transition], [`[Inv:Torch\|3→2]`],
  [`[Inv:Item\|depleted]`], [Item fully consumed or gone], [`[Inv:Oil Flask\|depleted]`],
  [`[Wealth:Currency N]`], [Concrete currency total], [`[Wealth:Gold 45]`],
  [`[Wealth:Currency+N]`], [Currency earned], [`[Wealth:Gold+15]`],
  [`[Wealth:Currency-N]`], [Currency spent], [`[Wealth:Gold-8]`],
)
=== Abstract Resources in `[PC:]`
<abstract-resources-in-pc>
#table(
  columns: (33.33%, 33.33%, 33.33%),
  align: (auto,auto,auto,),
  table.header([Pattern], [Purpose], [Example],),
  table.hline(),
  [`Supply d8`], [Usage Die resource], [`[PC:Kael\|Supply d8]`],
  [`Supply d8→d6`], [Usage Die step-down], [`[PC:Kael\|Supply d8→d6]`],
  [`Supply 4/5`], [Supply track], [`[PC:Kael\|Supply 4/5]`],
  [`Supplies:low`], [Qualitative level], [`[PC:Kael\|Supplies:low]`],
  [`Wealth d8`], [Abstract wealth as Usage Die], [`[PC:Kael\|Wealth d8]`],
  [`Aspect:Running Low`], [Narrative resource state], [`[PC:Sable\|Aspect:Running Low]`],
)
=== Structural Blocks
<structural-blocks>
#table(
  columns: (22.58%, 35.48%, 41.94%),
  align: (auto,auto,auto,),
  table.header([Block], [Opens When], [Closes When],),
  table.hline(),
  [`[RESOURCES]` / `[/RESOURCES]`], [Session start/end, before major expeditions], [After all current `[Inv:]` and `[PC:]` tags are listed],
)
=== Usage Die Step-Down Chain
<usage-die-step-down-chain>
```
d12 → d10 → d8 → d6 → d4 → depleted
```

=== Complete Example
<complete-example>
```
[RESOURCES]
[PC:Kael|HP 10/15|Supply d6] [Wealth:Gold 52]
[Inv:Torch|2] [Inv:Arrow|9] [Inv:Healing Potion|1]
[/RESOURCES]

@ Light a torch
[Inv:Torch-1] [Timer:Torchlight 6]

@ Fire at the orc
d: Ranged d6=5 vs TN 4 -> Success
=> [F:Orc|HP-4] [Inv:Arrow-1]

=> I bandage up after the fight. [Inv:Healing Potion-1] [PC:Kael|HP+5|HP 15]
```

#pagebreak()
== FAQ
<faq>
#strong[Q: When should I use `[Inv:]` vs.~just putting gear in `[PC:]`?] A: If resources are mechanically important and change often, use `[Inv:]`. If they're background flavor or you're only tracking one or two things, `[PC:Name|Gear:Sword,Shield]` is fine. There's no wrong answer --- use what keeps your log clear.

#strong[Q: Do I need the `[Wealth:]` tag, or can I put money in `[Inv:]`?] A: Either works. `[Wealth:]` is cleaner for multi-currency systems (gold/silver/copper) and for money that flows frequently. `[Inv:Gold|45]` works fine for simpler games or if you're already using `[Inv:]` for everything.

#strong[Q: Should I write a Resource Status Block every session?] A: Only if it helps you. If resources are central to your game (dungeon crawls, survival horror), a block at session start and end saves you from scrolling back. If resources rarely change or aren't mechanically important, skip it.

#strong[Q: What if I'm playing a game with no resource mechanics at all?] A: Then you probably don't need this add-on. Core Lonelog's `[PC:]` tag with a `Gear:` field is more than enough. This add-on exists for games where resources create tension and decisions.

#strong[Q: Can I combine `[Inv:]` with the Dungeon Crawling Add-on's `[R:]` tags?] A: Absolutely --- they're designed to work together. Tag loot in the room where you find it: `[R:3|looted] [Inv:Gold Ring|1|valuable]`. The `[R:]` tag tracks what happened to the room; the `[Inv:]` tag tracks what happened to the loot.

#strong[Q: How do I handle containers, bags of holding, saddlebags?] A: Either nest descriptively --- `[Inv:Bag of Holding|contains: Wand, Scrolls×3, Gold 100]` --- or track the container and contents separately. For slot-based systems, just mark which slots are "in the bag." Don't over-engineer it.

#strong[Q: The `×` symbol is hard to type. Can I use `x` instead?] A: Yes. `[Inv:Arrow×12]` and `[Inv:Arrowx12]` are both fine. Readability over formality.

#strong[Q: How does this work in an analog notebook?] A: The Resource Status Block works well in analog --- write it in a box or across the top of the page. For inline changes, use shorthand in the margin: `Torch -1`, `Arrow 9→8`. The `+`/`-` notation is fast enough that it doesn't slow down handwriting.

#pagebreak()
== Credits & License
<credits-license>
© 2025 Roberto Bisceglie

This add-on extends #link("https://zeruhur.itch.io/lonelog")[Lonelog] by Roberto Bisceglie.

#strong[Version History:]

- v 1.1.0: Block tags unified with `[BLOCK]`/`[/BLOCK]` convention; design principles updated
- v 1.0.0: Rewritten as a compliant add-on (previously "Resource Tracking Module")

This work is licensed under the #strong[Creative Commons Attribution-ShareAlike 4.0 International License];.

You are free to share and adapt this material, provided you give appropriate credit and distribute adaptations under the same license. Session logs and play records created using this add-on's notation are your own work and are not subject to this license.
