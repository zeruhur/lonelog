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
  title: "Lonelog: Dice Notation Add-on",
  subtitle: "A Standard Grammar for Recording Dice Expressions",
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
  logo-image: "assets/logo.png",
  license-image: "assets/by-sa.png",
  doc,
)

= Overview
<overview>
Core Lonelog gives you `d:` to mark a mechanics roll. What goes inside that field is left to you. That freedom is intentional --- different systems use wildly different dice conventions --- but it creates friction when logs are shared or when tools try to parse them.

This add-on solves that by defining a standard grammar for dice expressions. It is adapted from the specification used by rpg-dice-roller, an open-source dice library, and extended with Lonelog-specific conventions for how expressions appear inside `d:` entries.

The notation is a superset of the informal standard described in the Wikipedia article on #link("https://en.wikipedia.org/wiki/Dice_notation")[Dice Notation];. If you already write `2d6+3` or `4d6dl1`, you are already using it. This document formalizes that habit and fills in the gaps.

#strong[Who needs this add-on:]

- Players who share session logs and want their dice expressions to be unambiguous
- Developers building tools that parse or render Lonelog logs
- Players using systems with complex dice mechanics (dice pools, exploding dice, Fudge/Fate) who want a consistent way to write them

#strong[Who can skip it:] If you play a single system and never share logs, your informal dice notation probably works fine. Core Lonelog does not require this add-on.

#pagebreak()
== What This Add-on Adds
<what-this-add-on-adds>
This add-on does not introduce new Lonelog tags or structural blocks. It standardizes the dice expression grammar that appears inside existing core elements, primarily `d:` roll fields.

#table(
  columns: (25.71%, 25.71%, 48.57%),
  align: (auto,auto,auto,),
  table.header([Element], [Purpose], [Example in a log],),
  table.hline(),
  [Standard expression], [A dice roll with optional modifiers and math], [`d: Attack 2d6+3=9 -> Hit`],
  [Roll description], [Inline label attached to a dice expression], [`d: 4d6dl1 // Ability score=14`],
  [Group roll], [Multiple sub-expressions evaluated together], [`d: {4d6, 2d8}k2=11`],
)
#strong[No new core symbols.] This add-on introduces no additions to `@`, `?`, `d:`, `->`, or `=>`.

== Design Principles
<design-principles>
#strong[Grammar, not engine.] This spec defines how to #emph[write] dice expressions, not how to #emph[resolve] them. Any compliant tool should produce equivalent results, but the notation itself is system-agnostic.

#strong[Upward compatible.] Simple expressions --- `d6`, `2d10+3` --- are valid without reading this document. Complexity is opt-in.

#strong[Log-readable.] Expressions are meant to be read by humans in plain text. Modifier flags (`!`, `k`, `d`) are chosen to be short and memorable, not just machine-parseable.

#pagebreak()
= Part I: Practical Reference
<part-i-practical-reference>
This section covers the dice expressions that come up most often in solo RPG play. If you are logging sessions rather than building a parser, this is all you need.

== How dice expressions fit into a log entry
<how-dice-expressions-fit-into-a-log-entry>
In a `d:` field, the dice expression records #emph[what was rolled] and `=N` records the #emph[numeric total];. The `->` field is reserved for the interpreted outcome --- a state, not a number.

```
d: Strike 2d6+2=9 -> Hit
d: Pick the lock d20+Lockpicking=17 vs DC 15 -> Success
d: Overcome 4dF+2=3 -> Success with Style
```

The bracketed breakdown `[4, 3]` is optional. Include it when the individual results matter --- a lucky max roll, a dropped die that changed the outcome --- or leave it out when the total is all you need.

#pagebreak()
== Rolling Dice
<rolling-dice>
The core syntax is `NdS`, where `N` is the number of dice and `S` is the number of sides. `N` defaults to `1` if omitted.

```
d6       roll one 6-sided die
2d6      roll two 6-sided dice and sum the results
4d10     roll four 10-sided dice and sum the results
d20      roll one 20-sided die
d%       roll percentile dice (1–100); equivalent to d100
dF       roll one Fudge/Fate die (-1, 0, or +1)
4dF      roll four Fudge/Fate dice and sum the results
```

In a log:

```
d: Strike 2d6=9
d: Oracle d%=34
d: Fate 4dF=1
```

#pagebreak()
== Adding a Flat Modifier
<adding-a-flat-modifier>
Use standard arithmetic. The modifier applies to the total, not to individual dice.

```
d6+3     roll d6, add 3
2d6-1    roll 2d6, subtract 1
d20+5    roll d20, add 5
```

In a log:

```
d: Strike 2d6+2=9
```

== Keeping or Dropping Dice
<keeping-or-dropping-dice>
These are the most common modifiers in solo play. Use them for advantage/disadvantage, ability score generation, or any system that rolls and discards dice.

#strong[Keep highest / lowest:]

```
2d20kh1    roll 2d20, keep the highest (advantage)
2d20kl1    roll 2d20, keep the lowest (disadvantage)
4d6kh3     roll 4d6, keep the highest 3
```

`k` alone defaults to highest: `2d20k1` is the same as `2d20kh1`.

#pagebreak()
#strong[Drop lowest / highest:]

```
4d6dl1     roll 4d6, drop the lowest (ability scores)
4d6dh1     roll 4d6, drop the highest
```

`d` alone defaults to lowest: `4d6d1` is the same as `4d6dl1`.

In a log:

```
d: Ability score 4d6dl1=15
```

The breakdown (`[6, 4d, 5, 3]`) is optional --- useful when you want to record which die was dropped, but not required.

#strong[Note:] `k` (keep) and `d` (drop) are the same operation expressed from opposite directions. `4d6kh3` and `4d6dl1` both give you the top 3 dice from a pool of 4.

== Exploding Dice
<exploding-dice>
An exploding die is re-rolled when it hits its maximum value, and the new roll is added to the total.

```
d6!      roll d6; re-roll and add if you roll a 6
2d6!     roll 2d6; each die that rolls 6 explodes
```

#pagebreak()
In a log:

```
d: Damage 2d6! =13
```

#quote(block: true)[
#strong[Note:] When an expression ends with `!` or another modifier that accepts a compare point, write a space before `=` to distinguish the result from a compare point operator. `2d6!=13` would be parsed as "explode on any roll not equal to 13"; `2d6! =13` records a result of 13.
]

You can change the trigger with a compare point:

```
2d6!>4    explode on any roll greater than 4
4d10!<=3  explode on any roll less than or equal to 3
```

For systems where exploded values stack into a single result (e.g.~Savage Worlds raises):

```
d6!!     compound exploding: re-rolls stack on the same die
```

#pagebreak()
== Dice Pools (Counting Successes)
<dice-pools-counting-successes>
Some systems count how many dice beat a target rather than summing results. Attach a compare point directly to the die notation:

```
5d6>=5     count dice showing 5 or higher
4d10>7     count dice showing 8, 9, or 10
10d6=6     count dice showing exactly 6
```

In a log, the result is the success count:

```
d: Attack 5d10>=7=3 -> Hit
```

To count failures as negative successes, add an `f` compare point immediately after:

```
4d6>4f<3   successes on 5–6, failures on 1–2
```

#pagebreak()
== Roll Descriptions
<roll-descriptions>
Attach a label to a dice expression for clarity, especially when logging multiple rolls on one line.

Use `//` or `#` for inline descriptions:

```
4d6dl1 // Strength
2d6!   // Damage

d: 4d6dl1 // STR=15, 4d6dl1 // DEX=12, 4d6dl1 // CON=9
```

== Common Patterns by System Type
<common-patterns-by-system-type>
#strong[D&D / OSR ability scores:]

```
d: Stats 4d6dl1 // STR=15
```

#strong[Usage Dice (The Black Hack, Macchiato Monsters):]

```
d: Supply d8=2 -> Step down!
d: Torchlight d4=1 -> Depleted!
```

#strong[Note:] A usage die is written as a standard die expression. The step-down mechanic (`d8→d6`) and resource tracking are covered in the Resource Tracking Add-on.

#strong[PbtA / Ironsworn 2d6:]

```
d: Clash 2d6+2=9 -> Weak Hit
```

#strong[Advantage / Disadvantage:]

```
d: Persuade 2d20kh1+4=16
d: Sneak    2d20kl1+6=15
```

#pagebreak()
#strong[Fate / Fudge:]

```
d: Overcome 4dF+2=3 -> Success with Style
```

#strong[Savage Worlds trait roll] (note the space before `=` --- expressions ending in `!` need it):

```
d: Fighting d8!+2d6! =12 -> Hit
```

#strong[Percentile oracle:]

```
d: Mythic 2d10=47 -> Yes, but...
```

#pagebreak()
= Part II: Complete Reference
<part-ii-complete-reference>
= 1. Dice Types
<dice-types>
#strong[Note:] A single die type has a minimum quantity of `1` and a maximum quantity of `999`. Valid: `d8`, `1d10`, `999d6`. Invalid: `0d10`, `1000d6`, `-1d20`.

== Standard
<standard>
#strong[Notation:] `d{n}`

A standard die has a positive integer number of sides.

```
d6    roll a single 6-sided die
4d10  roll a 10-sided die 4 times and sum the results
```

== Percentile
<percentile>
#strong[Notation:] `d%`

Rolls a whole number between 1 and 100. Shorthand for `d100`.

```
4d%    equivalent to 4d100
```

#pagebreak()
== Fudge / Fate
<fudge-fate>
#strong[Notation:] `dF` / `dF.2` / `dF.1`

Six-sided dice marked with `-`, `+`, and blank faces, corresponding to `-1`, `+1`, and `0`.

- `dF` or `dF.2` --- standard: two of each face
- `dF.1` --- variant: four blanks, one `+`, one `-`

```
dF    standard Fudge die; equivalent to dF.2
dF.1  variant Fudge die
4dF   roll four standard Fudge dice and sum
```

= 2. Modifiers
<modifiers>
Modifiers alter the dice pool after rolling. Multiple modifiers can be combined; they execute in a fixed order (listed below) regardless of the order written.

```
5d10!k2    explode first (order 3), then keep highest 2 (order 6)
5d10k2!    equivalent — order is always by modifier priority
```

#pagebreak()
== Min
<min>
#strong[Notation:] `min{n}` | #strong[Order:] 1

Any roll below the minimum is treated as the minimum value.

```
4d6min3: [3^, 4, 3, 3^] = 13
```

#strong[Note:] Statistically, rolling the minimum becomes more likely than any other single value. `d6min3` gives a 50% chance of rolling 3.

== Max
<max>
#strong[Notation:] `max{n}` | #strong[Order:] 2

Any roll above the maximum is treated as the maximum value.

```
4d6max3: [3v, 3v, 3, 2] = 11
```

#pagebreak()
== Exploding
<exploding>
#strong[Notation:] `!` / `!{cp}` | #strong[Order:] 3

When a die rolls its maximum value, it is re-rolled and the new roll is added to the total. The re-roll can also explode.

```
2d6!: [4, 6!, 6!, 2] = 18
```

The second die rolled 6 and exploded; the re-roll also rolled 6 and exploded again.

Use a compare point to change the trigger:

```
2d6!=5    explode on 5
2d6!>4    explode on 5 or 6
4d10!<=3  explode on 1, 2, or 3
```

#quote(block: true)[
#strong[Note:] The `!=` (not equal) operator conflicts with the exploding notation. Use `<>` instead:

```
2d6!!=4   wrong — this means "compound on 4", not "explode on not-4"
2d6!<>4   correct — explode on any value that is not 4
```
]

#strong[Note:] To prevent infinite loops, modifiers are limited to 1000 iterations per die. `1d10!>0` returns at most 1001 rolls.

=== Compounding
<compounding>
#strong[Notation:] `!!` / `!!{cp}`

Like exploding, but re-rolls are added to the original die's total rather than listed separately.

```
2d6!:  [4, 6!, 6!, 2] = 18   exploding: separate rolls
2d6!!: [4, 14!!]       = 18   compounding: combined into one
```

=== Penetrating
<penetrating>
#strong[Notation:] `!p` / `!!p` / `!p{cp}` / `!!p{cp}`

Like exploding, but each re-roll has 1 subtracted from it. From the HackMaster Basic rules.

```
2d6!p: [6!p, 5!p, 5!p, 3, 1] = 20
```

Actual rolls were `[6, 6, 6, 4, 1]`; each exploded re-roll has 1 subtracted.

#pagebreak()
== Re-roll
<re-roll>
#strong[Notation:] `r` / `ro` / `r{cp}` / `ro{cp}` | #strong[Order:] 4

Re-rolls a die until it rolls above the minimum value, discarding the previous roll (unlike exploding, which keeps all rolls).

```
d6r      re-roll 1s indefinitely
d6ro     re-roll once on a 1, even if the re-roll is also 1
2d6r=5   re-roll any die showing 5, indefinitely
4d10r<=3 re-roll any die showing 1, 2, or 3
```

== Unique
<unique>
#strong[Notation:] `u` / `uo` / `u{cp}` / `uo{cp}` | #strong[Order:] 5

Re-rolls any die whose result duplicates another in the pool.

```
2d10u    re-roll duplicates until all results are unique
2d10uo   re-roll duplicates once; may still have duplicates
4d6u=5   only re-roll duplicates that show 5
```

#strong[Note:] If the number of dice exceeds the number of sides (e.g.~`5d3u`), unique results are impossible for all dice. The modifier is limited to 1000 iterations to prevent infinite loops.

== Keep
<keep>
#strong[Notation:] `k{n}` / `kh{n}` / `kl{n}` | #strong[Order:] 6

Keeps only the highest or lowest N results; all others are discarded. The opposite of Drop.

`k` alone defaults to highest.

```
4d10kh2  keep the highest 2
4d10k2   equivalent to above
4d10kl1  keep the lowest 1
```

Discarded dice are marked with `d` in tool output:

```
6d8k3: [3d, 6, 7, 2d, 5, 4d] = 18
```

== Drop
<drop>
#strong[Notation:] `d{n}` / `dh{n}` / `dl{n}` | #strong[Order:] 7

Drops the highest or lowest N results. The opposite of Keep.

`d` alone defaults to lowest.

```
4d10dl2    drop the lowest 2
4d10d2     equivalent to above
4d10dh1    drop the highest
4d10dh1dl2 drop both the highest and lowest 2
```

#quote(block: true)[
#strong[Note:] Both modifiers look at the full dice pool, including dice already flagged by the other modifier. Using them together can override each other unexpectedly.

```
3d10k1dh1: [7d, 1d, 2d] = 0   drops everything
3d10k1d1:  [6d, 1d, 9]  = 9   keeps only the highest
```
]

== Target Success / Dice Pool
<target-success-dice-pool>
#strong[Notation:] `{cp}` | #strong[Order:] 8

Counts how many dice meet a condition rather than summing values. Append a compare point directly to the die notation.

```
5d10>=8              count dice showing 8 or higher
2d6=6: [4, 6*] = 1  one success
4d3>1: [1, 3*, 2*, 1] = 2
```

Successful dice are marked with `*`.

#pagebreak()
#quote(block: true)[
#strong[Note:] A target compare point immediately following a modifier that uses compare points is interpreted as the modifier's compare point, not a success target. Specify the target first:

```
2d6!>3    explode on any roll greater than 3
2d6>3!    explode on 6; greater than 3 is a success
```
]

== Target Failure / Dice Pool
<target-failure-dice-pool>
#strong[Notation:] `f{cp}` | #strong[Order:] 8

Must follow a Target Success modifier directly. Each failure subtracts 1 from the success count.

```
4d6>4f<3: [2_, 5*, 4, 5*] = 1
```

Failed dice are marked with `_`.

== Critical Success
<critical-success>
#strong[Notation:] `cs` / `cs{cp}` | #strong[Order:] 9

Marks a die as a critical success. Aesthetic only --- does not change the numeric result.

```
2d20cs: [4, 20**] = 24
4d10cs>7            rolls greater than 7 are critical successes
```

Critical success dice are marked with `**`.

== Critical Failure
<critical-failure>
#strong[Notation:] `cf` / `cf{cp}` | #strong[Order:] 10

Marks a die as a critical failure. Aesthetic only.

```
2d20cf: [4, 1__] = 5
4d10cf<3           rolls less than 3 are critical failures
```

Critical failure dice are marked with `__`.

== Sorting
<sorting>
#strong[Notation:] `s` / `sa` / `sd` | #strong[Order:] 11

Sorts the dice results before display. Ascending by default.

```
4d6:   [4, 3, 5, 1]
4d6s:  [1, 3, 4, 5]   ascending (default)
4d6sa: [1, 3, 4, 5]   ascending (explicit)
4d6sd: [5, 4, 3, 1]   descending
```

== Compare Points
<compare-points>
A compare point is an operator followed by a number. Used by Exploding, Re-roll, Unique, Target Success, Target Failure, Critical Success, and Critical Failure modifiers.

#strong[Operators:]

#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Operator], [Meaning],),
  table.hline(),
  [`=`], [equal to],
  [`!=`], [not equal to],
  [`<>`], [also not equal to (use with exploding)],
  [`<`], [less than],
  [`>`], [greater than],
  [`<=`], [less than or equal to],
  [`>=`], [greater than or equal to],
)
```
d6!=3    explode on any roll not equal to 3
d10!>=5  explode on 5, 6, 7, 8, 9, or 10
d4r<3    re-roll anything less than 3
```

#quote(block: true)[
#strong[Note:] Both mean "not equal to" and are interchangeable in most contexts. However, `!=` conflicts with the exploding notation --- `2d6!!=4` is parsed as "compound on 4", not "explode on not-4". Use `<>` when combining not-equal with exploding:

```
2d6!<>4   correct: explode on any value that is not 4
```
]

= 3. Group Rolls
<group-rolls>
Group rolls evaluate multiple sub-expressions and apply modifiers to the group as a whole, rather than to individual dice. Sub-expressions are comma-separated and enclosed in `{}`.

```
{4d6, 2d10, d4}: {[2, 6, 4, 2], [7, 4], [1]} = 26
```

Without a modifier, sub-roll totals are summed. A single sub-roll in `{}` is functionally equivalent to the expression without braces.

== Keep and Drop with Groups
<keep-and-drop-with-groups>
When applied to a group with multiple sub-rolls, `k` and `d` keep or drop entire sub-rolls by their total value.

```
{4d10, 5d6, 2d10}k2   keep the 2 sub-rolls with the highest totals
{4d10, 5d6, 2d10}d2   drop the 2 sub-rolls with the lowest totals
```

When applied to a single sub-roll, they keep or drop individual die results within the expression:

```
{4d10*(2+5d6)}k2   keep the highest 2 individual rolls across all 9 dice
```

== Target Success / Failure with Groups
<target-success-failure-with-groups>
Compares each sub-roll's #emph[total] against the compare point rather than individual dice.

```
{3d20+5}>40: {([11, 7, 19]+5)*} = 1

{4d6+2d8, 3d20+3, 5d10+1}>40: {[4,3,3,2]+[2,6], ([17,5,20]+3)*, ([7,9,6,10,8]+1)*} = 2
```

== Sorting with Groups
<sorting-with-groups>
Sorts both individual dice within each sub-roll and sub-rolls by their total.

```
{4d6/2, 3d4+3, 2d10}s    ascending
{4d6/2, 3d4+3, 2d10}sd   descending
```

#pagebreak()
= 4. Roll Descriptions
<roll-descriptions-1>
A textual label can be attached to any dice expression or group roll. Labels are not parsed as notation.

== Inline Descriptions
<inline-descriptions>
Use `//` or `#` after the expression:

```
4d6dl1 // Strength score
2d6!   # Damage roll
{4d6, 2d10, d4} // Fire, frost, falling
```

In a Lonelog `d:` field:

```
d: 4d6dl1 // STR=14, 4d6dl1 // DEX=11
```

== Block Descriptions
<block-descriptions>
Use `[ ... ]` or `/* ... */` for multi-word or multi-line labels:

```
4d6 /* Ice damage */
2d10 [ Fire damage ]
{5d6+5} /* You can even
write on multiple lines */
```

#pagebreak()
Any dice notation inside a description block is not parsed:

```
4d6 /* Ice damage 5d10+7 */   only 4d6 is rolled
```

= 5. Math
<math>
== Arithmetic Operators
<arithmetic-operators>
Standard operators apply to roll totals:

#table(
  columns: 3,
  align: (auto,auto,auto,),
  table.header([Operator], [Meaning], [Example],),
  table.hline(),
  [`+`], [add], [`2d6+3`],
  [`-`], [subtract], [`d20-2`],
  [`*`], [multiply], [`d6*5`],
  [`/`], [divide], [`2d10/d20`],
  [`%`], [modulus (remainder)], [`d15%2`],
  [`^` or `**`], [exponent], [`3d20^4`],
)
Operators can also determine how many dice to roll or how many sides they have:

```
(4-2)d10   roll a d10 twice (4-2=2)
3d(2*6)    roll a 12-sided die (2*6=12) three times
```

== Parentheses
<parentheses>
Parentheses group expressions and define order of operations:

```
1d6+2*3:   [4]+2*3 = 10    multiplication first
(1d6+2)*3: ([4]+2)*3 = 18  addition first
```

#pagebreak()
= Quick Reference
<quick-reference>
== Dice Types
<dice-types-1>
#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Notation], [Meaning],),
  table.hline(),
  [`d{n}`], [Standard die with n sides],
  [`d%`], [Percentile die (1--100)],
  [`dF` / `dF.2`], [Standard Fudge die],
  [`dF.1`], [Variant Fudge die],
)
== Modifiers
<modifiers-1>
#table(
  columns: 3,
  align: (auto,auto,auto,),
  table.header([Notation], [Name], [Order],),
  table.hline(),
  [`min{n}`], [Minimum], [1],
  [`max{n}`], [Maximum], [2],
  [`!` / `!{cp}`], [Exploding], [3],
  [`!!` / `!!{cp}`], [Compounding], [3],
  [`!p` / `!!p`], [Penetrating], [3],
  [`r` / `ro` / `r{cp}`], [Re-roll], [4],
  [`u` / `uo` / `u{cp}`], [Unique], [5],
  [`kh{n}` / `kl{n}`], [Keep highest / lowest], [6],
  [`dh{n}` / `dl{n}`], [Drop highest / lowest], [7],
  [`{cp}`], [Target success], [8],
  [`f{cp}`], [Target failure], [8],
  [`cs` / `cs{cp}`], [Critical success], [9],
  [`cf` / `cf{cp}`], [Critical failure], [10],
  [`s` / `sa` / `sd`], [Sort], [11],
)
== Compare Point Operators
<compare-point-operators>
#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Operator], [Meaning],),
  table.hline(),
  [`=`], [equal to],
  [`!=`], [not equal to],
  [`<>`], [not equal to (use with exploding)],
  [`<`], [less than],
  [`>`], [greater than],
  [`<=`], [less than or equal to],
  [`>=`], [greater than or equal to],
)
== Output Flags (Tool Implementations)
<output-flags-tool-implementations>
#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Flag], [Meaning],),
  table.hline(),
  [`!`], [Exploded die],
  [`d`], [Dropped die],
  [`*`], [Success],
  [`_`], [Failure],
  [`**`], [Critical success],
  [`__`], [Critical failure],
  [`^`], [Min modifier applied],
  [`v`], [Max modifier applied],
)
== Common Patterns
<common-patterns>
```
2d6+3        PbtA / Ironsworn stat roll
2d20kh1      Advantage (D&D 5e)
2d20kl1      Disadvantage (D&D 5e)
4d6dl1       Ability score (D&D)
4dF+2        Fate roll with skill
d%           Percentile oracle
2d6!         Exploding roll
5d10>=7      Dice pool, target 7+
4d6>4f<3     Success/failure pool
```

#pagebreak()
= FAQ
<faq>
#strong[Q: Does this replace the notation I already use in my logs?] \
A: No.~If your existing dice notation is unambiguous to you, keep using it. This spec is a standard to adopt when consistency matters --- for sharing logs or building tools.

#strong[Q: What's the difference between `4d6dl1` and `4d6kh3`?] \
A: They produce identical results --- roll 4d6, keep the top 3. `dl1` (drop lowest 1) and `kh3` (keep highest 3) are two ways to express the same operation. Use whichever reads more naturally for your system.

#strong[Q: Can I use these expressions anywhere in a Lonelog entry, or only in `d:` fields?] \
A: The grammar applies wherever you record a dice result. It's most meaningful in `d:` fields, but nothing prevents using it in `=>` narrative lines or session notes when noting what was rolled.

#strong[Q: My system uses a custom die (like a d3 or d7). Is that valid?] \
A: Yes. Any positive integer is a valid number of sides: `d3`, `d7`, `d13`, `d100`. The standard dice shapes are just the most common cases.

#strong[Q: How do I record a roll result in my log --- just the expression, or the full breakdown?] \
A: The expression and total are always sufficient: `d: Attack 2d6+2=9`. The bracketed individual results (`[4, 3]+2`) are optional --- include them when the breakdown is meaningful (a die that exploded, a dropped result that mattered), skip them when it isn't.

#strong[Q: The `d` modifier letter conflicts with the `d` in `NdS`. How does a parser tell them apart?] \
A: By position. In `4d6`, the `d` separates quantity from sides. In `4d6d1`, the second `d` follows a complete die expression and is therefore the Drop modifier. Context disambiguates them.

#strong[Q: What about dice that aren't rolled --- oracle tables, card draws, etc.?] \
A: This notation covers dice only. Oracle results and non-dice mechanics are recorded using core Lonelog's `?` and `d:` fields with free-form text. The dice grammar is a layer on top of core notation, not a replacement for it.

#pagebreak()
= Credits & License
<credits-license>
© 2026 Roberto Bisceglie

This add-on extends #link("https://zeruhur.itch.io/lonelog")[Lonelog] by Roberto Bisceglie.

The dice notation grammar and reference documentation in Part II is adapted from the #link("https://dice-roller.github.io/documentation/")[rpg-dice-roller] specification by GreenImp Media Limited, used under the MIT License. The original MIT license and copyright notice are reproduced below.

#quote(block: true)[
MIT License \
Copyright (c) 2020--2021 GreenImp Limited \
Copyright (c) 2021--present GreenImp Media Limited

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]

#strong[Version History:]

- v1.0.0: Initial release

This work is licensed under the #strong[Creative Commons Attribution-ShareAlike 4.0 International License];.

You are free to share and adapt this material, provided you give appropriate credit and distribute adaptations under the same license. Session logs and play records created using this add-on's notation are your own work and are not subject to this license.
