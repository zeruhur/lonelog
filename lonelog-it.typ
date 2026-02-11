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
  title: "Lonelog",
  subtitle: "Una notazione standard per registrare le tue sessioni di GDR solitario",
  version: "1.0.0",
  authors: ("Roberto Bisceglie", ),
  date: none,
  abstract: none,
  cols: 1,
  lang: "it",
  region: "US",
  section-numbering: none,
  toc: true,
  toc_title: "Indice",
  toc_depth: 2,
  logo-image: "logo.png",
  license-image: "by-sa.png",
  doc,
)

= 1. Introduzione
<introduzione>
Se hai mai giocato a un GDR in solitaria, conosci la sfida: sei nel bel mezzo di una scena emozionante, i dadi rotolano, gli oracoli rispondono alle domande e improvvisamente ti rendi conto: come faccio a catturare tutto questo senza interrompere il flusso?

Forse hai provato a tenere un diario a mano libera (ma diventa subito disordinato), la prosa pura (ma perdi le meccaniche) o gli elenchi puntati (difficili da analizzare in seguito). Questo sistema di notazione offre un approccio diverso: una #strong[notazione abbreviata leggera] che cattura gli elementi essenziali del gioco lasciando spazio a quanta (o poca) narrazione desideri.

== 1.1 Perché "Lonelog"?
<perché-lonelog>
Questo sistema è nato come #strong[Notazione per GDR Solitario];, un nome descrittivo ma ingombrante. Quasi 5.000 download dopo, era chiaro che il concetto risuonasse nella comunità di giocatori. Ma l'uso nel mondo reale ha portato lezioni preziose su cosa ha funzionato, cosa ha causato problemi e dove la notazione potesse evolversi.

Il cambio di nome in #strong[Lonelog] riflette tre intuizioni:

- #strong[Un nome che resta impresso.] "Notazione per GDR Solitario" veniva abbreviato in una dozzina di modi diversi. #emph[Lonelog] è compatto ed evocativo: #emph[Lone] (gioco in solitaria) + #emph[registro] (registro di sessione). Funziona.
- #strong[Un nome che puoi trovare.] Cerca "notazione gdr solitario" e affogherai in risultati generici. Cerca "lonelog" e otterrai #emph[questo sistema];. Pensa a come #strong[Markdown] abbia avuto successo sia come formato che come marchio; non si chiama "Notazione per la formattazione del testo". Lonelog dà a questa notazione un'identità distinta e rintracciabile.
- #strong[Un nome costruito per durare.] Man mano che il sistema matura, avere un'identità chiara rende più facile per la comunità condividere risorse, strumenti e registro di sessione sotto un unico stendardo.

La filosofia di base non è cambiata: separare le meccaniche dalla finzione, restare compatti al tavolo, scalare dalle one-shot alle lunghe campagne e funzionare sia in markdown che nei taccuini cartacei.

== 1.2 Cosa fa Lonelog
<cosa-fa-lonelog>
Pensalo come un linguaggio condiviso per il gioco in solitaria. Che tu stia giocando a #emph[Ironsworn];, #emph[Thousand Year Old Vampire];, a un GDR non in solitaria usando Mythic GME, o al tuo sistema casalingo, questa notazione ti aiuta a:

- #strong[Registrare cosa è successo] senza rallentare il gioco
- #strong[Tracciare elementi in corso] come PNG, luoghi e fili della trama
- #strong[Condividere le tue sessioni] con altri giocatori solitari che capiranno il formato
- #strong[Rivedere le sessioni passate] e trovare rapidamente quel dettaglio cruciale di tre sessioni fa

La notazione è progettata per essere:

- #strong[Flessibile] --- utilizzabile tra diversi sistemi e formati
- #strong[Stratificata] --- funziona sia come rapida abbreviazione che come narrazione espansa
- #strong[Ricercabile] --- tag e codici rendono facile tracciare PNG, eventi e luoghi
- #strong[Agnostica rispetto al formato] --- funziona in file markdown digitali o taccuini analogici

Gli obiettivi della notazione:

- #strong[Rendere i report scritti da persone diverse leggibili a colpo d'occhio:] i simboli standard facilitano la lettura
- #strong[Separare le meccaniche dalla finzione:] i migliori report sono quelli che evidenziano come l'uso di regole e oracoli informi la finzione
- #strong[Avere un sistema modulare e scalabile:] puoi usare i simboli di base o estendere la notazione a tuo piacimento
- #strong[Renderla utile sia per note digitali che analogiche]
- #strong[Conformità ed estensione di markdown per l'uso digitale]

== 1.3 Come Usare Questa Notazione
<come-usare-questa-notazione>
Pensa a questa come a una #strong[cassetta degli attrezzi, non un libro di regole];. Il sistema è completamente modulare: prendi ciò che funziona per te e lascia il resto.

Al suo centro ci sono solo #strong[cinque simboli] (vedi #emph[Sezione 3: Notazione di Base];). Sono scelti con cura per evitare conflitti con la formattazione markdown e gli operatori di confronto. Questi sono il linguaggio minimo di gioco:

- `@` per le azioni del giocatore
- `?` per le domande all'oracolo
- `d:` per le meccaniche dei tiri
- `->` per i risultati dell'oracolo/dadi
- `=>` per le conseguenze

È tutto. #strong[Tutto il resto è opzionale.]

Scene, intestazioni di campagna, intestazioni di sessione, thread, orologi, estratti narrativi---questi sono tutti miglioramenti che puoi aggiungere quando servono al tuo gioco. Vuoi tracciare una lunga campagna? Aggiungi le intestazioni di campagna. Devi seguire trame complesse? Usa i tag dei thread. Giochi una rapida one-shot? Limitati ai cinque simboli di base.

Pensalo come a cerchi concentrici:

- #strong[Notazione di Base] (obbligatoria): Azioni, Risoluzioni, Conseguenze
- #strong[Livelli Opzionali] (si possono aggiungere al bisogno): Elementi Persistenti, Tracciamento dei progressi, Note, ecc.
- #strong[Struttura Opzionale] (per l'organizzazione): Intestazione Campagna, Intestazione Sessione, Scene

#strong[Inizia in piccolo.] Prova la notazione di base per una scena. Se scatta qualcosa, ottimo! Continua. Se hai bisogno di altro, aggiungi ciò che ti aiuta. Le tue note dovrebbero servire il tuo gioco, non il contrario.

== 1.4 Quick Start: La Tua Prima Sessione
<quick-start-la-tua-prima-sessione>
Non hai mai usato la notazione prima d'ora? Ecco tutto ciò di cui hai bisogno:

```
S1 *La tua scena iniziale*
@ Azione che compi
d: il tuo risultato del tiro -> Successo o Fallimento
=> Cosa succede di conseguenza

? Domanda che poni all'oracolo
-> Risposta dell'oracolo
=> Cosa significa nella storia
```

#strong[Ecco fatto!] Tutto il resto è opzionale. Prova questo per una scena e vedi come ti senti.

=== Esempio Quick Start
<esempio-quick-start>
```
S1 *Vicolo buio, mezzanotte*
@ Superare la guardia furtivamente
d: Furtività 4 vs CD 5 -> Fallimento
=> Calcio una bottiglia. La guardia si gira!

? Mi vede chiaramente?
-> No, ma...
=> È sospettoso, inizia a camminare verso il rumore
```

== 1.5 Migrazione da Notazione per GDR solitario v2.0
<migrazione-da-notazione-per-gdr-solitario-v2.0>
Se stai già usando Notazione per GDR solitario v2.0, benvenuto! Lonelog è un'evoluzione di quel sistema con simboli chiariti per una migliore coerenza.

#strong[Cosa è Cambiato:]

#table(
  columns: (33.33%, 33.33%, 33.33%),
  align: (auto,auto,auto,),
  table.header([Simbolo v2.0], [Simbolo Lonelog], [Perché il Cambiamento],),
  table.hline(),
  [`>`], [`@`], [Evita conflitti con i blockquote di Markdown],
  [`->` (solo oracolo)], [`->` (tutte le risoluzioni)], [Ora unificato sia per i risultati dei dadi CHE dell'oracolo],
  [`=>` (sovraccaricato)], [`=>` (solo conseguenze)], [Chiarito---non funge più da esito dei dadi],
)
#strong[Chiarimento chiave:] Nella v2.0, `=>` veniva usato confusamente sia per gli esiti dei dadi che per le conseguenze. Lonelog chiarisce questo utilizzando `->` per TUTTE le risoluzioni (dadi e oracolo), riservando `=>` esclusivamente alle conseguenze.

=== I Tuoi Vecchi Log Sono Ancora Validi
<i-tuoi-vecchi-log-sono-ancora-validi>
La struttura e la filosofia rimangono identiche. I tuoi registro esistenti sono perfettamente leggibili---non hai bisogno di convertirli a meno che tu non voglia coerenza in tutta la tua campagna.

=== Conversione
<conversione>
Se preferisci la conversione manuale, usa il trova & sostituisci nel tuo editor di testo:

+ Trova: `>` (all'inizio delle righe) → Sostituisci con: `@`
+ I simboli `->` e `=>` sono mantenuti ma con un utilizzo chiarito

= 2. Formati Digitali vs Analogici
<formati-digitali-vs-analogici>
Questa notazione funziona #strong[sia in file markdown digitali che in taccuini analogici];. Scegli il formato che meglio si adatta al tuo stile di gioco.

== 2.1 Formato Digitale (Markdown)
<formato-digitale-markdown>
Nei file markdown digitali:

- #strong[Metadati della campagna] → Intestazione YAML (in cima al file)
- #strong[Titolo della Campagna] → Intestazione di livello 1
- #strong[Sessioni] → Intestazioni di livello 2 (`## Sessione 1`)
- #strong[Scene] → Intestazioni di livello 3 (`### S1`)
- #strong[Notazione di base e tracciamento] → Blocchi di codice per facilitare la copia/analisi
- #strong[Narrativa] → Prosa regolare tra i blocchi di codice

#quote(block: true)[
#strong[Nota:] Incapsula sempre la notazione in blocchi di codice quando usi il markdown digitale. Questo previene conflitti con la sintassi Markdown e assicura che simboli come `=>` siano renderizzati correttamente. Alcune estensioni Markdown (Mermaid, plugin Obsidian) potrebbero interpretare `=>` al di fuori dei blocchi di codice.
]

== 2.2 Formato Analogico (Taccuini)
<formato-analogico-taccuini>
Nei taccuini cartacei:

- Scrivi intestazioni e metadati direttamente come mostrato
- La notazione di base funziona in modo identico ma senza i blocchi di codice
- Usa gli stessi simboli e la stessa struttura
- Parentesi e tag aiutano a scansionare le pagine cartacee

== 2.3 Esempi di Formato
<esempi-di-formato>
=== Markdown digitale
<markdown-digitale>
```markdown
## Sessione 1
*Data: 03-09-2025 | Durata: 1h30*

### S1 *Biblioteca scolastica dopo l'orario di chiusura*
```

\@ Intrufolarsi per controllare gli archivi d: Furtività d6=5 vs CD 4 -\> Successo =\> Entro inosservato. \[L:Biblioteca|buia|silenziosa\]

```
```

=== Taccuino analogico
<taccuino-analogico>
```
=== Sessione 1 ===
Data: 03-09-2025 | Durata: 1h30

S1 *Biblioteca scolastica dopo l'orario di chiusura*
@ Intrufolarsi per controllare gli archivi
d: Furtività d6=5 vs CD 4 -> Successo
=> Entro inosservato. [L:Biblioteca|buia|silenziosa]
```

Entrambi i formati usano una notazione identica --- cambia solo l'involucro.

= 3. Notazione di Base
<notazione-di-base>
Questo è il cuore del sistema: i simboli che userai in quasi ogni scena. Tutto il resto in questo documento è opzionale, ma questi elementi fondamentali sono ciò che fa funzionare la notazione.

Ci sono solo cinque simboli da ricordare, e rispecchiano il flusso naturale del gioco in solitaria: compi un'azione o poni una domanda, la risolvi con le meccaniche o un oracolo, quindi registri cosa accade come risultato.

Vediamoli nel dettaglio.

== 3.1 Azioni
<azioni>
Nel gioco in solitaria, l'incertezza deriva da due fonti distinte: #strong[non sai se il tuo personaggio può fare qualcosa] (meccaniche), o #strong[non sai cosa fa il mondo] (oracolo).

Questa distinzione è fondamentale. Quando sferri un colpo di spada, usi le meccaniche per vedere se colpisci. Quando ti chiedi se ci siano guardie nelle vicinanze, interroghi l'oracolo. Entrambe le situazioni creano incertezza, ma sono risolte diversamente.

La notazione riflette questo con due simboli diversi---uno per ogni tipo di azione.

Il simbolo `@` rappresenta te, il giocatore, che agisci nel mondo di gioco. Pensalo come "in questo momento, io…". È visivamente distinto dagli operatori di confronto, rendendo i tuoi registro più chiari ed evitando confusione quando registri i tiri di dadi.

#strong[Azioni rivolte al giocatore (meccaniche):]

```
@ Scassinare la serratura
@ Attaccare la guardia
@ Convincere il mercante
```

#strong[Domande rivolte al mondo / Master (oracolo):]

```
? C'è qualcuno all'interno?
? La corda regge?
? Il mercante è onesto?
```

== 3.2 Risoluzioni
<risoluzioni>
Una volta dichiarata un'azione (`@`) o posta una domanda (`?`), devi risolvere l'incertezza. Qui è dove il sistema di gioco o l'oracolo ti danno una risposta.

Esistono due tipi di risoluzioni: #strong[meccaniche] (quando tiri i dadi o applichi le regole) e #strong[risposte dell'oracolo] (quando interroghi il mondo di gioco).

=== 3.2.1 Tiri delle Meccaniche
<tiri-delle-meccaniche>
Formato:

```
d: [tiro o regola] -> esito
```

Il prefisso `d:` indica un tiro di meccanica o la risoluzione di una regola. Includi sempre l'esito (Successo/Fallimento o risultato narrativo).

=== Esempi
<esempi>
```
d: d20+Scassinare=17 vs CD 15 -> Successo
d: 2d6=8 vs CD 7 -> Successo
d: d100=42 -> Successo parziale (usando la tabella dei risultati)
d: Hackerare il terminale (spendi 1 Equipaggiamento) -> Successo
```

=== Abbreviazione di confronto
<abbreviazione-di-confronto>
Quando confronti i tiri con numeri bersaglio, puoi usare gli operatori di confronto:

```
d: 5 vs CD 4 -> Successo    (formato standard)
d: 5≥4 -> S                (shorthand: ≥ significa eguaglia/supera la CD)
d: 2≤4 -> F                (shorthand: ≤ significa fallisce nel raggiungere la CD)
```

#strong[Nota:] Gli operatori di confronto `≥` e `≤` funzionano perfettamente con la notazione lonelog, senza conflitti di simboli. Puoi anche usare `>=` e `<=`.

Aggiungi le lettere `S` (Successo) o `F` (Fallimento) se desideri flag espliciti:

```
d: 2≤4 F
d: 5≥4 S
```

=== 3.2.2 Risultati di Oracolo e Dadi
<risultati-di-oracolo-e-dadi>
Il simbolo `->` rappresenta una risoluzione definitiva---una dichiarazione di esito. La freccia mostra visivamente "questo porta al risultato", sia esso determinato dalla meccanica dei dadi o dalla risposta di un oracolo.

#strong[Formato:]

```
-> [risultato] (opzionale: riferimento al tiro)
```

Il prefisso `->` indica qualsiasi esito di risoluzione---meccanica o oracolare.

=== Risultati delle Meccaniche dei Dadi
<risultati-delle-meccaniche-dei-dadi>
Per i tiri di meccanica, `->` dichiara Successo o Fallimento:

```
d: Furtività d6=5 vs CD 4 -> Successo
d: Scassinare d20=8 vs CD 15 -> Fallimento
d: Attacco 2d6=7 vs CD 7 -> Successo
d: Hacking d10=3 -> Successo Parziale
```

=== Risposte dell'Oracolo
<risposte-delloracolo>
Per le domande all'oracolo, `->` dichiara ciò che il mondo rivela:

```
-> Sì (d6=6)
-> No, ma... (d6=3)
-> Sì, e... (d6=5)
-> No, e... (d6=1)
```

=== Formati comuni dell'oracolo
<formati-comuni-delloracolo>
- #strong[Oracoli Sì/No:] `-> Sì`, `-> No`
- #strong[Sì/No con modificatori:] `-> Sì, ma...`, `-> No, e...`
- #strong[Gradi di risultato:] `-> Sì forte`, `-> No debole`
- #strong[Risultati personalizzati:] `-> Parzialmente`, `-> Con un costo`

=== Perché una sintassi unificata?
<perché-una-sintassi-unificata>
Sia le meccaniche che gli oracoli risolvono l'incertezza. L'uso di `->` per entrambi crea coerenza---ogni risoluzione riceve la stessa dichiarazione, rendendo il registro più facile da scansionare e analizzare. Che tu abbia tirato i dadi o interrogato l'oracolo, `->` segna il momento in cui l'incertezza diventa certezza.

== 3.3 Conseguenze
<conseguenze>
Registra il risultato narrativo dopo i tiri usando `=>`. Il simbolo mostra le conseguenze che fluiscono in avanti dalle azioni e dalle risoluzioni. La doppia freccia visualizza come gli eventi si susseguono nella tua storia.

```
=> La porta cigola aprendosi, ma il rumore riecheggia nel corridoio.
=> La guardia mi vede e dà l'allarme.
=> Trovo un diario nascosto con un indizio cruciale.
```

=== Conseguenze multiple
<conseguenze-multiple>
Puoi concatenare più righe di conseguenze per effetti a cascata:

```
d: Scassinare 5≥4 -> Successo
=> La porta si apre
=> Ma i cardini stridono rumorosamente
=> [E:OrologioAllerta 1/6]
```

== 3.4 Sequenze d'Azione Complete
<sequenze-dazione-complete>
Ecco come si combinano gli elementi di base:

=== Sequenza guidata dalle meccaniche
<sequenza-guidata-dalle-meccaniche>
```
@ Scassinare la serratura
d: d20+Scassinare=17 vs CD 15 -> Successo
=> La porta cigola aprendosi, ma il rumore riecheggia nel corridoio.
```

=== Sequenza guidata dall'oracolo
<sequenza-guidata-dalloracolo>
```
? C'è qualcuno all'interno?
-> Sì, ma... (d6=4)
=> C'è qualcuno, ma è distratto.
```

=== Sequenza combinata
<sequenza-combinata>
```
@ Superare le guardie furtivamente
d: Furtività 2≤4 -> Fallimento
=> Il mio piede colpisce un barile. [E:OrologioAllerta 2/6]

? Mi vedono?
-> No, ma... (d6=3)
=> Sono distratti, ma una guardia si sofferma nelle vicinanze. [N:Guardia|vigile]
```

= 4. Livelli Opzionali
<livelli-opzionali>
Hai le basi---azioni, tiri e conseguenze. È sufficiente per un gioco semplice. Ma le campagne più lunghe hanno spesso bisogno di altro: PNG che riappaiono, fili della trama che si intrecciano tra le sessioni, progressi che si accumulano nel tempo.

Questa sezione copre gli #strong[elementi di tracciamento] che ti aiutano a gestire la complessità. Sono tutti opzionali. Se stai giocando un mistero one-shot, potresti non aver bisogno di nulla di tutto questo. Se stai conducendo una vasta campagna con dozzine di PNG e molteplici fili della trama, probabilmente vorrai usare la maggior parte di essi.

Scegli ciò di cui la tua campagna ha bisogno.

== 4.1 Elementi Persistenti
<elementi-persistenti>
Man mano che la tua campagna cresce, certi elementi rimangono: PNG che riappaiono, luoghi in cui ritorni, minacce in corso, domande della storia che abbracciano più sessioni. Questi sono i tuoi #strong[elementi persistenti];.

I tag ti permettono di tracciarli coerentemente tra scene e sessioni. Il formato è semplice: parentesi, un prefisso di tipo, un nome e dettagli opzionali. Come questo: `[N:Jonah|amichevole|ferito]`.

#strong[Perché usare i tag?]

- #strong[Ricercabilità];: Trova ogni scena in cui appare Jonah
- #strong[Coerenza];: Fai riferimento ai PNG nello stesso modo ogni volta
- #strong[Tracciamento dello stato];: Vedi come cambiano gli elementi nel tempo
- #strong[Aiuto per la memoria];: Ricorda dettagli dopo settimane

Non hai bisogno di taggare tutto---solo ciò che conta per la tua campagna. Un mercante casuale che non vedrai mai più? Chiamalo semplicemente "il mercante" nella prosa. Un cattivo ricorrente? Taggualo sicuramente.

Ecco i principali tipi di elementi persistenti che potresti tracciare:

=== 4.1.1 PNG (Personaggi Non Giocanti)
<png-personaggi-non-giocanti>
```
[N:Jonah|amichevole|ferito]
[N:Guardia|vigile|armata]
[N:Mercante|sospettoso]
```

#strong[Aggiornamento dei tag PNG:]

Quando lo stato di un PNG cambia, puoi:

- Riformulare con nuovi tag: `[N:Jonah|catturato|ferito]`
- Mostrare solo il cambiamento: `[N:Jonah|catturato]` (si assume che gli altri tag persistano)
- Usare aggiornamenti espliciti: `[N:Jonah|amichevole→ostile]`
- Aggiungere `+` o `-`: `[N:Jonah|+catturato]` o `[N:Jonah|-ferito]`

Scegli lo stile che mantiene il tuo registro più chiaro.

=== 4.1.2 Luoghi
<luoghi>
```
[L:Faro|rovinato|tempestoso]
[L:Biblioteca|buia|silenziosa]
[L:Taverna|affollata|rumorosa]
```

=== 4.1.3 Eventi & Orologi
<eventi-orologi>
```
[E:TramaCultisti 2/6]
[E:OrologioAllerta 3/4]
[E:ProgressoRituale 0/8]
```

Gli eventi tracciano elementi significativi della trama. Il formato numerico `X/Y` mostra il progresso attuale/totale.

=== 4.1.4 Fili della Trama (Thread)
<fili-della-trama-thread>
```
[Thread:Trovare la sorella di Jonah|Aperto]
[Thread:Scoprire la cospirazione|Aperto]
[Thread:Fuggire dalla città|Chiuso]
```

I thread tracciano le principali domande o obiettivi della storia. Stati comuni:

- `Aperto` --- thread attivo
- `Chiuso` --- thread risolto
- `Abbandonato` --- thread lasciato cadere
- Stati personalizzati permessi (es. `Urgente`, `Sottofondo`)

=== 4.1.5 Personaggio del Giocatore (PG)
<personaggio-del-giocatore-pg>
```
[PG:Alex|PF 8|Stress 0|Equip:Torcia,Taccuino]
[PG:Elara|PF 15|Munizioni 3|Stato:Ferita]
```

#strong[Aggiornamento delle statistiche del PG:]

```
[PG:Alex|PF 8]        (iniziale)
[PG:Alex|PF-2]        (shorthand: perso 2 PF, ora a 6)
[PG:Alex|PF 6]        (esplicito: ora a 6 PF)
[PG:Alex|PF+3|Stress-1]  (cambiamenti multipli)
```

=== 4.1.6 Tag di Riferimento
<tag-di-riferimento>
Per fare riferimento a un elemento stabilito in precedenza senza riformulare i tag, usa il prefisso `#`:

```
[N:Jonah|amichevole|ferito]     (prima menzione — stabilisce l'elemento)

... più avanti nel registro ...

[#N:Jonah]                     (riferimento — assume i tag precedenti)
```

Il simbolo `#` indica che questo elemento è stato definito in precedenza. Usalo per:

- Mantenere sintetiche le menzioni successive
- Segnalare ai lettori di guardare indietro per il contesto
- Mantenere la ricercabilità (l'ID "Jonah" appare ancora)

#strong[Quando usare i tag di riferimento:]

- Prima menzione: Tag completo con dettagli `[N:Nome|tag]`
- Menzioni successive nella stessa scena: Opzionale, usa il buon senso
- Menzioni successive in scene/sessioni diverse: Usa `[#N:Nome]` per segnalare il riferimento
- Cambiamenti di stato: Rimuovi il `#` e mostra i nuovi tag `[N:Nome|nuovi_tag]`

== 4.2 Tracciamento dei Progressi
<tracciamento-dei-progressi>
Alcune cose nella tua campagna non accadono tutto in una volta---si accumulano nel tempo. Il rituale richiede dodici passi per essere completato. Il sospetto delle guardie cresce a ogni rumore che fai. Il tuo piano di fuga avanza lentamente. La riserva d'aria diminuisce.

Il tracciamento dei progressi ti offre un modo visivo per vedere queste forze che si accumulano. Tre formati gestiscono diversi tipi di progressione:

#strong[Orologi] (si riempiono verso il completamento):

```
[Clock:Rituale 5/12]
[Clock:Sospetto 3/6]
```

#strong[Usa per:] Minacce in aumento, incantesimi in preparazione, pericolo che si accumula. Quando l'orologio si riempie, succede qualcosa (di solito negativo per te).

#strong[Tracciati] (progressi verso un obiettivo):

```
[Track:Fuga 3/8]
[Track:Investigazione 6/10]
```

#strong[Usa per:] I tuoi progressi nei progetti, l'avanzamento dei viaggi, obiettivi a lungo termine. Quando il tracciato si riempie, ottieni un successo.

#strong[Timer] (contano alla rovescia verso lo zero):

```
[Timer:Alba 3]
[Timer:RiservaAria 5]
```

#strong[Usa per:] Scadenze che si avvicinano, risorse che si esauriscono, pressione temporale. Quando arriva a zero, il tempo è scaduto.

#strong[La differenza?] Orologi e tracciati aumentano entrambi, ma gli orologi sono minacce (le cose vanno male quando sono pieni) e i tracciati sono progressioni (meglio quando sono pieni). I timer vanno contano alla rovescia e provocano senso di urgenza.

Non hai bisogno di tracciare tutto numericamente. Usa questi solo quando un conteggio ha un peso per la tua storia e vuoi un modo concreto per misurarlo.

== 4.3 Tabelle Random & Generatori
<tabelle-random-generatori>
Il gioco in solitaria prospera sulla sorpresa. A volte tiri su una tabella per vedere cosa trovi, o usi un generatore per creare un PNG al volo. Quando lo fai, aiuta registrare cosa hai tirato, sia per trasparenza che per poter ricreare la logica in seguito.

#strong[Semplice consultazione di tabella:]

```
tbl: d100=42 -> "Una spada spezzata"
tbl: d20=15 -> "Il mercante è nervoso"
```

Usa `tbl:` quando attingi da una tabella casuale semplice, quella in cui tiri una volta e ottieni un risultato.

#strong[Generatori complessi:]

```
gen: Mythic Event d100=78 + 11 -> Azione PNG / Tradimento
gen: Stars Without Number NPC d8=3,d10=7 -> Burbero/Pilota
```

Usa `gen:` quando usi un generatore a più fasi che combina più tiri o produce risultati composti.

#strong[Integrazione con le domande all'oracolo:]

```
? Cosa trovo nel forziere?
tbl: d100=42 -> "Una spada spezzata"
=> Una lama antica, spezzata in due, con strane rune sull'elsa.
```

#strong[Perché registrare i tiri?] Per tre ragioni:

+ #strong[Trasparenza];: Se condividi il registro, gli altri vedono il tuo processo
+ #strong[Riproducibilità];: Puoi tracciare come hai ottenuto risultati sorprendenti
+ #strong[Apprendimento];: Nel tempo, vedi quali tabelle usi di più

Detto questo, se giochi in modo rapido e informale, puoi saltare i dettagli del tiro e registrare solo il risultato: `=> Trovo una spada spezzata [tbl]`. La parte importante è la finzione, non la matematica.

== 4.4 Estratti Narrativi
<estratti-narrativi>
Ecco un segreto: #strong[non hai bisogno di scrivere alcuna narrazione];. L'abbreviazione cattura tutto meccanicamente. Ma a volte la finzione richiede di più: un frammento di dialogo troppo perfetto per non essere registrato, una descrizione che stabilisce l'atmosfera, un documento trovato dal tuo personaggio.

A questo servono gli estratti narrativi: i momenti in cui l'abbreviazione non basta.

#strong[Prosa inline] (brevi descrizioni):

```
=> La stanza puzza di muffa e decomposizione. Ci sono carte sparse ovunque.
```

#strong[Usa per:] Rapidi dettagli d'atmosfera, informazioni sensoriali, momenti emotivi. Mantienili brevi---una frase o due.

#strong[Dialogo] (conversazioni che vale la pena registrare):

```
N (Guardia): "Chi va là?"
PG: "Resta calmo... solo resta calmo."
N (Guardia): "Fatti vedere!"
PG: [sussurra] "Non se ne parla."
```

#strong[Usa per:] Scambi memorabili, la voce del personaggio, conversazioni importanti. Non hai bisogno di registrare ogni parola---solo gli scambi che contano.

#strong[Lunghi blocchi narrativi] (documenti trovati, descrizioni importanti):

```
\---
Il diario recita:
"Giorno 47: Le maree non obbediscono più alla luna. I pesci hanno smesso
di arrivare. Il guardiano del faro dice di vedere luci sotto le onde.
Temo per la nostra sanità mentale."
---\
```

#strong[Usa per:] Documenti in-game, descrizioni lunghe, rivelazioni chiave. I marcatori `\---` e `---\` lo separano dal tuo registro, rendendo chiaro che si tratta di contenuto in-fiction. I delimitatori asimmetrici prevengono conflitti con le linee orizzontali di Markdown.

#strong[Quanta narrazione dovresti scrivere?] Solo quella che ti serve. Se giochi per te stesso e l'abbreviazione ti dice tutto ciò che devi ricordare, salta la prosa. Se condividi il tuo registro o ami il processo di scrittura, aggiungine di più. Non c'è una quantità giusta, solo ciò che rende il tuo registro utile e piacevole per te.

== 4.5 Meta Note
<meta-note>
A volte hai bisogno di uscire dalla finzione e lasciarti una nota: un promemoria su una regola della casa (house rule) che stai testando, una riflessione su come è andata una scena, una domanda da rivisitare in seguito, o un chiarimento sulla tua interpretazione di una regola.

A questo servono le meta note: i tuoi commenti fuori-dal-personaggio (out-of-character) per te stesso (o per i lettori, se condividi il registro).

#strong[Formato:] Usa le parentesi per segnalare "questo è meta, non finzione":

```
(nota: sto testando una regola furtività alternativa dove il rumore aumenta l'orologio Allerta)
(riflessione: questa scena è stata tesa! il timer ha funzionato bene)
(house rule: concedo vantaggio su terreno familiare)
(promemoria: rivisitare questo thread nella prossima sessione)
(domanda: avrei dovuto tirare per questo? sembrava ovvio)
```

#strong[Quando usare le meta note:]

- #strong[Esperimenti];: Traccia varianti di regole o house rule che stai testando
- #strong[Riflessione];: Cattura ciò che ha funzionato o meno a livello emotivo
- #strong[Promemoria];: Segnala cose da approfondire più tardi
- #strong[Chiarimento];: Spiega decisioni o interpretazioni insolite
- #strong[Processo];: Documenta il tuo pensiero per i registro condivisi

#strong[Quando NON usarle:] Non lasciare che le meta note sommergano il tuo registro. Se ti fermi ogni poche righe per riflettere, probabilmente stai pensando troppo. Il gioco è la cosa principale, le meta note sono solo occasionali commenti a margine.

Pensale come al commento del regista su un film. Per la maggior parte del tempo, guardi solo il film. Occasionalmente, c'è una nota interessante dietro le quinte che vale la pena condividere.

#pagebreak()
= 5. Struttura Opzionale
<struttura-opzionale>
Finora abbiamo parlato di #emph[cosa] scrivi (azioni, tiri, tag). Ora parliamo di #emph[come organizzarlo];.

La struttura aiuta in due modi: rende le tue note più facili da consultare e segnala i confini (questa sessione è finita, quella scena è iniziata). Ma la struttura aggiunge carico di lavoro: più intestazioni da scrivere, più formattazione da mantenere.

Questa sezione mostra gli elementi organizzativi: intestazioni di campagna (metadati sull'intera campagna), intestazioni di sessione (per segnare le sessioni di gioco) e struttura della scena (l'unità base di gioco). Usa ciò che ti aiuta a orientarti senza rallentarti.

La differenza chiave? #strong[I formati digitali e analogici gestiscono la struttura diversamente.] Il markdown digitale usa intestazioni e YAML; i taccuini analogici usano intestazioni scritte e marcatori. Li mostreremo entrambi.

== 5.1 Intestazione Campagna
<intestazione-campagna>
Prima di tuffarti nel gioco, aiuta registrare alcune basi: A cosa stai giocando? Quale sistema? Quando hai iniziato? Pensala come alla "copertina" del tuo registro di campagna.

Questo è particolarmente utile quando:

- Conduci più campagne (ti aiuta a ricordare quale sia quale)
- Condividi i registro con altri (hanno bisogno di contesto)
- Ritorni a una campagna dopo una pausa (ti ricorda il tono/i temi)

Se stai solo provando la notazione con una rapida one-shot, salta questa parte. Ma per le campagne che pianifichi di rivisitare, un'intestazione vale quei 30 secondi di lavoro in più.

#strong[I formati digitali e analogici differiscono qui.] Il markdown digitale usa lo YAML front matter (metadati strutturati in cima al file). I taccuini analogici usano un blocco intestazione scritto.

#strong[Per i file markdown digitali];, usa lo YAML front matter proprio all'inizio:

```yaml
title: Mistero a Clearview
ruleset: Loner + Mythic Oracle
genre: Mistero adolescenziale / soprannaturale
player: Roberto
pcs: Alex [PG:Alex|PF 8|Stress 0|Equip:Torcia,Taccuino]
start_date: 2025-09-03
last_update: 2025-10-28
tools: Oracoli - Mythic, tabelle Eventi Casuali
themes: Amicizia, coraggio, segreti
tone: Inquietante ma giocoso
notes: Ispirato a serie mystery anni '80
```

#strong[Per i taccuini analogici];, scrivi un blocco intestazione della campagna:

```
=== Registro Campagna: Mistero a Clearview ===
[Titolo]        Mistero a Clearview
[Regolamento]   Loner + Mythic Oracle
[Genere]        Mistero adolescenziale / soprannaturale
[Giocatore]     Roberto
[PG]            Alex [PG:Alex|PF 8|Stress 0|Equip:Torcia,Taccuino]
[Data Inizio]   03-09-2025
[Ultimo Agg.]   28-10-2025
[Strumenti]     Oracoli: Mythic, tabelle Eventi Casuali
[Temi]          Amicizia, coraggio, segreti
[Tono]          Inquietante ma giocoso
[Note]          Ispirato a serie mystery anni '80
```

#strong[Campi opzionali] (da aggiungere al bisogno):

- `[Ambientazione]` --- Dettagli geografici o del mondo
- `[Ispirazione]` --- Media che hanno ispirato la campagna
- `[Strumenti di Sicurezza]` --- X-card, linee/veli, ecc.

== 5.2 Intestazione Sessione
<intestazione-sessione>
Un'intestazione di sessione segna il confine tra le sessioni di gioco e fornisce contesto: quando hai giocato, quanto a lungo, cosa è successo?

#strong[Perché usare le intestazioni di sessione?]

- #strong[Navigazione];: Salta rapidamente a sessioni specifiche
- #strong[Contesto];: Ricorda quando hai giocato e cosa stava succedendo
- #strong[Riflessione];: Traccia i tuoi schemi di gioco (quanto spesso? quanto a lungo?)
- #strong[Continuità];: Collega le sessioni con riassunti e obiettivi

#strong[Quando saltarle:]

- Giochi one-shot (nessuna sessione multipla)
- Gioco continuo (giochi quotidianamente senza interruzioni chiare)
- Log di pura abbreviazione (vuoi solo la finzione, non la meta-struttura)

Come le intestazioni di campagna, i formati digitali e analogici gestiscono le sessioni diversamente. Scegli lo stile che si adatta al tuo mezzo.

=== 5.2.1 Formato digitale (intestazione markdown)
<formato-digitale-intestazione-markdown>
```markdown
## Sessione 1
*Data: 03-09-2025 | Durata: 1h30 | Scene: S1-S2*

**Riassunto:** Prima sessione, introduzione di Alex e del mistero.

**Obiettivi:** Impostare il mistero centrale, stabilire il faro come luogo chiave.
```

=== 5.2.2 Formato analogico (intestazione scritta)
<formato-analogico-intestazione-scritta>
```
=== Sessione 1 ===
[Data]        03-09-2025
[Durata]      1h30
[Scene]       S1-S2
[Riassunto]   Prima sessione, introduzione di Alex e del mistero.
[Obiettivi]   Impostare il mistero centrale, stabilire il faro.
```

#strong[Campi opzionali:]

- `[Umore]` --- Tono pianificato o effettivo per la sessione
- `[Note]` --- Varianti di regole, esperimenti o condizioni speciali
- `[Thread]` --- Thread attivi in questa sessione

== 5.3 Struttura della Scena
<struttura-della-scena>
Le scene sono l'unità base di gioco all'interno di una sessione. Al suo livello più semplice, una scena è solo un marcatore numerato con contesto.

#strong[Formato digitale (intestazione markdown):]

```markdown
### S1 *Biblioteca scolastica dopo l'orario di chiusura*
```

#strong[Formato analogico:]

```
S1 *Biblioteca scolastica dopo l'orario di chiusura*
```

Il numero della scena ti aiuta a tracciare la progressione e a fare riferimento agli eventi in seguito. Il contesto (in corsivo/asterischi) inquadra dove e quando si svolge la scena.

=== 5.3.1 Scene Sequenziali (Standard)
<scene-sequenziali-standard>
La maggior parte delle campagne usa una semplice numerazione sequenziale:

```
S1 *Taverna, sera*
S2 *Piazza del paese, mezzanotte*
S3 *Sentiero nel bosco, alba*
S4 *Rovine antiche, mezzogiorno*
```

#strong[Quando usare:] Predefinito per il gioco lineare. La Scena 2 accade dopo la Scena 1, la Scena 3 dopo la Scena 2, ecc.

#strong[Numerazione:] Inizia da S1 ogni sessione, oppure continua in tutta la campagna (S1-S100+).

#strong[Esempio in gioco:]

```
S1 *Sala comune della taverna, sera*
@ Chiedere voci al locandiere
d: Carisma d6=5 vs CD 4 -> Successo
=> Si avvicina e mi parla di strane luci al vecchio mulino.
[Thread:Strane Luci|Aperto]

S2 *Fuori dalla taverna, notte*
@ Dirigersi verso il mulino
? Incontro qualcosa sulla strada?
-> Sì, ma... (d6=4)
=> Vedo una figura ombrosa, ma non sembra ostile.
[N:Straniero|misterioso|osservatore]
```

=== 5.3.2 Flashback
<flashback>
I flashback mostrano eventi passati che informano la storia attuale. Usa suffissi alfabetici che si diramano dalla scena "presente".

#strong[Formato:] `S#a`, `S#b`, `S#c`

#strong[Quando usare:]

- Rivelare il passato a metà sessione
- Inneschi della memoria del personaggio
- Mostrare come è successo qualcosa
- Spiegare elementi misteriosi

#strong[Esempio di struttura:]

```
S5 *Investigare il mulino*
=> Trovo il vecchio diario di mio padre.

S5a *Flashback: Officina del padre, 10 anni fa*
(Questo è accaduto prima della campagna)
=> Padre: "Promettimi che non andrai mai al mulino da solo."

S6 *Di nuovo al mulino, presente*
(Ora continuiamo dalla S5)
```

#strong[Esempio completo:]

```
S8 *Alloggi del guardiano del faro*
@ Cercare indizi sulla scrivania
d: Investigazione d6=6 vs CD 4 -> Successo
=> Trovo una fotografia sbiadita. È... mia madre? È in piedi davanti a questo faro!
[Thread:Connessione Materna|Aperto]

S8a *Flashback: Casa, 15 anni fa*
(Ricordo innescato dalla fotografia)
(Ricordo qualcosa di questo posto?)
? Mia madre ha mai menzionato un faro?
-> Sì, ma... (d6=5)
=> Lo menzionò una volta, brevemente, poi cambiò argomento in fretta.

PG (Io giovane): "Mamma, dov'è questo posto?"
N (Madre): [nervosa] "Solo un vecchio posto. Niente di importante."

S8b *Flashback: Studio della madre, 14 anni fa*
(Seguendo il filo della memoria)
(Ho mai visto documenti sul faro?)
? Stavo curiosando tra le sue carte?
-> Sì, e... (d6=6)
=> Ho trovato un atto di proprietà. Il faro apparteneva alla nostra famiglia!
[E:SegretoFaro 1/4]

S9 *Alloggi del guardiano del faro, presente*
(Torno alla linea temporale attuale)
=> Armato di questo ricordo, cerco più attentamente documenti di famiglia.
```

#strong[Suggerimenti per la numerazione:]

- Crea una diramazione dalla scena che innesca il flashback
- Torna alla numerazione sequenziale dopo
- Mantieni i flashback brevi (solitamente 1-3 scene)
- Annota nel contesto quando torni: `*Presente*` o `*Di nuovo al...*`

=== 5.3.3 Thread Paralleli
<thread-paralleli>
Quando tracci più linee narrative che accadono simultaneamente o con focus alternato, usa i prefissi dei thread.

#strong[Formato:] `T#-S#` dove T\# è il numero del thread, S\# è il numero della scena all'interno di quel thread

#strong[Quando usare:]

- Personaggi/punti di vista multipli
- Eventi simultanei in luoghi diversi
- Alternanza tra linee narrative
- Archi narrativi separati ma correlati

#strong[Esempio di struttura:]

```
T1-S1 *Personaggio principale al faro*
T2-S1 *Nel frattempo, l'alleato in città*
T1-S2 *Di nuovo al faro*
T2-S2 *Di nuovo in città*
T1-S3 *Faro, in continuazione*
```

#strong[Esempio completo:]

```
=== Sessione 3 ===
[Thread] Storia principale (T1), Investigazione in città (T2)

T1-S1 *Torre del faro, crepuscolo*
[PG:Alex|investiga la torre]
@ Salire in cima
d: Atletica d6=4 vs CD 4 -> Successo
=> Raggiungo la cima. Il meccanismo della luce è ancora funzionante!

? C'è qualcun altro qui?
-> No, ma... (d6=3)
=> Orme fresche nella polvere portano verso il basso.

T2-S1 *Archivi della città, stesso momento*
[PG:Jordan|ricerche in biblioteca]
@ Cercare documenti sul faro
d: Ricerca d6=6 vs CD 4 -> Successo
=> Trovo documenti di costruzione del 1923. C'è un seminterrato nascosto!
[E:SeminterratoSegreto 1/4]

T1-S2 *Scale del seminterrato del faro*
[PG:Alex]
@ Seguire le orme verso il basso
d: Furtività d6=3 vs CD 5 -> Fallimento
=> Un gradino scricchiola rumorosamente.

? Qualcuno reagisce?
-> Sì, e... (d6=6)
=> Una voce dal basso: "Chi va là?" [N:Cultista|ostile|armato]

T2-S2 *Archivi della città, pochi istanti dopo*
[PG:Jordan]
@ Chiamare Alex per avvertirlo del seminterrato
? La chiamata passa?
-> No, e... (d6=2)
=> Niente segnale. Il faro è in una zona d'ombra!
[Clock:Alex in Pericolo 2/6]

T1-S3 *Seminterrato del faro*
[PG:Alex|inconsapevole del pericolo]
@ Cercare di convincerli a parole
d: Inganno d6=2 vs CD 5 -> Fallimento
=> Il cultista non abbocca. Avanza con un coltello!
```

#strong[Quando i thread convergono:]

Una volta che i thread paralleli si incontrano, puoi:

- Continuare con i prefissi dei thread: `T1+T2-S5`
- Tornare alla sequenza: `S14` (nota: thread uniti)

```
T1-S6 *Alex scappa dal faro*
T2-S4 *Jordan guida verso il faro*

S14 *Ingresso del faro, entrambi riuniti*
(Thread uniti)
[PG:Alex|ferito] incontra [PG:Jordan|preoccupato]
```

=== 5.3.4 Montaggi e Salti Temporali
<montaggi-e-salti-temporali>
Per attività che abbracciano tempo o vignette multiple e veloci, usa la notazione decimale.

#strong[Formato:] `S#.#` (es. `S5.1`, `S5.2`, `S5.3`)

#strong[Quando usare:]

- Viaggiare attraverso lunghe distanze
- Addestramento/ricerca per settimane
- Incontri multipli veloci
- Raccolta di risorse
- Sequenze in time-lapse

#strong[Esempio di struttura:]

```
S7 *Inizio del viaggio*
S7.1 *Giorno 1: Foresta*
S7.2 *Giorno 3: Montagne*
S7.3 *Giorno 5: Deserto*
S8 *Arrivo a destinazione*
```

#strong[Esempio completo:]

```
S12 *Preparazione per il rituale*
=> Devo raccogliere tre componenti in tutta la regione.
[Track:Componenti Rituale 0/3]

S12.1 *Erboristeria, mattina*
@ Comprare erbe sacre
d: Persuasione d6=5 vs CD 4 -> Successo
=> L'erborista mi fa uno sconto.
[Track:Componenti Rituale 1/3]
[PG:Oro-5]

S12.2 *Fabbro, pomeriggio*
@ Ottenere un pugnale d'argento
? È disponibile?
-> No, ma... (d6=4)
=> Può farne uno entro domani.
[Timer:Scadenza Rituale 2]

S12.3 *Cimitero, mezzanotte*
@ Raccogliere terra del cimitero
? Vengo interrotto?
-> Sì, e... (d6=6)
=> Il custode mi cattura E chiama la guardia!
[Clock:Sospetto 3/6]

@ Scappare e nascondersi
d: Furtività d6=6 vs CD 5 -> Successo
=> Fuggo con la terra.
[Track:Componenti Rituale 2/3]

S13 *Bottega del fabbro, mattina dopo*
(Montaggio completato, ritorno alla sequenza)
=> Ritirato il pugnale d'argento.
[Track:Componenti Rituale 3/3]
```

#strong[Esempio di montaggio di viaggio:]

```
S8 *Partenza da Port Ashan*
=> Inizia il viaggio di tre settimane verso le Lande del Nord.

S8.1 *Settimana 1: Strada costiera*
? Incontri sulla strada?
tbl: d100=23 -> "Carovana di mercanti"
=> Mi unisco a una carovana per sicurezza. [N:Mercanti|amichevoli]

S8.2 *Settimana 2: Passo di montagna*
? Problemi meteorologici?
-> Sì, e... (d6=6)
=> Colpisce una bufera. Il passo è bloccato!
[Clock:Provviste Scarseggiano 2/4]

@ Trovare rifugio
d: Sopravvivenza d6=5 vs CD 5 -> Successo
=> Trovo una grotta. [L:Grotta Montana|rifugio|buia]

S8.3 *Settimana 3: Discesa nelle lande*
@ Navigare nel terreno ghiacciato
d: Sopravvivenza d6=4 vs CD 6 -> Fallimento
=> Mi perdo per due giorni.
[Clock:Provviste Scarseggiano 4/4]
[PG:Razioni esaurite]

S9 *Arrivo nelle Lande del Nord*
(Viaggio completato)
=> Esausto e affamato, ma ce l'ho fatta.
```

=== 5.3.5 Scegliere il Tuo Approccio
<scegliere-il-tuo-approccio>
#strong[Usa la sequenza (S1, S2, S3) quando:]

- Giochi una storia lineare e semplice
- Non hai bisogno di manipolazioni temporali complesse
- Vuoi semplicità
- Scelta più comune

#strong[Usa i flashback (S5a, S5b) quando:]

- Rivei il passato a metà gioco
- Momenti di sviluppo del personaggio
- Spieghi misteri
- Brevi diversioni dalla linea temporale principale

#strong[Usa i thread paralleli (T1-S1, T2-S1) quando:]

- Giochi con più personaggi
- Tracci eventi simultanei
- Alterni tra vari luoghi
- Trame complesse e intrecciate

#strong[Usa i montaggi (S7.1, S7.2) quando:]

- Copri lunghi periodi di tempo
- Serie di scene veloci
- Sequenze di viaggio
- Raccolta di risorse
- Periodi di addestramento/ricerca

=== 5.3.6 Elementi di Contesto della Scena
<elementi-di-contesto-della-scena>
Oltre alla numerazione, arricchisci le scene con il contesto nell'intestazione:

#strong[Luogo:]

```
S1 *Torre del faro*
S1 [L:Faro] *Stanza della torre*
```

#strong[Marcatori temporali:]

```
S1 *Faro, mezzanotte*
S1 *Faro, Giorno 3, crepuscolo*
S1 *Due settimane dopo: Faro*
```

#strong[Tono emotivo:]

```
S1 *Faro (teso)*
S1 *Faro - momento di calma*
```

#strong[Elementi multipli:]

```
S1 *Torre del faro, mezzanotte, Giorno 3*
S5a *Flashback: Officina del padre, 10 anni fa*
T2-S3 *Intanto in città, stessa sera*
S7.2 *Giorno 2 del viaggio: Passo di montagna*
```

#strong[Minimale (solo numero):]

```
S1
(Aggiungi il contesto nella prima azione o conseguenza)
```

Scegli il livello di dettaglio che ti aiuta a tracciare la tua storia. Più dettaglio aiuta il riferimento futuro; meno dettaglio mantiene le note più pulite.

#pagebreak()
= 6. Esempi Completi
<esempi-completi>
La teoria è una cosa, ma vedere la notazione in azione è dove scatta la comprensione. Questa sezione mostra esempi di gioco completi in stili diversi, dall'abbreviazione ultra-compatta ai ricchi registro narrativi, così puoi trovare l'approccio che funziona per te.

Ogni esempio dimostra lo stesso sistema di notazione, solo con diversi livelli di dettaglio. Scegli lo stile che corrisponde alle tue preferenze, o mescolali secondo le necessità della tua sessione.

== 6.1 Log ad Abbreviazione Minimale
<log-ad-abbreviazione-minimale>
Pura abbreviazione, nessuna formattazione. Perfetto per un gioco veloce:

```
S1 @Furtività d:4≥5 F => rumore [E:Allerta 1/6] ?Visto? ->Nb3 => distratto
S2 @Cerca d:6≥4 S => trova chiave [E:Indizio 1/4] ?Trappola? ->Yn6 => sì, punte!
S3 @Schiva d:3≤5 F => PF-2 [PG:PF 6] => ferita, serve ritirarsi
```

== 6.2 Formato Ibrido Digitale
<formato-ibrido-digitale>
Combina abbreviazioni con narrazione, usando la struttura markdown:

```markdown
### S7 *Vicolo buio dietro la taverna, Mezzanotte*
```

\@ Superare le guardie furtivamente d: Furtività d6=2 vs CD 4 -\> Fallimento =\> Il mio piede colpisce un barile. \[E:OrologioAllerta 2/6\]

? Mi vedono? -\> No, ma… (d6=3) =\> Sono distratti, ma una guardia si sofferma. \[N:Guardia|vigile\]

```

La luce della torcia della guardia spazza le pareti del vicolo. Mi schiaccio
contro le ombre, respirando appena.
```

N (Guardia): "Chi va là?" PG: "Resta calmo… solo resta calmo."

```
```

== 6.3 Formato Taccuino Analogico
<formato-taccuino-analogico>
Stesso contenuto del 6.2, formattato per note scritte a mano:

```
S7 *Vicolo buio dietro la taverna, Mezzanotte*

@ Superare le guardie furtivamente
d: Furtività d6=2 vs CD 4 -> Fallimento
=> Il mio piede colpisce un barile. [E:OrologioAllerta 2/6]

? Mi vedono?
-> No, ma... (d6=3)
=> Sono distratti, ma una guardia si sofferma. [N:Guardia|vigile]

La luce della torcia della guardia spazza il vicolo. Mi schiaccio nelle ombre.

N (Guardia): "Chi va là?"
PG: "Resta calmo... solo resta calmo."
```

== 6.4 Registro Campagna Completo (Digitale)
<registro-campagna-completo-digitale>
```markdown
---
title: Mistero a Clearview
ruleset: Loner + Mythic Oracle
genre: Mistero adolescenziale / soprannaturale
player: Roberto
pcs: Alex [PG:Alex|PF 8|Stress 0]
start_date: 2025-09-03
last_update: 2025-10-28
---

# Mistero a Clearview

## Sessione 1
*Data: 03-09-2025 | Durata: 1h30*

### S1 *Biblioteca scolastica dopo l'orario di chiusura*
```

\@ Intrufolarsi per controllare gli archivi d: Furtività d6=5 vs CD 4 -\> Successo =\> Entro inosservato. \[L:Biblioteca|buia|silenziosa\]

? C'è uno strano indizio ad attendermi? -\> Sì (d6=6) =\> Trovo una pagina di diario strappata che parla del faro. \[E:IndizioFaro 1/6\]

```

La pagina è ingiallita dal tempo. La grafia è tremolante: "La luce 
ci chiama. Non dobbiamo rispondere."
```

\[Thread:Mistero del Faro|Aperto\]

```

### S2 *Fuori dalla biblioteca, corridoio vuoto*
```

? Sento dei passi? -\> Sì, ma… (d6=4) =\> Si avvicina un custode, ma non mi ha ancora notato. \[N:Custode|stanco|sospettoso\]

```

Mi raggelo. Le sue chiavi tintinnano mentre passa davanti alla porta.

N (Custode): "Mi era parso di sentire qualcosa..."
PG (Alex, sussurro): "Devo andarmene da qui."
```

\@ Scivolare via mentre è distratto d: Furtività d6=6 vs CD 4 -\> Successo =\> Scappo nella notte in sicurezza.

```
## Sessione 2
*Data: 10-09-2025 | Durata: 2h*

**Riassunto:** Trovata pagina di diario che accenna al faro. Quasi scoperto in biblioteca.

### S3 *Sentiero verso il vecchio faro, Giorno 2*
```

\@ Avvicinarsi silenziosamente al crepuscolo d: Furtività d6=2 vs CD 4 -\> Fallimento =\> Calpesto dei vetri rotti, scricchiolando rumorosamente. \[Clock:Sospetto 1/6\]

? Qualcuno risponde dall'interno? -\> No, ma… (d6=3) =\> La luce sfarfalla brevemente nella finestra della torre. \[L:Faro|rovinato|infestato\]

```

### S4 *All'interno dell'atrio del faro*
```

\@ Cercare sul pavimento segni di attività d: Investigazione d6=6 vs CD 4 -\> Successo =\> Trovo orme fresche nella polvere. \[Thread:Chi sta usando il faro?|Aperto\]

tbl: d100=42 -\> "Una lanterna rotta" =\> Una lanterna crepata giace vicino alle scale. \[E:IndizioFaro 2/6\]

```

Qualcuno è stato qui. Di recente.

PG (Alex, pensando): "Questo posto non è così abbandonato come tutti pensano..."

```

== 6.5 Registro Campagna Completo (Analogico)
<registro-campagna-completo-analogico>
```
=== Registro Campagna: Mistero a Clearview ===
[Titolo]        Mistero a Clearview
[Regolamento]   Loner + Mythic Oracle
[Genere]        Mistero adolescenziale / soprannaturale
[Giocatore]     Roberto
[PG]            Alex [PG:Alex|PF 8|Stress 0]
[Data Inizio]   03-09-2025
[Ultimo Agg.]   28-10-2025

=== Sessione 1 ===
[Data]        03-09-2025
[Durata]      1h30

S1 *Biblioteca scolastica dopo l'orario di chiusura*

@ Intrufolarsi per controllare gli archivi
d: Furtività d6=5 vs CD 4 -> Successo
=> Entro inosservato. [L:Biblioteca|buia|silenziosa]

? C'è uno strano indizio ad attendermi?
-> Sì (d6=6)
=> Trovo una pagina di diario strappata che parla del faro. [E:IndizioFaro 1/6]

La pagina è ingiallita. Scrittura tremante: "La luce ci chiama."

[Thread:Mistero del Faro|Aperto]

S2 *Fuori dalla biblioteca, corridoio vuoto*

? Sento dei passi?
-> Sì, ma... (d6=4)
=> Si avvicina un custode, ma non mi ha ancora notato. [N:Custode|stanco|sospettoso]

N (Custode): "Mi era parso di sentire qualcosa..."
PG (Alex): "Devo andarmene da qui."

@ Scivolare via mentre è distratto
d: Furtività d6=6 vs CD 4 -> Successo
=> Scappo nella notte in sicurezza.

=== Sessione 2 ===
[Data]        10-09-2025
[Durata]      2h
[Riassunto]   Trovata pagina di diario, quasi scoperto in biblioteca.

S3 *Sentiero verso il faro, Giorno 2*

@ Avvicinarsi silenziosamente al crepuscolo
d: Furtività d6=2 vs CD 4 -> Fallimento
=> Calpesto dei vetri rotti. [Clock:Sospetto 1/6]

? Qualcuno risponde?
-> No, ma... (d6=3)
=> Luce sfarfalla nella finestra della torre. [L:Faro|rovinato|infestato]

S4 *All'interno dell'atrio del faro*

@ Cercare sul pavimento segni
d: Investigazione d6=6 vs CD 4 -> Successo
=> Orme fresche nella polvere. [Thread:Chi usa il faro?|Aperto]

tbl: d100=42 -> "Una lanterna rotta"
=> Lanterna crepata vicino alle scale. [E:IndizioFaro 2/6]

PG (Alex): "Questo posto non è così abbandonato come tutti pensano..."

```

#pagebreak()
= 7. Best Practices
<best-practices>
Hai imparato la notazione. Ora parliamo di come usarla bene. Questa sezione mostra schemi collaudati che rendono i tuoi registro più chiari e utili, oltre agli errori comuni da evitare.

Pensali come linee guida derivanti dall'esperienza collettiva della comunità solista. Non sono regole rigide, ma ti aiuteranno a creare registro facili da leggere, consultare e condividere.

== 7.1 Buone Pratiche ✓
<buone-pratiche>
Questi schemi rendono i tuoi registro più puliti, più ricercabili e più facili da consultare in seguito. Non hai bisogno di seguirli tutti, ma rappresentano ciò che funziona bene per la maggior parte dei giocatori solitari.

#strong[Sì: Mantieni azioni e tiri collegati]

```
@ Scassinare la serratura
d: d20=15 vs CD 14 -> Successo
=> La porta si apre silenziosamente.
```

#strong[Sì: Usa i tag per gli elementi persistenti]

```
[N:Jonah|amichevole|ferito]
[L:Faro|rovinato]
```

#strong[Sì: Registra le conseguenze chiaramente]

```
=> Trovo la chiave. [E:Indizio 2/4]
=> Ma la guardia mi ha sentito. [Clock:Allerta 1/6]
```

#strong[Sì: Usa i tag di riferimento nelle scene successive]

```
Prima menzione: [N:Jonah|amichevole]
Dopo: [#N:Jonah] si avvicina cautamente
```

#strong[Sì: Mescola abbreviazioni e narrazione al bisogno]

```
@ Superare la guardia furtivamente
d: 5≥4 S -> Successo
=> Scivolo via inosservato, con il cuore a mille.
```

== 7.2 Cattive Pratiche ✗
<cattive-pratiche>
Questi sono errori comuni che rendono i registro più difficili da leggere o analizzare. Se ti accorgi di farli, non preoccuparti: correggiti per la prossima volta. Ci siamo passati tutti!

#strong[No: Seppellire le meccaniche nella prosa]

```
❌ Ho provato a scassinare la serratura e ho fatto un 15 che ha battuto la CD quindi l'ho aperta

✔️ @ Scassinare la serratura
  d: 15≥14 -> Successo
  => La porta si apre silenziosamente.
```

#strong[No: Dimenticare di registrare le conseguenze]

```
❌ @ Attaccare la guardia
  d: 8≤10 -> Fallimento

✔️ @ Attaccare la guardia
  d: 8≤10 -> Fallimento
  => La mia lama rimbalza sulla sua armatura. Lui contrattacca!
```

#strong[No: Perdere traccia dei tag tra le scene]

```
❌ [N:Guardia|allerta] ... poi più tardi ... [N:Guardia|dormiente]
   (Come è cambiato? Quando?)

✔️ [N:Guardia|allerta] ... poi più tardi ...
  @ Metterla fuori combattimento
  d: 6≥5 S => [N:Guardia|priva di sensi]
```

#strong[No: Confondere i simboli di azione e oracolo]

```
❌ ? Superare le guardie furtivamente    (Questa è un'azione, non una domanda)

✔️ @ Superare le guardie furtivamente    (Le azioni usano @)
  ? Mi notano?                          (Le domande usano ?)
```

#strong[No: Dimenticare il contesto della scena]

```
❌ S7
  @ Superare le guardie furtivamente
  
✔️ S7 *Vicolo buio, mezzanotte*
  @ Superare le guardie furtivamente
```

#pagebreak()
= 8. Template
<template>
Iniziare da una pagina bianca può scoraggiare. Questi template ti offrono un punto di partenza strutturato. Copiali, compila i campi e inizia a giocare.

Ogni template è disponibile sia in formato #strong[markdown digitale] che per #strong[taccuino analogico];. Scegli quello che corrisponde al tuo stile di gioco, o usali come ispirazione per creare i tuoi.

Non trattare questi template come moduli rigidi. Sono impalcature. Una volta che sarai a tuo agio con la notazione, probabilmente svilupperai i tuoi template che si adattano meglio alle tue esigenze specifiche.

== 8.1 Template Campagna (Digitale YAML)
<template-campagna-digitale-yaml>
Per i file markdown digitali, usa lo YAML front matter per memorizzare i metadati della campagna. Questo va proprio in cima al tuo file, prima di qualsiasi altro contenuto.

Copia questo template, inserisci i tuoi dettagli e sarai pronto per iniziare la tua prima sessione.

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
# [Titolo Campagna]

## Sessione 1
*Data: | Durata: *

### S1 *Scena iniziale*

Il tuo registro di gioco qui...

```

== 8.2 Template Campagna (Analogico)
<template-campagna-analogico>
Per i taccuini cartacei, scrivi questo blocco intestazione all'inizio del registro della tua campagna. Mantienilo semplice---puoi sempre aggiungere altri dettagli in seguito, se necessario.

```
=== Registro Campagna: [Titolo] ===
[Titolo]        
[Regolamento]      
[Genere]        
[Giocatore]       
[PG]          
[Data Inizio]   
[Ultimo Agg.]  
[Strumenti]        
[Temi]          
[Tono]         
[Note]        

=== Sessione 1 ===
[Data]        
[Durata]    

S1 *Scena iniziale*

Il tuo registro di gioco qui...
```

== 8.3 Template Sessione
<template-sessione>
Usa questo all'inizio di ogni sessione di gioco per segnare i confini e fornire il contesto. La versione digitale usa le intestazioni markdown; la versione analogica usa intestazioni scritte.

Compila ciò che è utile e salta ciò che non lo è. L'unico campo essenziale è la data---tutto il resto è opzionale.

#strong[Digitale:]

```markdown
## Sessione X
*Data: | Durata: | Scene: *

**Riassunto:** **Obiettivi:** ### S1 *Descrizione scena*
```

#strong[Analogico:]

```
=== Sessione X ===
[Data]        
[Durata]    
[Riassunto]       
[Obiettivi]       

S1 *Descrizione scena*
```

== 8.4 Template Scena Rapida
<template-scena-rapida>
Questo è il tuo template da lavoro---la struttura base che userai scena dopo scena. È intenzionalmente minimale: solo la struttura sufficiente per tenerti orientato senza rallentarti.

Usa questo come punto di partenza predefinito per ogni scena, sia che tu giochi in digitale o in analogico.

```markdown
S# *Luogo, ora*
```

\@ La tua azione d: il tuo tiro -\> esito =\> Cosa succede

? La tua domanda -\> Risposta oracolo =\> Cosa significa

```
```

#pagebreak()
= 9. Adattare al Tuo Sistema
<adattare-al-tuo-sistema>
Ecco la parte bella: questa notazione funziona con #emph[qualsiasi] sistema GDR in solitaria. #emph[Ironsworn];, #emph[Mythic GME];, #emph[Thousand Year Old Vampire];, il tuo sistema casalingo… non importa. I simboli di base rimangono gli stessi; cambiano solo i dettagli della risoluzione.

Questa sezione ti mostra come adattare la notazione dei tiri `d:` e i formati dell'oracolo `->` per corrispondere al tuo specifico sistema di gioco. Copriremo sistemi comuni (PbtA, FitD, Ironsworn, OSR) e oracoli (Mythic, CRGE, MUNE), ma i principi funzionano per tutto.

#strong[L'intuizione chiave:] La notazione separa le #emph[meccaniche] dalla #emph[finzione];. Il tuo sistema determina come funzionano le meccaniche; la notazione si limita a registrarle in modo coerente.

== 9.1 Notazione dei Tiri Specifica del Sistema
<notazione-dei-tiri-specifica-del-sistema>
La notazione `d:` funziona con qualsiasi sistema---devi solo adattarla alle tue specifiche meccaniche dei dadi. Ecco come appare la notazione nei popolari sistemi GDR solisti.

Questi esempi mostrano lo schema: registra cosa hai tirato, confrontalo con ciò di cui avevi bisogno, annota l'esito. I dettagli cambiano a seconda del sistema, ma la struttura rimane la stessa.

=== 9.1.1 Powered by the Apocalypse (PbtA)
<powered-by-the-apocalypse-pbta>
```
d: 2d6=9 -> Successo Parziale (7-9)
d: 2d6=7 -> Successo Parziale (7-9)
d: 2d6=4 -> Fallimento (6-)
```

=== 9.1.2 Forged in the Dark (FitD)
<forged-in-the-dark-fitd>
```
d: 4d6=6,5,4,2 (prendi il più alto=6) -> Successo Critico
d: 3d6=4,4,2 -> Successo Parziale (4-5)
d: 2d6=3,2 -> Fallimento (1-3)
```

=== 9.1.3 Ironsworn
<ironsworn>
```
d: Azione=7+Stat=2=9 vs Sfida=4,8 -> Colpo Debole
d: Azione=10+Stat=3=13 vs Sfida=2,7 -> Colpo Forte
```

=== 9.1.4 Fate/Fudge
<fatefudge>
```
d: 4dF=+2 (++0-) +Abilità=3 = +5 -> Successo con Stile
d: 4dF=-1 (-0--) +Abilità=2 = +1 -> Pareggio
```

=== 9.1.5 OSR/D&D Tradizionale
<osrdd-tradizionale>
```
d: d20=15+Mod=2=17 vs CA 16 -> Colpito
d: d20=8+Mod=-1=7 vs CD 10 -> Fallimento
```

== 9.2 Adattamenti dell'Oracolo
<adattamenti-delloracolo>
Diversi sistemi oracolari hanno diversi formati di output. Alcuni danno risposte sì/no, altri generano risultati complessi. Ecco come registrare i risultati dei popolari sistemi oracolari.

La chiave è la coerenza: usa sempre `->` per i risultati dell'oracolo, quindi cattura qualsiasi informazione il tuo oracolo fornisca.

=== 9.2.1 Mythic GME
<mythic-gme>
```
? La guardia mi nota? (Probabilità: Improbabile)
-> No, ma... (CF=4)
=> Non mi vede, ma è sospettosa.
```

=== 9.2.2 CRGE (Conjectural Roleplaying Game Engine)
<crge-conjectural-roleplaying-game-engine>
```
? Qual è l'umore del mercante?
-> Impulso: Attore + Focus => Arrabbiato + Tradimento
=> Il mercante è furioso per essere stato ingannato.
```

=== 9.2.3 MUNE (Madey Upy Number Engine)
<mune-madey-upy-number-engine>
```
? C'è qualcuno in casa?
-> Probabile + tiro 2,4 => Sì
=> Le luci sono accese, c'è sicuramente qualcuno all'interno.
```

=== 9.2.4 UNE (Universal NPC Emulator)
<une-universal-npc-emulator>
```
gen: Motivazione UNE -> Potere + Reputazione
=> [N:Barone|ambizioso|cerca riconoscimento]
```

== 9.3 Gestione dei Casi Limite
<gestione-dei-casi-limite>
Ogni sistema ha le sue particolarità. Ecco come gestire situazioni comuni che non rientrano negli schemi di base della notazione.

=== 9.3.1 Tiri Multipli in un'Unica Azione
<tiri-multipli-in-ununica-azione>
Quando devi effettuare più tiri per una sola azione:

#strong[Vantaggio/Svantaggio:]

```
@ Attaccare con vantaggio
d: 2d20=15,8 (prendi il più alto) vs CD 12 -> 15≥12 Successo
=> Colpisco con precisione, la lama trova un varco nell'armatura.
```

#strong[Dice pool multipli:]

```
@ Eseguire un rituale complesso
d: INT d6=4, VOL d6=5, vs CD 4 ciascuno -> Entrambi successo
=> L'incantesimo prende piede, l'energia scoppietta tra le mie dita.
```

#strong[Tiri contrapposti:]

```
@ Braccio di ferro con il marinaio
d: FOR d20=12 vs marinaio d20=15 -> 12≤15 Fallimento
=> La sua presa si stringe. Il mio braccio sbatte sul tavolo.
```

=== 9.3.2 Risultati Ambigui dell'Oracolo
<risultati-ambigui-delloracolo>
Quando l'oracolo dà risultati poco chiari o contraddittori:

```
? Il mercante è degno di fiducia?
-> Sì, ma... (d6=4)
(nota: "ma" contraddice "sì"—interpretazione: degno di fiducia ma nasconde qualcosa)
=> Sembra onesto, ma continua a guardare la porta nervosamente.
```

Oppure tira di nuovo se sei davvero bloccato:

```
? Posso fidarmi di lui?
-> Risultato non chiaro (d6=3 su oracolo binario)
(nota: tiro di nuovo con un inquadramento diverso)
? Sta cercando di aiutarmi?
-> No, e... (d6=2)
=> Sta lavorando attivamente contro di me.
```

=== 9.3.3 Conseguenze Annidate
<conseguenze-annidate>
A volte una conseguenza ne genera un'altra, creando una cascata:

```
d: Scassinare 5≥4 -> Successo
=> La porta si apre
=> Ma i cardini stridono rumorosamente
=> Le guardie nella stanza accanto sentono [E:OrologioAllerta 1/6]
=> Una inizia a camminare in questa direzione [N:Guardia|investigazione]
```

#strong[Quando usare:] Grandi successi o fallimenti con molteplici effetti a catena. Non esagerare: la maggior parte delle azioni ha una chiara conseguenza.

=== 9.3.4 Domande all'Oracolo Fallite
<domande-alloracolo-fallite>
Cosa succede se l'oracolo non aiuta?

```
? Cosa c'è dietro la porta?
-> [Risultato poco chiaro/contraddittorio]
(nota: pongo una domanda più specifica)
? C'è pericolo dietro la porta?
-> Sì, e...
=> Pericolo, ed è immediato!
```

#strong[Pro tip:] Se un risultato dell'oracolo non innesca la finzione, va bene riformulare la domanda o tirare di nuovo. L'oracolo serve la tua storia, non il contrario.

#pagebreak()
= Appendici
<appendici>
== A. Legenda di Lonelog
<a.-legenda-di-lonelog>
Questo è il tuo riferimento rapido, il foglio riassuntivo da tenere a portata di mano mentre giochi. Hai dimenticato cosa significa `=>`? Hai bisogno di ricordare come formattare un orologio? Questa sezione ti aiuta.

Pensalo come al "vocabolario" della notazione. Tutto qui è stato spiegato in dettaglio in precedenza; questa è solo la versione condensata per una rapida consultazione.

Metti un segnalibro a questa sezione. Ci tornerai spesso nelle tue prime sessioni, poi sempre meno man mano che la notazione diventerà naturale.

=== A.1 Simboli di Base
<a.1-simboli-di-base>
#table(
  columns: (33.33%, 33.33%, 33.33%),
  align: (auto,auto,auto,),
  table.header([Simbolo], [Significato], [Esempio],),
  table.hline(),
  [`@`], [Azione del giocatore (meccaniche)], [`@ Scassinare la serratura`],
  [`?`], [Domanda all'oracolo (mondo/incertezza)], [`? C'è qualcuno all'interno?`],
  [`d:`], [Tiro/risultato meccanica], [`d: 2d6=8 vs CD 7 -> Successo`],
  [`->`], [Risultato oracolo/dadi], [`-> Sì, ma...`],
  [`=>`], [Conseguenza/esito], [`=> La porta si apre silenziosamente`],
)
=== A.2 Operatori di Confronto
<a.2-operatori-di-confronto>
- `≥` o `>=` --- Maggiore o uguale (eguaglia/supera la CD)
- `≤` o `<=` --- Minore o uguale (fallisce nel raggiungere la CD)
- `vs` --- Versus (confronto esplicito)
- `S` --- Flag di Successo
- `F` --- Flag di Fallimento

=== A.3 Tag di Tracciamento
<a.3-tag-di-tracciamento>
- `[N:Nome|tag]` --- PNG (prima menzione)
- `[#N:Nome]` --- PNG (riferimento a menzione precedente)
- `[L:Nome|tag]` --- Luogo
- `[E:Nome X/Y]` --- Evento/Orologio
- `[Thread:Nome|stato]` --- Filo della trama
- `[PG:Nome|stat]` --- Personaggio del Giocatore

=== A.4 Tracciamento dei Progressi
<a.4-tracciamento-dei-progressi>
- `[Clock:Nome X/Y]` --- Orologio (si riempie)
- `[Track:Nome X/Y]` --- Tracciato dei progressi
- `[Timer:Nome X]` --- Timer per il conto alla rovescia

=== A.5 Generazione Casuale
<a.5-generazione-casuale>
- `tbl: tiro -> risultato` --- Semplice consultazione di tabella
- `gen: sistema -> risultato` --- Generatore complesso

=== A.6 Struttura
<a.6-struttura>
- `S#` o `S#a` --- Numero della scena
- `T#-S#` --- Scena specifica del thread

=== A.7 Narrativa (Opzionale)
<a.7-narrativa-opzionale>
- Inline: `=> Prosa qui`
- Dialogo: `N (Nome): "Parlato"`
- Blocco: `--- testo ---`

=== A.8 Meta
<a.8-meta>
- `(nota: ...)` --- Riflessione, promemoria, house rule

=== A.9 Riga di Esempio Completa
<a.9-riga-di-esempio-completa>
```
S3 @Scassinare d:15≥14 S => porta si apre silenziosamente [N:Guardia|vigile]
```

== B. FAQ
<b.-faq>
Hai domande? Non sei solo. Queste sono le domande più comuni di chi impara la notazione, con risposte dirette.

Se la tua domanda non è qui, ricorda: la notazione è flessibile. Se ti chiedi se puoi fare qualcosa diversamente, la risposta è probabilmente "sì, se funziona per te".

#strong[D: Devo usare ogni elemento?]

R: No! Inizia solo con `@`, `?`, `d:`, `->`, e `=>`. Aggiungi altri elementi solo se ti aiutano.

#strong[D: Posso usarlo con GDR tradizionali (con un Master)?]

R: La notazione di base funziona benissimo per qualsiasi nota di GDR. Gli elementi dell'oracolo (`?`, `->`) sono specifici per il gioco solista, ma la notazione azione/risoluzione funziona ovunque.

#strong[D: E se il mio sistema non usa i dadi?]

R: Usa `d:` per qualsiasi meccanica di risoluzione: `d: Pesca dal mazzo -> Regina di Picche`, `d: Spendi token -> Successo`

#strong[D: Dovrei usare il formato digitale o analogico?]

R: Quello che preferisci! Usano la stessa notazione. Il digitale ha una migliore ricerca/organizzazione; l'analogico è immediato e tattile.

#strong[D: Quanto dovrebbero essere dettagliate le mie note?]

R: Quanto vuoi! Il sistema funziona per abbreviazioni pure (Esempio 6.1) o narrazione ricca (Esempio 6.4).

#strong[D: Posso condividere i miei registro con altri?]

R: Sì! Questo è uno dei motivi per una notazione standardizzata. Altri che conoscono il sistema possono leggere facilmente i tuoi registro.

#strong[D: E per quanto riguarda le house rule o i simboli personalizzati?]

R: Documentali nelle meta note: `(nota: uso + per vantaggio, - per svantaggio)`. Il sistema è progettato per essere esteso.

#strong[D: I numeri delle scene devono essere sequenziali?]

R: No.~Usa `S1`, `S2`, `S3` per semplicità, ma dirama (`S3a`, `S3b`) o usa i prefissi dei thread (`T1-S1`) se utile.

#strong[D: Dovrei aggiornare i tag ogni volta che qualcosa cambia?]

R: Mostra esplicitamente i cambiamenti significativi: `[N:Guardia|vigile]` → `[N:Guardia|priva di sensi]`. I cambiamenti minori possono essere impliciti nella narrazione.

== C. Filosofia del Design dei Simboli
<c.-filosofia-del-design-dei-simboli>
I simboli di Lonelog sono stati scelti per ragioni specifiche:

- #strong[`@` (Azione)];: Rappresenta "in questo punto" o l'attore che compie l'azione. Cambiato da `>` nella v2.0 per evitare conflitti con i blockquote di Markdown.
- #strong[`?` (Domanda)];: Simbolo universale per l'interrogazione. Invariato dalla v2.0.
- #strong[`d:` (Dadi/Risoluzione)];: Chiara abbreviazione per i tiri di dadi. Invariato dalla v2.0.
- #strong[`->` (Risoluzione)];: Mantenuto dalla v2.0. Ora unificato per TUTTE le risoluzioni (dadi e oracolo). La freccia mostra visivamente "questo porta al risultato".
- #strong[`=>` (Conseguenza)];: Mantenuto dalla v2.0. La doppia freccia mostra gli effetti a cascata. Uso chiarito: solo conseguenze (la v2.0 sovraccaricava questo simbolo anche per gli esiti dei dadi).

#strong[Compatibilità Markdown];: Tutti i simboli funzionano correttamente nei blocchi di codice e non confliggono con la formattazione markdown o gli operatori matematici. Avvolgi sempre la notazione in blocchi di codice quando usi il markdown digitale per prevenire conflitti con le estensioni Markdown.

#pagebreak()
= Crediti & Licenza
<crediti-licenza>
© 2025-2026 Roberto Bisceglie

Questa notazione è ispirata al #link("https://alfredvalley.itch.io/the-valley-standard")[Valley Standard];.

#strong[Ringraziamenti:]

- matita per il metodo `+`/`-` per tracciare i cambiamenti nei tag
- flyincaveman per il suggerimento sull'uso del simbolo `@` per le azioni del personaggio (nella tradizione dei primi RPG ASCII)
- r/solorpgplay e r/Solo\_Roleplaying per la positiva accoglienza di questa notazione e per i feedback utili.
- Enrico Fasoli per il playtesting e il feedback

#strong[Cronologia Versioni:]

- v 1.0.0: Evoluto da Notazione per GDR Solitario v2.0 di Roberto Bisceglie

Questo lavoro è distribuito sotto la licenza #strong[Creative Commons Attribution-ShareAlike 4.0 International];.

#strong[Sei libero di:]

- Condividere --- copiare e ridistribuire il materiale
- Adattare --- rimixare, trasformare e sviluppare il materiale

#strong[Alle seguenti condizioni:]

- Attribuzione --- Devi dare i crediti appropriati
- Stessa Licenza --- Se adatti il materiale, devi distribuire i tuoi contributi sotto la stessa licenza

#emph[Buone avventure, giocatori solitari!]
