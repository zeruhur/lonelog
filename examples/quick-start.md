---
title: Quick Start Example
ruleset: Any system
genre: Example
player: Your Name
pcs: Adventurer
start_date: 2025-12-30
---

# Quick Start Example

This is a minimal example showing the absolute basics of Solo RPG Notation. Perfect for beginners!

## Session 1

### S1 *Dark alley, midnight*

```
> Sneak past the guard
d: Stealth d6=4 vs TN 5 => Fail
=> My foot kicks a bottle. The guard turns! [N:Guard|alert]

? Does he see me clearly?
-> No, but... (d6=3)
=> He's suspicious, starts walking toward the noise

> Hide behind the crates
d: Stealth d6=6 vs TN 4 => Success
=> I press into the shadows. He walks right past me.
```

That was close! The guard finally moves on, muttering to himself.

### S2 *Inside the warehouse*

```
> Search for the package
d: Investigation d6=5 vs TN 4 => Success
=> I find a locked chest. [L:Warehouse|dark|abandoned]

? Is it trapped?
-> No (d6=4)
=> Safe to open

> Pick the lock
d: Lockpicking d6=6 vs TN 5 => Success
=> The lock clicks open. Inside: a strange glowing crystal!

[Thread:Mysterious Crystal|Open]
```

---

**That's the basics!** You just saw:
- **Actions** (`>`) - what your character does
- **Dice rolls** (`d:`) - mechanics resolution
- **Oracle questions** (`?`) - asking the game world
- **Oracle answers** (`->`) - what the oracle says
- **Consequences** (`=>`) - what happens as a result
- **Tags** - track NPCs, locations, threads

Ready for more? Check out `clearview-mystery.md` for a complete campaign example!
