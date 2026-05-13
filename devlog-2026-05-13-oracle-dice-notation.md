---
title: "Two Updates: Block Tag Consistency and Oracle Dice Notation"
date: 2026-05-13
type: devlog
tags: [lonelog, add-ons, notation, oracle, update]
---

# Two Updates: Oracle Dice Notation and Block Tag Consistency 

## Clarifying Oracle Dice Notation in v1.5.0

One of the things I've watched people get confused by since the early days of this notation is the oracle roll line. When you ask the oracle a question and roll dice to answer it, how do you write that down?

The old answer was: use `->`. But `->` was already the symbol for *any* resolution outcome — mechanics and oracle alike. The result was ambiguity. When you saw `-> No (d6=3)`, was that a standalone oracle answer, or the tail end of a `d:` line? Readable in isolation, but inconsistent when mixed with mechanics-heavy logs.

**What changed in v1.5.0:**

`d:` is now the preferred notation for oracle dice rolls, exactly as it is for mechanics rolls:

```
? Do they see Phoebe?
d: d100=60 vs 35 (Unlikely) -> No
=> Distracted, but one guard lingers. [N:Guard|watchful]

? Is anyone home?
d: d6=5 vs 4+ -> Yes
=> Lights are on inside.
```

The logic is simple: if you're rolling dice, write `d:`. Doesn't matter whether that roll is resolving an action or answering an oracle question — dice are dice. `->` follows to declare the outcome, as it always did.

The old `-> Yes (d6=6)` format isn't gone. It's now explicitly a shorthand — for when you don't need to show the roll at all:

```
-> Yes, and... (d6=6)
-> No, but... (d6=3)
```

Use it when the dice details don't matter and you just want to capture the result. Use `d:` when the roll itself is part of the story.

**The three oracle resolution forms, clarified:**

There was also a subtler confusion about when to use `d:` vs `tbl:` vs `gen:` for oracle answers. v1.5.0 pins this down explicitly:

- **`d:`** — direct dice roll against a probability or target (yes/no checks, likelihood rolls)
- **`tbl:`** — lookup on a named oracle table (Mythic Random Event table, your own custom oracle)
- **`gen:`** — compound generator producing multi-axis results

```
? Does the guard notice me? (Unlikely)
d: d100=60 vs 35 -> No                           (direct probability roll)

? What random event disrupts the scene?
tbl: Mythic Event d100=78 -> NPC Action           (named table oracle)

? What does the oracle reveal about my enemy?
gen: Mythic Event d100=78+d100=34 -> NPC Action / Betray  (compound generator)
```

**Add-on updates:**

All three official add-ons are updated to reference Lonelog v1.5.0 as their parent. Oracle examples in the Dungeon Crawling and Resource Tracking add-ons have been updated to use the preferred `d:` form. Two stray `R1`/`R2` round markers were also corrected to `Rd1`/`Rd2`.

**Your existing logs are fine.** The `-> result (d#=N)` format still appears in the spec as valid shorthand. This is a clarification, not a breaking change.

## Add-on Block Tags Now Consistent Across the Ecosystem

Small but satisfying fix.

The three official add-ons — Combat, Dungeon Crawling, and Resource Tracking — each introduced a structural block to delimit a mode of play: a combat encounter, a dungeon session status, a resource snapshot. The Combat Add-on got this right from the start: `[COMBAT]` / `[/COMBAT]`, bracket tags, consistent with everything else in Lonelog. The other two didn't. Dungeon Crawling used `=== Dungeon Status ===` with no closing tag. Resource Tracking used `--- RESOURCES ---` / `--- /RESOURCES ---` with dash separators.

That inconsistency bugged me. If you're using all three add-ons together — which is the point — switching mental models for block delimiters mid-session is friction you shouldn't have to deal with.

**What changed:**

- `=== Dungeon Status ===` → `[DUNGEON STATUS]` / `[/DUNGEON STATUS]`
- `--- RESOURCES ---` / `--- /RESOURCES ---` → `[RESOURCES]` / `[/RESOURCES]`
- Analog notebook alternatives now consistently use `--- BLOCK ---` / `--- END BLOCK ---` across all three add-ons

Both updated add-ons are now at **v1.1.0**.

The Community Add-on Guidelines have also been updated (v1.1.0) with an explicit §3.3 on structural block syntax, so future add-ons get this right from the start. The rule is simple: bracket tags for digital, dashed separators for analog, explicit closing tag always required.

No changes to any notation logic, tag semantics, or examples beyond the block delimiters themselves. If you have session logs using the old format, they're still perfectly readable — this only affects how you write new blocks going forward.