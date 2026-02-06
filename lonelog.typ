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
      )[#if toc_title != none { toc_title } else { "Contents" }]
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
  title: "Lonelog",
  subtitle: "A Standard Notation for Solo RPG Session Logging",
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

= 1. Introduction
<introduction>
If you've ever played a solo RPG, you know the challenge: you're deep in an exciting scene, dice are rolling, oracles are answering questions, and suddenly you realize: how do I capture all this without breaking the flow?

Maybe you've tried free-form journaling (gets messy), pure prose (loses the mechanics), or bullet points (hard to parse later). This notation system offers a different approach: a #strong[lightweight shorthand] that captures the essential game elements while leaving room for as much (or as little) narrative as you want.

== 1.1 Why "Lonelog"?
<why-lonelog>
This system started life as #strong[Solo TTRPG Notation];, a name that was descriptive but unwieldy. Nearly 5,000 downloads later, it was clear the concept resonated with the community. But real-world use brought valuable lessons about what worked, what caused friction, and where the notation could evolve.

The rename to #strong[Lonelog] reflects three insights:

- #strong[A name that sticks.] "Solo TTRPG Notation" got abbreviated a dozen different ways. #emph[Lonelog] is compact and evocative: #emph[Lone] (solo play) + #emph[log] (session record). It works.

- #strong[A name you can find.] Search "solo ttrpg notation" and you'll drown in generic results. Search "lonelog" and you get #emph[this system];. Think of how #strong[Markdown] succeeded as both a format and a brand, it's not called "Text Formatting Notation." Lonelog gives this notation a distinct, findable identity.

- #strong[A name built to last.] As the system matures, having a clear identity makes it easier for the community to share resources, tools, and session logs under one banner.

The core philosophy hasn't changed: separate mechanics from fiction, stay compact at the table, scale from one-shots to long campaigns, and work in both markdown and paper notebooks.

== 1.2 What Lonelog Does
<what-lonelog-does>
Think of it as a shared language for solo play. Whether you're playing #emph[Ironsworn];, #emph[Thousand Year Old Vampire];, a non-solo RPG using Mythic GME, or your own homebrew system, this notation helps you:

- #strong[Record what happened] without slowing down play
- #strong[Track ongoing elements] like NPCs, locations, and plot threads
- #strong[Share your sessions] with other solo players who'll understand the format
- #strong[Review past sessions] and quickly find that crucial detail from three sessions ago

The notation is designed to be:

- #strong[Flexible] --- usable across different systems and formats
- #strong[Layered] --- works as both quick shorthand or expanded narrative
- #strong[Searchable] --- tags and codes make it easy to track NPCs, events, and locations
- #strong[Format-agnostic] --- works in digital markdown files or analog notebooks

The notation's goals:

- #strong[Make reports written by different people readable at a glance:] standard symbols facilitate reading
- #strong[Separate mechanics from fiction:] the best reports are those that highlight how the use of rules and oracles informs fiction
- #strong[Have a modular and scalable system:] you can use the core symbols or extend the notation as you wish
- #strong[Make it useful for both digital and analog notes]
- #strong[Compliance and extension of markdown for digital use]

== 1.3 How to Use This Notation
<how-to-use-this-notation>
Think of this as a #strong[toolbox, not a rulebook];. The system is fully modular: grab what works for you and leave the rest behind.

At its core are just #strong[five symbols] (see #emph[Section 3: Core Notation];). They are carefully chosen to avoid conflicts with markdown formatting and comparison operators. These are the minimal language of play:

- `@` for player actions
- `?` for oracle questions
- `d:` for mechanics rolls
- `->` for oracle/dice results
- `=>` for consequences

That's it. #strong[Everything else is optional.]

Scenes, campaign headers, session headers, threads, clocks, narrative excerpts---these are all enhancements you can add when they serve your play. Want to track a long campaign? Add campaign headers. Need to follow complex plots? Use thread tags. Playing a quick one-shot? Stick to the five core symbols.

Think of it as concentric circles:

- #strong[Core Notation] (required): Actions, Resolutions, Consequences
- #strong[Optional Layers] (add as needed): Persistent Elements, Progress tracking, Notes, etc.
- #strong[Optional Structure] (for organization): Campaign Header, Session Header, Scenes

#strong[Start small.] Try the core notation for one scene. If it clicks, great---keep going. If you need more, layer in what helps. Your notes should serve your play, not the other way around.

== 1.4 Quick Start: Your First Session
<quick-start-your-first-session>
Never used notation before? Here's everything you need:

```
S1 *Your starting scene*
@ Action you take
d: your roll result -> Success or Fail
=> What happens as a result

? Question you ask the oracle
-> Oracle's answer
=> What that means in the story
```

#strong[That's it!] Everything else is optional. Try this for one scene and see how it feels.

=== Quick Start Example
<quick-start-example>
```
S1 *Dark alley, midnight*
@ Sneak past the guard
d: Stealth 4 vs TN 5 -> Fail
=> I kick a bottle. Guard turns!

? Does he see me clearly?
-> No, but...
=> He's suspicious, starts walking toward the noise
```

== 1.5 Migrating from Solo TTRPG Notation v2.0
<migrating-from-solo-ttrpg-notation-v2.0>
If you're already using Solo TTRPG Notation v2.0, welcome! Lonelog is an evolution of that system with clarified symbols for better consistency.

#strong[What Changed:]

#table(
  columns: (28.89%, 35.56%, 35.56%),
  align: (auto,auto,auto,),
  table.header([v2.0 Symbol], [Lonelog Symbol], [Why the Change],),
  table.hline(),
  [`>`], [`@`], [Avoids conflict with Markdown blockquotes],
  [`->` (oracle only)], [`->` (all resolutions)], [Now unified for both dice AND oracle results],
  [`=>` (overloaded)], [`=>` (consequences only)], [Clarified---no longer doubles as dice outcome],
)
#strong[Key clarification:] In v2.0, `=>` was confusingly used for both dice outcomes and consequences. Lonelog clarifies this by using `->` for ALL resolutions (dice and oracle), reserving `=>` exclusively for consequences.

=== Your Old Logs Are Still Valid
<your-old-logs-are-still-valid>
The structure and philosophy remain identical. Your existing logs are perfectly readable---you don't need to convert them unless you want consistency across your campaign.

=== Conversion
<conversion>
If you prefer manual conversion, use find & replace in your text editor:

+ Find: `>` (at start of lines) → Replace: `@`
+ The `->` and `=>` symbols are retained but with clarified usage

= 2. Digital vs Analog Formats
<digital-vs-analog-formats>
This notation works in #strong[both digital markdown files and analog notebooks];. Choose the format that suits your play style.

== 2.1 Digital Format (Markdown)
<digital-format-markdown>
In digital markdown files:

- #strong[Campaign metadata] → YAML front matter (top of file)
- #strong[Campaign Title] → Level 1 heading
- #strong[Sessions] → Level 2 headings (`## Session 1`)
- #strong[Scenes] → Level 3 headings (`### S1`)
- #strong[Core notation and tracking] → Code blocks for easy copying/parsing
- #strong[Narrative] → Regular prose between code blocks

#quote(block: true)[
#strong[Note:] Always wrap notation in code blocks (#raw("```");) when using digital markdown. This prevents conflicts with Markdown syntax and ensures symbols like `=>` render correctly. Some Markdown extensions (Mermaid, Obsidian plugins) may interpret `=>` outside of code blocks.
]

== 2.2 Analog Format (Notebooks)
<analog-format-notebooks>
In paper notebooks:

- Write headers and metadata directly as shown
- Core notation works identically but without code fences
- Use the same symbols and structure
- Brackets and tags help scanning paper pages

== 2.3 Format Examples
<format-examples>
=== Digital markdown
<digital-markdown>
````markdown
## Session 1
*Date: 2025-09-03 | Duration: 1h30*

### S1 *School library after hours*

```
@ Sneak inside to check the archives
d: Stealth d6=5 vs TN 4 -> Success
=> I slip inside unnoticed. [L:Library|dark|quiet]
```
````

=== Analog notebook
<analog-notebook>
```
=== Session 1 ===
Date: 2025-09-03 | Duration: 1h30

S1 *School library after hours*
@ Sneak inside to check the archives
d: Stealth d6=5 vs TN 4 -> Success
=> I slip inside unnoticed. [L:Library|dark|quiet]
```

Both formats use identical notation --- only the wrapping differs.

= 3. Core Notation
<core-notation>
This is the heart of the system---the symbols you'll use in nearly every scene. Everything else in this document is optional, but these core elements are what make the notation work.

There are only five symbols to remember, and they mirror the natural flow of solo play: you take an action or ask a question, you resolve it with mechanics or an oracle, then you record what happens as a result.

Let's break it down.

== 3.1 Actions
<actions>
In solo play, uncertainty comes from two distinct sources: #strong[you don't know if your character can do something] (that's mechanics), or #strong[you don't know what the world does] (that's the oracle).

This distinction is fundamental. When you swing a sword, you use mechanics to see if you hit. When you wonder whether guards are nearby, you ask the oracle. Both create uncertainty, but they're resolved differently.

The notation reflects this with two different symbols---one for each type of action.

The `@` symbol represents you, the player, acting in the game world. Think of it as 'at this moment, I…' It's visually distinct from comparison operators, making your logs clearer and avoiding confusion when recording dice rolls.

#strong[Player-facing actions (mechanics):]

```
@ Pick the lock
@ Attack the guard
@ Convince the merchant
```

#strong[World / GM questions (oracle):]

```
? Is anyone inside?
? Does the rope hold?
? Is the merchant honest?
```

== 3.2 Resolutions
<resolutions>
Once you've declared an action (`@`) or asked a question (`?`), you need to resolve the uncertainty. This is where the game system or oracle gives you an answer.

There are two types of resolutions: #strong[mechanics] (when you roll dice or apply rules) and #strong[oracle answers] (when you ask the game world a question).

=== 3.2.1 Mechanics Rolls
<mechanics-rolls>
Format:

```
d: [roll or rule] -> outcome
```

The `d:` prefix indicates a mechanics roll or rule resolution. Always include the outcome (Success/Fail or narrative result).

=== Examples
<examples>
```
d: d20+Lockpicking=17 vs DC 15 -> Success
d: 2d6=8 vs TN 7 -> Success
d: d100=42 -> Partial success (using result table)
d: Hack the terminal (spend 1 Gear) -> Success
```

=== Comparison shorthand
<comparison-shorthand>
When comparing rolls to target numbers, you can use comparison operators:

```
d: 5 vs TN 4 -> Success    (standard format)
d: 5≥4 -> S                (shorthand: ≥ means meets/exceeds TN)
d: 2≤4 -> F                (shorthand: ≤ means fails to meet TN)
```

#strong[Note:] Comparison operators `≥` and `≤` work seamlessly with lonelog notation, with no symbol conflicts. You can also use `>=` and `<=`.

Add `S` (Success) or `F` (Fail) letters if you want explicit flags:

```
d: 2≤4 F
d: 5≥4 S
```

=== 3.2.2 Oracle and Dice Results
<oracle-and-dice-results>
The `->` symbol represents a definitive resolution---a declaration of outcome. The arrow visually shows "this leads to outcome," whether determined by dice mechanics or the oracle's answer.

#strong[Format:]

```
-> [result] (optional: roll reference)
```

The `->` prefix indicates any resolution outcome---mechanics or oracle.

=== Dice Mechanics Results
<dice-mechanics-results>
For mechanics rolls, `->` declares Success or Fail:

```
d: Stealth d6=5 vs TN 4 -> Success
d: Lockpicking d20=8 vs DC 15 -> Fail
d: Attack 2d6=7 vs TN 7 -> Success
d: Hacking d10=3 -> Partial Success
```

=== Oracle Answers
<oracle-answers>
For oracle questions, `->` declares what the world reveals:

```
-> Yes (d6=6)
-> No, but... (d6=3)
-> Yes, and... (d6=5)
-> No, and... (d6=1)
```

=== Common oracle formats
<common-oracle-formats>
- #strong[Yes/No oracles:] `-> Yes`, `-> No`
- #strong[Yes/No with modifiers:] `-> Yes, but...`, `-> No, and...`
- #strong[Degree results:] `-> Strong yes`, `-> Weak no`
- #strong[Custom results:] `-> Partially`, `-> With a cost`

=== Why unified syntax?
<why-unified-syntax>
Both mechanics and oracles resolve uncertainty. Using `->` for both creates consistency---every resolution gets the same declaration, making your log easier to scan and parse. Whether you rolled dice or asked the oracle, `->` marks the moment uncertainty becomes certainty.

== 3.3 Consequences
<consequences>
Record the narrative result after rolls using `=>`. The symbol shows consequences flowing forward from actions and resolutions. The double arrow visualizes how events cascade through your story.

```
=> The door creaks open, but the noise echoes through the hall.
=> The guard spots me and raises the alarm.
=> I find a hidden diary with a crucial clue.
```

=== Multiple consequences
<multiple-consequences>
You can chain multiple consequence lines for cascading effects:

```
d: Lockpicking 5≥4 -> Success
=> The door opens
=> But the hinges squeal loudly
=> [E:AlertClock 1/6]
```

== 3.4 Complete Action Sequences
<complete-action-sequences>
Here's how the core elements combine:

=== Mechanics-driven sequence
<mechanics-driven-sequence>
```
@ Pick the lock
d: d20+Lockpicking=17 vs DC 15 -> Success
=> The door creaks open, but the noise echoes through the hall.
```

=== Oracle-driven sequence
<oracle-driven-sequence>
```
? Is anyone inside?
-> Yes, but... (d6=4)
=> Someone is here, but they're distracted.
```

=== Combined sequence
<combined-sequence>
```
@ Sneak past the guards
d: Stealth 2≤4 -> Fail
=> My foot kicks a barrel. [E:AlertClock 2/6]

? Do they see me?
-> No, but... (d6=3)
=> Distracted, but one guard lingers nearby. [N:Guard|watchful]
```

= 4. Optional Layers
<optional-layers>
You've got the basics---actions, rolls, and consequences. That's enough for simple play. But longer campaigns often need more: NPCs who reappear, plot threads that weave through sessions, progress that accumulates over time.

This section covers the #strong[tracking elements] that help you manage complexity. They're all optional. If you're playing a one-shot mystery, you might not need any of this. If you're running a sprawling campaign with dozens of NPCs and multiple plot threads, you'll probably want most of it.

Pick and choose based on what your campaign needs.

== 4.1 Persistent Elements
<persistent-elements>
As your campaign grows, certain things stick around: NPCs who reappear, locations you return to, ongoing threats, story questions that span sessions. These are your #strong[persistent elements];.

Tags let you track them consistently across scenes and sessions. The format is simple: brackets, a type prefix, a name, and optional details. Like this: `[N:Jonah|friendly|wounded]`.

#strong[Why use tags?]

- #strong[Searchability];: Find every scene where Jonah appears
- #strong[Consistency];: Reference NPCs the same way every time
- #strong[Status tracking];: See how elements change over time
- #strong[Memory aid];: Remind yourself of details weeks later

You don't need to tag everything---only what matters to your campaign. A random merchant you'll never see again? Just call them "the merchant" in prose. A recurring villain? Definitely tag them.

Here are the main types of persistent elements you might track:

=== 4.1.1 NPCs
<npcs>
```
[N:Jonah|friendly|injured]
[N:Guard|watchful|armed]
[N:Merchant|suspicious]
```

#strong[Updating NPC tags:]

When an NPC's status changes, you can either:

- Restate with new tags: `[N:Jonah|captured|wounded]`
- Show just the change: `[N:Jonah|captured]` (assumes other tags persist)
- Use explicit updates: `[N:Jonah|friendly→hostile]`
- Add `+` or `-`: `[N:Jonah|+captured]` or `[N:Jonah|-wounded]`

Choose the style that keeps your log clearest.

=== 4.1.2 Locations
<locations>
```
[L:Lighthouse|ruined|stormy]
[L:Library|dark|quiet]
[L:Tavern|crowded|noisy]
```

=== 4.1.3 Events & Clocks
<events-clocks>
```
[E:CultistPlot 2/6]
[E:AlertClock 3/4]
[E:RitualProgress 0/8]
```

Events track significant plot elements. The number format `X/Y` shows current/total progress.

=== 4.1.4 Story Threads
<story-threads>
```
[Thread:Find Jonah's Sister|Open]
[Thread:Discover the Conspiracy|Open]
[Thread:Escape the City|Closed]
```

Threads track major story questions or goals. Common states:

- `Open` --- active thread
- `Closed` --- resolved thread
- `Abandoned` --- dropped thread
- Custom states allowed (e.g., `Urgent`, `Background`)

=== 4.1.5 Player Character
<player-character>
```
[PC:Alex|HP 8|Stress 0|Gear:Flashlight,Notebook]
[PC:Elara|HP 15|Ammo 3|Status:Wounded]
```

#strong[Updating PC stats:]

```
[PC:Alex|HP 8]        (initial)
[PC:Alex|HP-2]        (shorthand: lost 2 HP, now at 6)
[PC:Alex|HP 6]        (explicit: now at 6 HP)
[PC:Alex|HP+3|Stress-1]  (multiple changes)
```

=== 4.1.6 Reference Tags
<reference-tags>
To reference a previously established element without restating tags, use the `#` prefix:

```
[N:Jonah|friendly|injured]     (first mention — establishes the element)

... later in the log ...

[#N:Jonah]                     (reference — assumes tags from earlier)
```

The `#` tells you this element was defined earlier. Use it to:

- Keep later mentions concise
- Signal to readers they should look back for context
- Maintain searchability (the ID "Jonah" still appears)

#strong[When to use reference tags:]

- First mention: Full tag with details `[N:Name|tags]`
- Later mentions in same scene: Optional, use judgment
- Later mentions in different scenes/sessions: Use `[#N:Name]` to signal reference
- Status changes: Drop the `#` and show new tags `[N:Name|new_tags]`

== 4.2 Progress Tracking
<progress-tracking>
Some things in your campaign don't happen all at once---they build up over time. The ritual takes twelve steps to complete. The guards' suspicion grows with each noise you make. Your escape plan inches forward. The air supply counts down.

Progress tracking gives you a visual way to see these accumulating forces. Three formats handle different types of progression:

#strong[Clocks] (fill up toward completion):

```
[Clock:Ritual 5/12]
[Clock:Suspicion 3/6]
```

#strong[Use for:] Threats building, spells preparing, danger accumulating. When the clock fills, something happens (usually bad for you).

#strong[Tracks] (progress toward a goal):

```
[Track:Escape 3/8]
[Track:Investigation 6/10]
```

#strong[Use for:] Your progress on projects, journey advancement, long-term goals. When the track fills, you succeed at something.

#strong[Timers] (count down toward zero):

```
[Timer:Dawn 3]
[Timer:AirSupply 5]
```

#strong[Use for:] Deadlines approaching, resources depleting, time pressure. When it hits zero, time's up.

#strong[The difference?] Clocks and tracks both go up, but clocks are threats (bad when full) and tracks are progress (good when full). Timers go down and create urgency.

You don't need to track everything numerically. Only use these when the accumulation matters to your story and you want a concrete way to measure it.

== 4.3 Random Tables & Generators
<random-tables-generators>
Solo play thrives on surprise. Sometimes you roll on a table to see what you find, or use a generator to create an NPC on the fly. When you do, it helps to record what you rolled---both for transparency and so you can recreate the logic later.

#strong[Simple table lookup:]

```
tbl: d100=42 -> "A broken sword"
tbl: d20=15 -> "The merchant is nervous"
```

Use `tbl:` when you're pulling from a straightforward random table---the kind where you roll once and get a result.

#strong[Complex generators:]

```
gen: Mythic Event d100=78 + 11 -> NPC Action / Betray
gen: Stars Without Number NPC d8=3,d10=7 -> Gruff/Pilot
```

Use `gen:` when you're using a multi-step generator that combines multiple rolls or produces compound results.

#strong[Integrating with oracle questions:]

```
? What do I find in the chest?
tbl: d100=42 -> "A broken sword"
=> An ancient blade, snapped in two, with strange runes on the hilt.
```

#strong[Why record the rolls?] Three reasons:

+ #strong[Transparency];: If you're sharing the log, others see your process
+ #strong[Reproducibility];: You can trace how you got surprising results \
+ #strong[Learning];: Over time, you see which tables you use most

That said, if you're playing fast and loose, you can skip the roll details and just record the result: `=> I find a broken sword [tbl]`. The important part is the fiction, not the math.

== 4.4 Narrative Excerpts
<narrative-excerpts>
Here's a secret: #strong[you don't need to write narrative at all];. The shorthand captures everything mechanically. But sometimes the fiction demands more---a piece of dialogue that's too perfect not to record, a description that sets the mood, a document your character finds.

That's what narrative excerpts are for: the moments where shorthand isn't enough.

#strong[Inline prose] (short descriptions):

```
=> The room reeks of mildew and decay. Papers are scattered everywhere.
```

#strong[Use for:] Quick atmospheric details, sensory information, emotional beats. Keep it short---a sentence or two.

#strong[Dialogue] (conversations worth recording):

```
N (Guard): "Who's there?"
PC: "Stay calm... just stay calm."
N (Guard): "Show yourself!"
PC: [whispers] "Not happening."
```

#strong[Use for:] Memorable exchanges, character voice, important conversations. You don't need to record every word---just the exchanges that matter.

#strong[Long narrative blocks] (found documents, important descriptions):

```
\---
The diary reads:
"Day 47: The tides no longer obey the moon. The fish have stopped
coming. The lighthouse keeper says he sees lights beneath the waves.
I fear for our sanity."
---\
```

#strong[Use for:] In-world documents, lengthy descriptions, key revelations. The `\---` and `---\` markers separate it from your log, making it clear this is in-fiction content. The asymmetric delimiters prevent conflicts with Markdown horizontal rules.

#strong[How much narrative should you write?] Only as much as serves you. If you're playing for yourself and shorthand tells you everything you need to remember, skip the prose. If you're sharing your log or you love the writing process, add more. There's no right amount---just what makes your log useful and enjoyable to you.

== 4.5 Meta Notes
<meta-notes>
Sometimes you need to step outside the fiction and leave yourself a note: a reminder about a house rule you're testing, a reflection on how a scene felt, a question to revisit later, or a clarification about your interpretation of a rule.

That's what meta notes are for---your out-of-character asides to yourself (or to readers, if you're sharing).

#strong[Format:] Use parentheses to signal "this is meta, not fiction":

```
(note: testing alternate stealth rule where noise increases Alert clock)
(reflection: this scene felt tense! the timer really worked)
(house rule: giving advantage on familiar terrain)
(reminder: revisit this thread next session)
(question: should I have rolled for that? seemed obvious)
```

#strong[When to use meta notes:]

- #strong[Experiments];: Track rule variants or house rules you're testing
- #strong[Reflection];: Capture what worked or didn't work emotionally
- #strong[Reminders];: Flag things to follow up on later
- #strong[Clarification];: Explain unusual rulings or interpretations
- #strong[Process];: Document your thinking for shared logs

#strong[When NOT to use them:] Don't let meta notes overwhelm your log. If you're stopping every few lines to reflect, you're probably over-thinking it. The game is the thing---meta notes are just occasional margin comments.

Think of them like director's commentary on a movie. Most of the time, you just watch the film. Occasionally, there's an interesting behind-the-scenes note worth sharing.

= 5. Optional Structure
<optional-structure>
So far we've talked about #emph[what] you write (actions, rolls, tags). Now let's talk about #emph[how you organize it];.

Structure helps in two ways: it makes your notes easier to navigate, and it signals boundaries (this session ended, that scene began). But structure adds overhead---more headers to write, more formatting to maintain.

This section shows you the organizing elements: campaign headers (metadata about your whole campaign), session headers (marking play sessions), and scene structure (the basic unit of play). Use what helps you stay oriented without slowing you down.

The key difference? #strong[Digital and analog formats handle structure differently.] Digital markdown uses headings and YAML; analog notebooks use written headers and markers. We'll show both.

== 5.1 Campaign Header
<campaign-header>
Before you dive into play, it helps to record some basics: What are you playing? What system? When did you start? Think of this as the "cover page" of your campaign log.

This is especially useful when:

- You're running multiple campaigns (helps you remember which is which)
- You're sharing logs with others (they need context)
- You return to a campaign after a break (reminds you of tone/themes)

If you're just trying out the notation with a quick one-shot, skip this entirely. But for campaigns you plan to revisit, a header is worth the 30 seconds.

#strong[Digital and analog formats differ here.] Digital markdown uses YAML front matter (structured metadata at the top of the file). Analog notebooks use a written header block.

#strong[For digital markdown files];, use YAML front matter at the very top:

```yaml
title: Clearview Mystery
ruleset: Loner + Mythic Oracle
genre: Teen mystery / supernatural
player: Roberto
pcs: Alex [PC:Alex|HP 8|Stress 0|Gear:Flashlight,Notebook]
start_date: 2025-09-03
last_update: 2025-10-28
tools: Oracles - Mythic, Random Event tables
themes: Friendship, courage, secrets
tone: Eerie but playful
notes: Inspired by 80s teen mystery shows
```

#strong[For analog notebooks];, write a campaign header block:

```
=== Campaign Log: Clearview Mystery ===
[Title]        Clearview Mystery
[Ruleset]      Loner + Mythic Oracle
[Genre]        Teen mystery / supernatural
[Player]       Roberto
[PCs]          Alex [PC:Alex|HP 8|Stress 0|Gear:Flashlight,Notebook]
[Start Date]   2025-09-03
[Last Update]  2025-10-28
[Tools]        Oracles: Mythic, Random Event tables
[Themes]       Friendship, courage, secrets
[Tone]         Eerie but playful
[Notes]        Inspired by 80s teen mystery shows
```

#strong[Optional fields] (add as needed):

- `[Setting]` --- Geographic or world details
- `[Inspiration]` --- Media that inspired the campaign
- `[Safety Tools]` --- X-card, lines/veils, etc.

== 5.2 Session Header
<session-header>
A session header marks the boundary between play sessions and provides context: when did you play, how long, what happened?

#strong[Why use session headers?]

- #strong[Navigation];: Jump to specific sessions quickly
- #strong[Context];: Remember when you played and what was happening
- #strong[Reflection];: Track your play patterns (how often? how long?)
- #strong[Continuity];: Connect sessions with recaps and goals

#strong[When to skip them:]

- One-shot games (no multiple sessions)
- Continuous play (you play daily with no clear breaks)
- Pure shorthand logs (you just want the fiction, not the meta-structure)

Like campaign headers, digital and analog formats handle sessions differently. Choose the style that fits your medium.

=== 5.2.1 Digital format (markdown heading)
<digital-format-markdown-heading>
```markdown
## Session 1
*Date: 2025-09-03 | Duration: 1h30 | Scenes: S1-S2*

**Recap:** First session, introducing Alex and the mystery.

**Goals:** Set up the central mystery, establish the lighthouse as key location.
```

=== 5.2.2 Analog format (written header)
<analog-format-written-header>
```
=== Session 1 ===
[Date]        2025-09-03
[Duration]    1h30
[Scenes]      S1-S2
[Recap]       First session, introducing Alex and the mystery.
[Goals]       Set up the central mystery, establish the lighthouse.
```

#strong[Optional fields:]

- `[Mood]` --- Planned or actual tone for the session
- `[Notes]` --- Rules variants, experiments, or special conditions
- `[Threads]` --- Active threads this session

== 5.3 Scene Structure
<scene-structure>
Scenes are the basic unit of play within a session. At its simplest, a scene is just a numbered marker with context.

#strong[Digital format (markdown heading):]

```markdown
### S1 *School library after hours*
```

#strong[Analog format:]

```
S1 *School library after hours*
```

The scene number helps you track progression and reference events later. The context (in italics/asterisks) frames where and when the scene takes place.

=== 5.3.1 Sequential Scenes (Standard)
<sequential-scenes-standard>
Most campaigns use simple sequential numbering:

```
S1 *Tavern, evening*
S2 *Town square, midnight*
S3 *Forest path, dawn*
S4 *Ancient ruins, midday*
```

#strong[When to use:] Default for linear play. Scene 2 happens after Scene 1, Scene 3 after Scene 2, etc.

#strong[Numbering:] Start at S1 each session, or continue across the whole campaign (S1-S100+).

#strong[Example in play:]

```
S1 *Tavern common room, evening*
@ Ask the barkeep about rumors
d: Charisma d6=5 vs TN 4 -> Success
=> He leans in close and tells me about strange lights at the old mill.
[Thread:Strange Lights|Open]

S2 *Outside the tavern, night*
@ Head toward the mill
? Do I encounter anything on the way?
-> Yes, but... (d6=4)
=> I see a shadowy figure, but they don't seem hostile.
[N:Stranger|mysterious|watching]
```

=== 5.3.2 Flashbacks
<flashbacks>
Flashbacks show past events that inform the current story. Use letter suffixes branching from the "present" scene.

#strong[Format:] `S#a`, `S#b`, `S#c`

#strong[When to use:]

- Revealing backstory mid-session
- Character memory triggers
- Showing how something happened
- Explaining mysterious elements

#strong[Example structure:]

```
S5 *Investigating the mill*
=> I find my father's old journal.

S5a *Flashback: Father's workshop, 10 years ago*
(This happened before the campaign)
=> Father: "Promise me you'll never go to the mill alone."

S6 *Back at the mill, present day*
(Now we continue from S5)
```

#strong[Complete example:]

```
S8 *Lighthouse keeper's quarters*
@ Search the desk for clues
d: Investigation d6=6 vs TN 4 -> Success
=> I find a faded photograph. It's... my mother? She's standing at this lighthouse!
[Thread:Mother's Connection|Open]

S8a *Flashback: Home, 15 years ago*
(Memory triggered by the photograph)
(Do I remember anything about this place?)
? Did mother ever mention a lighthouse?
-> Yes, but... (d6=5)
=> She mentioned it once, briefly, then changed the subject quickly.

PC (Young me): "Mom, where is this?"
N (Mother): [nervous] "Just an old place. Nothing important."

S8b *Flashback: Mother's study, 14 years ago*
(Following the thread of memory)
(Did I ever see documents about the lighthouse?)
? Was I snooping in her papers?
-> Yes, and... (d6=6)
=> I found a deed. The lighthouse belonged to our family!
[E:LighthouseSecret 1/4]

S9 *Lighthouse keeper's quarters, present*
(Back to current timeline)
=> Armed with this memory, I search more carefully for family records.
```

#strong[Numbering tips:]

- Branch from the scene that triggers the flashback
- Return to sequential numbering afterward
- Keep flashbacks short (1-3 scenes usually)
- Note in context when returning: `*Present day*` or `*Back at the...*`

=== 5.3.3 Parallel Threads
<parallel-threads>
When tracking multiple storylines that happen simultaneously or in alternating focus, use thread prefixes.

#strong[Format:] `T#-S#` where T\# is the thread number, S\# is the scene number within that thread

#strong[When to use:]

- Multiple characters/viewpoints
- Simultaneous events in different locations
- Alternating between plot lines
- Separate but related story arcs

#strong[Example structure:]

```
T1-S1 *Main character at the lighthouse*
T2-S1 *Meanwhile, ally in the city*
T1-S2 *Back to lighthouse*
T2-S2 *Back to city*
T1-S3 *Lighthouse, continuing*
```

#strong[Complete example:]

```
=== Session 3 ===
[Threads] Main story (T1), City investigation (T2)

T1-S1 *Lighthouse tower, dusk*
[PC:Alex|investigating the tower]
@ Climb to the top
d: Athletics d6=4 vs TN 4 -> Success
=> I reach the top. The light mechanism is still functional!

? Is anyone else here?
-> No, but... (d6=3)
=> Fresh footprints in the dust lead down.

T2-S1 *City archives, same time*
[PC:Jordan|researching at the library]
@ Search for lighthouse records
d: Research d6=6 vs TN 4 -> Success
=> I find construction documents from 1923. There's a hidden basement!
[E:SecretBasement 1/4]

T1-S2 *Lighthouse basement stairs*
[PC:Alex]
@ Follow the footprints down
d: Stealth d6=3 vs TN 5 -> Fail
=> A step creaks loudly.

? Does someone react?
-> Yes, and... (d6=6)
=> A voice from below: "Who's there?" [N:Cultist|hostile|armed]

T2-S2 *City archives, moments later*
[PC:Jordan]
@ Call Alex to warn about the basement
? Does the call go through?
-> No, and... (d6=2)
=> No signal. The lighthouse is in a dead zone!
[Clock:Alex in Danger 2/6]

T1-S3 *Lighthouse basement*
[PC:Alex|unaware of danger]
@ Try to talk my way out
d: Deception d6=2 vs TN 5 -> Fail
=> The cultist isn't buying it. He advances with a knife!
```

#strong[When threads converge:]

Once parallel threads meet, you can either:

- Continue with thread prefixes: `T1+T2-S5`
- Return to sequential: `S14` (note: threads merged)

```
T1-S6 *Alex escapes the lighthouse*
T2-S4 *Jordan drives toward the lighthouse*

S14 *Lighthouse entrance, both reunited*
(Threads merged)
[PC:Alex|wounded] meets [PC:Jordan|worried]
```

=== 5.3.4 Montages and Time Cuts
<montages-and-time-cuts>
For activities that span time or multiple quick vignettes, use decimal notation.

#strong[Format:] `S#.#` (e.g., `S5.1`, `S5.2`, `S5.3`)

#strong[When to use:]

- Traveling across long distances
- Training/research over weeks
- Multiple quick encounters
- Gathering resources
- Time-lapse sequences

#strong[Example structure:]

```
S7 *Beginning the journey*
S7.1 *Day 1: Forest*
S7.2 *Day 3: Mountains*
S7.3 *Day 5: Desert*
S8 *Arriving at destination*
```

#strong[Complete example:]

```
S12 *Preparing for the ritual*
=> I need to gather three components across the region.
[Track:Ritual Components 0/3]

S12.1 *Herb shop, morning*
@ Buy sacred herbs
d: Persuasion d6=5 vs TN 4 -> Success
=> The herbalist gives me a discount.
[Track:Ritual Components 1/3]
[PC:Gold-5]

S12.2 *Blacksmith, afternoon*
@ Obtain silver dagger
? Is it in stock?
-> No, but... (d6=4)
=> He can make one by tomorrow.
[Timer:Ritual Deadline 2]

S12.3 *Graveyard, midnight*
@ Collect cemetery soil
? Am I interrupted?
-> Yes, and... (d6=6)
=> The groundskeeper catches me AND calls the guard!
[Clock:Suspicion 3/6]

@ Run and hide
d: Stealth d6=6 vs TN 5 -> Success
=> I escape with the soil.
[Track:Ritual Components 2/3]

S13 *Blacksmith shop, next morning*
(Montage complete, back to sequential)
=> I collect the silver dagger.
[Track:Ritual Components 3/3]
```

#strong[Travel montage example:]

```
S8 *Setting out from Port Ashan*
=> Three-week journey to the Northern Wastes begins.

S8.1 *Week 1: Coastal road*
? Encounters on the road?
tbl: d100=23 -> "Merchant caravan"
=> I join a caravan for safety. [N:Merchants|friendly]

S8.2 *Week 2: Mountain pass*
? Weather problems?
-> Yes, and... (d6=6)
=> Blizzard hits. The pass is blocked!
[Clock:Supplies Dwindle 2/4]

@ Find shelter
d: Survival d6=5 vs TN 5 -> Success
=> I locate a cave. [L:Mountain Cave|shelter|dark]

S8.3 *Week 3: Descending into wastes*
@ Navigate the frozen terrain
d: Survival d6=4 vs TN 6 -> Fail
=> I'm lost for two days.
[Clock:Supplies Dwindle 4/4]
[PC:Rations depleted]

S9 *Arriving at the Northern Wastes*
(Journey complete)
=> Exhausted and hungry, but I've made it.
```

=== 5.3.5 Choosing Your Approach
<choosing-your-approach>
#strong[Use sequential (S1, S2, S3) when:]

- Playing straightforward, linear story
- Don't need complex time manipulation
- Want simplicity
- Most common choice

#strong[Use flashbacks (S5a, S5b) when:]

- Revealing backstory mid-game
- Character development moments
- Explaining mysteries
- Short diversions from main timeline

#strong[Use parallel threads (T1-S1, T2-S1) when:]

- Playing multiple characters
- Tracking simultaneous events
- Alternating between locations
- Complex, interwoven plots

#strong[Use montages (S7.1, S7.2) when:]

- Covering long time periods
- Series of quick scenes
- Travel sequences
- Resource gathering
- Training/research periods

=== 5.3.6 Scene Context Elements
<scene-context-elements>
Beyond numbering, enrich scenes with context in the frame:

#strong[Location:]

```
S1 *Lighthouse tower*
S1 [L:Lighthouse] *Tower room*
```

#strong[Time markers:]

```
S1 *Lighthouse, midnight*
S1 *Lighthouse, Day 3, dusk*
S1 *Two weeks later: Lighthouse*
```

#strong[Emotional tone:]

```
S1 *Lighthouse (tense)*
S1 *Lighthouse - moment of calm*
```

#strong[Multiple elements:]

```
S1 *Lighthouse tower, midnight, Day 3*
S5a *Flashback: Father's workshop, 10 years ago*
T2-S3 *Meanwhile in the city, same evening*
S7.2 *Day 2 of journey: Mountain pass*
```

#strong[Minimal (just number):]

```
S1
(Add context in first action or consequence)
```

Choose the level of detail that helps you track your story. More detail helps future reference; less detail keeps notes cleaner.

= 6. Complete Examples
<complete-examples>
Theory is one thing, but seeing the notation in action is where it clicks. This section shows complete play examples in different styles---from ultra-compact shorthand to rich narrative logs---so you can find the approach that works for you.

Each example demonstrates the same notation system, just with different levels of detail. Pick the style that matches your preference, or mix and match as your session demands.

== 6.1 Minimal Shorthand Log
<minimal-shorthand-log>
Pure shorthand, no formatting --- perfect for fast play:

```
S1 @Sneak d:4≥5 F => noise [E:Alert 1/6] ?Seen? ->Nb3 => distracted
S2 @Search d:6≥4 S => find key [E:Clue 1/4] ?Trapped? ->Yn6 => yes, spikes!
S3 @Dodge d:3≤5 F => HP-2 [PC:HP 6] => bleeding, need to retreat
```

== 6.2 Hybrid Digital Format
<hybrid-digital-format>
Combines shorthand with narrative, using markdown structure:

````markdown
### S7 *Dark alley behind tavern, Midnight*

```
@ Sneak past the guards
d: Stealth d6=2 vs TN 4 -> Fail
=> My foot kicks a barrel. [E:AlertClock 2/6]

? Do they see me?
-> No, but... (d6=3)
=> Distracted, but one guard lingers. [N:Guard|watchful]
```

The guard's torch light sweeps across the alley walls. I press myself
into the shadows, barely breathing.

```
N (Guard): "Who's there?"
PC: "Stay calm... just stay calm."
```
````

== 6.3 Analog Notebook Format
<analog-notebook-format>
Same content as 6.2, formatted for handwritten notes:

```
S7 *Dark alley behind tavern, Midnight*

@ Sneak past the guards
d: Stealth d6=2 vs TN 4 -> Fail
=> My foot kicks a barrel. [E:AlertClock 2/6]

? Do they see me?
-> No, but... (d6=3)
=> Distracted, but one guard lingers. [N:Guard|watchful]

The guard's torch light sweeps across the alley. I press into shadows.

N (Guard): "Who's there?"
PC: "Stay calm... just stay calm."
```

== 6.4 Complete Campaign Log (Digital)
<complete-campaign-log-digital>
````markdown
---
title: Clearview Mystery
ruleset: Loner + Mythic Oracle
genre: Teen mystery / supernatural
player: Roberto
pcs: Alex [PC:Alex|HP 8|Stress 0]
start_date: 2025-09-03
last_update: 2025-10-28
---

# Clearview Mystery

## Session 1
*Date: 2025-09-03 | Duration: 1h30*

### S1 *School library after hours*

```
@ Sneak inside to check the archives
d: Stealth d6=5 vs TN 4 -> Success
=> I slip inside unnoticed. [L:Library|dark|quiet]

? Is there a strange clue waiting?
-> Yes (d6=6)
=> I find a torn diary page about the lighthouse. [E:LighthouseClue 1/6]
```

The page is yellowed with age. The handwriting is shaky: "The light 
calls to us. We must not answer."

```
[Thread:Lighthouse Mystery|Open]
```

### S2 *Outside the library, empty hall*

```
? Do I hear footsteps?
-> Yes, but... (d6=4)
=> A janitor approaches, but he doesn't notice me yet. [N:Janitor|tired|suspicious]
```

I freeze. His keys jangle as he walks past the doorway.

N (Janitor): "Thought I heard something..."
PC (Alex, whisper): "Gotta get out of here."

```
@ Slip out while he's distracted
d: Stealth d6=6 vs TN 4 -> Success
=> I escape into the night safely.
```
## Session 2
*Date: 2025-09-10 | Duration: 2h*

**Recap:** Found diary page hinting at lighthouse. Nearly spotted in library.

### S3 *Path to the old lighthouse, Day 2*

```
@ Approach quietly at dusk
d: Stealth d6=2 vs TN 4 -> Fail
=> I step on broken glass, crunching loudly. [Clock:Suspicion 1/6]

? Does anyone respond from inside?
-> No, but... (d6=3)
=> The light flickers briefly in the tower window. [L:Lighthouse|ruined|haunted]
```

### S4 *Inside lighthouse foyer*

```
@ Search the floor for signs of activity
d: Investigation d6=6 vs TN 4 -> Success
=> I find fresh footprints in the dust. [Thread:Who is using the lighthouse?|Open]

tbl: d100=42 -> "A broken lantern"
=> A cracked lantern lies near the stairs. [E:LighthouseClue 2/6]
```

Someone's been here. Recently.

PC (Alex, thinking): "This place isn't as abandoned as everyone thinks..."
````

== 6.5 Complete Campaign Log (Analog)
<complete-campaign-log-analog>
```
=== Campaign Log: Clearview Mystery ===
[Title]        Clearview Mystery
[Ruleset]      Loner + Mythic Oracle
[Genre]        Teen mystery / supernatural
[Player]       Roberto
[PCs]          Alex [PC:Alex|HP 8|Stress 0]
[Start Date]   2025-09-03
[Last Update]  2025-10-28

=== Session 1 ===
[Date]        2025-09-03
[Duration]    1h30

S1 *School library after hours*

@ Sneak inside to check the archives
d: Stealth d6=5 vs TN 4 -> Success
=> I slip inside unnoticed. [L:Library|dark|quiet]

? Is there a strange clue waiting?
-> Yes (d6=6)
=> I find a torn diary page about the lighthouse. [E:LighthouseClue 1/6]

The page is yellowed. Shaky writing: "The light calls to us."

[Thread:Lighthouse Mystery|Open]

S2 *Outside the library, empty hall*

? Do I hear footsteps?
-> Yes, but... (d6=4)
=> A janitor approaches, but doesn't notice me yet. [N:Janitor|tired|suspicious]

N (Janitor): "Thought I heard something..."
PC (Alex): "Gotta get out of here."

@ Slip out while distracted
d: Stealth d6=6 vs TN 4 -> Success
=> I escape into the night safely.

=== Session 2 ===
[Date]        2025-09-10
[Duration]    2h
[Recap]       Found diary page, nearly spotted in library.

S3 *Path to lighthouse, Day 2*

@ Approach quietly at dusk
d: Stealth d6=2 vs TN 4 -> Fail
=> I step on broken glass. [Clock:Suspicion 1/6]

? Does anyone respond?
-> No, but... (d6=3)
=> Light flickers in tower window. [L:Lighthouse|ruined|haunted]

S4 *Inside lighthouse foyer*

@ Search floor for signs
d: Investigation d6=6 vs TN 4 -> Success
=> Fresh footprints in dust. [Thread:Who uses lighthouse?|Open]

tbl: d100=42 -> "A broken lantern"
=> Cracked lantern near stairs. [E:LighthouseClue 2/6]

PC (Alex): "This place isn't as abandoned as everyone thinks..."
```

= 7. Best Practices
<best-practices>
You've learned the notation---now let's talk about using it well. This section shows proven patterns that make your logs clearer and more useful, plus common mistakes to avoid.

Think of these as guidelines from the solo community's collective experience. They're not rigid rules, but they'll help you create logs that are easy to read, reference, and share.

== 7.1 Good Practices ✓
<good-practices>
These patterns make your logs cleaner, more searchable, and easier to reference later. You don't need to follow all of them, but they represent what works well for most solo players.

#strong[Do: Keep actions and rolls connected]

```
@ Pick the lock
d: d20=15 vs DC 14 -> Success
=> The door swings open silently.
```

#strong[Do: Use tags for persistent elements]

```
[N:Jonah|friendly|wounded]
[L:Lighthouse|ruined]
```

#strong[Do: Record consequences clearly]

```
=> I find the key. [E:Clue 2/4]
=> But the guard heard me. [Clock:Alert 1/6]
```

#strong[Do: Use reference tags in later scenes]

```
First mention: [N:Jonah|friendly]
Later: [#N:Jonah] approaches cautiously
```

#strong[Do: Mix shorthand and narrative as needed]

```
@ Sneak past guard
d: 5≥4 S -> Success
=> I slip by unnoticed, heart pounding.
```

== 7.2 Bad Practices ✗
<bad-practices>
These are common pitfalls that make logs harder to read or parse. If you catch yourself doing these, don't worry---just adjust for next time. We've all been there!

#strong[Don't: Bury mechanics in prose]

```
❌ I tried to pick the lock and rolled a 15 which beat the DC so I opened it

✔️ @ Pick the lock
  d: 15≥14 -> Success
  => The door opens quietly.
```

#strong[Don't: Forget to record consequences]

```
❌ @ Attack the guard
  d: 8≤10 -> Fail

✔️ @ Attack the guard
  d: 8≤10 -> Fail
  => My blade glances off his armor. He counterattacks!
```

#strong[Don't: Lose track of tags across scenes]

```
❌ [N:Guard|alert] ... then later ... [N:Guard|sleeping]
   (How did this change? When?)

✔️ [N:Guard|alert] ... then later ...
  @ Knock him out
  d: 6≥5 S => [N:Guard|unconscious]
```

#strong[Don't: Mix action and oracle symbols]

```
❌ ? Sneak past guards    (This is an action, not a question)

✔️ @ Sneak past guards    (Actions use @)
  ? Do they notice?      (Questions use ?)
```

#strong[Don't: Forget scene context]

```
❌ S7
  @ Sneak past guards
  
✔️ S7 *Dark alley, midnight*
  @ Sneak past guards
```

= 8. Templates
<templates>
Starting from a blank page can be daunting. These templates give you a structured starting point---copy them, fill in the blanks, and start playing.

Each template comes in both #strong[digital markdown] and #strong[analog notebook] formats. Choose whichever matches your play style, or use them as inspiration to create your own.

Don't treat these as rigid forms. They're scaffolding. Once you're comfortable with the notation, you'll probably develop your own templates that fit your specific needs better.

== 8.1 Campaign Template (Digital YAML)
<campaign-template-digital-yaml>
For digital markdown files, use YAML front matter to store campaign metadata. This goes at the very top of your file, before any other content.

Copy this template, fill in your details, and you're ready to start your first session.

```yaml
title: 
ruleset: 
genre: 
player: 
pcs: 
start_date: 
last_update: 
tools: 
themes: 
tone: 
notes: 
```

```
# [Campaign Title]

## Session 1
*Date: | Duration: *

### S1 *Starting scene*

Your play log here...
```

== 8.2 Campaign Template (Analog)
<campaign-template-analog>
For paper notebooks, write this header block at the start of your campaign log. Keep it simple---you can always add more details later if needed.

```
=== Campaign Log: [Title] ===
[Title]        
[Ruleset]      
[Genre]        
[Player]       
[PCs]          
[Start Date]   
[Last Update]  
[Tools]        
[Themes]       
[Tone]         
[Notes]        

=== Session 1 ===
[Date]        
[Duration]    

S1 *Starting scene*

Your play log here...
```

== 8.3 Session Template
<session-template>
Use this at the start of each play session to mark boundaries and provide context. The digital version uses markdown headings; the analog version uses written headers.

Fill in what's useful and skip what's not. The only essential field is the date---everything else is optional.

#strong[Digital:]

```markdown
## Session X
*Date: | Duration: | Scenes: *

**Recap:** 

**Goals:** 

### S1 *Scene description*
```

#strong[Analog:]

```
=== Session X ===
[Date]        
[Duration]    
[Recap]       
[Goals]       

S1 *Scene description*
```

== 8.4 Quick Scene Template
<quick-scene-template>
This is your workhorse template---the basic structure you'll use scene after scene. It's intentionally minimal: just enough structure to keep you oriented without slowing you down.

Use this as your default starting point for every scene, whether you're playing digitally or analog.

````markdown
S# *Location, time*
```
@ Your action
d: your roll -> outcome
=> What happens

? Your question
-> Oracle answer
=> What it means
```
````

= 9. Adapting to Your System
<adapting-to-your-system>
Here's the beautiful part: this notation works with #emph[any] solo RPG system. #emph[Ironsworn];, #emph[Mythic GME];, #emph[Thousand Year Old Vampire];, your own homebrew---doesn't matter. The core symbols stay the same; only the resolution details change.

This section shows you how to adapt the `d:` roll notation and `->` oracle formats to match your specific game system. We'll cover common systems (PbtA, FitD, Ironsworn, OSR) and oracles (Mythic, CRGE, MUNE), but the principles work for anything.

#strong[The key insight:] The notation separates #emph[mechanics] from #emph[fiction];. Your system determines how mechanics work; the notation just records them consistently.

== 9.1 System-Specific Roll Notation
<system-specific-roll-notation>
The `d:` notation works with any system---you just need to adapt it to your specific dice mechanics. Here's how the notation looks across popular solo RPG systems.

These examples show the pattern: record what you rolled, compare it to what you needed, note the outcome. The details change by system, but the structure stays the same.

=== 9.1.1 Powered by the Apocalypse (PbtA)
<powered-by-the-apocalypse-pbta>
```
d: 2d6=9 -> Strong Hit (10+)
d: 2d6=7 -> Weak Hit (7-9)
d: 2d6=4 -> Miss (6-)
```

=== 9.1.2 Forged in the Dark (FitD)
<forged-in-the-dark-fitd>
```
d: 4d6=6,5,4,2 (take highest=6) -> Critical Success
d: 3d6=4,4,2 -> Partial Success (4-5)
d: 2d6=3,2 -> Failure (1-3)
```

=== 9.1.3 Ironsworn
<ironsworn>
```
d: Action=7+Stat=2=9 vs Challenge=4,8 -> Weak Hit
d: Action=10+Stat=3=13 vs Challenge=2,7 -> Strong Hit
```

=== 9.1.4 Fate/Fudge
<fatefudge>
```
d: 4dF=+2 (++0-) +Skill=3 = +5 -> Success with Style
d: 4dF=-1 (-0--) +Skill=2 = +1 -> Tie
```

=== 9.1.5 OSR/Traditional D&D
<osrtraditional-dd>
```
d: d20=15+Mod=2=17 vs AC 16 -> Hit
d: d20=8+Mod=-1=7 vs DC 10 -> Fail
```

== 9.2 Oracle Adaptations
<oracle-adaptations>
Different oracle systems have different output formats. Some give yes/no answers, others generate complex results. Here's how to record results from popular oracle systems.

The key is consistency: always use `->` for oracle results, then capture whatever information your oracle provides.

=== 9.2.1 Mythic GME
<mythic-gme>
```
? Does the guard notice me? (Likelihood: Unlikely)
-> No, but... (CF=4)
=> He doesn't see me, but he's suspicious.
```

=== 9.2.2 CRGE (Conjectural Roleplaying Game Engine)
<crge-conjectural-roleplaying-game-engine>
```
? What is the merchant's mood?
-> Surge: Actor + Focus => Angry + Betrayal
=> The merchant is furious about being cheated.
```

=== 9.2.3 MUNE (Madey Upy Number Engine)
<mune-madey-upy-number-engine>
```
? Is anyone home?
-> Likely + roll 2,4 => Yes
=> Lights are on, someone's definitely inside.
```

=== 9.2.4 UNE (Universal NPC Emulator)
<une-universal-npc-emulator>
```
gen: UNE Motivation -> Power + Reputation
=> [N:Baron|ambitious|seeks recognition]
```

== 9.3 Handling Edge Cases
<handling-edge-cases>
Every system has quirks. Here's how to handle common situations that don't fit the basic notation patterns.

=== 9.3.1 Multiple Rolls in One Action
<multiple-rolls-in-one-action>
When you need to make multiple rolls for one action:

#strong[Advantage/Disadvantage:]

```
@ Attack with advantage
d: 2d20=15,8 (take higher) vs TN 12 -> 15≥12 Success
=> I strike true, blade finding a gap in the armor.
```

#strong[Multiple dice pools:]

```
@ Perform complex ritual
d: INT d6=4, WILL d6=5, vs TN 4 each -> Both succeed
=> The spell takes hold, energy crackling between my fingers.
```

#strong[Contested rolls:]

```
@ Arm wrestle the sailor
d: STR d20=12 vs sailor d20=15 -> 12≤15 Fail
=> His grip tightens. My arm slams to the table.
```

=== 9.3.2 Ambiguous Oracle Results
<ambiguous-oracle-results>
When the oracle gives unclear or contradictory results:

```
? Is the merchant trustworthy?
-> Yes, but... (d6=4)
(note: "but" contradicts "yes"—interpreting as: trustworthy but hiding something)
=> He seems honest, but keeps glancing at the door nervously.
```

Or re-roll if truly stuck:

```
? Can I trust him?
-> Unclear result (d6=3 on binary oracle)
(note: re-rolling with different framing)
? Is he trying to help me?
-> No, and... (d6=2)
=> He's actively working against me.
```

=== 9.3.3 Nested Consequences
<nested-consequences>
Sometimes one consequence leads to another, creating a cascade:

```
d: Lockpicking 5≥4 -> Success
=> The door opens
=> But the hinges squeal loudly
=> Guards in the next room hear it [E:AlertClock 1/6]
=> One starts walking this way [N:Guard|investigating]
```

#strong[When to use:] Major successes or failures with multiple ripple effects. Don't overuse---most actions have one clear consequence.

=== 9.3.4 Failed Oracle Questions
<failed-oracle-questions>
What if the oracle doesn't help?

```
? What's behind the door?
-> [Roll unclear/contradictory]
(note: asking a more specific question)
? Is there danger behind the door?
-> Yes, and...
=> Danger, and it's immediate!
```

#strong[Pro tip:] If an oracle result doesn't spark fiction, it's okay to re-frame the question or roll again. The oracle serves your story, not the other way around.

= Appendices
<appendices>
== A. Solo RPG Notation Legend
<a.-solo-rpg-notation-legend>
This is your quick reference---the cheat sheet to keep handy while you play. Forget what `=>` means? Need to remember how to format a clock? This section has you covered.

Think of it as the notation's "vocabulary list." Everything here has been explained earlier in detail; this is just the condensed version for fast lookup.

Bookmark this section. You'll come back to it often in your first few sessions, then less and less as the notation becomes second nature.

=== A.1 Core Symbols
<a.1-core-symbols>
#table(
  columns: 3,
  align: (auto,auto,auto,),
  table.header([Symbol], [Meaning], [Example],),
  table.hline(),
  [`@`], [Player action (mechanics)], [`@ Pick the lock`],
  [`?`], [Oracle question (world/uncertainty)], [`? Is anyone inside?`],
  [`d:`], [Mechanics roll/result], [`d: 2d6=8 vs TN 7 -> Success`],
  [`->`], [Oracle/dice result], [`-> Yes, but...`],
  [`=>`], [Consequence/outcome], [`=> The door opens quietly`],
)
=== A.2 Comparison Operators
<a.2-comparison-operators>
- `≥` or `>=` --- Greater than or equal (meets/beats TN)
- `≤` or `<=` --- Less than or equal (fails to meet TN)
- `vs` --- Versus (explicit comparison)
- `S` --- Success flag
- `F` --- Fail flag

=== A.3 Tracking Tags
<a.3-tracking-tags>
- `[N:Name|tags]` --- NPC (first mention)
- `[#N:Name]` --- NPC (reference to earlier mention)
- `[L:Name|tags]` --- Location
- `[E:Name X/Y]` --- Event/Clock
- `[Thread:Name|state]` --- Story thread
- `[PC:Name|stats]` --- Player character

=== A.4 Progress Tracking
<a.4-progress-tracking>
- `[Clock:Name X/Y]` --- Clock (fills up)
- `[Track:Name X/Y]` --- Progress track
- `[Timer:Name X]` --- Countdown timer

=== A.5 Random Generation
<a.5-random-generation>
- `tbl: roll -> result` --- Simple table lookup
- `gen: system -> result` --- Complex generator

=== A.6 Structure
<a.6-structure>
- `S#` or `S#a` --- Scene number
- `T#-S#` --- Thread-specific scene

=== A.7 Narrative (Optional)
<a.7-narrative-optional>
- Inline: `=> Prose here`
- Dialogue: `N (Name): "Speech"`
- Block: `--- text ---`

=== A.8 Meta
<a.8-meta>
- `(note: ...)` --- Reflection, reminder, house rule

=== A.9 Complete Example Line
<a.9-complete-example-line>
```
S3 @Pick lock d:15≥14 S => door opens quietly [N:Guard|alert]
```

= B. FAQ
<b.-faq>
Got questions? You're not alone. These are the most common questions from people learning the notation, along with straight answers.

If your question isn't here, remember: the notation is flexible. If you're wondering whether you can do something differently, the answer is probably "yes, if it works for you."

#strong[Q: Do I need to use every element?] \
A: No! Start with just `@`, `?`, `d:`, `->`, and `=>`. Add other elements only if they help you.

#strong[Q: Can I use this with traditional RPGs (with a GM)?] \
A: The core notation works great for any RPG notes. The oracle elements (`?`, `->`) are specifically for solo play, but the action/resolution notation works everywhere.

#strong[Q: What if my system doesn't use dice?] \
A: Use `d:` for any resolution mechanic: `d: Draw from deck -> Queen of Spades`, `d: Spend token -> Success`

#strong[Q: Should I use digital or analog format?] \
A: Whichever you prefer! They use the same notation. Digital has better search/organization; analog is immediate and tactile.

#strong[Q: How detailed should my notes be?] \
A: As detailed as you want! The system works for pure shorthand (Example 6.1) or rich narrative (Example 6.4).

#strong[Q: Can I share my logs with others?] \
A: Yes! That's one reason for standardized notation. Others familiar with the system can read your logs easily.

#strong[Q: What about house rules or custom symbols?] \
A: Document them in meta notes: `(note: using + for advantage, - for disadvantage)`. The system is designed to be extended.

#strong[Q: Do scene numbers have to be sequential?] \
A: No.~Use `S1`, `S2`, `S3` for simplicity, but branch (`S3a`, `S3b`) or use thread prefixes (`T1-S1`) if helpful.

#strong[Q: Should I update tags every time something changes?] \
A: Show significant changes explicitly: `[N:Guard|alert]` → `[N:Guard|unconscious]`. Minor changes can be implied through narrative.

= C. Symbol Design Philosophy
<c.-symbol-design-philosophy>
Lonelog's symbols were chosen for specific reasons:

- #strong[`@` (Action)];: Represents "at this point" or the actor taking action. Changed from `>` in v2.0 to avoid conflict with Markdown blockquotes.

- #strong[`?` (Question)];: Universal symbol for inquiry. Unchanged from v2.0.

- #strong[`d:` (Dice/Resolution)];: Clear abbreviation for dice rolls. Unchanged from v2.0.

- #strong[`->` (Resolution)];: Retained from v2.0. Now unified for ALL resolutions (dice and oracle). The arrow visually shows "this leads to outcome."

- #strong[`=>` (Consequence)];: Retained from v2.0. Double arrow shows cascading effects. Clarified usage: consequences only (v2.0 overloaded this for dice outcomes too).

#strong[Markdown Compatibility];: All symbols work cleanly in code blocks and don't conflict with markdown formatting or mathematical operators. Always wrap notation in code blocks when using digital markdown to prevent conflicts with Markdown extensions.

= Credits & License
<credits-license>
© 2025-2026 Roberto Bisceglie

This notation is inspired by the #link("https://alfredvalley.itch.io/the-valley-standard")[Valley Standard];.

#strong[Thanks to:]

- matita for the `+`/`-` method to track changes in tags
- flyincaveman for the suggestion on the use of the `@` symbol for character actions (in the tradition of the early ASCII rpgs)
- r/solorpgplay and r/Solo\_Roleplaying for the positive reception of this notation and the useful feedbacks.
- Enrico Fasoli for playtesting and feedback

#strong[Version History:]

- v 1.0.0: Evolved from Solo TTRPG Notation v2.0 by Roberto Bisceglie

This work is licensed under the #strong[Creative Commons Attribution-ShareAlike 4.0 International License];.

#strong[You are free to:]

- Share --- copy and redistribute the material
- Adapt --- remix, transform, and build upon the material

#strong[Under these terms:]

- Attribution --- Give appropriate credit
- ShareAlike --- Distribute adaptations under the same license

#emph[Happy adventuring, solo players!]
