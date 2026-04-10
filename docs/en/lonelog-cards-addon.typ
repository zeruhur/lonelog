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
  title: "Lonelog: Card Notation Add-on",
  subtitle: "A Standard Notation for Playing Cards in Session Logs",
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
Core Lonelog already acknowledges card draws as a valid resolution mechanic. What it doesn't define is a compact, unambiguous shorthand for card identities.

Without a standard, logs fill with inconsistent spellings: "Q of spades", "queen♠", "Queen Spades", "QS". Tarot draws fare worse --- "reversed Tower" and "The Tower (rev.)" and "XVI r" are all the same card. For tools that parse logs, and for players who share them, the inconsistency creates friction.

This add-on defines a compact notation for three types of card draws:

- #strong[Standard playing cards] --- the 52-card deck plus jokers
- #strong[Tarot] --- Major Arcana, Minor Arcana, and upright/reversed orientation
- #strong[Oracle decks] --- a lightweight convention for named-card systems

#strong[When not to use this add-on:] If you play a single system with a single card type and never share logs, your current spelling probably works fine. Adopt this notation when consistency matters --- for shared logs, tool support, or crossing between multiple card systems in one campaign.

#pagebreak()
== What This Add-on Adds
<what-this-add-on-adds>
#table(
  columns: (25.71%, 25.71%, 48.57%),
  align: (auto,auto,auto,),
  table.header([Element], [Purpose], [Example in a log],),
  table.hline(),
  [`{rank}{suit}`], [Compact standard card identity], [`d: draw=Qs -> Dark omen`],
  [`M{n}`], [Major Arcana by number], [`d: draw=M12r -> Blocked`],
  [`{rank}{suit}` with tarot suits], [Minor Arcana], [`d: draw=KnCu`],
  [`r` suffix], [Reversed orientation (Tarot)], [`d: draw=M16r`],
  [Position labels in spreads], [Named positions in a multi-card spread], [`d: Past=5s, Present=Ks`],
)
#strong[No new core symbols.] Card draws use `d:` and `->` exactly as defined in core Lonelog. The card identity uses `=` as the drawn result; `->` carries the interpreted outcome.

== Design Principles
<design-principles>
#strong[Cards follow the same pattern as dice.] `=` records the drawn card, `->` carries the interpreted outcome, `=>` carries the narrative consequence. `d: draw=Qs -> Dark omen` is the same structure as `d: Strike 2d6+2=9 -> Hit`.

#strong[Compact but readable.] `Qs` over "Queen of Spades". Abbreviations should be recoverable without a lookup table by anyone who knows the card system.

#strong[No orientation assumption.] Upright is the default and unmarked. Reversed is the exception and is always marked with `r`. A card with no suffix is always upright.

#pagebreak()
= Part I: Practical Reference
<part-i-practical-reference>
== How card draws fit into a log entry
<how-card-draws-fit-into-a-log-entry>
Card draws follow the same structure as dice rolls. The card drawn is the raw result and uses `=`; the interpreted outcome uses `->`.

```
d: draw=Qs
d: draw=M12r -> The obstacle is myself.
=> The Hanged Man reversed. I've been the obstacle all along.
```

For oracle reads that answer a question, pair with `?`:

```
? Can I trust the merchant?
d: draw=Jc -> Scheming youth
=> No.
```

For spreads, label each position with `=`:

```
d: Past=5s, Present=Ks, Future=ACu
```

#pagebreak()
Or split across lines when each card needs its own consequence:

```
d: Past=5s
d: Present=Ks
d: Future=ACu
=> Conflict led here. Authority holds the present. Something new waits at the end.
```

#pagebreak()
== Standard Playing Cards
<standard-playing-cards>
Ranks: `A`, `2`--`10`, `J`, `Q`, `K` \
Suits: `h` (hearts ♥), `d` (diamonds ♦), `c` (clubs ♣), `s` (spades ♠) \
Format: `{rank}{suit}`

```
Ah    Ace of Hearts
7c    Seven of Clubs
Ks    King of Spades
10d   Ten of Diamonds
Jh    Jack of Hearts
```

Jokers: `Jkr` (generic), `RJkr` (red joker), `BJkr` (black joker).

When the game cares about color but not suit: `R` (red --- hearts or diamonds), `B` (black --- clubs or spades).

In a log:

```
@ Search the body
d: draw=3h -> Minor find
=> A folded note, damp and illegible.

@ Fate check
d: draw=Jkr -> Chaos surge
=> Everything changes.
```

#pagebreak()
== Tarot
<tarot>
=== Major Arcana
<major-arcana>
Format: `M{n}` where `n` is the card's number (0--21).

#table(
  columns: 4,
  align: (auto,auto,auto,auto,),
  table.header([n], [Card], [n], [Card],),
  table.hline(),
  [0], [The Fool], [11], [Justice],
  [1], [The Magician], [12], [The Hanged Man],
  [2], [The High Priestess], [13], [Death],
  [3], [The Empress], [14], [Temperance],
  [4], [The Emperor], [15], [The Devil],
  [5], [The Hierophant], [16], [The Tower],
  [6], [The Lovers], [17], [The Star],
  [7], [The Chariot], [18], [The Moon],
  [8], [Strength], [19], [The Sun],
  [9], [The Hermit], [20], [Judgement],
  [10], [Wheel of Fortune], [21], [The World],
)
Reversed: append `r`.

```
d: draw=M0       The Fool, upright
d: draw=M16r     The Tower, reversed
```

When space allows, add the name as an inline description:

```
d: draw=M12 // The Hanged Man
d: draw=M16r // The Tower reversed
```

=== Minor Arcana
<minor-arcana>
Suits: `Wa` (Wands), `Cu` (Cups), `Sw` (Swords), `Pe` (Pentacles) \
Ranks: `A`, `2`--`10`, `Pg` (Page), `Kn` (Knight), `Q`, `K` \
Format: `{rank}{suit}`

```
ACu     Ace of Cups
7Wa     Seven of Wands
PgSw    Page of Swords
KnPe    Knight of Pentacles
QCu     Queen of Cups
KWa     King of Wands
```

Reversed: append `r`.

```
d: draw=5Swr    Five of Swords, reversed
d: draw=KnCu    Knight of Cups, upright
```

In a log:

```
? What force opposes me here?
d: draw=KSw -> Adversary: principle, not malice
=> The King of Swords — cold logic. He acts on conviction, not cruelty.
```

#pagebreak()
== Oracle Decks
<oracle-decks>
Oracle decks use proprietary card names that cannot be standardized. Use the card's name as free text with `=`, optionally with an inline description naming the deck.

```
d: draw // Ironsworn Oracle=Darkness and Shadow
d: draw // Mythic Fate=Exceptional Yes -> Yes, and...
d: draw // Crow's Eye Oracle=The Lantern -> Safe passage
```

For decks you use repeatedly, a short deck tag in the `d:` label keeps things scannable:

```
d: Crow=The Lantern -> Safe passage
d: Crow=The Abyss -> Something follows
```

#pagebreak()
== Spreads
<spreads>
A spread is a multi-card draw where each card occupies a named position. Write position labels with `=` for each card.

#strong[Single-line (compact, for short spreads):]

```
d: Past=5s, Present=Ks, Future=ACu
```

#strong[Multi-line (when each card needs interpretation space):]

```
d: Past=M16r -> Collapse that was delayed, not avoided.
=> The Tower reversed. I should have fallen sooner.

d: Present=KWa -> I am the force at work here.
=> The King of Wands. The fire is mine to wield or waste.

d: Future=ACu -> Something new if I let go.
=> The Ace of Cups. Grief first, then an opening.
```

#strong[Labeled spread with deck name:]

```
d: Celtic Past=7Wa, Celtic Present=M12, Celtic Future=3Cu
```

#pagebreak()
== Common Patterns by System
<common-patterns-by-system>
#strong[Standard deck as oracle (e.g.~#emph[Carta];, #emph[For the Queen];):]

```
@ Explore the next hex
d: draw=7d -> Forest path
=> Tall pines, no trail. I mark it as unmapped.
```

#strong[Tarot for scene framing:]

```
? What is the mood of this place?
d: draw=M18 // The Moon -> Illusion, hidden things
=> Nothing here is what it seems.
```

#strong[Fate deck for #emph[Ironsworn] variants:]

```
d: Oracle 2d10=47 -> Yes, and...
d: draw=Ks -> Complication: authority figure
=> The bridge is there, but a city guard holds the crossing.
```

#strong[Reversed card as obstacle:]

```
? Does my contact show up?
d: draw=M6r // The Lovers reversed -> Divided loyalties
=> He's here, but he brought someone I didn't expect.
```

#strong[Horror game --- Joker as catastrophe trigger:]

```
d: draw=RJkr -> The Worst Thing
=> The lights go out across the whole building. Something found the generator.
```

#pagebreak()
= Part II: Complete Reference
<part-ii-complete-reference>
#pagebreak()
= 1. Standard Deck Notation
<standard-deck-notation>
== Ranks
<ranks>
#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Symbol], [Card],),
  table.hline(),
  [`A`], [Ace],
  [`2`--`10`], [Number cards],
  [`J`], [Jack],
  [`Q`], [Queen],
  [`K`], [King],
)
== Suits
<suits>
#table(
  columns: 3,
  align: (auto,auto,auto,),
  table.header([Symbol], [Suit], [Color],),
  table.hline(),
  [`h`], [Hearts ♥], [Red],
  [`d`], [Diamonds ♦], [Red],
  [`c`], [Clubs ♣], [Black],
  [`s`], [Spades ♠], [Black],
)
== Jokers
<jokers>
#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Symbol], [Card],),
  table.hline(),
  [`Jkr`], [Joker (generic, when color doesn't matter)],
  [`RJkr`], [Red Joker],
  [`BJkr`], [Black Joker],
)
== Color Shorthand
<color-shorthand>
When a system cares about red/black but not the specific suit:

#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Symbol], [Meaning],),
  table.hline(),
  [`R`], [Red card (hearts or diamonds)],
  [`B`], [Black card (clubs or spades)],
)
== Full Card Examples
<full-card-examples>
```
Ah    Ace of Hearts
2c    Two of Clubs
10d   Ten of Diamonds
Jh    Jack of Hearts
Qs    Queen of Spades
Kd    King of Diamonds
Jkr   Joker
```

#strong[Note:] `10d` (Ten of Diamonds) is two characters before the suit. All other ranks are one character. Parsers should treat `10` as a complete rank token.

= 2. Tarot Notation
<tarot-notation>
== Major Arcana
<major-arcana-1>
#strong[Format:] `M{n}` where `n` is 0--21.

#strong[Reversed:] append `r` --- `M0r`, `M16r`.

#table(
  columns: 4,
  align: (auto,auto,auto,auto,),
  table.header([n], [Card], [Symbol], [Reversed],),
  table.hline(),
  [0], [The Fool], [`M0`], [`M0r`],
  [1], [The Magician], [`M1`], [`M1r`],
  [2], [The High Priestess], [`M2`], [`M2r`],
  [3], [The Empress], [`M3`], [`M3r`],
  [4], [The Emperor], [`M4`], [`M4r`],
  [5], [The Hierophant], [`M5`], [`M5r`],
  [6], [The Lovers], [`M6`], [`M6r`],
  [7], [The Chariot], [`M7`], [`M7r`],
  [8], [Strength], [`M8`], [`M8r`],
  [9], [The Hermit], [`M9`], [`M9r`],
  [10], [Wheel of Fortune], [`M10`], [`M10r`],
  [11], [Justice], [`M11`], [`M11r`],
  [12], [The Hanged Man], [`M12`], [`M12r`],
  [13], [Death], [`M13`], [`M13r`],
  [14], [Temperance], [`M14`], [`M14r`],
  [15], [The Devil], [`M15`], [`M15r`],
  [16], [The Tower], [`M16`], [`M16r`],
  [17], [The Star], [`M17`], [`M17r`],
  [18], [The Moon], [`M18`], [`M18r`],
  [19], [The Sun], [`M19`], [`M19r`],
  [20], [Judgement], [`M20`], [`M20r`],
  [21], [The World], [`M21`], [`M21r`],
)
#strong[Note:] The Thoth Tarot and some other decks swap the positions of Strength (VIII) and Justice (XI). The `M{n}` notation follows the Rider-Waite-Smith standard (Strength = 8, Justice = 11). If you use a different numbering, note it in your session header.

== Minor Arcana
<minor-arcana-1>
#strong[Suits:]

#table(
  columns: 3,
  align: (auto,auto,auto,),
  table.header([Symbol], [Suit], [Element],),
  table.hline(),
  [`Wa`], [Wands], [Fire],
  [`Cu`], [Cups], [Water],
  [`Sw`], [Swords], [Air],
  [`Pe`], [Pentacles / Coins], [Earth],
)
#strong[Ranks:]

#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Symbol], [Card],),
  table.hline(),
  [`A`], [Ace],
  [`2`--`10`], [Number cards],
  [`Pg`], [Page],
  [`Kn`], [Knight],
  [`Q`], [Queen],
  [`K`], [King],
)
#strong[Format:] `{rank}{suit}` --- `ACu`, `7Wa`, `PgSw`, `KnPe`, `QCu`, `KWa`

#strong[Reversed:] append `r` --- `7War`, `PgSwr`

== Orientation
<orientation>
#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Suffix], [Meaning],),
  table.hline(),
  [#emph[(none)];], [Upright (default)],
  [`r`], [Reversed],
)
= 3. Oracle Decks
<oracle-decks-1>
Oracle decks use proprietary card names. No compact symbol system can cover them all. Use the card's name as free text with `=`.

For logs that use a single oracle deck throughout, establish a short deck prefix in your session header or as a note, then use it consistently:

```
[Session: ...] [Oracle: Crow's Eye]

d: draw=The Lantern -> Safe passage
d: draw=The Abyss -> Something follows
```

For mixed-deck sessions, name the deck inline:

```
d: draw // Crow's Eye=The Lantern
d: draw // Ironsworn Oracle=Darkness and Shadow
```

#pagebreak()
= 4. Spread Notation
<spread-notation>
A spread assigns each drawn card to a named position. The position label appears in the `d:` field with `=` for each card.

== Single-line format
<single-line-format>
```
d: {Position1}={card1}, {Position2}={card2}, ...
```

Example:

```
d: Past=5Sw, Present=KWa, Future=ACu
```

== Multi-line format
<multi-line-format>
Use when each card warrants its own `->` or `=>`:

```
d: {Position}={card} -> [outcome]
=> [Narrative consequence]
```

#pagebreak()
== Common spread names
<common-spread-names>
These are conventions, not requirements. Any position label is valid.

#table(
  columns: (42.11%, 57.89%),
  align: (auto,auto,),
  table.header([Spread], [Positions],),
  table.hline(),
  [Three-card], [`Past`, `Present`, `Future`],
  [Three-card (alt)], [`Situation`, `Action`, `Outcome`],
  [Three-card (alt)], [`Mind`, `Body`, `Spirit`],
  [Celtic Cross], [`Self`, `Cross`, `Foundation`, `Past`, `Crown`, `Future`, `Self2`, `Environment`, `Hopes`, `Outcome`],
  [Single draw], [`draw` (no position label needed)],
)
#pagebreak()
= Quick Reference
<quick-reference>
== Standard Deck
<standard-deck>
```
Ah  Ac  Ad  As    Aces
Kh  Kc  Kd  Ks    Kings
Qh  Qc  Qd  Qs    Queens
Jh  Jc  Jd  Js    Jacks
10h … 2h          Number cards (any suit)
Jkr  RJkr  BJkr   Jokers
R  B                Color only
```

== Tarot
<tarot-1>
```
M0 – M21            Major Arcana (M0 = The Fool, M21 = The World)
M0r                 Reversed Major Arcana

ACu  7Wa  PgSw  KnPe  QCu  KWa   Minor Arcana
7War                              Reversed Minor Arcana

Suits: Wa (Wands)  Cu (Cups)  Sw (Swords)  Pe (Pentacles)
Ranks: A  2–10  Pg  Kn  Q  K
```

== In a Log
<in-a-log>
```
d: draw=Qs                             single draw, no interpretation needed
d: draw=Qs -> Dark omen                single draw with outcome
d: draw=M16r -> Everything breaks      Tarot reversed with outcome
d: draw=M12 // The Hanged Man          draw with name annotation
d: Past=5Sw, Present=KWa               spread, single line
? Is this the right path?
d: draw=M17 -> Yes                     oracle question answered by card
```

#pagebreak()
= FAQ
<faq>
#strong[Q: Why does the card use `=` rather than `->` --- isn't the card itself the outcome?] \
A: The card drawn is the raw result of the mechanic, just as `9` is the raw result of `2d6+2`. What the card #emph[means] in context --- the interpreted state --- is the outcome, and that goes in `->`. `d: draw=Qs -> Dark omen` mirrors `d: Strike 2d6+2=9 -> Hit` exactly.

#strong[Q: What about card games that use multiple decks, or partial decks?] \
A: The notation identifies individual cards, not deck composition. Track deck state in a `[Deck:]` tag or a session note as needed.

#strong[Q: My system uses pip value (Ace = 1, King = 13) rather than card identity. Should I write the card or the number?] \
A: Write the card: `d: draw=Ah -> 1`. The card identity is the raw result; the pip value is the interpreted outcome. Both are preserved.

#strong[Q: How do I note a hand of cards (drawn but not played)?] \
A: List them space-separated: `Hand: Ah Kd 7c Qs 3h`. When one is played, log it as a normal draw.

#strong[Q: Tarot decks vary --- some have different names or art. Does `M12` always mean The Hanged Man?] \
A: This spec follows the Rider-Waite-Smith numbering, which is the most common standard. If your deck diverges (e.g.~Thoth swaps Strength and Justice), note it once in your session header: `[Deck: Thoth — Strength=M11, Justice=M8]`.

#pagebreak()
#strong[Q: Can I use `?` with a card draw instead of `d:`?] \
A: Use `?` for the question, then `d:` for the draw that answers it. They are separate events --- the question is asked, then the card is drawn as the mechanical resolution.

```
? What does fate hold for this meeting?
d: draw=M10 // Wheel of Fortune -> Chance rules all
=> Anything could happen. I prepare for nothing and everything.
```

#strong[Q: What about digital tools that render suit symbols (♥ ♦ ♣ ♠)?] \
A: The letter abbreviations (`h d c s`) are the canonical form for logs. Tools that render logs may substitute suit symbols for display, but the stored notation should use letters to stay plain-text safe.

#pagebreak()
= Credits & License
<credits-license>
© 2026 Roberto Bisceglie

This add-on extends #link("https://zeruhur.itch.io/lonelog")[Lonelog] by Roberto Bisceglie.

#strong[Version History:]

- v1.0.0: Initial release

This work is licensed under the #strong[Creative Commons Attribution-ShareAlike 4.0 International License];.

You are free to share and adapt this material, provided you give appropriate credit and distribute adaptations under the same license. Session logs and play records created using this add-on's notation are your own work and are not subject to this license.
