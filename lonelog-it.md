---
title: Lonelog
subtitle: "Una notazione standard per registrare le tue sessioni di GDR solitario"
author: Roberto Bisceglie
version: 1.0.0
license: CC BY-SA 4.0
lang: it
---

## 1. Introduzione

Se hai mai giocato a un GDR in solitaria, conosci la sfida: sei nel bel mezzo di una scena emozionante, i dadi rotolano, gli oracoli rispondono alle domande e improvvisamente ti rendi conto: come faccio a catturare tutto questo senza interrompere il flusso?

Forse hai provato a tenere un diario a mano libera (ma diventa subito disordinato), la prosa pura (ma perdi le meccaniche) o gli elenchi puntati (difficili da analizzare in seguito). Questo sistema di notazione offre un approccio diverso: una **notazione abbreviata leggera** che cattura gli elementi essenziali del gioco lasciando spazio a quanta (o poca) narrazione desideri.

### 1.1 Perché "Lonelog"?

Questo sistema è nato come **Notazione per GDR Solitario**, un nome descrittivo ma ingombrante. Quasi 5.000 download dopo, era chiaro che il concetto risuonasse nella comunità di giocatori. Ma l'uso nel mondo reale ha portato lezioni preziose su cosa ha funzionato, cosa ha causato problemi e dove la notazione potesse evolversi.

Il cambio di nome in **Lonelog** riflette tre intuizioni:

* **Un nome che resta impresso.** "Notazione per GDR Solitario" veniva abbreviato in una dozzina di modi diversi. *Lonelog* è compatto ed evocativo: *Lone* (gioco in solitaria) + *registro* (registro di sessione). Funziona.
* **Un nome che puoi trovare.** Cerca "notazione gdr solitario" e affogherai in risultati generici. Cerca "lonelog" e otterrai *questo sistema*. Pensa a come **Markdown** abbia avuto successo sia come formato che come marchio; non si chiama "Notazione per la formattazione del testo". Lonelog dà a questa notazione un'identità distinta e rintracciabile.
* **Un nome costruito per durare.** Man mano che il sistema matura, avere un'identità chiara rende più facile per la comunità condividere risorse, strumenti e registro di sessione sotto un unico stendardo.

La filosofia di base non è cambiata: separare le meccaniche dalla finzione, restare compatti al tavolo, scalare dalle one-shot alle lunghe campagne e funzionare sia in markdown che nei taccuini cartacei.

### 1.2 Cosa fa Lonelog

Pensalo come un linguaggio condiviso per il gioco in solitaria. Che tu stia giocando a *Ironsworn*, *Thousand Year Old Vampire*, a un GDR non in solitaria usando Mythic GME, o al tuo sistema casalingo, questa notazione ti aiuta a:

* **Registrare cosa è successo** senza rallentare il gioco
* **Tracciare elementi in corso** come PNG, luoghi e fili della trama
* **Condividere le tue sessioni** con altri giocatori solitari che capiranno il formato
* **Rivedere le sessioni passate** e trovare rapidamente quel dettaglio cruciale di tre sessioni fa

La notazione è progettata per essere:

* **Flessibile** — utilizzabile tra diversi sistemi e formati
* **Stratificata** — funziona sia come rapida abbreviazione che come narrazione espansa
* **Ricercabile** — tag e codici rendono facile tracciare PNG, eventi e luoghi
* **Agnostica rispetto al formato** — funziona in file markdown digitali o taccuini analogici

Gli obiettivi della notazione:

* **Rendere i report scritti da persone diverse leggibili a colpo d'occhio:** i simboli standard facilitano la lettura
* **Separare le meccaniche dalla finzione:** i migliori report sono quelli che evidenziano come l'uso di regole e oracoli informi la finzione
* **Avere un sistema modulare e scalabile:** puoi usare i simboli di base o estendere la notazione a tuo piacimento
* **Renderla utile sia per note digitali che analogiche**
* **Conformità ed estensione di markdown per l'uso digitale**

### 1.3 Come Usare Questa Notazione

Pensa a questa come a una **cassetta degli attrezzi, non un libro di regole**. Il sistema è completamente modulare: prendi ciò che funziona per te e lascia il resto.

Al suo centro ci sono solo **cinque simboli** (vedi *Sezione 3: Notazione di Base*). Sono scelti con cura per evitare conflitti con la formattazione markdown e gli operatori di confronto. Questi sono il linguaggio minimo di gioco:

* `@` per le azioni del giocatore
* `?` per le domande all'oracolo
* `d:` per le meccaniche dei tiri
* `->` per i risultati dell'oracolo/dadi
* `=>` per le conseguenze

È tutto. **Tutto il resto è opzionale.**

Scene, intestazioni di campagna, intestazioni di sessione, thread, orologi, estratti narrativi—questi sono tutti miglioramenti che puoi aggiungere quando servono al tuo gioco. Vuoi tracciare una lunga campagna? Aggiungi le intestazioni di campagna. Devi seguire trame complesse? Usa i tag dei thread. Giochi una rapida one-shot? Limitati ai cinque simboli di base.

Pensalo come a cerchi concentrici:

* **Notazione di Base** (obbligatoria): Azioni, Risoluzioni, Conseguenze
* **Livelli Opzionali** (si possono aggiungere al bisogno): Elementi Persistenti, Tracciamento dei progressi, Note, ecc.
* **Struttura Opzionale** (per l'organizzazione): Intestazione Campagna, Intestazione Sessione, Scene

**Inizia in piccolo.** Prova la notazione di base per una scena. Se scatta qualcosa, ottimo! Continua. Se hai bisogno di altro, aggiungi ciò che ti aiuta. Le tue note dovrebbero servire il tuo gioco, non il contrario.

### 1.4 Quick Start: La Tua Prima Sessione

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

**Ecco fatto!** Tutto il resto è opzionale. Prova questo per una scena e vedi come ti senti.

#### Esempio Quick Start

```
S1 *Vicolo buio, mezzanotte*
@ Superare la guardia furtivamente
d: Furtività 4 vs CD 5 -> Fallimento
=> Calcio una bottiglia. La guardia si gira!

? Mi vede chiaramente?
-> No, ma...
=> È sospettoso, inizia a camminare verso il rumore

```

### 1.5 Migrazione da Notazione per GDR solitario v2.0

Se stai già usando Notazione per GDR solitario v2.0, benvenuto! Lonelog è un'evoluzione di quel sistema con simboli chiariti per una migliore coerenza.

**Cosa è Cambiato:**

| Simbolo v2.0 | Simbolo Lonelog | Perché il Cambiamento |
| --- | --- | --- |
| `>` | `@` | Evita conflitti con i blockquote di Markdown |
| `->` (solo oracolo) | `->` (tutte le risoluzioni) | Ora unificato sia per i risultati dei dadi CHE dell'oracolo |
| `=>` (sovraccaricato) | `=>` (solo conseguenze) | Chiarito—non funge più da esito dei dadi |

**Chiarimento chiave:** Nella v2.0, `=>` veniva usato confusamente sia per gli esiti dei dadi che per le conseguenze. Lonelog chiarisce questo utilizzando `->` per TUTTE le risoluzioni (dadi e oracolo), riservando `=>` esclusivamente alle conseguenze.

#### I Tuoi Vecchi Log Sono Ancora Validi

La struttura e la filosofia rimangono identiche. I tuoi registro esistenti sono perfettamente leggibili—non hai bisogno di convertirli a meno che tu non voglia coerenza in tutta la tua campagna.

#### Conversione

Se preferisci la conversione manuale, usa il trova & sostituisci nel tuo editor di testo:

1. Trova: `>` (all'inizio delle righe) → Sostituisci con: `@`
2. I simboli `->` e `=>` sono mantenuti ma con un utilizzo chiarito

## 2. Formati Digitali vs Analogici

Questa notazione funziona **sia in file markdown digitali che in taccuini analogici**. Scegli il formato che meglio si adatta al tuo stile di gioco.

### 2.1 Formato Digitale (Markdown)

Nei file markdown digitali:

* **Metadati della campagna** → Intestazione YAML (in cima al file)
* **Titolo della Campagna** → Intestazione di livello 1
* **Sessioni** → Intestazioni di livello 2 (`## Sessione 1`)
* **Scene** → Intestazioni di livello 3 (`### S1`)
* **Notazione di base e tracciamento** → Blocchi di codice per facilitare la copia/analisi
* **Narrativa** → Prosa regolare tra i blocchi di codice

> **Nota:** Incapsula sempre la notazione in blocchi di codice quando usi il markdown digitale. Questo previene conflitti con la sintassi Markdown e assicura che simboli come `=>` siano renderizzati correttamente. Alcune estensioni Markdown (Mermaid, plugin Obsidian) potrebbero interpretare `=>` al di fuori dei blocchi di codice.

### 2.2 Formato Analogico (Taccuini)

Nei taccuini cartacei:

* Scrivi intestazioni e metadati direttamente come mostrato
* La notazione di base funziona in modo identico ma senza i blocchi di codice
* Usa gli stessi simboli e la stessa struttura
* Parentesi e tag aiutano a scansionare le pagine cartacee

### 2.3 Esempi di Formato

#### Markdown digitale

```markdown
## Sessione 1
*Data: 03-09-2025 | Durata: 1h30*

### S1 *Biblioteca scolastica dopo l'orario di chiusura*

```
@ Intrufolarsi per controllare gli archivi
d: Furtività d6=5 vs CD 4 -> Successo
=> Entro inosservato. [L:Biblioteca|buia|silenziosa]
```

```

#### Taccuino analogico

```
=== Sessione 1 ===
Data: 03-09-2025 | Durata: 1h30

S1 *Biblioteca scolastica dopo l'orario di chiusura*
@ Intrufolarsi per controllare gli archivi
d: Furtività d6=5 vs CD 4 -> Successo
=> Entro inosservato. [L:Biblioteca|buia|silenziosa]

```

Entrambi i formati usano una notazione identica — cambia solo l'involucro.

## 3. Notazione di Base

Questo è il cuore del sistema: i simboli che userai in quasi ogni scena. Tutto il resto in questo documento è opzionale, ma questi elementi fondamentali sono ciò che fa funzionare la notazione.

Ci sono solo cinque simboli da ricordare, e rispecchiano il flusso naturale del gioco in solitaria: compi un'azione o poni una domanda, la risolvi con le meccaniche o un oracolo, quindi registri cosa accade come risultato.

Vediamoli nel dettaglio.

### 3.1 Azioni

Nel gioco in solitaria, l'incertezza deriva da due fonti distinte: **non sai se il tuo personaggio può fare qualcosa** (meccaniche), o **non sai cosa fa il mondo** (oracolo).

Questa distinzione è fondamentale. Quando sferri un colpo di spada, usi le meccaniche per vedere se colpisci. Quando ti chiedi se ci siano guardie nelle vicinanze, interroghi l'oracolo. Entrambe le situazioni creano incertezza, ma sono risolte diversamente.

La notazione riflette questo con due simboli diversi—uno per ogni tipo di azione.

Il simbolo `@` rappresenta te, il giocatore, che agisci nel mondo di gioco. Pensalo come "in questo momento, io...". È visivamente distinto dagli operatori di confronto, rendendo i tuoi registro più chiari ed evitando confusione quando registri i tiri di dadi.

**Azioni rivolte al giocatore (meccaniche):**

```
@ Scassinare la serratura
@ Attaccare la guardia
@ Convincere il mercante

```

**Domande rivolte al mondo / Master (oracolo):**

```
? C'è qualcuno all'interno?
? La corda regge?
? Il mercante è onesto?

```

### 3.2 Risoluzioni

Una volta dichiarata un'azione (`@`) o posta una domanda (`?`), devi risolvere l'incertezza. Qui è dove il sistema di gioco o l'oracolo ti danno una risposta.

Esistono due tipi di risoluzioni: **meccaniche** (quando tiri i dadi o applichi le regole) e **risposte dell'oracolo** (quando interroghi il mondo di gioco).

#### 3.2.1 Tiri delle Meccaniche

Formato:

```
d: [tiro o regola] -> esito

```

Il prefisso `d:` indica un tiro di meccanica o la risoluzione di una regola. Includi sempre l'esito (Successo/Fallimento o risultato narrativo).

#### Esempi

```
d: d20+Scassinare=17 vs CD 15 -> Successo
d: 2d6=8 vs CD 7 -> Successo
d: d100=42 -> Successo parziale (usando la tabella dei risultati)
d: Hackerare il terminale (spendi 1 Equipaggiamento) -> Successo

```

#### Abbreviazione di confronto

Quando confronti i tiri con numeri bersaglio, puoi usare gli operatori di confronto:

```
d: 5 vs CD 4 -> Successo    (formato standard)
d: 5≥4 -> S                (shorthand: ≥ significa eguaglia/supera la CD)
d: 2≤4 -> F                (shorthand: ≤ significa fallisce nel raggiungere la CD)

```

**Nota:** Gli operatori di confronto `≥` e `≤` funzionano perfettamente con la notazione lonelog, senza conflitti di simboli. Puoi anche usare `>=` e `<=`.

Aggiungi le lettere `S` (Successo) o `F` (Fallimento) se desideri flag espliciti:

```
d: 2≤4 F
d: 5≥4 S

```

#### 3.2.2 Risultati di Oracolo e Dadi

Il simbolo `->` rappresenta una risoluzione definitiva—una dichiarazione di esito. La freccia mostra visivamente "questo porta al risultato", sia esso determinato dalla meccanica dei dadi o dalla risposta di un oracolo.

**Formato:**

```
-> [risultato] (opzionale: riferimento al tiro)

```

Il prefisso `->` indica qualsiasi esito di risoluzione—meccanica o oracolare.

#### Risultati delle Meccaniche dei Dadi

Per i tiri di meccanica, `->` dichiara Successo o Fallimento:

```
d: Furtività d6=5 vs CD 4 -> Successo
d: Scassinare d20=8 vs CD 15 -> Fallimento
d: Attacco 2d6=7 vs CD 7 -> Successo
d: Hacking d10=3 -> Successo Parziale

```

#### Risposte dell'Oracolo

Per le domande all'oracolo, `->` dichiara ciò che il mondo rivela:

```
-> Sì (d6=6)
-> No, ma... (d6=3)
-> Sì, e... (d6=5)
-> No, e... (d6=1)

```

#### Formati comuni dell'oracolo

* **Oracoli Sì/No:** `-> Sì`, `-> No`
* **Sì/No con modificatori:** `-> Sì, ma...`, `-> No, e...`
* **Gradi di risultato:** `-> Sì forte`, `-> No debole`
* **Risultati personalizzati:** `-> Parzialmente`, `-> Con un costo`

#### Perché una sintassi unificata?

Sia le meccaniche che gli oracoli risolvono l'incertezza. L'uso di `->` per entrambi crea coerenza—ogni risoluzione riceve la stessa dichiarazione, rendendo il registro più facile da scansionare e analizzare. Che tu abbia tirato i dadi o interrogato l'oracolo, `->` segna il momento in cui l'incertezza diventa certezza.

### 3.3 Conseguenze

Registra il risultato narrativo dopo i tiri usando `=>`. Il simbolo mostra le conseguenze che fluiscono in avanti dalle azioni e dalle risoluzioni. La doppia freccia visualizza come gli eventi si susseguono nella tua storia.

```
=> La porta cigola aprendosi, ma il rumore riecheggia nel corridoio.
=> La guardia mi vede e dà l'allarme.
=> Trovo un diario nascosto con un indizio cruciale.

```

#### Conseguenze multiple

Puoi concatenare più righe di conseguenze per effetti a cascata:

```
d: Scassinare 5≥4 -> Successo
=> La porta si apre
=> Ma i cardini stridono rumorosamente
=> [E:OrologioAllerta 1/6]

```

### 3.4 Sequenze d'Azione Complete

Ecco come si combinano gli elementi di base:

#### Sequenza guidata dalle meccaniche

```
@ Scassinare la serratura
d: d20+Scassinare=17 vs CD 15 -> Successo
=> La porta cigola aprendosi, ma il rumore riecheggia nel corridoio.

```

#### Sequenza guidata dall'oracolo

```
? C'è qualcuno all'interno?
-> Sì, ma... (d6=4)
=> C'è qualcuno, ma è distratto.

```

#### Sequenza combinata

```
@ Superare le guardie furtivamente
d: Furtività 2≤4 -> Fallimento
=> Il mio piede colpisce un barile. [E:OrologioAllerta 2/6]

? Mi vedono?
-> No, ma... (d6=3)
=> Sono distratti, ma una guardia si sofferma nelle vicinanze. [N:Guardia|vigile]

```

## 4. Livelli Opzionali

Hai le basi—azioni, tiri e conseguenze. È sufficiente per un gioco semplice. Ma le campagne più lunghe hanno spesso bisogno di altro: PNG che riappaiono, fili della trama che si intrecciano tra le sessioni, progressi che si accumulano nel tempo.

Questa sezione copre gli **elementi di tracciamento** che ti aiutano a gestire la complessità. Sono tutti opzionali. Se stai giocando un mistero one-shot, potresti non aver bisogno di nulla di tutto questo. Se stai conducendo una vasta campagna con dozzine di PNG e molteplici fili della trama, probabilmente vorrai usare la maggior parte di essi.

Scegli ciò di cui la tua campagna ha bisogno.

### 4.1 Elementi Persistenti

Man mano che la tua campagna cresce, certi elementi rimangono: PNG che riappaiono, luoghi in cui ritorni, minacce in corso, domande della storia che abbracciano più sessioni. Questi sono i tuoi **elementi persistenti**.

I tag ti permettono di tracciarli coerentemente tra scene e sessioni. Il formato è semplice: parentesi, un prefisso di tipo, un nome e dettagli opzionali. Come questo: `[N:Jonah|amichevole|ferito]`.

**Perché usare i tag?**

* **Ricercabilità**: Trova ogni scena in cui appare Jonah
* **Coerenza**: Fai riferimento ai PNG nello stesso modo ogni volta
* **Tracciamento dello stato**: Vedi come cambiano gli elementi nel tempo
* **Aiuto per la memoria**: Ricorda dettagli dopo settimane

Non hai bisogno di taggare tutto—solo ciò che conta per la tua campagna. Un mercante casuale che non vedrai mai più? Chiamalo semplicemente "il mercante" nella prosa. Un cattivo ricorrente? Taggualo sicuramente.

Ecco i principali tipi di elementi persistenti che potresti tracciare:

#### 4.1.1 PNG (Personaggi Non Giocanti)

```
[N:Jonah|amichevole|ferito]
[N:Guardia|vigile|armata]
[N:Mercante|sospettoso]

```

**Aggiornamento dei tag PNG:**

Quando lo stato di un PNG cambia, puoi:

* Riformulare con nuovi tag: `[N:Jonah|catturato|ferito]`
* Mostrare solo il cambiamento: `[N:Jonah|catturato]` (si assume che gli altri tag persistano)
* Usare aggiornamenti espliciti: `[N:Jonah|amichevole→ostile]`
* Aggiungere `+` o `-`: `[N:Jonah|+catturato]` o `[N:Jonah|-ferito]`

Scegli lo stile che mantiene il tuo registro più chiaro.

#### 4.1.2 Luoghi

```
[L:Faro|rovinato|tempestoso]
[L:Biblioteca|buia|silenziosa]
[L:Taverna|affollata|rumorosa]

```

#### 4.1.3 Eventi & Orologi

```
[E:TramaCultisti 2/6]
[E:OrologioAllerta 3/4]
[E:ProgressoRituale 0/8]

```

Gli eventi tracciano elementi significativi della trama. Il formato numerico `X/Y` mostra il progresso attuale/totale.

#### 4.1.4 Fili della Trama (Thread)

```
[Thread:Trovare la sorella di Jonah|Aperto]
[Thread:Scoprire la cospirazione|Aperto]
[Thread:Fuggire dalla città|Chiuso]

```

I thread tracciano le principali domande o obiettivi della storia. Stati comuni:

* `Aperto` — thread attivo
* `Chiuso` — thread risolto
* `Abbandonato` — thread lasciato cadere
* Stati personalizzati permessi (es. `Urgente`, `Sottofondo`)

#### 4.1.5 Personaggio del Giocatore (PG)

```
[PG:Alex|PF 8|Stress 0|Equip:Torcia,Taccuino]
[PG:Elara|PF 15|Munizioni 3|Stato:Ferita]

```

**Aggiornamento delle statistiche del PG:**

```
[PG:Alex|PF 8]        (iniziale)
[PG:Alex|PF-2]        (shorthand: perso 2 PF, ora a 6)
[PG:Alex|PF 6]        (esplicito: ora a 6 PF)
[PG:Alex|PF+3|Stress-1]  (cambiamenti multipli)

```

#### 4.1.6 Tag di Riferimento

Per fare riferimento a un elemento stabilito in precedenza senza riformulare i tag, usa il prefisso `#`:

```
[N:Jonah|amichevole|ferito]     (prima menzione — stabilisce l'elemento)

... più avanti nel registro ...

[#N:Jonah]                     (riferimento — assume i tag precedenti)

```

Il simbolo `#` indica che questo elemento è stato definito in precedenza. Usalo per:

* Mantenere sintetiche le menzioni successive
* Segnalare ai lettori di guardare indietro per il contesto
* Mantenere la ricercabilità (l'ID "Jonah" appare ancora)

**Quando usare i tag di riferimento:**

* Prima menzione: Tag completo con dettagli `[N:Nome|tag]`
* Menzioni successive nella stessa scena: Opzionale, usa il buon senso
* Menzioni successive in scene/sessioni diverse: Usa `[#N:Nome]` per segnalare il riferimento
* Cambiamenti di stato: Rimuovi il `#` e mostra i nuovi tag `[N:Nome|nuovi_tag]`

### 4.2 Tracciamento dei Progressi

Alcune cose nella tua campagna non accadono tutto in una volta—si accumulano nel tempo. Il rituale richiede dodici passi per essere completato. Il sospetto delle guardie cresce a ogni rumore che fai. Il tuo piano di fuga avanza lentamente. La riserva d'aria diminuisce.

Il tracciamento dei progressi ti offre un modo visivo per vedere queste forze che si accumulano. Tre formati gestiscono diversi tipi di progressione:

**Orologi** (si riempiono verso il completamento):

```
[Clock:Rituale 5/12]
[Clock:Sospetto 3/6]

```

**Usa per:** Minacce in aumento, incantesimi in preparazione, pericolo che si accumula. Quando l'orologio si riempie, succede qualcosa (di solito negativo per te).

**Tracciati** (progressi verso un obiettivo):

```
[Track:Fuga 3/8]
[Track:Investigazione 6/10]

```

**Usa per:** I tuoi progressi nei progetti, l'avanzamento dei viaggi, obiettivi a lungo termine. Quando il tracciato si riempie, ottieni un successo.

**Timer** (contano alla rovescia verso lo zero):

```
[Timer:Alba 3]
[Timer:RiservaAria 5]

```

**Usa per:** Scadenze che si avvicinano, risorse che si esauriscono, pressione temporale. Quando arriva a zero, il tempo è scaduto.

**La differenza?** Orologi e tracciati aumentano entrambi, ma gli orologi sono minacce (le cose vanno male quando sono pieni) e i tracciati sono progressioni (meglio quando sono pieni). I timer vanno contano alla rovescia e provocano senso di urgenza.

Non hai bisogno di tracciare tutto numericamente. Usa questi solo quando un conteggio ha un peso per la tua storia e vuoi un modo concreto per misurarlo.

### 4.3 Tabelle Random & Generatori

Il gioco in solitaria prospera sulla sorpresa. A volte tiri su una tabella per vedere cosa trovi, o usi un generatore per creare un PNG al volo. Quando lo fai, aiuta registrare cosa hai tirato, sia per trasparenza che per poter ricreare la logica in seguito.

**Semplice consultazione di tabella:**

```
tbl: d100=42 -> "Una spada spezzata"
tbl: d20=15 -> "Il mercante è nervoso"

```

Usa `tbl:` quando attingi da una tabella casuale semplice, quella in cui tiri una volta e ottieni un risultato.

**Generatori complessi:**

```
gen: Mythic Event d100=78 + 11 -> Azione PNG / Tradimento
gen: Stars Without Number NPC d8=3,d10=7 -> Burbero/Pilota

```

Usa `gen:` quando usi un generatore a più fasi che combina più tiri o produce risultati composti.

**Integrazione con le domande all'oracolo:**

```
? Cosa trovo nel forziere?
tbl: d100=42 -> "Una spada spezzata"
=> Una lama antica, spezzata in due, con strane rune sull'elsa.

```

**Perché registrare i tiri?** Per tre ragioni:

1. **Trasparenza**: Se condividi il registro, gli altri vedono il tuo processo
2. **Riproducibilità**: Puoi tracciare come hai ottenuto risultati sorprendenti
3. **Apprendimento**: Nel tempo, vedi quali tabelle usi di più

Detto questo, se giochi in modo rapido e informale, puoi saltare i dettagli del tiro e registrare solo il risultato: `=> Trovo una spada spezzata [tbl]`. La parte importante è la finzione, non la matematica.

### 4.4 Estratti Narrativi

Ecco un segreto: **non hai bisogno di scrivere alcuna narrazione**. L'abbreviazione cattura tutto meccanicamente. Ma a volte la finzione richiede di più: un frammento di dialogo troppo perfetto per non essere registrato, una descrizione che stabilisce l'atmosfera, un documento trovato dal tuo personaggio.

A questo servono gli estratti narrativi: i momenti in cui l'abbreviazione non basta.

**Prosa inline** (brevi descrizioni):

```
=> La stanza puzza di muffa e decomposizione. Ci sono carte sparse ovunque.

```

**Usa per:** Rapidi dettagli d'atmosfera, informazioni sensoriali, momenti emotivi. Mantienili brevi—una frase o due.

**Dialogo** (conversazioni che vale la pena registrare):

```
N (Guardia): "Chi va là?"
PG: "Resta calmo... solo resta calmo."
N (Guardia): "Fatti vedere!"
PG: [sussurra] "Non se ne parla."

```

**Usa per:** Scambi memorabili, la voce del personaggio, conversazioni importanti. Non hai bisogno di registrare ogni parola—solo gli scambi che contano.

**Lunghi blocchi narrativi** (documenti trovati, descrizioni importanti):

```
\---
Il diario recita:
"Giorno 47: Le maree non obbediscono più alla luna. I pesci hanno smesso
di arrivare. Il guardiano del faro dice di vedere luci sotto le onde.
Temo per la nostra sanità mentale."
---\

```

**Usa per:** Documenti in-game, descrizioni lunghe, rivelazioni chiave. I marcatori `\---` e `---\` lo separano dal tuo registro, rendendo chiaro che si tratta di contenuto in-fiction. I delimitatori asimmetrici prevengono conflitti con le linee orizzontali di Markdown.

**Quanta narrazione dovresti scrivere?** Solo quella che ti serve. Se giochi per te stesso e l'abbreviazione ti dice tutto ciò che devi ricordare, salta la prosa. Se condividi il tuo registro o ami il processo di scrittura, aggiungine di più. Non c'è una quantità giusta, solo ciò che rende il tuo registro utile e piacevole per te.

### 4.5 Meta Note

A volte hai bisogno di uscire dalla finzione e lasciarti una nota: un promemoria su una regola della casa (house rule) che stai testando, una riflessione su come è andata una scena, una domanda da rivisitare in seguito, o un chiarimento sulla tua interpretazione di una regola.

A questo servono le meta note: i tuoi commenti fuori-dal-personaggio (out-of-character) per te stesso (o per i lettori, se condividi il registro).

**Formato:** Usa le parentesi per segnalare "questo è meta, non finzione":

```
(nota: sto testando una regola furtività alternativa dove il rumore aumenta l'orologio Allerta)
(riflessione: questa scena è stata tesa! il timer ha funzionato bene)
(house rule: concedo vantaggio su terreno familiare)
(promemoria: rivisitare questo thread nella prossima sessione)
(domanda: avrei dovuto tirare per questo? sembrava ovvio)

```

**Quando usare le meta note:**

* **Esperimenti**: Traccia varianti di regole o house rule che stai testando
* **Riflessione**: Cattura ciò che ha funzionato o meno a livello emotivo
* **Promemoria**: Segnala cose da approfondire più tardi
* **Chiarimento**: Spiega decisioni o interpretazioni insolite
* **Processo**: Documenta il tuo pensiero per i registro condivisi

**Quando NON usarle:** Non lasciare che le meta note sommergano il tuo registro. Se ti fermi ogni poche righe per riflettere, probabilmente stai pensando troppo. Il gioco è la cosa principale, le meta note sono solo occasionali commenti a margine.

Pensale come al commento del regista su un film. Per la maggior parte del tempo, guardi solo il film. Occasionalmente, c'è una nota interessante dietro le quinte che vale la pena condividere.

---

## 5. Struttura Opzionale

Finora abbiamo parlato di *cosa* scrivi (azioni, tiri, tag). Ora parliamo di *come organizzarlo*.

La struttura aiuta in due modi: rende le tue note più facili da consultare e segnala i confini (questa sessione è finita, quella scena è iniziata). Ma la struttura aggiunge carico di lavoro: più intestazioni da scrivere, più formattazione da mantenere.

Questa sezione mostra gli elementi organizzativi: intestazioni di campagna (metadati sull'intera campagna), intestazioni di sessione (per segnare le sessioni di gioco) e struttura della scena (l'unità base di gioco). Usa ciò che ti aiuta a orientarti senza rallentarti.

La differenza chiave? **I formati digitali e analogici gestiscono la struttura diversamente.** Il markdown digitale usa intestazioni e YAML; i taccuini analogici usano intestazioni scritte e marcatori. Li mostreremo entrambi.

### 5.1 Intestazione Campagna

Prima di tuffarti nel gioco, aiuta registrare alcune basi: A cosa stai giocando? Quale sistema? Quando hai iniziato? Pensala come alla "copertina" del tuo registro di campagna.

Questo è particolarmente utile quando:

* Conduci più campagne (ti aiuta a ricordare quale sia quale)
* Condividi i registro con altri (hanno bisogno di contesto)
* Ritorni a una campagna dopo una pausa (ti ricorda il tono/i temi)

Se stai solo provando la notazione con una rapida one-shot, salta questa parte. Ma per le campagne che pianifichi di rivisitare, un'intestazione vale quei 30 secondi di lavoro in più.

**I formati digitali e analogici differiscono qui.** Il markdown digitale usa lo YAML front matter (metadati strutturati in cima al file). I taccuini analogici usano un blocco intestazione scritto.

**Per i file markdown digitali**, usa lo YAML front matter proprio all'inizio:

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

**Per i taccuini analogici**, scrivi un blocco intestazione della campagna:

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

**Campi opzionali** (da aggiungere al bisogno):

* `[Ambientazione]` — Dettagli geografici o del mondo
* `[Ispirazione]` — Media che hanno ispirato la campagna
* `[Strumenti di Sicurezza]` — X-card, linee/veli, ecc.

### 5.2 Intestazione Sessione

Un'intestazione di sessione segna il confine tra le sessioni di gioco e fornisce contesto: quando hai giocato, quanto a lungo, cosa è successo?

**Perché usare le intestazioni di sessione?**

* **Navigazione**: Salta rapidamente a sessioni specifiche
* **Contesto**: Ricorda quando hai giocato e cosa stava succedendo
* **Riflessione**: Traccia i tuoi schemi di gioco (quanto spesso? quanto a lungo?)
* **Continuità**: Collega le sessioni con riassunti e obiettivi

**Quando saltarle:**

* Giochi one-shot (nessuna sessione multipla)
* Gioco continuo (giochi quotidianamente senza interruzioni chiare)
* Log di pura abbreviazione (vuoi solo la finzione, non la meta-struttura)

Come le intestazioni di campagna, i formati digitali e analogici gestiscono le sessioni diversamente. Scegli lo stile che si adatta al tuo mezzo.

#### 5.2.1 Formato digitale (intestazione markdown)

```markdown
## Sessione 1
*Data: 03-09-2025 | Durata: 1h30 | Scene: S1-S2*

**Riassunto:** Prima sessione, introduzione di Alex e del mistero.

**Obiettivi:** Impostare il mistero centrale, stabilire il faro come luogo chiave.

```

#### 5.2.2 Formato analogico (intestazione scritta)

```
=== Sessione 1 ===
[Data]        03-09-2025
[Durata]      1h30
[Scene]       S1-S2
[Riassunto]   Prima sessione, introduzione di Alex e del mistero.
[Obiettivi]   Impostare il mistero centrale, stabilire il faro.

```

**Campi opzionali:**

* `[Umore]` — Tono pianificato o effettivo per la sessione
* `[Note]` — Varianti di regole, esperimenti o condizioni speciali
* `[Thread]` — Thread attivi in questa sessione

### 5.3 Struttura della Scena

Le scene sono l'unità base di gioco all'interno di una sessione. Al suo livello più semplice, una scena è solo un marcatore numerato con contesto.

**Formato digitale (intestazione markdown):**

```markdown
### S1 *Biblioteca scolastica dopo l'orario di chiusura*

```

**Formato analogico:**

```
S1 *Biblioteca scolastica dopo l'orario di chiusura*

```

Il numero della scena ti aiuta a tracciare la progressione e a fare riferimento agli eventi in seguito. Il contesto (in corsivo/asterischi) inquadra dove e quando si svolge la scena.

#### 5.3.1 Scene Sequenziali (Standard)

La maggior parte delle campagne usa una semplice numerazione sequenziale:

```
S1 *Taverna, sera*
S2 *Piazza del paese, mezzanotte*
S3 *Sentiero nel bosco, alba*
S4 *Rovine antiche, mezzogiorno*

```

**Quando usare:** Predefinito per il gioco lineare. La Scena 2 accade dopo la Scena 1, la Scena 3 dopo la Scena 2, ecc.

**Numerazione:** Inizia da S1 ogni sessione, oppure continua in tutta la campagna (S1-S100+).

**Esempio in gioco:**

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

#### 5.3.2 Flashback

I flashback mostrano eventi passati che informano la storia attuale. Usa suffissi alfabetici che si diramano dalla scena "presente".

**Formato:** `S#a`, `S#b`, `S#c`

**Quando usare:**

* Rivelare il passato a metà sessione
* Inneschi della memoria del personaggio
* Mostrare come è successo qualcosa
* Spiegare elementi misteriosi

**Esempio di struttura:**

```
S5 *Investigare il mulino*
=> Trovo il vecchio diario di mio padre.

S5a *Flashback: Officina del padre, 10 anni fa*
(Questo è accaduto prima della campagna)
=> Padre: "Promettimi che non andrai mai al mulino da solo."

S6 *Di nuovo al mulino, presente*
(Ora continuiamo dalla S5)

```

**Esempio completo:**

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

**Suggerimenti per la numerazione:**

* Crea una diramazione dalla scena che innesca il flashback
* Torna alla numerazione sequenziale dopo
* Mantieni i flashback brevi (solitamente 1-3 scene)
* Annota nel contesto quando torni: `*Presente*` o `*Di nuovo al...*`

#### 5.3.3 Thread Paralleli

Quando tracci più linee narrative che accadono simultaneamente o con focus alternato, usa i prefissi dei thread.

**Formato:** `T#-S#` dove T# è il numero del thread, S# è il numero della scena all'interno di quel thread

**Quando usare:**

* Personaggi/punti di vista multipli
* Eventi simultanei in luoghi diversi
* Alternanza tra linee narrative
* Archi narrativi separati ma correlati

**Esempio di struttura:**

```
T1-S1 *Personaggio principale al faro*
T2-S1 *Nel frattempo, l'alleato in città*
T1-S2 *Di nuovo al faro*
T2-S2 *Di nuovo in città*
T1-S3 *Faro, in continuazione*

```

**Esempio completo:**

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

**Quando i thread convergono:**

Una volta che i thread paralleli si incontrano, puoi:

* Continuare con i prefissi dei thread: `T1+T2-S5`
* Tornare alla sequenza: `S14` (nota: thread uniti)

```
T1-S6 *Alex scappa dal faro*
T2-S4 *Jordan guida verso il faro*

S14 *Ingresso del faro, entrambi riuniti*
(Thread uniti)
[PG:Alex|ferito] incontra [PG:Jordan|preoccupato]

```

#### 5.3.4 Montaggi e Salti Temporali

Per attività che abbracciano tempo o vignette multiple e veloci, usa la notazione decimale.

**Formato:** `S#.#` (es. `S5.1`, `S5.2`, `S5.3`)

**Quando usare:**

* Viaggiare attraverso lunghe distanze
* Addestramento/ricerca per settimane
* Incontri multipli veloci
* Raccolta di risorse
* Sequenze in time-lapse

**Esempio di struttura:**

```
S7 *Inizio del viaggio*
S7.1 *Giorno 1: Foresta*
S7.2 *Giorno 3: Montagne*
S7.3 *Giorno 5: Deserto*
S8 *Arrivo a destinazione*

```

**Esempio completo:**

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

**Esempio di montaggio di viaggio:**

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

#### 5.3.5 Scegliere il Tuo Approccio

**Usa la sequenza (S1, S2, S3) quando:**

* Giochi una storia lineare e semplice
* Non hai bisogno di manipolazioni temporali complesse
* Vuoi semplicità
* Scelta più comune

**Usa i flashback (S5a, S5b) quando:**

* Rivei il passato a metà gioco
* Momenti di sviluppo del personaggio
* Spieghi misteri
* Brevi diversioni dalla linea temporale principale

**Usa i thread paralleli (T1-S1, T2-S1) quando:**

* Giochi con più personaggi
* Tracci eventi simultanei
* Alterni tra vari luoghi
* Trame complesse e intrecciate

**Usa i montaggi (S7.1, S7.2) quando:**

* Copri lunghi periodi di tempo
* Serie di scene veloci
* Sequenze di viaggio
* Raccolta di risorse
* Periodi di addestramento/ricerca

#### 5.3.6 Elementi di Contesto della Scena

Oltre alla numerazione, arricchisci le scene con il contesto nell'intestazione:

**Luogo:**

```
S1 *Torre del faro*
S1 [L:Faro] *Stanza della torre*

```

**Marcatori temporali:**

```
S1 *Faro, mezzanotte*
S1 *Faro, Giorno 3, crepuscolo*
S1 *Due settimane dopo: Faro*

```

**Tono emotivo:**

```
S1 *Faro (teso)*
S1 *Faro - momento di calma*

```

**Elementi multipli:**

```
S1 *Torre del faro, mezzanotte, Giorno 3*
S5a *Flashback: Officina del padre, 10 anni fa*
T2-S3 *Intanto in città, stessa sera*
S7.2 *Giorno 2 del viaggio: Passo di montagna*

```

**Minimale (solo numero):**

```
S1
(Aggiungi il contesto nella prima azione o conseguenza)

```

Scegli il livello di dettaglio che ti aiuta a tracciare la tua storia. Più dettaglio aiuta il riferimento futuro; meno dettaglio mantiene le note più pulite.

---

## 6. Esempi Completi

La teoria è una cosa, ma vedere la notazione in azione è dove scatta la comprensione. Questa sezione mostra esempi di gioco completi in stili diversi, dall'abbreviazione ultra-compatta ai ricchi registro narrativi, così puoi trovare l'approccio che funziona per te.

Ogni esempio dimostra lo stesso sistema di notazione, solo con diversi livelli di dettaglio. Scegli lo stile che corrisponde alle tue preferenze, o mescolali secondo le necessità della tua sessione.

### 6.1 Log ad Abbreviazione Minimale

Pura abbreviazione, nessuna formattazione. Perfetto per un gioco veloce:

```
S1 @Furtività d:4≥5 F => rumore [E:Allerta 1/6] ?Visto? ->Nb3 => distratto
S2 @Cerca d:6≥4 S => trova chiave [E:Indizio 1/4] ?Trappola? ->Yn6 => sì, punte!
S3 @Schiva d:3≤5 F => PF-2 [PG:PF 6] => ferita, serve ritirarsi

```

### 6.2 Formato Ibrido Digitale

Combina abbreviazioni con narrazione, usando la struttura markdown:

```markdown
### S7 *Vicolo buio dietro la taverna, Mezzanotte*

```
@ Superare le guardie furtivamente
d: Furtività d6=2 vs CD 4 -> Fallimento
=> Il mio piede colpisce un barile. [E:OrologioAllerta 2/6]

? Mi vedono?
-> No, ma... (d6=3)
=> Sono distratti, ma una guardia si sofferma. [N:Guardia|vigile]
```

La luce della torcia della guardia spazza le pareti del vicolo. Mi schiaccio
contro le ombre, respirando appena.

```
N (Guardia): "Chi va là?"
PG: "Resta calmo... solo resta calmo."
```

```

### 6.3 Formato Taccuino Analogico

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

### 6.4 Registro Campagna Completo (Digitale)

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
@ Intrufolarsi per controllare gli archivi
d: Furtività d6=5 vs CD 4 -> Successo
=> Entro inosservato. [L:Biblioteca|buia|silenziosa]

? C'è uno strano indizio ad attendermi?
-> Sì (d6=6)
=> Trovo una pagina di diario strappata che parla del faro. [E:IndizioFaro 1/6]
```

La pagina è ingiallita dal tempo. La grafia è tremolante: "La luce 
ci chiama. Non dobbiamo rispondere."

```
[Thread:Mistero del Faro|Aperto]
```

### S2 *Fuori dalla biblioteca, corridoio vuoto*

```
? Sento dei passi?
-> Sì, ma... (d6=4)
=> Si avvicina un custode, ma non mi ha ancora notato. [N:Custode|stanco|sospettoso]
```

Mi raggelo. Le sue chiavi tintinnano mentre passa davanti alla porta.

N (Custode): "Mi era parso di sentire qualcosa..."
PG (Alex, sussurro): "Devo andarmene da qui."

```
@ Scivolare via mentre è distratto
d: Furtività d6=6 vs CD 4 -> Successo
=> Scappo nella notte in sicurezza.
```
## Sessione 2
*Data: 10-09-2025 | Durata: 2h*

**Riassunto:** Trovata pagina di diario che accenna al faro. Quasi scoperto in biblioteca.

### S3 *Sentiero verso il vecchio faro, Giorno 2*

```
@ Avvicinarsi silenziosamente al crepuscolo
d: Furtività d6=2 vs CD 4 -> Fallimento
=> Calpesto dei vetri rotti, scricchiolando rumorosamente. [Clock:Sospetto 1/6]

? Qualcuno risponde dall'interno?
-> No, ma... (d6=3)
=> La luce sfarfalla brevemente nella finestra della torre. [L:Faro|rovinato|infestato]
```

### S4 *All'interno dell'atrio del faro*

```
@ Cercare sul pavimento segni di attività
d: Investigazione d6=6 vs CD 4 -> Successo
=> Trovo orme fresche nella polvere. [Thread:Chi sta usando il faro?|Aperto]

tbl: d100=42 -> "Una lanterna rotta"
=> Una lanterna crepata giace vicino alle scale. [E:IndizioFaro 2/6]
```

Qualcuno è stato qui. Di recente.

PG (Alex, pensando): "Questo posto non è così abbandonato come tutti pensano..."


```

### 6.5 Registro Campagna Completo (Analogico)

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

---

## 7. Best Practices

Hai imparato la notazione. Ora parliamo di come usarla bene. Questa sezione mostra schemi collaudati che rendono i tuoi registro più chiari e utili, oltre agli errori comuni da evitare.

Pensali come linee guida derivanti dall'esperienza collettiva della comunità solista. Non sono regole rigide, ma ti aiuteranno a creare registro facili da leggere, consultare e condividere.

### 7.1 Buone Pratiche ✓

Questi schemi rendono i tuoi registro più puliti, più ricercabili e più facili da consultare in seguito. Non hai bisogno di seguirli tutti, ma rappresentano ciò che funziona bene per la maggior parte dei giocatori solitari.

**Sì: Mantieni azioni e tiri collegati**

```
@ Scassinare la serratura
d: d20=15 vs CD 14 -> Successo
=> La porta si apre silenziosamente.

```

**Sì: Usa i tag per gli elementi persistenti**

```
[N:Jonah|amichevole|ferito]
[L:Faro|rovinato]

```

**Sì: Registra le conseguenze chiaramente**

```
=> Trovo la chiave. [E:Indizio 2/4]
=> Ma la guardia mi ha sentito. [Clock:Allerta 1/6]

```

**Sì: Usa i tag di riferimento nelle scene successive**

```
Prima menzione: [N:Jonah|amichevole]
Dopo: [#N:Jonah] si avvicina cautamente

```

**Sì: Mescola abbreviazioni e narrazione al bisogno**

```
@ Superare la guardia furtivamente
d: 5≥4 S -> Successo
=> Scivolo via inosservato, con il cuore a mille.

```

### 7.2 Cattive Pratiche ✗

Questi sono errori comuni che rendono i registro più difficili da leggere o analizzare. Se ti accorgi di farli, non preoccuparti: correggiti per la prossima volta. Ci siamo passati tutti!

**No: Seppellire le meccaniche nella prosa**

```
❌ Ho provato a scassinare la serratura e ho fatto un 15 che ha battuto la CD quindi l'ho aperta

✔️ @ Scassinare la serratura
  d: 15≥14 -> Successo
  => La porta si apre silenziosamente.

```

**No: Dimenticare di registrare le conseguenze**

```
❌ @ Attaccare la guardia
  d: 8≤10 -> Fallimento

✔️ @ Attaccare la guardia
  d: 8≤10 -> Fallimento
  => La mia lama rimbalza sulla sua armatura. Lui contrattacca!

```

**No: Perdere traccia dei tag tra le scene**

```
❌ [N:Guardia|allerta] ... poi più tardi ... [N:Guardia|dormiente]
   (Come è cambiato? Quando?)

✔️ [N:Guardia|allerta] ... poi più tardi ...
  @ Metterla fuori combattimento
  d: 6≥5 S => [N:Guardia|priva di sensi]

```

**No: Confondere i simboli di azione e oracolo**

```
❌ ? Superare le guardie furtivamente    (Questa è un'azione, non una domanda)

✔️ @ Superare le guardie furtivamente    (Le azioni usano @)
  ? Mi notano?                          (Le domande usano ?)

```

**No: Dimenticare il contesto della scena**

```
❌ S7
  @ Superare le guardie furtivamente
  
✔️ S7 *Vicolo buio, mezzanotte*
  @ Superare le guardie furtivamente

```

---

## 8. Template

Iniziare da una pagina bianca può scoraggiare. Questi template ti offrono un punto di partenza strutturato. Copiali, compila i campi e inizia a giocare.

Ogni template è disponibile sia in formato **markdown digitale** che per **taccuino analogico**. Scegli quello che corrisponde al tuo stile di gioco, o usali come ispirazione per creare i tuoi.

Non trattare questi template come moduli rigidi. Sono impalcature. Una volta che sarai a tuo agio con la notazione, probabilmente svilupperai i tuoi template che si adattano meglio alle tue esigenze specifiche.

### 8.1 Template Campagna (Digitale YAML)

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

### 8.2 Template Campagna (Analogico)

Per i taccuini cartacei, scrivi questo blocco intestazione all'inizio del registro della tua campagna. Mantienilo semplice—puoi sempre aggiungere altri dettagli in seguito, se necessario.

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

### 8.3 Template Sessione

Usa questo all'inizio di ogni sessione di gioco per segnare i confini e fornire il contesto. La versione digitale usa le intestazioni markdown; la versione analogica usa intestazioni scritte.

Compila ciò che è utile e salta ciò che non lo è. L'unico campo essenziale è la data—tutto il resto è opzionale.

**Digitale:**

```markdown
## Sessione X
*Data: | Durata: | Scene: *

**Riassunto:** **Obiettivi:** ### S1 *Descrizione scena*

```

**Analogico:**

```
=== Sessione X ===
[Data]        
[Durata]    
[Riassunto]       
[Obiettivi]       

S1 *Descrizione scena*

```

### 8.4 Template Scena Rapida

Questo è il tuo template da lavoro—la struttura base che userai scena dopo scena. È intenzionalmente minimale: solo la struttura sufficiente per tenerti orientato senza rallentarti.

Usa questo come punto di partenza predefinito per ogni scena, sia che tu giochi in digitale o in analogico.

```markdown
S# *Luogo, ora*
```
@ La tua azione
d: il tuo tiro -> esito
=> Cosa succede

? La tua domanda
-> Risposta oracolo
=> Cosa significa
```

```

---

## 9. Adattare al Tuo Sistema

Ecco la parte bella: questa notazione funziona con *qualsiasi* sistema GDR in solitaria. *Ironsworn*, *Mythic GME*, *Thousand Year Old Vampire*, il tuo sistema casalingo... non importa. I simboli di base rimangono gli stessi; cambiano solo i dettagli della risoluzione.

Questa sezione ti mostra come adattare la notazione dei tiri `d:` e i formati dell'oracolo `->` per corrispondere al tuo specifico sistema di gioco. Copriremo sistemi comuni (PbtA, FitD, Ironsworn, OSR) e oracoli (Mythic, CRGE, MUNE), ma i principi funzionano per tutto.

**L'intuizione chiave:** La notazione separa le *meccaniche* dalla *finzione*. Il tuo sistema determina come funzionano le meccaniche; la notazione si limita a registrarle in modo coerente.

### 9.1 Notazione dei Tiri Specifica del Sistema

La notazione `d:` funziona con qualsiasi sistema—devi solo adattarla alle tue specifiche meccaniche dei dadi. Ecco come appare la notazione nei popolari sistemi GDR solisti.

Questi esempi mostrano lo schema: registra cosa hai tirato, confrontalo con ciò di cui avevi bisogno, annota l'esito. I dettagli cambiano a seconda del sistema, ma la struttura rimane la stessa.

#### 9.1.1 Powered by the Apocalypse (PbtA)

```
d: 2d6=9 -> Successo Parziale (7-9)
d: 2d6=7 -> Successo Parziale (7-9)
d: 2d6=4 -> Fallimento (6-)

```

#### 9.1.2 Forged in the Dark (FitD)

```
d: 4d6=6,5,4,2 (prendi il più alto=6) -> Successo Critico
d: 3d6=4,4,2 -> Successo Parziale (4-5)
d: 2d6=3,2 -> Fallimento (1-3)

```

#### 9.1.3 Ironsworn

```
d: Azione=7+Stat=2=9 vs Sfida=4,8 -> Colpo Debole
d: Azione=10+Stat=3=13 vs Sfida=2,7 -> Colpo Forte

```

#### 9.1.4 Fate/Fudge

```
d: 4dF=+2 (++0-) +Abilità=3 = +5 -> Successo con Stile
d: 4dF=-1 (-0--) +Abilità=2 = +1 -> Pareggio

```

#### 9.1.5 OSR/D&D Tradizionale

```
d: d20=15+Mod=2=17 vs CA 16 -> Colpito
d: d20=8+Mod=-1=7 vs CD 10 -> Fallimento

```

### 9.2 Adattamenti dell'Oracolo

Diversi sistemi oracolari hanno diversi formati di output. Alcuni danno risposte sì/no, altri generano risultati complessi. Ecco come registrare i risultati dei popolari sistemi oracolari.

La chiave è la coerenza: usa sempre `->` per i risultati dell'oracolo, quindi cattura qualsiasi informazione il tuo oracolo fornisca.

#### 9.2.1 Mythic GME

```
? La guardia mi nota? (Probabilità: Improbabile)
-> No, ma... (CF=4)
=> Non mi vede, ma è sospettosa.

```

#### 9.2.2 CRGE (Conjectural Roleplaying Game Engine)

```
? Qual è l'umore del mercante?
-> Impulso: Attore + Focus => Arrabbiato + Tradimento
=> Il mercante è furioso per essere stato ingannato.

```

#### 9.2.3 MUNE (Madey Upy Number Engine)

```
? C'è qualcuno in casa?
-> Probabile + tiro 2,4 => Sì
=> Le luci sono accese, c'è sicuramente qualcuno all'interno.

```

#### 9.2.4 UNE (Universal NPC Emulator)

```
gen: Motivazione UNE -> Potere + Reputazione
=> [N:Barone|ambizioso|cerca riconoscimento]

```

### 9.3 Gestione dei Casi Limite

Ogni sistema ha le sue particolarità. Ecco come gestire situazioni comuni che non rientrano negli schemi di base della notazione.

#### 9.3.1 Tiri Multipli in un'Unica Azione

Quando devi effettuare più tiri per una sola azione:

**Vantaggio/Svantaggio:**

```
@ Attaccare con vantaggio
d: 2d20=15,8 (prendi il più alto) vs CD 12 -> 15≥12 Successo
=> Colpisco con precisione, la lama trova un varco nell'armatura.

```

**Dice pool multipli:**

```
@ Eseguire un rituale complesso
d: INT d6=4, VOL d6=5, vs CD 4 ciascuno -> Entrambi successo
=> L'incantesimo prende piede, l'energia scoppietta tra le mie dita.

```

**Tiri contrapposti:**

```
@ Braccio di ferro con il marinaio
d: FOR d20=12 vs marinaio d20=15 -> 12≤15 Fallimento
=> La sua presa si stringe. Il mio braccio sbatte sul tavolo.

```

#### 9.3.2 Risultati Ambigui dell'Oracolo

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

#### 9.3.3 Conseguenze Annidate

A volte una conseguenza ne genera un'altra, creando una cascata:

```
d: Scassinare 5≥4 -> Successo
=> La porta si apre
=> Ma i cardini stridono rumorosamente
=> Le guardie nella stanza accanto sentono [E:OrologioAllerta 1/6]
=> Una inizia a camminare in questa direzione [N:Guardia|investigazione]

```

**Quando usare:** Grandi successi o fallimenti con molteplici effetti a catena. Non esagerare: la maggior parte delle azioni ha una chiara conseguenza.

#### 9.3.4 Domande all'Oracolo Fallite

Cosa succede se l'oracolo non aiuta?

```
? Cosa c'è dietro la porta?
-> [Risultato poco chiaro/contraddittorio]
(nota: pongo una domanda più specifica)
? C'è pericolo dietro la porta?
-> Sì, e...
=> Pericolo, ed è immediato!

```

**Pro tip:** Se un risultato dell'oracolo non innesca la finzione, va bene riformulare la domanda o tirare di nuovo. L'oracolo serve la tua storia, non il contrario.

---

## Appendici

### A. Legenda di Lonelog

Questo è il tuo riferimento rapido, il foglio riassuntivo da tenere a portata di mano mentre giochi. Hai dimenticato cosa significa `=>`? Hai bisogno di ricordare come formattare un orologio? Questa sezione ti aiuta.

Pensalo come al "vocabolario" della notazione. Tutto qui è stato spiegato in dettaglio in precedenza; questa è solo la versione condensata per una rapida consultazione.

Metti un segnalibro a questa sezione. Ci tornerai spesso nelle tue prime sessioni, poi sempre meno man mano che la notazione diventerà naturale.

#### A.1 Simboli di Base

| Simbolo | Significato | Esempio |
| --- | --- | --- |
| `@` | Azione del giocatore (meccaniche) | `@ Scassinare la serratura` |
| `?` | Domanda all'oracolo (mondo/incertezza) | `? C'è qualcuno all'interno?` |
| `d:` | Tiro/risultato meccanica | `d: 2d6=8 vs CD 7 -> Successo` |
| `->` | Risultato oracolo/dadi | `-> Sì, ma...` |
| `=>` | Conseguenza/esito | `=> La porta si apre silenziosamente` |

#### A.2 Operatori di Confronto

* `≥` o `>=` — Maggiore o uguale (eguaglia/supera la CD)
* `≤` o `<=` — Minore o uguale (fallisce nel raggiungere la CD)
* `vs` — Versus (confronto esplicito)
* `S` — Flag di Successo
* `F` — Flag di Fallimento

#### A.3 Tag di Tracciamento

* `[N:Nome|tag]` — PNG (prima menzione)
* `[#N:Nome]` — PNG (riferimento a menzione precedente)
* `[L:Nome|tag]` — Luogo
* `[E:Nome X/Y]` — Evento/Orologio
* `[Thread:Nome|stato]` — Filo della trama
* `[PG:Nome|stat]` — Personaggio del Giocatore

#### A.4 Tracciamento dei Progressi

* `[Clock:Nome X/Y]` — Orologio (si riempie)
* `[Track:Nome X/Y]` — Tracciato dei progressi
* `[Timer:Nome X]` — Timer per il conto alla rovescia

#### A.5 Generazione Casuale

* `tbl: tiro -> risultato` — Semplice consultazione di tabella
* `gen: sistema -> risultato` — Generatore complesso

#### A.6 Struttura

* `S#` o `S#a` — Numero della scena
* `T#-S#` — Scena specifica del thread

#### A.7 Narrativa (Opzionale)

* Inline: `=> Prosa qui`
* Dialogo: `N (Nome): "Parlato"`
* Blocco: `--- testo ---`

#### A.8 Meta

* `(nota: ...)` — Riflessione, promemoria, house rule

#### A.9 Riga di Esempio Completa

```
S3 @Scassinare d:15≥14 S => porta si apre silenziosamente [N:Guardia|vigile]

```

### B. FAQ

Hai domande? Non sei solo. Queste sono le domande più comuni di chi impara la notazione, con risposte dirette.

Se la tua domanda non è qui, ricorda: la notazione è flessibile. Se ti chiedi se puoi fare qualcosa diversamente, la risposta è probabilmente "sì, se funziona per te".

**D: Devo usare ogni elemento?**

R: No! Inizia solo con `@`, `?`, `d:`, `->`, e `=>`. Aggiungi altri elementi solo se ti aiutano.

**D: Posso usarlo con GDR tradizionali (con un Master)?**

R: La notazione di base funziona benissimo per qualsiasi nota di GDR. Gli elementi dell'oracolo (`?`, `->`) sono specifici per il gioco solista, ma la notazione azione/risoluzione funziona ovunque.

**D: E se il mio sistema non usa i dadi?**

R: Usa `d:` per qualsiasi meccanica di risoluzione: `d: Pesca dal mazzo -> Regina di Picche`, `d: Spendi token -> Successo`

**D: Dovrei usare il formato digitale o analogico?**

R: Quello che preferisci! Usano la stessa notazione. Il digitale ha una migliore ricerca/organizzazione; l'analogico è immediato e tattile.

**D: Quanto dovrebbero essere dettagliate le mie note?**

R: Quanto vuoi! Il sistema funziona per abbreviazioni pure (Esempio 6.1) o narrazione ricca (Esempio 6.4).

**D: Posso condividere i miei registro con altri?**

R: Sì! Questo è uno dei motivi per una notazione standardizzata. Altri che conoscono il sistema possono leggere facilmente i tuoi registro.

**D: E per quanto riguarda le house rule o i simboli personalizzati?**

R: Documentali nelle meta note: `(nota: uso + per vantaggio, - per svantaggio)`. Il sistema è progettato per essere esteso.

**D: I numeri delle scene devono essere sequenziali?**

R: No. Usa `S1`, `S2`, `S3` per semplicità, ma dirama (`S3a`, `S3b`) o usa i prefissi dei thread (`T1-S1`) se utile.

**D: Dovrei aggiornare i tag ogni volta che qualcosa cambia?**

R: Mostra esplicitamente i cambiamenti significativi: `[N:Guardia|vigile]` → `[N:Guardia|priva di sensi]`. I cambiamenti minori possono essere impliciti nella narrazione.

### C. Filosofia del Design dei Simboli

I simboli di Lonelog sono stati scelti per ragioni specifiche:

* **`@` (Azione)**: Rappresenta "in questo punto" o l'attore che compie l'azione. Cambiato da `>` nella v2.0 per evitare conflitti con i blockquote di Markdown.
* **`?` (Domanda)**: Simbolo universale per l'interrogazione. Invariato dalla v2.0.
* **`d:` (Dadi/Risoluzione)**: Chiara abbreviazione per i tiri di dadi. Invariato dalla v2.0.
* **`->` (Risoluzione)**: Mantenuto dalla v2.0. Ora unificato per TUTTE le risoluzioni (dadi e oracolo). La freccia mostra visivamente "questo porta al risultato".
* **`=>` (Conseguenza)**: Mantenuto dalla v2.0. La doppia freccia mostra gli effetti a cascata. Uso chiarito: solo conseguenze (la v2.0 sovraccaricava questo simbolo anche per gli esiti dei dadi).

**Compatibilità Markdown**: Tutti i simboli funzionano correttamente nei blocchi di codice e non confliggono con la formattazione markdown o gli operatori matematici. Avvolgi sempre la notazione in blocchi di codice quando usi il markdown digitale per prevenire conflitti con le estensioni Markdown.

---

## Crediti & Licenza

© 2025-2026 Roberto Bisceglie

Questa notazione è ispirata al [Valley Standard](https://alfredvalley.itch.io/the-valley-standard).

**Ringraziamenti:**

* matita per il metodo `+`/`-` per tracciare i cambiamenti nei tag
* flyincaveman per il suggerimento sull'uso del simbolo `@` per le azioni del personaggio (nella tradizione dei primi RPG ASCII)
* r/solorpgplay e r/Solo_Roleplaying per la positiva accoglienza di questa notazione e per i feedback utili.
* Enrico Fasoli per il playtesting e il feedback

**Cronologia Versioni:**

* v 1.0.0: Evoluto da Notazione per GDR Solitario v2.0 di Roberto Bisceglie

Questo lavoro è distribuito sotto la licenza **Creative Commons Attribution-ShareAlike 4.0 International**.

**Sei libero di:**

* Condividere — copiare e ridistribuire il materiale
* Adattare — rimixare, trasformare e sviluppare il materiale

**Alle seguenti condizioni:**

* Attribuzione — Devi dare i crediti appropriati
* Stessa Licenza — Se adatti il materiale, devi distribuire i tuoi contributi sotto la stessa licenza

*Buone avventure, giocatori solitari!*

