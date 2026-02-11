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
  "it": "Indice",
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
  subtitle: "Une notation standardisée pour la prise de note de session JDR solo",
  version: "1.0.0",
  authors: ("Roberto Bisceglie", ),
  date: none,
  abstract: none,
  cols: 1,
  lang: "fr",
  region: "US",
  section-numbering: none,
  toc: true,
  toc_title: "Table des matières",
  toc_depth: 2,
  logo-image: "logo.png",
  license-image: "by-sa.png",
  doc,
)

= 1. Introduction
<introduction>
Si vous avez déjà joué à un JDR en solo, vous connaissez le défi : vous êtes au cœur d'une scène passionnante, les dés roulent, les oracles répondent aux questions, et soudain vous réalisez : comment puis-je noter tout cela sans interrompre le rythme ?

Peut-être avez-vous essayé le journal de bord libre (qui devient désordonné), la prose pure (qui perd la mécanique de jeu), ou les listes à puces (difficiles à analyser plus tard). Ce système de notation offre une approche différente : un #strong[raccourci léger] qui capture les éléments de jeu essentiels tout en laissant de la place pour autant (ou aussi peu) de narration que vous le souhaitez.

== 1.1 Pourquoi "Lonelog" ?
<pourquoi-lonelog>
Ce système a commencé sous le nom de #strong[Solo TTRPG Notation];, un nom descriptif mais peu pratique. Près de 5 000 téléchargements plus tard, il était clair que le concept trouvait un écho auprès de la communauté. Mais l'utilisation réelle a apporté de précieuses leçons sur ce qui fonctionnait, ce qui créait des frictions et où la notation pouvait évoluer.

Le changement de nom pour #strong[Lonelog] reflète trois idées :

- #strong[Un nom qui reste.] "Solo TTRPG Notation" a été abrégé d'une douzaine de manières différentes. #emph[Lonelog] est compact et évocateur : #emph[Lone] (jeu en solo) + #emph[log] (journal de session). Ça fonctionne.

- #strong[Un nom que vous pouvez trouver.] Cherchez "solo ttrpg notation" et vous vous noierez dans des résultats génériques. Cherchez "lonelog" et vous obtenez #emph[ce système];. Pensez à la façon dont #strong[Markdown] a réussi à la fois comme format et comme marque, il ne s'appelle pas "Notation de Formatage de Texte". Lonelog donne à cette notation une identité distincte et trouvable.

- #strong[Un nom conçu pour durer.] À mesure que le système mûrit, avoir une identité claire facilite le partage de ressources, d'outils et de journaux de session par la communauté sous une seule bannière.

La philosophie de base n'a pas changé : séparer la mécanique de la fiction, rester compact à la table de jeu, s'adapter des one-shots aux longues campagnes, et fonctionner aussi bien en markdown que sur des carnets papier.

== 1.2 Ce que fait Lonelog
<ce-que-fait-lonelog>
Pensez-y comme un langage commun pour le jeu en solo. Que vous jouiez à #emph[Ironsworn];, #emph[Thousand Year Old Vampire];, à un JDR non solo avec le Mythic GME, ou à votre propre système maison, cette notation vous aide à :

- #strong[Enregistrer ce qui s'est passé] sans ralentir le jeu
- #strong[Suivre les éléments en cours] comme les PNJ, les lieux et les intrigues
- #strong[Partager vos sessions] avec d'autres joueurs solo qui comprendront le format
- #strong[Relire les sessions passées] et retrouver rapidement ce détail crucial d'il y a trois sessions

La notation est conçue pour être :

- #strong[Flexible] --- utilisable avec différents systèmes et formats
- #strong[Superposable] --- fonctionne à la fois comme un raccourci rapide ou une narration développée
- #strong[Recherchable] --- les balises et les codes facilitent le suivi des PNJ, des événements et des lieux
- #strong[Indépendante du format] --- fonctionne dans des fichiers markdown numériques ou des carnets analogiques

Les objectifs de la notation :

- #strong[Rendre les rapports écrits par différentes personnes lisibles en un coup d'œil :] les symboles standards facilitent la lecture
- #strong[Séparer la mécanique de la fiction :] les meilleurs rapports sont ceux qui mettent en évidence comment l'utilisation des règles et des oracles informe la fiction
- #strong[Avoir un système modulaire et évolutif :] vous pouvez utiliser les symboles de base ou étendre la notation comme vous le souhaitez
- #strong[Le rendre utile pour les notes numériques et analogiques]
- #strong[Conformité et extension de markdown pour un usage numérique]

== 1.3 Comment utiliser cette notation
<comment-utiliser-cette-notation>
Considérez ceci comme une #strong[boîte à outils, pas un livre de règles];. Le système est entièrement modulaire : prenez ce qui fonctionne pour vous et laissez le reste.

À la base, il n'y a que #strong[cinq symboles] (voir #emph[Section 3 : Notation de base];). Ils sont soigneusement choisis pour éviter les conflits avec le formatage markdown et les opérateurs de comparaison. C'est le langage minimal du jeu :

- `@` pour les actions du joueur
- `?` pour les questions à l'oracle
- `d:` pour les jets de mécanique
- `->` pour les résultats de l'oracle/des dés
- `=>` pour les conséquences

C'est tout. #strong[Tout le reste est optionnel.]

Les scènes, les en-têtes de campagne, les en-têtes de session, les fils conducteurs, les horloges, les extraits narratifs --- ce sont tous des ajouts que vous pouvez faire quand ils servent votre jeu. Vous voulez suivre une longue campagne ? Ajoutez des en-têtes de campagne. Besoin de suivre des intrigues complexes ? Utilisez des balises de fil conducteur. Vous jouez un one-shot rapide ? Tenez-vous-en aux cinq symboles de base.

Pensez-y comme des cercles concentriques :

- #strong[Notation de base] (requise) : Actions, Résolutions, Conséquences
- #strong[Couches optionnelles] (à ajouter au besoin) : Éléments persistants, Suivi de progression, Notes, etc.
- #strong[Structure optionnelle] (pour l'organisation) : En-tête de campagne, En-tête de session, Scènes

#strong[Commencez petit.] Essayez la notation de base pour une scène. Si ça vous plaît, super --- continuez. Si vous avez besoin de plus, ajoutez ce qui vous aide. Vos notes doivent servir votre jeu, pas l'inverse.

== 1.4 Démarrage rapide : Votre première session
<démarrage-rapide-votre-première-session>
Jamais utilisé de notation auparavant ? Voici tout ce dont vous avez besoin :

```
S1 *Votre scène de départ*
@ Action que vous entreprenez
d: votre résultat de jet -> Succès ou Échec
=> Ce qui se passe en conséquence

? Question que vous posez à l'oracle
-> Réponse de l'oracle
=> Ce que cela signifie dans l'histoire
```

#strong[C'est tout !] Tout le reste est optionnel. Essayez ceci pour une scène et voyez ce que vous en pensez.

=== Exemple de démarrage rapide
<exemple-de-démarrage-rapide>
```
S1 *Ruelle sombre, minuit*
@ Se faufiler devant le garde
d: Discrétion 4 vs ND 5 -> Échec
=> Je donne un coup de pied dans une bouteille. Le garde se retourne !

? Me voit-il clairement ?
-> Non, mais...
=> Il est méfiant, commence à marcher vers le bruit
```

== 1.5 Migration depuis Solo TTRPG Notation v2.0
<migration-depuis-solo-ttrpg-notation-v2.0>
Si vous utilisez déjà Solo TTRPG Notation v2.0, bienvenue ! Lonelog est une évolution de ce système avec des symboles clarifiés pour une meilleure cohérence.

#strong[Ce qui a changé :]

#table(
  columns: (25%, 30.36%, 44.64%),
  align: (auto,auto,auto,),
  table.header([Symbole v2.0], [Symbole Lonelog], [Pourquoi le changement],),
  table.hline(),
  [`>`], [`@`], [Évite le conflit avec les citations en bloc de Markdown],
  [`->` (oracle uniquement)], [`->` (toutes les résolutions)], [Maintenant unifié pour les résultats des dés ET de l'oracle],
  [`=>` (surchargé)], [`=>` (conséquences uniquement)], [Clarifié --- ne sert plus de résultat de dé],
)
#strong[Clarification clé :] Dans la v2.0, `=>` était utilisé de manière confuse pour les résultats des dés et les conséquences. Lonelog clarifie cela en utilisant `->` pour TOUTES les résolutions (dés et oracle), réservant `=>` exclusivement aux conséquences.

=== Vos anciens journaux sont toujours valides
<vos-anciens-journaux-sont-toujours-valides>
La structure et la philosophie restent identiques. Vos journaux existants sont parfaitement lisibles --- vous n'avez pas besoin de les convertir à moins de vouloir une cohérence dans toute votre campagne.

=== Conversion
<conversion>
Si vous préférez une conversion manuelle, utilisez rechercher & remplacer dans votre éditeur de texte :

+ Trouver : `>` (en début de ligne) → Remplacer : `@`
+ Les symboles `->` et `=>` sont conservés mais avec une utilisation clarifiée.

= 2. Formats numérique vs analogique
<formats-numérique-vs-analogique>
Cette notation fonctionne à la fois dans des #strong[fichiers markdown numériques et des carnets analogiques];. Choisissez le format qui convient à votre style de jeu.

== 2.1 Format numérique (Markdown)
<format-numérique-markdown>
Dans les fichiers markdown numériques :

- #strong[Métadonnées de la campagne] → YAML front matter (en haut du fichier)
- #strong[Titre de la campagne] → Titre de niveau 1
- #strong[Sessions] → Titres de niveau 2 (`## Session 1`)
- #strong[Scènes] → Titres de niveau 3 (`### S1`)
- #strong[Notation de base et suivi] → Blocs de code pour faciliter la copie/l'analyse
- #strong[Narration] → Prose normale entre les blocs de code

#quote(block: true)[
#strong[Note :] Enveloppez toujours la notation dans des blocs de code (#raw("```");) lorsque vous utilisez le markdown numérique. Cela évite les conflits avec la syntaxe Markdown et garantit que les symboles comme `=>` s'affichent correctement. Certaines extensions Markdown (Mermaid, plugins Obsidian) peuvent interpréter `=>` en dehors des blocs de code.
]

== 2.2 Format analogique (Carnet)
<format-analogique-carnet>
Dans les carnets papier :

- Écrivez les en-têtes et les métadonnées directement comme indiqué
- La notation de base fonctionne de manière identique mais sans les clôtures de code
- Utilisez les mêmes symboles et la même structure
- Les crochets et les balises aident à parcourir les pages papier

== 2.3 Exemples de format
<exemples-de-format>
=== Markdown numérique
<markdown-numérique>
````markdown
## Session 1
*Date : 2025-09-03 | Durée : 1h30 | Scènes : S1-S2*

### S1 *Bibliothèque de l'école après les cours*

```
@ Se faufiler à l'intérieur pour vérifier les archives
d: Discrétion d6=5 vs ND 4 -> Succès
=> Je me glisse à l'intérieur sans être remarqué. [L:Bibliothèque|sombre|calme]
```
````

=== Carnet analogique
<carnet-analogique>
```
=== Session 1 ===
Date : 2025-09-03
Durée : 1h30
Scènes : S1-S2

S1 *Bibliothèque de l'école après les cours*

@ Se faufiler à l'intérieur pour vérifier les archives
d: Discrétion d6=5 vs ND 4 -> Succès
=> Je me glisse à l'intérieur sans être remarqué. [L:Bibliothèque|sombre|calme]
```

Les deux formats utilisent une notation identique --- seul l'emballage diffère.

= 3. Notation de base
<notation-de-base>
C'est le cœur du système --- les symboles que vous utiliserez dans presque chaque scène. Tout le reste dans ce document est optionnel, mais ces éléments de base sont ce qui fait fonctionner la notation.

Il n'y a que cinq symboles à retenir, et ils reflètent le flux naturel du jeu en solo : vous entreprenez une action ou posez une question, vous la résolvez avec la mécanique ou un oracle, puis vous enregistrez ce qui se passe en conséquence.

Détaillons cela.

== 3.1 Actions
<actions>
En jeu solo, l'incertitude provient de deux sources distinctes : #strong[vous ne savez pas si votre personnage peut faire quelque chose] (c'est la mécanique), ou #strong[vous ne savez pas ce que fait le monde] (c'est l'oracle).

Cette distinction est fondamentale. Lorsque vous balancez une épée, vous utilisez la mécanique pour voir si vous touchez. Lorsque vous vous demandez si des gardes sont à proximité, vous demandez à l'oracle. Les deux créent de l'incertitude, mais ils sont résolus différemment.

La notation reflète cela avec deux symboles différents --- un pour chaque type d'action.

Le symbole `@` vous représente, le joueur, agissant dans le monde du jeu. Pensez-y comme "à ce moment, je…". Il est visuellement distinct des opérateurs de comparaison, rendant vos journaux plus clairs et évitant la confusion lors de l'enregistrement des jets de dés.

#strong[Actions orientées joueur (mécanique) :]

```
@ Crocheter la serrure
@ Attaquer le garde
@ Convaincre le marchand
```

#strong[Questions sur le monde / MJ (oracle) :]

```
? Y a-t-il quelqu'un à l'intérieur ?
? La corde tient-elle ?
? Le marchand est-il honnête ?
```

== 3.2 Résolutions
<résolutions>
Une fois que vous avez déclaré une action (`@`) ou posé une question (`?`), vous devez résoudre l'incertitude. C'est là que le système de jeu ou l'oracle vous donne une réponse.

Il existe deux types de résolutions : la #strong[mécanique] (lorsque vous lancez des dés ou appliquez des règles) et les #strong[réponses de l'oracle] (lorsque vous posez une question au monde du jeu).

=== 3.2.1 Jets de mécanique
<jets-de-mécanique>
Format :

```
d: [jet ou règle] -> résultat
```

Le préfixe `d:` indique une résolution par jet de mécanique ou par règle. Incluez toujours le résultat (Succès/Échec ou résultat narratif).

=== Exemples
<exemples>
```
d: d20+Crochetage=17 vs DC 15 -> Succès
d: 2d6=8 vs ND 7 -> Succès
d: Pirater le terminal (dépenser 1 Équipement) -> Succès
```

=== Raccourci de comparaison
<raccourci-de-comparaison>
Lors de la comparaison des jets à des nombres cibles, vous pouvez utiliser des opérateurs de comparaison :

```
d: 5 vs ND 4 -> Succès (format standard)
d: 5≥4 -> S (raccourci : ≥ signifie atteint/dépasse le ND)
d: 2≤4 -> F (raccourci : ≤ signifie n'atteint pas le ND)
```

#strong[Note :] Les opérateurs de comparaison `≥` et `≤` fonctionnent de manière transparente avec la notation lonelog, sans conflit de symboles. Vous pouvez également utiliser `>=` et `<=`.

Ajoutez les lettres `S` (Succès) ou `F` (Échec) si vous voulez des indicateurs explicites :

```
d: 2≤4 F
d: 5≥4 S
```

=== 3.2.2 Résultats de l'oracle et des dés
<résultats-de-loracle-et-des-dés>
Le symbole `->` représente une résolution définitive --- une déclaration de résultat. La flèche montre visuellement "ceci mène au résultat", qu'il soit déterminé par la mécanique des dés ou la réponse de l'oracle.

#strong[Format :]

```
-> [résultat] (référence de jet optionnelle)
```

Le préfixe `->` indique tout résultat de résolution --- mécanique ou oracle.

=== Résultats de la mécanique des dés
<résultats-de-la-mécanique-des-dés>
Pour les jets de mécanique, `->` déclare le Succès ou l'Échec :

```
d: Discrétion d6=5 vs ND 4 -> Succès
d: Crochetage d20=8 vs DC 15 -> Échec
d: Attaque 2d6=7 vs ND 7 -> Succès
d: Piratage d10=3 -> Succès Partiel
```

=== Réponses de l'oracle
<réponses-de-loracle>
Pour les questions à l'oracle, `->` déclare ce que le monde révèle :

```
-> Oui (d6=6)
-> Non, mais... (d6=3)
-> Oui, et... (d6=5)
-> Non, et... (d6=1)
```

=== Formats d'oracle courants
<formats-doracle-courants>
- #strong[Oracles Oui/Non :] `-> Oui`, `-> Non`
- #strong[Oui/Non avec modificateurs :] `-> Oui, mais...`, `-> Non, et...`
- #strong[Résultats gradués :] `-> Oui franc`, `-> Non faible`
- #strong[Résultats personnalisés :] `-> Partiellement`, `-> Avec un coût`

=== Pourquoi une syntaxe unifiée ?
<pourquoi-une-syntaxe-unifiée>
La mécanique et les oracles résolvent tous deux l'incertitude. Utiliser `->` pour les deux crée de la cohérence --- chaque résolution reçoit la même déclaration, ce qui rend votre journal plus facile à parcourir et à analyser. Que vous ayez lancé des dés ou demandé à l'oracle, `->` marque le moment où l'incertitude devient certitude.

== 3.3 Conséquences
<conséquences>
Enregistrez le résultat narratif après les jets en utilisant `=>`. Le symbole montre les conséquences découlant des actions et des résolutions. La double flèche visualise comment les événements se répercutent dans votre histoire.

```
=> La porte grince en s'ouvrant, mais le bruit résonne dans le couloir.
=> Le garde me repère et donne l'alarme.
=> Je trouve un journal intime caché avec un indice crucial.
```

=== Conséquences multiples
<conséquences-multiples>
Vous pouvez enchaîner plusieurs lignes de conséquences pour des effets en cascade :

```
d: Crochetage 5≥4 -> Succès
=> La porte s'ouvre
=> Mais les gonds grincent bruyamment
=> [E:HorlogeAlerte 1/6]
```

== 3.4 Séquences d'action complètes
<séquences-daction-complètes>
Voici comment les éléments de base se combinent :

=== Séquence axée sur la mécanique
<séquence-axée-sur-la-mécanique>
```
@ Crocheter la serrure
d: d20+Crochetage=17 vs DC 15 -> Succès
=> La porte grince en s'ouvrant, mais le bruit résonne dans le couloir.
```

=== Séquence axée sur l'oracle
<séquence-axée-sur-loracle>
```
? Y a-t-il quelqu'un à l'intérieur ?
-> Oui, mais... (d6=4)
=> Quelqu'un est là, mais il est distrait.
```

=== Séquence combinée
<séquence-combinée>
```
@ Se faufiler devant les gardes
d: Discrétion 2≤4 -> Échec
=> Mon pied heurte un tonneau. [E:HorlogeAlerte 2/6]

? Me voient-ils ?
-> Non, mais... (d6=3)
=> Distraits, mais un garde s'attarde. [N:Garde|vigilant]
```

= 4. Couches optionnelles
<couches-optionnelles>
Vous avez les bases --- actions, jets et conséquences. C'est suffisant pour un jeu simple. Mais les campagnes plus longues nécessitent souvent plus : des PNJ qui réapparaissent, des fils d'intrigue qui se tissent à travers les sessions, une progression qui s'accumule avec le temps.

Cette section couvre les #strong[éléments de suivi] qui vous aident à gérer la complexité. Ils sont tous optionnels. Si vous jouez un mystère en une seule session, vous n'aurez peut-être besoin de rien de tout cela. Si vous menez une campagne tentaculaire avec des dizaines de PNJ et de multiples fils d'intrigue, vous voudrez probablement la plupart de ces éléments.

Choisissez ce dont votre campagne a besoin.

== 4.1 Éléments persistants
<éléments-persistants>
Au fur et à mesure que votre campagne se développe, certaines choses restent : les PNJ qui réapparaissent, les lieux où vous retournez, les menaces en cours, les questions de l'histoire qui s'étendent sur plusieurs sessions. Ce sont vos #strong[éléments persistants];.

Les balises vous permettent de les suivre de manière cohérente à travers les scènes et les sessions. Le format est simple : des crochets, un préfixe de type, un nom et des détails facultatifs. Comme ceci : `[N:Jonah|amical|blessé]`.

#strong[Pourquoi utiliser des balises ?]

- #strong[Recherche facile] : Trouvez chaque scène où Jonah apparaît
- #strong[Cohérence] : Référencez les PNJ de la même manière à chaque fois
- #strong[Suivi de statut] : Voyez comment les éléments changent au fil du temps
- #strong[Aide-mémoire] : Rappelez-vous des détails des semaines plus tard

Vous n'avez pas besoin de tout baliser --- seulement ce qui compte pour votre campagne. Un marchand aléatoire que vous ne reverrez jamais ? Appelez-le simplement "le marchand" en prose. Un méchant récurrent ? Balisez-le absolument.

Voici les principaux types d'éléments persistants que vous pourriez suivre :

=== 4.1.1 PNJ (Personnages Non-Joueurs)
<pnj-personnages-non-joueurs>
```
[N:Jonah|amical|blessé]
[N:Garde|vigilant|armé]
[N:Marchand|méfiant]
```

#strong[Mise à jour des balises de PNJ :]

Lorsque le statut d'un PNJ change, vous pouvez soit :

- Redéclarer avec de nouvelles balises : `[N:Jonah|capturé|blessé]`
- Montrer juste le changement : `[N:Jonah|capturé]` (suppose que les autres balises persistent)
- Utiliser des mises à jour explicites : `[N:Jonah|amical→hostile]`
- Ajouter `+` ou `-` : `[N:Jonah|+capturé]` ou `[N:Jonah|-blessé]`

Choisissez le style qui rend votre journal le plus clair.

=== 4.1.2 Lieux
<lieux>
```
[L:Phare|en ruine|orageux]
[L:Bibliothèque|sombre|calme]
[L:Taverne|bondée|bruyante]
```

=== 4.1.3 Événements & Horloges
<événements-horloges>
```
[E:ComplotCultiste 2/6]
[E:HorlogeAlerte 3/4]
[E:ProgressionRituel 0/8]
```

Les événements suivent les éléments importants de l'intrigue. Le format `X/Y` indique la progression actuelle/totale.

=== 4.1.4 Fils conducteurs de l'histoire
<fils-conducteurs-de-lhistoire>
```
[Fil:Retrouver la sœur de Jonah|Ouvert]
[Fil:Découvrir la conspiration|Ouvert]
[Fil:S'échapper de la ville|Fermé]
```

Les fils conducteurs suivent les questions ou objectifs majeurs de l'histoire. États courants :

- `Ouvert` --- fil actif
- `Fermé` --- fil résolu
- `Abandonné` --- fil abandonné
- États personnalisés autorisés (par ex., `Urgent`, `En arrière-plan`)

=== 4.1.5 Personnage Joueur
<personnage-joueur>
```
[PJ:Alex|PV 8|Stress 0|Équipement:Lampe de poche,Carnet]
[PJ:Elara|PV 15|Munitions 3|Statut:Blessée]
```

#strong[Mise à jour des stats du PJ :]

```
[PJ:Alex|PV 8] (initial)
[PJ:Alex|PV-2] (raccourci : a perdu 2 PV, maintenant à 6)
[PJ:Alex|PV 6] (explicite : maintenant à 6 PV)
[PJ:Alex|PV+3|Stress-1] (changements multiples)
```

=== 4.1.6 Balises de référence
<balises-de-référence>
Pour faire référence à un élément précédemment établi sans répéter les balises, utilisez le préfixe `#` :

```
[N:Jonah|amical|blessé] (première mention — établit l'élément)

... plus loin dans le journal ...

[#N:Jonah] (référence — suppose les balises d'avant)
```

Le `#` vous indique que cet élément a été défini plus tôt. Utilisez-le pour :

- Garder les mentions ultérieures concises
- Signaler aux lecteurs qu'ils doivent chercher le contexte plus haut
- Maintenir la capacité de recherche (l'ID "Jonah" apparaît toujours)

#strong[Quand utiliser les balises de référence :]

- Première mention : Balise complète avec détails `[N:Nom|balises]`
- Mentions ultérieures dans la même scène : Optionnel, à votre jugement
- Mentions ultérieures dans des scènes/sessions différentes : Utilisez `[#N:Nom]` pour signaler la référence
- Changements de statut : Laissez tomber le `#` et montrez les nouvelles balises `[N:Nom|nouvelles_balises]`

== 4.2 Suivi de la progression
<suivi-de-la-progression>
Certaines choses dans votre campagne ne se produisent pas d'un coup --- elles se construisent avec le temps. Le rituel prend douze étapes à compléter. La méfiance des gardes grandit à chaque bruit que vous faites. Votre plan d'évasion avance petit à petit. La réserve d'air diminue.

Le suivi de la progression vous donne un moyen visuel de voir ces forces s'accumuler. Trois formats gèrent différents types de progression :

#strong[Horloges] (se remplissent jusqu'à l'achèvement) :

```
[Horloge:Rituel 5/12]
[Horloge:Méfiance 3/6]
```

#strong[Utiliser pour :] Menaces qui montent, sorts en préparation, danger qui s'accumule. Quand l'horloge est pleine, quelque chose se passe (généralement mauvais pour vous).

#strong[Pistes] (progression vers un objectif) :

```
[Piste:Évasion 3/8]
[Piste:Enquête 6/10]
```

#strong[Utiliser pour :] Votre progression sur des projets, l'avancement d'un voyage, des objectifs à long terme. Quand la piste est pleine, vous réussissez quelque chose.

#strong[Compteurs] (comptent à rebours jusqu'à zéro) :

```
[Compteur:Aube 3]
[Compteur:RéserveAir 5]
```

#strong[Utiliser pour :] Échéances qui approchent, ressources qui s'épuisent, pression temporelle. Quand il atteint zéro, le temps est écoulé.

#strong[La différence ?] Les horloges et les pistes augmentent toutes deux, mais les horloges sont des menaces (mauvaises quand elles sont pleines) et les pistes sont des progrès (bonnes quand elles sont pleines). Les compteurs diminuent et créent de l'urgence.

Vous n'avez pas besoin de tout suivre numériquement. N'utilisez ces outils que lorsque l'accumulation est importante pour votre histoire et que vous voulez un moyen concret de la mesurer.

== 4.3 Tables aléatoires & Générateurs
<tables-aléatoires-générateurs>
Le jeu en solo se nourrit de la surprise. Parfois, vous lancez sur une table pour voir ce que vous trouvez, ou vous utilisez un générateur pour créer un PNJ à la volée. Lorsque vous le faites, il est utile d'enregistrer ce que vous avez lancé --- à la fois pour la transparence et pour que vous puissiez recréer la logique plus tard.

#strong[Consultation simple d'une table :]

```
tbl: d100=42 -> "Une épée brisée"
tbl: d20=15 -> "Le marchand est nerveux"
```

Utilisez `tbl:` lorsque vous piochez dans une table aléatoire simple --- le genre où vous lancez une fois et obtenez un résultat.

#strong[Générateurs complexes :]

```
gen: Événement Mythic d100=78 + 11 -> Action PNJ / Trahison
gen: PNJ Stars Without Number d8=3,d10=7 -> Bourru/Pilote
```

Utilisez `gen:` lorsque vous utilisez un générateur à plusieurs étapes qui combine plusieurs lancers ou produit des résultats composés.

#strong[Intégration avec les questions à l'oracle :]

```
? Que trouve-je dans le coffre ?
tbl: d100=42 -> "Une épée brisée"
=> Une ancienne lame, brisée en deux, avec d'étranges runes sur la garde.
```

#strong[Pourquoi enregistrer les lancers ?] Trois raisons :

+ #strong[Transparence] : Si vous partagez le journal, les autres voient votre processus
+ #strong[Reproductibilité] : Vous pouvez retracer comment vous avez obtenu des résultats surprenants
+ #strong[Apprentissage] : Au fil du temps, vous voyez quelles tables vous utilisez le plus

Cela dit, si vous jouez vite et sans chichis, vous pouvez sauter les détails du lancer et simplement enregistrer le résultat : `=> Je trouve une épée brisée [tbl]`. La partie importante est la fiction, pas les maths.

== 4.4 Extraits narratifs
<extraits-narratifs>
Voici un secret : #strong[vous n'avez pas du tout besoin d'écrire de narration];. Le raccourci capture tout mécaniquement. Mais parfois, la fiction exige plus --- un dialogue trop parfait pour ne pas être enregistré, une description qui plante le décor, un document que votre personnage trouve.

C'est à cela que servent les extraits narratifs : les moments où le raccourci ne suffit pas.

#strong[Prose en ligne] (descriptions courtes) :

```
=> La pièce empeste le moisi et la pourriture. Des papiers sont éparpillés partout.
```

#strong[Utiliser pour :] Détails atmosphériques rapides, informations sensorielles, touches émotionnelles. Soyez bref --- une phrase ou deux.

#strong[Dialogue] (conversations qui méritent d'être enregistrées) :

```
N (Garde) : "Qui est là ?"
PJ : "Restez calme... restez juste calme."
N (Garde) : "Montrez-vous !"
PJ : [chuchote] "Ça n'arrivera pas."
```

#strong[Utiliser pour :] Échanges mémorables, voix du personnage, conversations importantes. Vous n'avez pas besoin d'enregistrer chaque mot --- juste les échanges qui comptent.

#strong[Longs blocs narratifs] (documents trouvés, descriptions importantes) :

```
\---
Le journal intime dit :
"Jour 47 : Les marées n'obéissent plus à la lune. Les poissons ont cessé
de venir. Le gardien du phare dit qu'il voit des lumières sous les vagues.
Je crains pour notre santé mentale."
---
```

#strong[Utiliser pour :] Documents du monde du jeu, longues descriptions, révélations clés. Les marqueurs `\---` et `---` le séparent de votre journal, indiquant clairement qu'il s'agit de contenu fictionnel. Les délimiteurs asymétriques évitent les conflits avec les règles horizontales de Markdown.

#strong[Quelle quantité de narration devriez-vous écrire ?] Seulement autant que cela vous sert. Si vous jouez pour vous-même et que le raccourci vous dit tout ce que vous devez vous rappeler, sautez la prose. Si vous partagez votre journal ou que vous aimez le processus d'écriture, ajoutez-en plus. Il n'y a pas de bonne quantité --- juste ce qui rend votre journal utile et agréable pour vous.

== 4.5 Notes méta
<notes-méta>
Parfois, vous avez besoin de sortir de la fiction et de vous laisser une note : un rappel sur une règle maison que vous testez, une réflexion sur la façon dont une scène a été ressentie, une question à revoir plus tard, ou une clarification sur votre interprétation d'une règle.

C'est à cela que servent les notes méta --- vos apartés hors personnage pour vous-même (ou pour les lecteurs, si vous partagez).

#strong[Format :] Utilisez des parenthèses pour signaler "ceci est méta, pas de la fiction" :

```
(note : test de la règle alternative de discrétion où le bruit augmente l'horloge d'Alerte)
(réflexion : cette scène était tendue ! le minuteur a vraiment fonctionné)
(règle maison : donner un avantage sur un terrain familier)
(rappel : revoir ce fil la prochaine session)
(question : aurais-je dû faire un jet pour ça ? ça semblait évident)
```

#strong[Quand utiliser les notes méta :]

- #strong[Expériences] : Suivez les variantes de règles ou les règles maison que vous testez
- #strong[Réflexion] : Capturez ce qui a fonctionné ou non émotionnellement
- #strong[Rappels] : Marquez les choses à suivre plus tard
- #strong[Clarification] : Expliquez les décisions inhabituelles ou les interprétations
- #strong[Processus] : Documentez votre pensée pour les journaux partagés

#strong[Quand NE PAS les utiliser :] Ne laissez pas les notes méta submerger votre journal. Si vous vous arrêtez toutes les quelques lignes pour réfléchir, vous sur-analysez probablement. Le jeu est la chose la plus importante --- les notes méta ne sont que des commentaires occasionnels en marge.

Pensez-y comme le commentaire du réalisateur sur un film. La plupart du temps, vous regardez simplement le film. Occasionnellement, il y a une note intéressante en coulisses qui vaut la peine d'être partagée.

= 5. Structure optionnelle
<structure-optionnelle>
Jusqu'à présent, nous avons parlé de #emph[ce que] vous écrivez (actions, jets, balises). Parlons maintenant de #emph[la façon dont vous l'organisez];.

La structure aide de deux manières : elle rend vos notes plus faciles à naviguer et elle signale des limites (cette session s'est terminée, cette scène a commencé). Mais la structure ajoute une surcharge --- plus d'en-têtes à écrire, plus de formatage à maintenir.

Cette section présente les éléments d'organisation : les en-têtes de campagne (métadonnées sur l'ensemble de votre campagne), les en-têtes de session (marquant les sessions de jeu) et la structure de scène (l'unité de base du jeu). Utilisez ce qui vous aide à rester orienté sans vous ralentir.

La différence clé ? #strong[Les formats numérique et analogique gèrent la structure différemment.] Le markdown numérique utilise des titres et du YAML ; les carnets analogiques utilisent des en-têtes écrits et des marqueurs. Nous montrerons les deux.

== 5.1 En-tête de campagne
<en-tête-de-campagne>
Avant de vous plonger dans le jeu, il est utile d'enregistrer quelques bases : À quoi jouez-vous ? Quel système ? Quand avez-vous commencé ? Pensez-y comme la "page de couverture" de votre journal de campagne.

Ceci est particulièrement utile lorsque :

- Vous menez plusieurs campagnes (vous aide à vous rappeler laquelle est laquelle)
- Vous partagez des journaux avec d'autres (ils ont besoin de contexte)
- Vous revenez à une campagne après une pause (vous rappelle le ton/les thèmes)

Si vous essayez simplement la notation avec un one-shot rapide, ignorez complètement ceci. Mais pour les campagnes que vous prévoyez de revisiter, un en-tête vaut les 30 secondes.

#strong[Les formats numérique et analogique diffèrent ici.] Le markdown numérique utilise le YAML front matter (métadonnées structurées en haut du fichier). Les carnets analogiques utilisent un bloc d'en-tête écrit.

#strong[Pour les fichiers markdown numériques];, utilisez le YAML front matter tout en haut :

```yaml
title: Mystère de Clearview
ruleset: Loner + Oracle Mythic
genre: Mystère adolescent / surnaturel
player: Roberto
pcs: Alex [PJ:Alex|PV 8|Stress 0|Équipement:Lampe de poche,Carnet]
start_date: 2025-09-03
last_update: 2025-10-28
tools: Oracles - Mythic, tables d'événements aléatoires
themes: Amitié, courage, secrets
tone: Inquiétant mais ludique
notes: Inspiré des séries de mystère pour adolescents des années 80
```

#strong[Pour les carnets analogiques];, écrivez un bloc d'en-tête de campagne :

```
=== Journal de campagne : Mystère de Clearview ===
[Titre] Mystère de Clearview
[Règles] Loner + Oracle Mythic
[Genre] Mystère adolescent / surnaturel
[Joueur] Roberto
[PJs] Alex [PJ:Alex|PV 8|Stress 0|Équipement:Lampe de poche,Carnet]
[Date de début] 2025-09-03
[Dernière mise à jour] 2025-10-28
[Outils] Oracles : Mythic, tables d'événements aléatoires
[Thèmes] Amitié, courage, secrets
[Ton] Inquiétant mais ludique
[Notes] Inspiré des séries de mystère pour adolescents des années 80
```

#strong[Champs optionnels] (à ajouter au besoin) :

- `[Cadre]` --- Détails géographiques ou du monde
- `[Inspiration]` --- Médias qui ont inspiré la campagne
- `[Outils de sécurité]` --- Carte X, lignes/voiles, etc.

== 5.2 En-tête de session
<en-tête-de-session>
Un en-tête de session marque la frontière entre les sessions de jeu et fournit un contexte : quand avez-vous joué, combien de temps, que s'est-il passé ?

#strong[Pourquoi utiliser des en-têtes de session ?]

- #strong[Navigation] : Sautez rapidement à des sessions spécifiques
- #strong[Contexte] : Rappelez-vous quand vous avez joué et ce qui se passait
- #strong[Réflexion] : Suivez vos habitudes de jeu (à quelle fréquence ? combien de temps ?)
- #strong[Continuité] : Connectez les sessions avec des résumés et des objectifs

#strong[Quand les ignorer :]

- Parties uniques (pas de sessions multiples)
- Jeu continu (vous jouez quotidiennement sans pauses claires)
- Journaux purement en raccourci (vous voulez juste la fiction, pas la méta-structure)

Comme les en-têtes de campagne, les formats numérique et analogique gèrent les sessions différemment. Choisissez le style qui correspond à votre support.

=== 5.2.1 Format numérique (titre markdown)
<format-numérique-titre-markdown>
```markdown
## Session 1
*Date : 2025-09-03 | Durée : 1h30 | Scènes : S1-S2*

**Résumé :** Première session, présentation d'Alex et du mystère.

**Objectifs :** Mettre en place le mystère central, établir le phare comme lieu clé.
```

=== 5.2.2 Format analogique (en-tête écrit)
<format-analogique-en-tête-écrit>
```
=== Session 1 ===
[Date] 2025-09-03
[Durée] 1h30
[Scènes] S1-S2
[Résumé] Première session, présentation d'Alex et du mystère.
[Objectifs] Mettre en place le mystère central, établir le phare.
```

#strong[Champs optionnels :]

- `[Ambiance]` --- Ton prévu ou réel pour la session
- `[Notes]` --- Variantes de règles, expériences ou conditions spéciales
- `[Fils]` --- Fils conducteurs actifs cette session

== 5.3 Structure de scène
<structure-de-scène>
Les scènes sont l'unité de base du jeu au sein d'une session. Au plus simple, une scène n'est qu'un marqueur numéroté avec un contexte.

#strong[Format numérique (titre markdown) :]

```markdown
### S1 *Bibliothèque de l'école après les cours*
```

#strong[Format analogique :]

```
S1 *Bibliothèque de l'école après les cours*
```

Le numéro de scène vous aide à suivre la progression et à référencer les événements plus tard. Le contexte (en italique/astérisques) encadre où et quand la scène se déroule.

=== 5.3.1 Scènes séquentielles (Standard)
<scènes-séquentielles-standard>
La plupart des campagnes utilisent une numérotation séquentielle simple :

```
S1 *Taverne, soir*
S2 *Place de la ville, minuit*
S3 *Sentier forestier, aube*
S4 *Ruines anciennes, midi*
```

#strong[Quand utiliser :] Par défaut pour un jeu linéaire. La scène 2 se passe après la scène 1, la scène 3 après la scène 2, etc.

#strong[Numérotation :] Commencez à S1 à chaque session, ou continuez sur toute la campagne (S1-S100+).

#strong[Exemple en jeu :]

```
S1 *Salle commune de la taverne, soir*
@ Demander au tavernier les rumeurs
d: Charisme d6=5 vs ND 4 -> Succès
=> Il se penche et me parle de lumières étranges à l'ancien moulin.
[Fil:Lumières Étranges|Ouvert]

S2 *Devant la taverne, nuit*
@ Se diriger vers le moulin
? Est-ce que je rencontre quelque chose en chemin ?
-> Oui, mais... (d6=3)
=> Je vois une silhouette sombre, mais elle ne semble pas hostile.
```

=== 5.3.2 Flashbacks
<flashbacks>
Les flashbacks montrent des événements passés qui éclairent l'histoire actuelle. Utilisez des suffixes alphabétiques partant de la scène "présente".

#strong[Format :] `S#a`, `S#b`, `S#c`

#strong[Quand utiliser :]

- Révéler une histoire de fond en milieu de session
- Déclencheurs de mémoire du personnage
- Montrer comment quelque chose s'est passé
- Expliquer des éléments mystérieux

#strong[Exemple de structure :]

```
S5 *Enquête au moulin*
=> Je trouve le vieux journal de mon père.

S5a *Flashback : Atelier du père, il y a 10 ans*
(Ceci s'est passé avant la campagne)
=> Père : "Promets-moi que tu n'iras jamais seul au moulin."

S6 *Retour au moulin, présent*
(Maintenant on continue à partir de S5)
```

#strong[Exemple complet :]

```
S8 *Quartiers du gardien de phare*
@ Fouiller le bureau pour des indices
d: Investigation d6=6 vs ND 4 -> Succès
=> Je trouve une photo délavée. C'est... ma mère ? Elle se tient devant ce phare !
[Fil:Lien Maternel|Ouvert]

S8a *Flashback : Maison, il y a 15 ans*
(Souvenir déclenché par la photo)
(Est-ce que je me souviens de quelque chose à propos de cet endroit ?)
? Mère a-t-elle déjà mentionné un phare ?
-> Oui, mais... (d6=5)
=> Elle l'a mentionné une fois, brièvement, puis a rapidement changé de sujet.

PJ (Moi, jeune) : "Maman, où est-ce ?"
N (Mère) : [nerveuse] "Juste un vieil endroit. Rien d'important."

S8b *Flashback : Bureau de mère, il y a 14 ans*
(Suivant le fil de la mémoire)
(Ai-je déjà vu des documents sur le phare ?)
? Est-ce que je fouinais dans ses papiers ?
-> Oui, et... (d6=6)
=> J'ai trouvé un acte de propriété. Le phare appartenait à notre famille !
[E:SecretPhare 1/4]

S9 *Quartiers du gardien de phare, présent*
(Retour à la chronologie actuelle)
=> Armé de ce souvenir, je cherche plus attentivement des registres familiaux.
```

#strong[Conseils de numérotation :]

- Partez de la scène qui déclenche le flashback
- Revenez à la numérotation séquentielle après
- Gardez les flashbacks courts (1-3 scènes généralement)
- Notez dans le contexte en revenant : `*Présent*` ou `*Retour à...*`

=== 5.3.3 Fils narratifs parallèles
<fils-narratifs-parallèles>
Lorsque vous suivez plusieurs scénarios qui se déroulent simultanément ou en alternance, utilisez des préfixes de fil.

#strong[Format :] `T#-S#` où T\# est le numéro du fil, S\# est le numéro de la scène dans ce fil.

#strong[Quand utiliser :]

- Plusieurs personnages/points de vue
- Événements simultanés dans différents lieux
- Alternance entre les lignes de l'intrigue
- Arcs narratifs distincts mais liés

#strong[Exemple de structure :]

```
T1-S1 *Personnage principal au phare*
T2-S1 *Pendant ce temps, un allié en ville*
T1-S2 *Retour au phare*
T2-S2 *Retour en ville*
T1-S3 *Phare, suite*
```

#strong[Exemple complet :]

```
=== Session 3 ===
[Fils] Histoire principale (T1), Enquête en ville (T2)

T1-S1 *Tour du phare, crépuscule*
[PJ:Alex|enquête sur la tour]
@ Grimper au sommet
d: Athlétisme d6=4 vs ND 4 -> Succès
=> J'atteins le sommet. Le mécanisme de la lumière est toujours fonctionnel !

? Y a-t-il quelqu'un d'autre ici ?
-> Non, mais... (d6=3)
=> Des empreintes fraîches dans la poussière descendent.

T2-S1 *Archives de la ville, même heure*
[PJ:Jordan|recherche à la bibliothèque]
@ Chercher des registres sur le phare
d: Recherche d6=6 vs ND 4 -> Succès
=> Je trouve des documents de construction de 1923. Il y a un sous-sol caché !
[E:Sous-solSecret 1/4]

T1-S2 *Escaliers du sous-sol du phare*
[PJ:Alex]
@ Suivre les empreintes en bas
d: Discrétion d6=3 vs ND 5 -> Échec
=> Une marche grince bruyamment.

? Quelqu'un réagit-il ?
-> Oui, et... (d6=6)
=> Une voix d'en bas : "Qui est là ?" [N:Cultiste|hostile|armé]

T2-S2 *Archives de la ville, quelques instants plus tard*
[PJ:Jordan]
@ Appeler Alex pour le prévenir du sous-sol
? L'appel passe-t-il ?
-> Non, et... (d6=2)
=> Pas de signal. Le phare est dans une zone morte !
[Horloge:Alex en Danger 2/6]

T1-S3 *Sous-sol du phare*
[PJ:Alex|ignorant le danger]
@ Essayer de négocier
d: Tromperie d6=2 vs ND 5 -> Échec
=> Le cultiste ne me croit pas. Il avance avec un couteau !
```

#strong[Quand les fils convergent :]

Une fois que les fils parallèles se rejoignent, vous pouvez soit :

- Continuer avec les préfixes de fil : `T1+T2-S5`
- Revenir au séquentiel : `S14` (note : fils fusionnés)

```
T1-S6 *Alex s'échappe du phare*
T2-S4 *Jordan conduit vers le phare*

S14 *Entrée du phare, tous deux réunis*
(Fils fusionnés)
[PJ:Alex|blessé] rencontre [PJ:Jordan|inquiet]
```

=== 5.3.4 Montages et ellipses temporelles
<montages-et-ellipses-temporelles>
Pour les activités qui s'étendent dans le temps ou plusieurs vignettes rapides, utilisez la notation décimale.

#strong[Format :] `S#.#` (par ex., `S5.1`, `S5.2`, `S5.3`)

#strong[Quand utiliser :]

- Voyager sur de longues distances
- Entraînement/recherche sur plusieurs semaines
- Rencontres rapides multiples
- Collecte de ressources
- Séquences en accéléré

#strong[Exemple de structure :]

```
S7 *Début du voyage*
S7.1 *Jour 1 : Forêt*
S7.2 *Jour 3 : Montagnes*
S7.3 *Jour 5 : Désert*
S8 *Arrivée à destination*
```

#strong[Exemple complet :]

```
S12 *Préparation pour le rituel*
=> Je dois rassembler trois composants à travers la région.
[Piste:ComposantsRituels 0/3]

S12.1 *Herboristerie, matin*
@ Acheter des herbes sacrées
d: Persuasion d6=5 vs ND 4 -> Succès
=> L'herboriste me fait une réduction.
[Piste:ComposantsRituels 1/3]
[PJ:Or-5]

S12.2 *Forgeron, après-midi*
@ Obtenir une dague en argent
? Est-elle en stock ?
-> Non, mais... (d6=4)
=> Il peut en fabriquer une pour demain.
[Compteur:ÉchéanceRituel 2]

S12.3 *Cimetière, minuit*
@ Collecter de la terre de cimetière
? Suis-je interrompu ?
-> Oui, et... (d6=6)
=> Le gardien me surprend ET appelle la garde !
[Horloge:Méfiance 3/6]

@ Courir et se cacher
d: Discrétion d6=6 vs ND 5 -> Succès
=> Je m'échappe avec la terre.
[Piste:ComposantsRituels 2/3]

S13 *Forge du forgeron, le lendemain matin*
(Montage terminé, retour au séquentiel)
=> Je récupère la dague en argent.
[Piste:ComposantsRituels 3/3]
```

#strong[Exemple de montage de voyage :]

```
S8 *Départ de Port Cendres*
=> Le voyage de trois semaines vers les Terres du Nord commence.

S8.1 *Semaine 1 : Route côtière*
? Rencontres sur la route ?
tbl: d100=23 -> "Caravane de marchands"
=> Je me joins à une caravane pour plus de sécurité. [N:Marchands|amicaux]

S8.2 *Semaine 2 : Col de montagne*
? Problèmes météorologiques ?
-> Oui, et... (d6=6)
=> Un blizzard frappe. Le col est bloqué !
[Horloge:ProvisionsDiminuent 2/4]

@ Trouver un abri
d: Survie d6=5 vs ND 5 -> Succès
=> Je trouve une grotte. [L:GrotteMontagne|abri|sombre]

S8.3 *Semaine 3 : Descente vers les terres désolées*
@ Naviguer sur le terrain gelé
d: Survie d6=4 vs ND 6 -> Échec
=> Je suis perdu pendant deux jours.
[Horloge:ProvisionsDiminuent 4/4]
[PJ:Rations épuisées]

S9 *Arrivée dans les Terres du Nord*
(Voyage terminé)
=> Épuisé et affamé, but j'y suis arrivé.
```

=== 5.3.5 Choisir votre approche
<choisir-votre-approche>
#strong[Utilisez le séquentiel (S1, S2, S3) quand :]

- Vous jouez une histoire linéaire et simple
- Vous n'avez pas besoin de manipulation temporelle complexe
- Vous voulez de la simplicité
- Le choix le plus courant

#strong[Utilisez les flashbacks (S5a, S5b) quand :]

- Vous révélez une histoire de fond en cours de jeu
- Moments de développement de personnage
- Vous expliquez des mystères
- Courtes diversions de la chronologie principale

#strong[Utilisez les fils parallèles (T1-S1, T2-S1) quand :]

- Vous jouez plusieurs personnages
- Vous suivez des événements simultanés
- Vous alternez entre les lieux
- Intrigues complexes et entrelacées

#strong[Utilisez les montages (S7.1, S7.2) quand :]

- Vous couvrez de longues périodes de temps
- Séries de scènes rapides
- Séquences de voyage
- Collecte de ressources
- Périodes d'entraînement/recherche

=== 5.3.6 Éléments de contexte de scène
<éléments-de-contexte-de-scène>
Au-delà de la numérotation, enrichissez les scènes avec du contexte dans le cadre :

#strong[Lieu :]

```
S1 *Tour du phare*
S1 [L:Phare] *Salle de la tour*
```

#strong[Marqueurs temporels :]

```
S1 *Phare, minuit*
S1 *Phare, Jour 3, crépuscule*
S1 *Deux semaines plus tard : Phare*
```

#strong[Ton émotionnel :]

```
S1 *Phare (tendu)*
S1 *Phare - moment de calme*
```

#strong[Éléments multiples :]

```
S1 *Tour du phare, minuit, Jour 3*
S5a *Flashback : Atelier du père, il y a 10 ans*
T2-S3 *Pendant ce temps en ville, même soirée*
S7.2 *Jour 2 du voyage : Col de montagne*
```

#strong[Minimal (juste le numéro) :]

```
S1
(Ajoutez le contexte dans la première action ou conséquence)
```

Choisissez le niveau de détail qui vous aide à suivre votre histoire. Plus de détails aident à la référence future ; moins de détails gardent les notes plus propres.

= 6. Exemples complets
<exemples-complets>
La théorie est une chose, mais voir la notation en action est ce qui la fait comprendre. Cette section montre des exemples de jeu complets dans différents styles --- du raccourci ultra-compact aux journaux narratifs riches --- afin que vous puissiez trouver l'approche qui vous convient.

Chaque exemple démontre le même système de notation, juste avec différents niveaux de détail. Choisissez le style qui correspond à vos préférences, ou mélangez et associez selon les besoins de votre session.

== 6.1 Journal minimaliste en raccourci
<journal-minimaliste-en-raccourci>
Raccourci pur, sans formatage --- parfait pour un jeu rapide :

```
S1 @SeFaufiler d:4≥5 F => bruit [E:Alerte 1/6] ?Vu? ->Nn3 => distrait
S2 @Fouiller d:6≥4 S => trouve clé [E:Indice 1/4] ?Piégé? ->Oi6 => oui, piques !
S3 @Esquiver d:3≤5 F => PV-2 [PJ:PV 6] => saigne, besoin de reculer
```

== 6.2 Format numérique hybride
<format-numérique-hybride>
Combine le raccourci avec la narration, en utilisant la structure markdown :

````markdown
### S7 *Ruelle sombre derrière la taverne, Minuit*

```
@ Se faufiler devant les gardes
d: Discrétion d6=2 vs ND 4 -> Échec
=> Mon pied heurte un tonneau. [E:HorlogeAlerte 2/6]

? Me voient-ils ?
-> Non, mais... (d6=3)
=> Distraits, mais un garde s'attarde. [N:Garde|vigilant]
```

La lumière de la torche du garde balaie les murs de la ruelle. Je me plaque
dans l'ombre, retenant à peine ma respiration.

```
N (Garde) : "Qui est là ?"
PJ : "Reste calme... reste juste calme."
```
````

== 6.3 Format carnet analogique
<format-carnet-analogique>
Même contenu que 6.2, formaté pour des notes manuscrites :

```
S7 *Ruelle sombre derrière la taverne, Minuit*

@ Se faufiler devant les gardes
d: Discrétion d6=2 vs ND 4 -> Échec
=> Mon pied heurte un tonneau. [E:HorlogeAlerte 2/6]

? Me voient-ils ?
-> Non, mais... (d6=3)
=> Distraits, mais un garde s'attarde. [N:Garde|vigilant]

La lumière de la torche du garde balaie la ruelle. Je me plaque dans l'ombre.

N (Garde) : "Qui est là ?"
PJ : "Reste calme... reste juste calme."
```

== 6.4 Journal de campagne complet (Numérique)
<journal-de-campagne-complet-numérique>
````markdown
---
title: Mystère de Clearview
ruleset: Loner + Oracle Mythic
genre: Mystère adolescent / surnaturel
player: Roberto
pcs: Alex [PJ:Alex|PV 8|Stress 0]
start_date: 2025-09-03
last_update: 2025-10-28
---

# Mystère de Clearview

## Session 1
*Date : 2025-09-03 | Durée : 1h30*

### S1 *Bibliothèque de l'école après les cours*

```
@ Se faufiler à l'intérieur pour vérifier les archives
d: Discrétion d6=5 vs ND 4 -> Succès
=> Je me glisse à l'intérieur sans être remarqué. [L:Bibliothèque|sombre|calme]

? Y a-t-il un indice étrange qui attend ?
-> Oui (d6=6)
=> Je trouve une page de journal déchirée sur le phare. [E:IndicePhare 1/6]
```

La page est jaunie par le temps. L'écriture est tremblante : "La lumière
nous appelle. Nous ne devons pas répondre."

```
[Fil:Mystère du Phare|Ouvert]
```

### S2 *Devant la bibliothèque, couloir vide*

```
? Est-ce que j'entends des pas ?
-> Oui, mais... (d6=4)
=> Un concierge s'approche, mais il ne me remarque pas encore. [N:Concierge|fatigué|méfiant]
```

Je me fige. Ses clés tintent alors qu'il passe devant la porte.

N (Concierge) : "J'ai cru entendre quelque chose..."
PJ (Alex, chuchotant) : "Il faut que je sorte d'ici."

```
@ Sortir en douce pendant qu'il est distrait
d: Discrétion d6=6 vs ND 4 -> Succès
=> Je m'échappe dans la nuit en toute sécurité.
```

## Session 2
*Date : 2025-09-10 | Durée : 2h*

**Résumé :** Trouvé une page de journal faisant allusion au phare. Presque repéré dans la bibliothèque.

### S3 *Chemin vers le vieux phare, Jour 2*

```
@ Approcher silencieusement au crépuscule
d: Discrétion d6=2 vs ND 4 -> Échec
=> Je marche sur du verre brisé, ça craque bruyamment. [Horloge:Méfiance 1/6]

? Quelqu'un répond-il de l'intérieur ?
-> Non, mais... (d6=3)
=> La lumière vacille brièvement dans la fenêtre de la tour. [L:Phare|en ruine|hanté]
```

### S4 *Hall d'entrée du phare*

```
@ Chercher des signes d'activité sur le sol
d: Investigation d6=6 vs ND 4 -> Succès
=> Je trouve des empreintes fraîches dans la poussière. [Fil:Qui utilise le phare ?|Ouvert]

tbl: d100=42 -> "Une lanterne cassée"
=> Une lanterne fissurée gît près des escaliers. [E:IndicePhare 2/6]
```

Quelqu'un est venu ici. Récemment.

PJ (Alex, pensant) : "Cet endroit n'est pas aussi abandonné que tout le monde le pense..."
````

== 6.5 Journal de campagne complet (Analogique)
<journal-de-campagne-complet-analogique>
```
=== Journal de campagne : Mystère de Clearview ===
[Titre] Mystère de Clearview
[Règles] Loner + Oracle Mythic
[Genre] Mystère adolescent / surnaturel
[Joueur] Roberto
[PJs] Alex [PJ:Alex|PV 8|Stress 0]
[Date de début] 2025-09-03
[Dernière mise à jour] 2025-10-28

=== Session 1 ===
[Date] 2025-09-03
[Durée] 1h30

S1 *Bibliothèque de l'école après les cours*

@ Se faufiler à l'intérieur pour vérifier les archives
d: Discrétion d6=5 vs ND 4 -> Succès
=> Je me glisse à l'intérieur sans être remarqué. [L:Bibliothèque|sombre|calme]

? Y a-t-il un indice étrange qui attend ?
-> Oui (d6=6)
=> Je trouve une page de journal déchirée sur le phare. [E:IndicePhare 1/6]

La page est jaunie. Écriture tremblante : "La lumière nous appelle."

[Fil:Mystère du Phare|Ouvert]

S2 *Devant la bibliothèque, couloir vide*

? Est-ce que j'entends des pas ?
-> Oui, mais... (d6=4)
=> Un concierge s'approche, mais ne me remarque pas encore. [N:Concierge|fatigué|méfiant]

N (Concierge) : "J'ai cru entendre quelque chose..."
PJ (Alex) : "Il faut que je sorte d'ici."

@ Sortir en douce pendant qu'il est distrait
d: Discrétion d6=6 vs ND 4 -> Succès
=> Je m'échappe dans la nuit en toute sécurité.

=== Session 2 ===
[Date] 2025-09-10
[Durée] 2h
[Résumé] Trouvé une page de journal, presque repéré dans la bibliothèque.

S3 *Chemin vers le phare, Jour 2*

@ Approcher silencieusement au crépuscule
d: Discrétion d6=2 vs ND 4 -> Échec
=> Je marche sur du verre brisé. [Horloge:Méfiance 1/6]

? Quelqu'un répond-il ?
-> Non, mais... (d6=3)
=> La lumière vacille dans la fenêtre de la tour. [L:Phare|en ruine|hanté]

S4 *Hall d'entrée du phare*

@ Chercher des signes sur le sol
d: Investigation d6=6 vs ND 4 -> Succès
=> Empreintes fraîches dans la poussière. [Fil:Qui utilise le phare ?|Ouvert]

tbl: d100=42 -> "Une lanterne cassée"
=> Lanterne fissurée près des escaliers. [E:IndicePhare 2/6]

PJ (Alex) : "Cet endroit n'est pas aussi abandonné que tout le monde le pense..."
```

= 7. Bonnes pratiques
<bonnes-pratiques>
Vous avez appris la notation --- parlons maintenant de son utilisation efficace. Cette section présente des modèles éprouvés qui rendent vos journaux plus clairs et plus utiles, ainsi que des erreurs courantes à éviter.

Considérez-les comme des lignes directrices issues de l'expérience collective de la communauté solo. Ce ne sont pas des règles rigides, mais elles vous aideront à créer des journaux faciles à lire, à référencer et à partager.

== 7.1 Bonnes pratiques ✓
<bonnes-pratiques-1>
Ces modèles rendent vos journaux plus propres, plus faciles à rechercher et à référencer plus tard. Vous n'avez pas besoin de tous les suivre, mais ils représentent ce qui fonctionne bien pour la plupart des joueurs solo.

#strong[À faire : Garder les actions et les jets connectés]

```
@ Crocheter la serrure
d: d20=15 vs DC 14 -> Succès
=> La porte s'ouvre silencieusement.
```

#strong[À faire : Utiliser des balises pour les éléments persistants]

```
[N:Jonah|amical|blessé]
[L:Phare|en ruine]
```

#strong[À faire : Enregistrer clairement les conséquences]

```
=> Je trouve la clé. [E:Indice 2/4]
=> Mais le garde m'a entendu. [Horloge:Alerte 1/6]
```

#strong[À faire : Utiliser des balises de référence dans les scènes ultérieures]

```
Première mention : [N:Jonah|amical]
Plus tard : [#N:Jonah] s'approche prudemment
```

#strong[À faire : Mélanger raccourci et narration au besoin]

```
@ Se faufiler devant le garde
d: 5≥4 S -> Succès
=> Je passe inaperçu, le cœur battant.
```

== 7.2 Mauvaises pratiques ✗
<mauvaises-pratiques>
Ce sont des pièmes courants qui rendent les journaux plus difficiles à lire ou à analyser. Si vous vous surprenez à faire cela, ne vous inquiétez pas --- ajustez simplement pour la prochaine fois. Nous sommes tous passés par là !

#strong[À ne pas faire : Enfouir la mécanique dans la prose]

```
❌ J'ai essayé de crocheter la serrure et j'ai fait un 15 qui a battu le DC donc je l'ai ouverte

✔️ @ Crocheter la serrure
  d: 15≥14 -> Succès
  => La porte s'ouvre silencieusement.
```

#strong[À ne pas faire : Oublier d'enregistrer les conséquences]

```
❌ @ Attaquer le garde
  d: 8≤10 -> Échec

✔️ @ Attaquer le garde
  d: 8≤10 -> Échec
  => Ma lame ricoche sur son armure. Il contre-attaque !
```

#strong[À ne pas faire : Perdre le fil des balises entre les scènes]

```
❌ [N:Garde|alerte] ... puis plus tard ... [N:Garde|endormi]
   (Comment cela a-t-il changé ? Quand ?)

✔️ [N:Garde|alerte] ... puis plus tard ...
  @ L'assommer
  d: 6≥5 S => [N:Garde|inconscient]
```

#strong[À ne pas faire : Mélanger les symboles d'action et d'oracle]

```
❌ ? Se faufiler devant les gardes (C'est une action, pas une question)

✔️ @ Se faufiler devant les gardes (Les actions utilisent @)
  ? Me remarquent-ils ? (Les questions utilisent ?)
```

#strong[À ne pas faire : Oublier le contexte de la scène]

```
❌ S7
  @ Se faufiler devant les gardes
  
✔️ S7 *Ruelle sombre, minuit*
  @ Se faufiler devant les gardes
```

= 8. Modèles
<modèles>
Partir d'une page blanche peut être intimidant. Ces modèles vous donnent un point de départ structuré --- copiez-les, remplissez les blancs et commencez à jouer.

Chaque modèle est disponible en formats #strong[markdown numérique] et #strong[carnet analogique];. Choisissez celui qui correspond à votre style de jeu, ou utilisez-les comme inspiration pour créer vos propres modèles.

Ne les traitez pas comme des formulaires rigides. Ce sont des échafaudages. Une fois que vous serez à l'aise avec la notation, vous développerez probablement vos propres modèles qui répondront mieux à vos besoins spécifiques.

== 8.1 Modèle de campagne (YAML numérique)
<modèle-de-campagne-yaml-numérique>
Pour les fichiers markdown numériques, utilisez le YAML front matter pour stocker les métadonnées de la campagne. Cela va tout en haut de votre fichier, avant tout autre contenu.

Copiez ce modèle, remplissez vos détails, et vous êtes prêt à commencer votre première session.

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
# [Titre de la campagne]

## Session 1
*Date : | Durée : *

### S1 *Scène de départ*

Votre journal de jeu ici...
```

== 8.2 Modèle de campagne (Analogique)
<modèle-de-campagne-analogique>
Pour les carnets papier, écrivez ce bloc d'en-tête au début de votre journal de campagne. Restez simple --- vous pouvez toujours ajouter plus de détails plus tard si nécessaire.

```
=== Journal de campagne : [Titre] ===
[Titre] 
[Règles] 
[Genre] 
[Joueur] 
[PJs] 
[Date de début] 
[Dernière mise à jour] 
[Outils] 
[Thèmes] 
[Ton] 
[Notes] 

=== Session 1 ===
[Date] 
[Durée] 

S1 *Scène de départ*

Votre journal de jeu ici...
```

== 8.3 Modèle de session
<modèle-de-session>
Utilisez ceci au début de chaque session de jeu pour marquer les limites et fournir un contexte. La version numérique utilise des titres markdown ; la version analogique utilise des en-têtes écrits.

Remplissez ce qui est utile et sautez ce qui ne l'est pas. Le seul champ essentiel est la date --- tout le reste est facultatif.

#strong[Numérique :]

```markdown
## Session X
*Date : | Durée : | Scènes : *

**Résumé :** 

**Objectifs :** 

### S1 *Description de la scène*
```

#strong[Analogique :]

```
=== Session X ===
[Date] 
[Durée] 
[Résumé] 
[Objectifs] 

S1 *Description de la scène*
```

== 8.4 Modèle de scène rapide
<modèle-de-scène-rapide>
C'est votre modèle de travail --- la structure de base que vous utiliserez scène après scène. Il est intentionnellement minimal : juste assez de structure pour vous garder orienté sans vous ralentir.

Utilisez-le comme point de départ par défaut pour chaque scène, que vous jouiez en numérique ou en analogique.

````markdown
S# *Lieu, heure*
```
@ Votre action
d: votre jet -> résultat
=> Ce qui se passe

? Votre question
-> Réponse de l'oracle
=> Ce que cela signifie
```
````

= 9. Adaptation à votre système
<adaptation-à-votre-système>
Voici la belle partie : cette notation fonctionne avec #emph[n'importe quel] système de JDR solo. #emph[Ironsworn];, #emph[Mythic GME];, #emph[Thousand Year Old Vampire];, votre propre système maison --- peu importe. Les symboles de base restent les mêmes ; seuls les détails de la résolution changent.

Cette section vous montre comment adapter la notation de jet `d:` et les formats d'oracle `->` pour correspondre à votre système de jeu spécifique. Nous couvrirons les systèmes courants (PbtA, FitD, Ironsworn, OSR) et les oracles (Mythic, CRGE, MUNE), mais les principes fonctionnent pour n'importe quoi.

#strong[L'idée clé :] La notation sépare la #emph[mécanique] de la #emph[fiction];. Votre système détermine comment la mécanique fonctionne ; la notation ne fait que les enregistrer de manière cohérente.

== 9.1 Notation de jet spécifique au système
<notation-de-jet-spécifique-au-système>
La notation `d:` fonctionne avec n'importe quel système --- vous avez juste besoin de l'adapter à vos mécaniques de dés spécifiques. Voici à quoi ressemble la notation pour les systèmes de JDR solo populaires.

Ces exemples montrent le modèle : enregistrez ce que vous avez lancé, comparez-le à ce dont vous aviez besoin, notez le résultat. Les détails changent selon le système, mais la structure reste la même.

=== 9.1.1 Powered by the Apocalypse (PbtA)
<powered-by-the-apocalypse-pbta>
```
d: 2d6=9 -> Succès complet (10+)
d: 2d6=7 -> Succès partiel (7-9)
d: 2d6=4 -> Échec (6-)
```

=== 9.1.2 Forged in the Dark (FitD)
<forged-in-the-dark-fitd>
```
d: 4d6=6,5,4,2 (prendre le plus haut=6) -> Succès critique
d: 3d6=4,4,2 -> Succès partiel (4-5)
d: 2d6=3,2 -> Échec (1-3)
```

=== 9.1.3 Ironsworn
<ironsworn>
```
d: Action=7+Stat=2=9 vs Défi=4,8 -> Succès faible
d: Action=10+Stat=3=13 vs Défi=2,7 -> Succès fort
```

=== 9.1.4 Fate/Fudge
<fatefudge>
```
d: 4dF=+2 (++0-) +Compétence=3 = +5 -> Succès avec style
d: 4dF=-1 (-0--) +Compétence=2 = +1 -> Égalité
```

=== 9.1.5 OSR/D&D traditionnel
<osrdd-traditionnel>
```
d: d20=15+Mod=2=17 vs CA 16 -> Touche
d: d20=8+Mod=-1=7 vs DC 10 -> Échec
```

== 9.2 Adaptations de l'oracle
<adaptations-de-loracle>
Différents systèmes d'oracle ont différents formats de sortie. Certains donnent des réponses oui/non, d'autres génèrent des résultats complexes. Voici comment enregistrer les résultats des systèmes d'oracle populaires.

La clé est la cohérence : utilisez toujours `->` pour les résultats de l'oracle, puis capturez toutes les informations que votre oracle fournit.

=== 9.2.1 Mythic GME
<mythic-gme>
```
? Le garde me remarque-t-il ? (Probabilité : Improbable)
-> Non, mais... (FC=4)
=> Il ne me voit pas, mais il est méfiant.
```

=== 9.2.2 CRGE (Conjectural Roleplaying Game Engine)
<crge-conjectural-roleplaying-game-engine>
```
? Quelle est l'humeur du marchand ?
-> Afflux : Acteur + Foyer => En colère + Trahison
=> Le marchand est furieux d'avoir été trompé.
```

=== 9.2.3 MUNE (Madey Upy Number Engine)
<mune-madey-upy-number-engine>
```
? Y a-t-il quelqu'un à la maison ?
-> Probable + jet 2,4 => Oui
=> Les lumières sont allumées, quelqu'un est certainement à l'intérieur.
```

=== 9.2.4 UNE (Universal NPC Emulator)
<une-universal-npc-emulator>
```
gen: Motivation UNE -> Pouvoir + Réputation
=> [N:Baron|ambitieux|cherche la reconnaissance]
```

== 9.3 Gestion des cas particuliers
<gestion-des-cas-particuliers>
Chaque système a ses bizarreries. Voici comment gérer les situations courantes qui ne correspondent pas aux modèles de notation de base.

=== 9.3.1 Jets multiples en une seule action
<jets-multiples-en-une-seule-action>
Lorsque vous devez faire plusieurs jets pour une seule action :

#strong[Avantage/Désavantage :]

```
@ Attaquer avec avantage
d: 2d20=15,8 (prendre le plus haut) vs ND 12 -> 15≥12 Succès
=> Je frappe juste, la lame trouvant une faille dans l'armure.
```

#strong[Plusieurs pools de dés :]

```
@ Effectuer un rituel complexe
d: INT d6=4, VOL d6=5, vs ND 4 chacun -> Les deux réussissent
=> Le sort prend effet, l'énergie crépitant entre mes doigts.
```

#strong[Jets opposés :]

```
@ Bras de fer avec le marin
d: FOR d20=12 vs marin d20=15 -> 12≤15 Échec
=> Sa poigne se resserre. Mon bras claque sur la table.
```

=== 9.3.2 Résultats d'oracle ambigus
<résultats-doracle-ambigus>
Lorsque l'oracle donne des résultats flous ou contradictoires :

```
? Le marchand est-il digne de confiance ?
-> Oui, mais... (d6=4)
(note : "mais" contredit "oui" — interprétation : digne de confiance mais cache quelque chose)
=> Il semble honnête, mais jette des regards nerveux vers la porte.
```

Ou relancez si vous êtes vraiment bloqué :

```
? Puis-je lui faire confiance ?
-> Résultat incertain (d6=3 sur oracle binaire)
(note : je pose une question plus spécifique)
? Essaie-t-il de m'aider ?
-> Non, et... (d6=2)
=> Il travaille activement contre moi.
```

=== 9.3.3 Conséquences imbriquées
<conséquences-imbriquées>
Parfois, une conséquence en entraîne une autre, créant une cascade :

```
d: Crochetage 5≥4 -> Succès
=> La porte s'ouvre
=> Mais les gonds grincent bruyamment
=> Les gardes dans la pièce voisine l'entendent [E:HorlogeAlerte 1/6]
=> L'un d'eux commence à marcher dans cette direction [N:Garde|enquête]
```

#strong[Quand utiliser :] Succès ou échecs majeurs avec de multiples effets d'entraînement. N'en abusez pas --- la plupart des actions ont une conséquence claire.

=== 9.3.4 Questions à l'oracle qui échouent
<questions-à-loracle-qui-échouent>
Et si l'oracle n'aide pas ?

```
? Qu'y a-t-il derrière la porte ?
-> [Résultat de jet flou/contradictoire]
(note : je pose une question plus spécifique)
? Y a-t-il un danger derrière la porte ?
-> Oui, et...
=> Danger, et c'est immédiat !
```

#strong[Conseil de pro :] Si un résultat d'oracle ne suscite pas de fiction, il est acceptable de reformuler la question ou de relancer. L'oracle sert votre histoire, pas l'inverse.

= Annexes
<annexes>
== A. Légende de la notation de JDR Solo
<a.-légende-de-la-notation-de-jdr-solo>
Ceci est votre référence rapide --- l'aide-mémoire à garder à portée de main pendant que vous jouez. Vous avez oublié ce que signifie `=>` ? Besoin de vous rappeler comment formater une horloge ? Cette section est là pour vous.

Pensez-y comme la "liste de vocabulaire" de la notation. Tout ce qui est ici a été expliqué en détail plus tôt ; c'est juste la version condensée pour une recherche rapide.

Mettez cette section en favori. Vous y reviendrez souvent lors de vos premières sessions, puis de moins en moins à mesure que la notation deviendra une seconde nature.

=== A.1 Symboles de base
<a.1-symboles-de-base>
#table(
  columns: (33.33%, 33.33%, 33.33%),
  align: (auto,auto,auto,),
  table.header([Symbole], [Signification], [Exemple],),
  table.hline(),
  [`@`], [Action du joueur (mécanique)], [`@ Crocheter la serrure`],
  [`?`], [Question à l'oracle (monde/incertitude)], [`? Y a-t-il quelqu'un à l'intérieur ?`],
  [`d:`], [Jet de mécanique/résultat], [`d: 2d6=8 vs ND 7 -> Succès`],
  [`->`], [Résultat de l'oracle/des dés], [`-> Oui, mais...`],
  [`=>`], [Conséquence/résultat], [`=> La porte s'ouvre silencieusement`],
)
=== A.2 Opérateurs de comparaison
<a.2-opérateurs-de-comparaison>
- `≥` ou `>=` --- Supérieur ou égal (atteint/bat le ND)
- `≤` ou `<=` --- Inférieur ou égal (n'atteint pas le ND)
- `vs` --- Contre (comparaison explicite)
- `S` --- Indicateur de succès
- `F` --- Indicateur d'échec

=== A.3 Balises de suivi
<a.3-balises-de-suivi>
- `[N:Nom|balises]` --- PNJ (première mention)
- `[#N:Nom]` --- PNJ (référence à une mention antérieure)
- `[L:Nom|balises]` --- Lieu
- `[E:Nom X/Y]` --- Événement/Horloge
- `[Fil:Nom|état]` --- Fil conducteur de l'histoire
- `[PJ:Nom|stats]` --- Personnage joueur

=== A.4 Suivi de la progression
<a.4-suivi-de-la-progression>
- `[Horloge:Nom X/Y]` --- Horloge (se remplit)
- `[Piste:Nom X/Y]` --- Piste de progression
- `[Compteur:Nom X]` --- Compte à rebours

=== A.5 Génération aléatoire
<a.5-génération-aléatoire>
- `tbl: jet -> résultat` --- Consultation simple de table
- `gen: système -> résultat` --- Générateur complexe

=== A.6 Structure
<a.6-structure>
- `S#` ou `S#a` --- Numéro de scène
- `T#-S#` --- Scène spécifique à un fil

=== A.7 Narration (Optionnel)
<a.7-narration-optionnel>
- En ligne : `=> Prose ici`
- Dialogue : `N (Nom) : "Discours"`
- Bloc : `--- texte ---`

=== A.8 Méta
<a.8-méta>
- `(note : ...)` --- Réflexion, rappel, règle maison

=== A.9 Exemple de ligne complète
<a.9-exemple-de-ligne-complète>
```
S3 @Crocheter serrure d:15≥14 S => porte s'ouvre silencieusement [N:Garde|alerte]
```

= B. FAQ
<b.-faq>
Vous avez des questions ? Vous n'êtes pas seul. Voici les questions les plus courantes des personnes qui apprennent la notation, avec des réponses directes.

Si votre question n'est pas ici, rappelez-vous : la notation est flexible. Si vous vous demandez si vous pouvez faire quelque chose différemment, la réponse est probablement "oui, si ça marche pour vous."

#strong[Q : Dois-je utiliser tous les éléments ?] R : Non ! Commencez avec juste `@`, `?`, `d:`, `->`, et `=>`. N'ajoutez d'autres éléments que s'ils vous aident.

#strong[Q : Puis-je utiliser ceci avec des JDR traditionnels (avec un MJ) ?] R : La notation de base fonctionne très bien pour toutes les notes de JDR. Les éléments de l'oracle (`?`, `->`) sont spécifiquement pour le jeu solo, mais la notation action/résolution fonctionne partout.

#strong[Q : Et si mon système n'utilise pas de dés ?] R : Utilisez `d:` pour toute mécanique de résolution : `d: Tirer une carte -> Dame de Pique`, `d: Dépenser un jeton -> Succès`

#strong[Q : Dois-je utiliser le format numérique ou analogique ?] R : Celui que vous préférez ! Ils utilisent la même notation. Le numérique a une meilleure recherche/organisation ; l'analogique est immédiat et tactile.

#strong[Q : À quel point mes notes doivent-elles être détaillées ?] R : Aussi détaillées que vous le souhaitez ! Le système fonctionne pour du raccourci pur (Exemple 6.1) ou une narration riche (Exemple 6.4).

#strong[Q : Puis-je partager mes journaux avec d'autres ?] R : Oui ! C'est l'une des raisons d'une notation standardisée. D'autres personnes familières avec le système peuvent lire vos journaux facilement.

#strong[Q : Qu'en est-il des règles maison ou des symboles personnalisés ?] R : Documentez-les dans des notes méta : `(note : utilisation de + pour l'avantage, - pour le désavantage)`. Le système est conçu pour être étendu.

#strong[Q : Les numéros de scène doivent-ils être séquentiels ?] R : Non. Utilisez `S1`, `S2`, `S3` pour la simplicité, mais créez des branches (`S3a`, `S3b`) ou utilisez des préfixes de fil (`T1-S1`) si cela est utile.

#strong[Q : Dois-je mettre à jour les balises à chaque changement ?] R : Montrez explicitement les changements significatifs : `[N:Garde|alerte]` → `[N:Garde|inconscient]`. Les changements mineurs peuvent être implicites par la narration.

= C. Philosophie de conception des symboles
<c.-philosophie-de-conception-des-symboles>
Les symboles de Lonelog ont été choisis pour des raisons spécifiques :

- #strong[`@` (Action)] : Représente "à ce moment" ou l'acteur qui agit. Changé de `>` dans la v2.0 pour éviter le conflit avec les citations en bloc de Markdown.

- #strong[`?` (Question)] : Symbole universel pour l'interrogation. Inchangé par rapport à la v2.0.

- #strong[`d:` (Dés/Résolution)] : Abréviation claire pour les jets de dés. Inchangé par rapport à la v2.0.

- #strong[`->` (Résolution)] : Conservé de la v2.0. Maintenant unifié pour TOUTES les résolutions (dés et oracle). La flèche montre visuellement "ceci mène au résultat".

- #strong[`=>` (Conséquence)] : Conservé de la v2.0. La double flèche montre les effets en cascade. Utilisation clarifiée : conséquences uniquement (la v2.0 surchargeait ce symbole pour les résultats de dés également).

#strong[Compatibilité Markdown] : Tous les symboles fonctionnent proprement dans les blocs de code et n'entrent pas en conflit avec le formatage markdown ou les opérateurs mathématiques. Enveloppez toujours la notation dans des blocs de code lorsque vous utilisez le markdown numérique pour éviter les conflots avec les extensions Markdown.

= Crédits & Licence
<crédits-licence>
© 2025-2026 Roberto Bisceglie

Cette notation est inspirée de la #link("https://alfredvalley.itch.io/the-valley-standard")[Valley Standard];.

#strong[Remerciements à :]

- matita pour la méthode `+`/`-` pour suivre les changements dans les balises
- flyincaveman pour la suggestion sur l'utilisation du symbole `@` pour les actions des personnages (dans la tradition des premiers JDR en ASCII)
- r/solorpgplay et r/Solo\_Roleplaying pour l'accueil positif de cette notation et les retours utiles.
- Enrico Fasoli pour les tests et les retours

#strong[Historique des versions :]

- v 1.0.0 : A évolué à partir de Solo TTRPG Notation v2.0 par Roberto Bisceglie

Ce travail est sous licence #strong[Creative Commons Attribution-ShareAlike 4.0 International];.

#strong[Vous êtes libre de :]

- Partager --- copier et redistribuer le matériel
- Adapter --- remixer, transformer et construire sur le matériel

#strong[Sous ces conditions :]

- Attribution --- Donner un crédit approprié
- Partage dans les mêmes conditions --- Distribuer les adaptations sous la même licence

#emph[Bonnes aventures, joueurs solo !]
