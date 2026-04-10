---
title: "Lonelog: Card Notation Add-on"
subtitle: "A Standard Notation for Playing Cards in Session Logs"
author: Roberto Bisceglie
version: 1.0.0
license: CC BY-SA 4.0
lang: en
parent: Lonelog v1.4.0
requires: Core Notation (§3)
---

## Overview

Core Lonelog already acknowledges card draws as a valid resolution mechanic. What it doesn't define is a compact, unambiguous shorthand for card identities.

Without a standard, logs fill with inconsistent spellings: "Q of spades", "queen♠", "Queen Spades", "QS". Tarot draws fare worse — "reversed Tower" and "The Tower (rev.)" and "XVI r" are all the same card. For tools that parse logs, and for players who share them, the inconsistency creates friction.

This add-on defines a compact notation for three types of card draws:

- **Standard playing cards** — the 52-card deck plus jokers
- **Tarot** — Major Arcana, Minor Arcana, and upright/reversed orientation
- **Oracle decks** — a lightweight convention for named-card systems

**When not to use this add-on:** If you play a single system with a single card type and never share logs, your current spelling probably works fine. Adopt this notation when consistency matters — for shared logs, tool support, or crossing between multiple card systems in one campaign.

---

### What This Add-on Adds

| Element | Purpose | Example in a log |
|---------|---------|-----------------|
| `{rank}{suit}` | Compact standard card identity | `d: draw=Qs -> Dark omen` |
| `M{n}` | Major Arcana by number | `d: draw=M12r -> Blocked` |
| `{rank}{suit}` with tarot suits | Minor Arcana | `d: draw=KnCu` |
| `r` suffix | Reversed orientation (Tarot) | `d: draw=M16r` |
| Position labels in spreads | Named positions in a multi-card spread | `d: Past=5s, Present=Ks` |

**No new core symbols.** Card draws use `d:` and `->` exactly as defined in core Lonelog. The card identity uses `=` as the drawn result; `->` carries the interpreted outcome.

### Design Principles

**Cards follow the same pattern as dice.** `=` records the drawn card, `->` carries the interpreted outcome, `=>` carries the narrative consequence. `d: draw=Qs -> Dark omen` is the same structure as `d: Strike 2d6+2=9 -> Hit`.

**Compact but readable.** `Qs` over "Queen of Spades". Abbreviations should be recoverable without a lookup table by anyone who knows the card system.

**No orientation assumption.** Upright is the default and unmarked. Reversed is the exception and is always marked with `r`. A card with no suffix is always upright.

---

## Part I: Practical Reference

### How card draws fit into a log entry

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

---

Or split across lines when each card needs its own consequence:

```
d: Past=5s
d: Present=Ks
d: Future=ACu
=> Conflict led here. Authority holds the present. Something new waits at the end.
```

---

### Standard Playing Cards

Ranks: `A`, `2`–`10`, `J`, `Q`, `K`  
Suits: `h` (hearts ♥), `d` (diamonds ♦), `c` (clubs ♣), `s` (spades ♠)  
Format: `{rank}{suit}`

```
Ah    Ace of Hearts
7c    Seven of Clubs
Ks    King of Spades
10d   Ten of Diamonds
Jh    Jack of Hearts
```

Jokers: `Jkr` (generic), `RJkr` (red joker), `BJkr` (black joker).

When the game cares about color but not suit: `R` (red — hearts or diamonds), `B` (black — clubs or spades).

In a log:

```
@ Search the body
d: draw=3h -> Minor find
=> A folded note, damp and illegible.

@ Fate check
d: draw=Jkr -> Chaos surge
=> Everything changes.
```

---

### Tarot

#### Major Arcana

Format: `M{n}` where `n` is the card's number (0–21).

| n | Card | n | Card |
|---|------|---|------|
| 0 | The Fool | 11 | Justice |
| 1 | The Magician | 12 | The Hanged Man |
| 2 | The High Priestess | 13 | Death |
| 3 | The Empress | 14 | Temperance |
| 4 | The Emperor | 15 | The Devil |
| 5 | The Hierophant | 16 | The Tower |
| 6 | The Lovers | 17 | The Star |
| 7 | The Chariot | 18 | The Moon |
| 8 | Strength | 19 | The Sun |
| 9 | The Hermit | 20 | Judgement |
| 10 | Wheel of Fortune | 21 | The World |

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

#### Minor Arcana

Suits: `Wa` (Wands), `Cu` (Cups), `Sw` (Swords), `Pe` (Pentacles)  
Ranks: `A`, `2`–`10`, `Pg` (Page), `Kn` (Knight), `Q`, `K`  
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

---

### Oracle Decks

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

---

### Spreads

A spread is a multi-card draw where each card occupies a named position. Write position labels with `=` for each card.

**Single-line (compact, for short spreads):**

```
d: Past=5s, Present=Ks, Future=ACu
```

**Multi-line (when each card needs interpretation space):**

```
d: Past=M16r -> Collapse that was delayed, not avoided.
=> The Tower reversed. I should have fallen sooner.

d: Present=KWa -> I am the force at work here.
=> The King of Wands. The fire is mine to wield or waste.

d: Future=ACu -> Something new if I let go.
=> The Ace of Cups. Grief first, then an opening.
```

**Labeled spread with deck name:**

```
d: Celtic Past=7Wa, Celtic Present=M12, Celtic Future=3Cu
```

---

### Common Patterns by System

**Standard deck as oracle (e.g. *Carta*, *For the Queen*):**

```
@ Explore the next hex
d: draw=7d -> Forest path
=> Tall pines, no trail. I mark it as unmapped.
```

**Tarot for scene framing:**

```
? What is the mood of this place?
d: draw=M18 // The Moon -> Illusion, hidden things
=> Nothing here is what it seems.
```

**Fate deck for *Ironsworn* variants:**

```
d: Oracle 2d10=47 -> Yes, and...
d: draw=Ks -> Complication: authority figure
=> The bridge is there, but a city guard holds the crossing.
```

**Reversed card as obstacle:**

```
? Does my contact show up?
d: draw=M6r // The Lovers reversed -> Divided loyalties
=> He's here, but he brought someone I didn't expect.
```

**Horror game — Joker as catastrophe trigger:**

```
d: draw=RJkr -> The Worst Thing
=> The lights go out across the whole building. Something found the generator.
```

---

## Part II: Complete Reference

---

## 1. Standard Deck Notation

### Ranks

| Symbol | Card |
|--------|------|
| `A` | Ace |
| `2`–`10` | Number cards |
| `J` | Jack |
| `Q` | Queen |
| `K` | King |

### Suits

| Symbol | Suit | Color |
|--------|------|-------|
| `h` | Hearts ♥ | Red |
| `d` | Diamonds ♦ | Red |
| `c` | Clubs ♣ | Black |
| `s` | Spades ♠ | Black |

### Jokers

| Symbol | Card |
|--------|------|
| `Jkr` | Joker (generic, when color doesn't matter) |
| `RJkr` | Red Joker |
| `BJkr` | Black Joker |

### Color Shorthand

When a system cares about red/black but not the specific suit:

| Symbol | Meaning |
|--------|---------|
| `R` | Red card (hearts or diamonds) |
| `B` | Black card (clubs or spades) |

### Full Card Examples

```
Ah    Ace of Hearts
2c    Two of Clubs
10d   Ten of Diamonds
Jh    Jack of Hearts
Qs    Queen of Spades
Kd    King of Diamonds
Jkr   Joker
```

**Note:** `10d` (Ten of Diamonds) is two characters before the suit. All other ranks are one character. Parsers should treat `10` as a complete rank token.

## 2. Tarot Notation

### Major Arcana

**Format:** `M{n}` where `n` is 0–21.

**Reversed:** append `r` — `M0r`, `M16r`.

| n | Card | Symbol | Reversed |
|---|------|--------|---------|
| 0 | The Fool | `M0` | `M0r` |
| 1 | The Magician | `M1` | `M1r` |
| 2 | The High Priestess | `M2` | `M2r` |
| 3 | The Empress | `M3` | `M3r` |
| 4 | The Emperor | `M4` | `M4r` |
| 5 | The Hierophant | `M5` | `M5r` |
| 6 | The Lovers | `M6` | `M6r` |
| 7 | The Chariot | `M7` | `M7r` |
| 8 | Strength | `M8` | `M8r` |
| 9 | The Hermit | `M9` | `M9r` |
| 10 | Wheel of Fortune | `M10` | `M10r` |
| 11 | Justice | `M11` | `M11r` |
| 12 | The Hanged Man | `M12` | `M12r` |
| 13 | Death | `M13` | `M13r` |
| 14 | Temperance | `M14` | `M14r` |
| 15 | The Devil | `M15` | `M15r` |
| 16 | The Tower | `M16` | `M16r` |
| 17 | The Star | `M17` | `M17r` |
| 18 | The Moon | `M18` | `M18r` |
| 19 | The Sun | `M19` | `M19r` |
| 20 | Judgement | `M20` | `M20r` |
| 21 | The World | `M21` | `M21r` |

**Note:** The Thoth Tarot and some other decks swap the positions of Strength (VIII) and Justice (XI). The `M{n}` notation follows the Rider-Waite-Smith standard (Strength = 8, Justice = 11). If you use a different numbering, note it in your session header.

### Minor Arcana

**Suits:**

| Symbol | Suit | Element |
|--------|------|---------|
| `Wa` | Wands | Fire |
| `Cu` | Cups | Water |
| `Sw` | Swords | Air |
| `Pe` | Pentacles / Coins | Earth |

**Ranks:**

| Symbol | Card |
|--------|------|
| `A` | Ace |
| `2`–`10` | Number cards |
| `Pg` | Page |
| `Kn` | Knight |
| `Q` | Queen |
| `K` | King |

**Format:** `{rank}{suit}` — `ACu`, `7Wa`, `PgSw`, `KnPe`, `QCu`, `KWa`

**Reversed:** append `r` — `7War`, `PgSwr`

### Orientation

| Suffix | Meaning |
|--------|---------|
| *(none)* | Upright (default) |
| `r` | Reversed |

## 3. Oracle Decks

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

---

## 4. Spread Notation

A spread assigns each drawn card to a named position. The position label appears in the `d:` field with `=` for each card.

### Single-line format

```
d: {Position1}={card1}, {Position2}={card2}, ...
```

Example:

```
d: Past=5Sw, Present=KWa, Future=ACu
```

### Multi-line format

Use when each card warrants its own `->` or `=>`:

```
d: {Position}={card} -> [outcome]
=> [Narrative consequence]
```

---

### Common spread names

These are conventions, not requirements. Any position label is valid.

| Spread | Positions |
|--------|-----------|
| Three-card | `Past`, `Present`, `Future` |
| Three-card (alt) | `Situation`, `Action`, `Outcome` |
| Three-card (alt) | `Mind`, `Body`, `Spirit` |
| Celtic Cross | `Self`, `Cross`, `Foundation`, `Past`, `Crown`, `Future`, `Self2`, `Environment`, `Hopes`, `Outcome` |
| Single draw | `draw` (no position label needed) |

---

## Quick Reference

### Standard Deck

```
Ah  Ac  Ad  As    Aces
Kh  Kc  Kd  Ks    Kings
Qh  Qc  Qd  Qs    Queens
Jh  Jc  Jd  Js    Jacks
10h … 2h          Number cards (any suit)
Jkr  RJkr  BJkr   Jokers
R  B                Color only
```

### Tarot

```
M0 – M21            Major Arcana (M0 = The Fool, M21 = The World)
M0r                 Reversed Major Arcana

ACu  7Wa  PgSw  KnPe  QCu  KWa   Minor Arcana
7War                              Reversed Minor Arcana

Suits: Wa (Wands)  Cu (Cups)  Sw (Swords)  Pe (Pentacles)
Ranks: A  2–10  Pg  Kn  Q  K
```

### In a Log

```
d: draw=Qs                             single draw, no interpretation needed
d: draw=Qs -> Dark omen                single draw with outcome
d: draw=M16r -> Everything breaks      Tarot reversed with outcome
d: draw=M12 // The Hanged Man          draw with name annotation
d: Past=5Sw, Present=KWa               spread, single line
? Is this the right path?
d: draw=M17 -> Yes                     oracle question answered by card
```

---

## FAQ

**Q: Why does the card use `=` rather than `->` — isn't the card itself the outcome?**  
A: The card drawn is the raw result of the mechanic, just as `9` is the raw result of `2d6+2`. What the card *means* in context — the interpreted state — is the outcome, and that goes in `->`. `d: draw=Qs -> Dark omen` mirrors `d: Strike 2d6+2=9 -> Hit` exactly.

**Q: What about card games that use multiple decks, or partial decks?**  
A: The notation identifies individual cards, not deck composition. Track deck state in a `[Deck:]` tag or a session note as needed.

**Q: My system uses pip value (Ace = 1, King = 13) rather than card identity. Should I write the card or the number?**  
A: Write the card: `d: draw=Ah -> 1`. The card identity is the raw result; the pip value is the interpreted outcome. Both are preserved.

**Q: How do I note a hand of cards (drawn but not played)?**  
A: List them space-separated: `Hand: Ah Kd 7c Qs 3h`. When one is played, log it as a normal draw.

**Q: Tarot decks vary — some have different names or art. Does `M12` always mean The Hanged Man?**  
A: This spec follows the Rider-Waite-Smith numbering, which is the most common standard. If your deck diverges (e.g. Thoth swaps Strength and Justice), note it once in your session header: `[Deck: Thoth — Strength=M11, Justice=M8]`.

---

**Q: Can I use `?` with a card draw instead of `d:`?**  
A: Use `?` for the question, then `d:` for the draw that answers it. They are separate events — the question is asked, then the card is drawn as the mechanical resolution.

```
? What does fate hold for this meeting?
d: draw=M10 // Wheel of Fortune -> Chance rules all
=> Anything could happen. I prepare for nothing and everything.
```

**Q: What about digital tools that render suit symbols (♥ ♦ ♣ ♠)?**  
A: The letter abbreviations (`h d c s`) are the canonical form for logs. Tools that render logs may substitute suit symbols for display, but the stored notation should use letters to stay plain-text safe.

---

## Credits & License

© 2026 Roberto Bisceglie

This add-on extends [Lonelog](https://zeruhur.itch.io/lonelog) by Roberto Bisceglie.

**Version History:**

- v1.0.0: Initial release

This work is licensed under the **Creative Commons Attribution-ShareAlike 4.0 International License**.

You are free to share and adapt this material, provided you give appropriate credit and distribute adaptations under the same license. Session logs and play records created using this add-on's notation are your own work and are not subject to this license.
