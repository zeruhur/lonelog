# Lonelog

**Una Notazione Standard per i Log delle Sessioni di GdR Solo**

[![Licenza: CC BY-SA 4.0](https://img.shields.io/badge/Licenza-CC%20BY--SA%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-sa/4.0/)

Lonelog è un sistema di notazione leggero per registrare le sessioni di gioco di ruolo da tavolo in solitario. Fornisce un modo standardizzato per catturare le meccaniche di gioco, le domande all'oracolo e gli esiti narrativi, mantenendo i log delle sessioni leggibili, ricercabili e condivisibili.

## Cos'è Lonelog?

Se hai giocato a GdR in solitario, conosci la sfida: sei nel bel mezzo di una scena emozionante, i dadi rotolano, gli oracoli rispondono alle domande e hai bisogno di catturare tutto senza interrompere il flusso.

Lonelog offre una **notazione abbreviata modulare** che:

- Separa le meccaniche dalla narrazione
- Funziona con qualsiasi sistema RPG (Ironsworn, Mythic GME, Thousand Year Old Vampire, ecc.)
- Si adatta sia a rapide sessioni singole che a lunghe campagne
- Funziona sia in file digitali markdown che in quaderni cartacei

### Notazione di Base (5 simboli)

```
@ Azione del giocatore
? Domanda all'oracolo
d: Lancio di dadi/meccaniche
-> Risultato/risposta
=> Conseguenza/esito
```

### Esempio Rapido

```
S1 *Vicolo buio, mezzanotte*
@ Sgattaiolare oltre la guardia
d: Stealth 4 vs TN 5 -> Fallimento
=> La guardia mi avvista e grida l'allarme

? Arrivano i rinforzi? (Probabile)
-> Sì, e hanno dei cani
=> Devo correre—veloce
```

Questo è l'intero sistema centrale. Tutto il resto (scene, thread, clock di progresso, ecc.) è opzionale.

## Documentazione Disponibile

La documentazione è disponibile in diversi formati e lingue:

### Inglese (English)

- [PDF](../../output/en/lonelog.pdf) - Versione pronta per la stampa
- [EPUB](../../output/en/lonelog.epub) - Formato e-reader
- [ODT](../../output/en/lonelog.odt) - Formato LibreOffice/Word

### Italiano

- [PDF](../../output/it/lonelog-it.pdf) - Versione per la stampa
- [EPUB](../../output/it/lonelog-it.epub) - Formato e-reader
- [ODT](../../output/it/lonelog-it.odt) - Formato LibreOffice/Word

### Francese (Français)

- [PDF](../../output/fr/lonelog-fr.pdf) - Version imprimable
- [EPUB](../../output/fr/lonelog-fr.epub) - Format e-reader
- [ODT](../../output/fr/lonelog-fr.odt) - Format LibreOffice/Word

### Add-on Opzionali

Notazione estesa per esigenze di gioco specifiche:

- [Combat Add-on](../en/lonelog-combat-addon.md) - Notazione per scontri tattici (EN)
- [Dungeon Crawling Add-on](../en/lonelog-dungeon-crawling-addon.md) - Notazione per l'esplorazione (EN)
- [Resource Tracking Add-on](../en/lonelog-resource-tracking-addon.md) - Inventario e scorte (EN)
- [Add-on Guidelines](../en/lonelog-addon-guidelines.md) - Come scrivere il proprio add-on (EN)
- [Add-on Template](../en/lonelog-addon-template.md) - Modello di partenza (EN)

## Caratteristiche

- **Indipendente dal sistema** - Funziona con qualsiasi sistema RPG in solitario
- **Modulare** - Usa solo ciò di cui hai bisogno
- **Compatibile con Markdown** - Strumenti digitali e quaderni in testo semplice
- **Ricercabile** - Tag e simboli rendono facile trovare eventi passati
- **Condivisibile** - La notazione standard permette ad altri di leggere i tuoi log
- **Multilingua** - Documentazione disponibile in inglese, italiano e francese

## Generazione della Documentazione

Questo repository utilizza [Quarto](https://quarto.org/) per generare la documentazione dai file sorgente Markdown.

### Prerequisiti

Installa Quarto:

- **Windows**: `choco install quarto` (via Chocolatey)
- **macOS**: `brew install quarto`
- **Linux**: Scarica da [quarto.org](https://quarto.org/docs/get-started/)

### Comandi per la Generazione

Genera tutte le lingue:

```bash
for lang in en it fr; do
  quarto render docs/$lang/lonelog*.md --output-dir output/$lang/
done
```

Genera una lingua specifica:

```bash
quarto render docs/en/lonelog.md --output-dir output/en/      # Inglese
quarto render docs/it/lonelog-it.md --output-dir output/it/   # Italiano
quarto render docs/fr/lonelog-fr.md --output-dir output/fr/   # Francese
```

Genera in un formato specifico:

```bash
quarto render docs/en/lonelog.md --to pdf --output-dir output/en/
quarto render docs/en/lonelog.md --to epub --output-dir output/en/
```

Anteprima con ricaricamento in tempo reale:

```bash
quarto preview docs/en/lonelog.md
```

## Struttura del Progetto

```
/
├── index.html                              # Punto di ingresso Docsify
├── _quarto.yml                             # Configurazione Quarto
├── docs/                                   # File sorgente Markdown
│   ├── README.md                           # Home del sito (selettore lingua)
│   ├── en/                                 # Documentazione inglese
│   │   ├── lonelog.md                      # Specifica principale
│   │   ├── lonelog-addon-guidelines.md     # Linee guida add-on
│   │   ├── lonelog-addon-template.md       # Modello add-on
│   │   ├── lonelog-combat-addon.md         # Add-on combattimento
│   │   ├── lonelog-dungeon-crawling-addon.md # Add-on dungeon crawling
│   │   ├── lonelog-resource-tracking-addon.md # Add-on tracciamento risorse
│   │   └── _sidebar.md                     # Sidebar Docsify (EN)
│   ├── it/                                 # Traduzione italiana
│   │   ├── lonelog-it.md
│   │   └── _sidebar.md
│   └── fr/                                 # Traduzione francese
│       ├── lonelog-fr.md
│       └── _sidebar.md
├── output/                                 # Documenti generati (Quarto)
│   ├── en/                                 # Generazioni inglesi
│   ├── it/                                 # Generazioni italiane
│   └── fr/                                 # Generazioni francesi
├── _extensions/                            # Modelli e filtri personalizzati
│   ├── typst-template.typ                  # Styling Typst personalizzato
│   ├── typst-show.typ                      # Parziale del modello
│   └── pagebreak.lua                       # Filtro per l'interruzione di pagina
├── assets/                                 # Risorse condivise (immagini, font)
├── legacy/                                 # Versioni precedenti
└── .readthedocs.yaml                       # Configurazione build Read the Docs
```

## Contribuire

I contributi sono benvenuti! Ecco come puoi aiutare:

### Traduzioni

Aiuta a tradurre Lonelog in altre lingue. Usa `docs/en/lonelog.md` come sorgente e mantieni la stessa struttura del frontmatter.

### Miglioramenti

Hai trovato un errore di battitura o una spiegazione poco chiara? Apri una segnalazione (issue) o invia una richiesta di modifica (pull request).

### Estensioni Modulari

Hai creato un add-on opzionale per un tipo specifico di gioco? Condividilo con la comunità!

### Esempi

I log di sessioni reali che utilizzano Lonelog sono preziosi per dimostrare la notazione. Considera di condividere esempi anonimizzati.

## Cronologia delle Versioni

- **v1.3.0** (Attuale) - Ecosistema add-on e notazione espansa
- **v1.1.0** - Licenze e definizioni in linea
- **v1.0.0** - Rinominato da "Solo TTRPG Notation" a "Lonelog"

## Licenza

Questo lavoro è concesso in licenza sotto una [Licenza Internazionale Creative Commons Attribuzione-Condividi allo stesso modo 4.0](https://creativecommons.org/licenses/by-sa/4.0/).

Sei libero di:

- **Condividere** — riprodurre, distribuire, comunicare al pubblico, esporre in pubblico, rappresentare, eseguire e recitare questo materiale con qualsiasi mezzo e formato
- **Modificare** — remixare, trasformare il materiale e basarti su di esso per le tue opere

Alle seguenti condizioni:

- **Attribuzione** — Devi fornire il giusto riconoscimento
- **Condividi allo stesso modo** — Se remixi, trasformi il materiale o ti basi su di esso, devi distribuire i tuoi contributi con la stessa licenza dell'originale.

## Autore

**Roberto Bisceglie**

## Comunità

- Condividi i tuoi log di sessione con l'hashtag `#lonelog`
- Fai domande o suggerisci miglioramenti tramite le GitHub Issues
- Partecipa alle discussioni sulla notazione per GdR in solitario e sulle migliori pratiche

## Ringraziamenti

Grazie alla comunità dei GdR in solitario per il feedback, i suggerimenti e l'uso nel mondo reale che hanno plasmato questo sistema di notazione dalle sue origini come "Solo TTRPG Notation" a Lonelog v1.0.0.

---

*Realizzato con [Quarto](https://quarto.org/) • Stilizzato con [Typst](https://typst.app/)*
