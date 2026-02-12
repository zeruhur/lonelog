---
title: "Lonelog: Combat Module"
subtitle: "Optional Notation for Tactical Encounters"
status: Draft
parent: Lonelog v1.0.0
---

## Combat Module

Combat is where solo play gets dense. Dice fly, hit points drop, positions shift—and you're running both sides. Without structure, your log turns into a wall of text where you can't tell who hit whom or when things went wrong.

This module gives you **optional notation for combat encounters**. It layers on top of core Lonelog—same `@`, `d:`, `->`, `=>` symbols—and adds just enough structure to keep fights readable without turning your session into a spreadsheet.

Like everything in Lonelog: **take what helps, leave the rest.**

### Why a Separate Module?

Not every solo game has tactical combat. *Thousand Year Old Vampire* doesn't need round tracking. A *Mythic GME*-driven investigation might resolve a bar fight in a single oracle question. This module exists for the games where combat *is* mechanical—where you're tracking rounds, multiple combatants, ranges, and hit points.

If your system resolves combat with a single roll, you don't need any of this. Core notation handles it fine:

```
@ Fight the bandits
d: Combat 2d6=9 -> Strong Hit
=> I cut through them and escape into the alley.
```

This module is for everything more involved than that.

### Design Principles

The module follows three rules:

1. **No new core symbols.** Combat uses `@`, `d:`, `->`, `=>` exactly as defined in Lonelog core. We only add *structural markers* and *conventions*.
2. **Scale to complexity.** A quick skirmish needs less notation than a five-round battle with six combatants. The module supports both.
3. **Actor clarity.** The central problem of combat logging is "who's doing what." Every addition here serves that goal.


### C.1 Combat Blocks

Mark the boundaries of a combat encounter with a combat tag in the scene header or as a standalone marker. This signals "different mode"—denser notation, round-by-round tracking.

**In a scene header:**

```
S5 *Warehouse ambush* [COMBAT]
```

**As a standalone marker** (when combat starts mid-scene):

```
S5 *Warehouse, midnight*
@ Search the crates for evidence
d: Investigation d6=5 vs TN 4 -> Success
=> I find shipping manifests—but hear footsteps behind me.

[COMBAT]
...combat notation here...
[/COMBAT]

=> With the thugs unconscious, I grab the manifests and run.
```

The `[COMBAT]` / `[/COMBAT]` delimiters are optional but useful. They help you:

- Visually separate the tactical section from the narrative
- Find combat encounters when scanning a log
- Signal to readers (or future-you) that denser notation follows

**Analog notebooks:** Write `--- COMBAT ---` and `--- END COMBAT ---` if you prefer visual separators. Or just skip them—the round markers (below) already signal combat.

**When to skip delimiters:** If the entire scene *is* a fight, the scene header is enough: `S5 *Warehouse ambush* [COMBAT]`. No need for closing tags—the next scene marker ends it.


### C.2 Rounds

Track combat rounds with `R#` markers. Think of them like mini-scenes within the fight.

```
R1
...actions...

R2
...actions...

R3
...actions...
```

**Numbering:** Start at `R1` each combat. Rounds are local to the encounter, not the session.

**When to skip round markers:** If combat is fast (1–2 rounds) or your system doesn't use discrete rounds, don't bother. Just log actions sequentially.


### C.3 Combatants: The Foe Tag

Core Lonelog tracks NPCs with `[N:Name|tags]`. In combat, you often need tighter tracking—hit points, position, threat level, status effects. The **foe tag** `[F:Name|stats]` is a combat-specific variant designed for this.

**Format:**

```
[F:Name|key stats|position|status]
```

**Examples:**

```
[F:Thug A|HP 6|Close|armed]
[F:Thug B|HP 4|Medium|armed]
[F:Cultist Leader|HP 12|Far|spellcaster]
[F:Wolf Pack|HP 8|Close|3 wolves]
```

**Why `[F:]` instead of `[N:]`?**

`[N:]` is for persistent NPCs who matter to your story. `[F:]` is for combatants—often disposable, defined by mechanical stats rather than narrative tags. The distinction keeps your NPC index clean. A recurring villain might start as `[N:Viktor|ambitious|ruthless]` in the story and gain a `[F:Viktor|HP 15|Far|armored]` when the swords come out.

**Updating foe tags during combat:**

```
[F:Thug A|HP 6|Close]
...Thug A takes 3 damage...
[F:Thug A|HP 3|Close|wounded]
...or shorthand:
[F:Thug A|HP-3]
```

**Group combatants** when individuals don't matter:

```
[F:Goblins×4|HP 3 each|Close]
...one dies...
[F:Goblins×3|Close]
```

**When to skip foe tags:** For simple fights (one enemy, no position tracking), just use `[N:]` or name them in prose. Foe tags earn their keep when you need to track multiple combatants with changing stats.


### C.4 Actor Turns: Who Does What

This is the core problem of combat logging: in normal play, `@` always means "I, the player character, do something." In combat, enemies act too. 

**The rule is simple:** `@` stays as the PC action. For other actors, **prefix the action with the actor's name in parentheses.**

| Actor | Format | Example |
|-------|--------|---------|
| PC (default) | `@ Action` | `@ Swing at Thug A` |
| Named foe | `@(Name) Action` | `@(Thug A) Slash at PC` |
| Group | `@(Group) Action` | `@(Goblins) Swarm attack` |
| Ally NPC | `@(Name) Action` | `@(Jordan) Cover fire` |

**Examples in play:**

```
R1
@ Draw sword and attack Thug A
d: d20+5=18 vs AC 12 -> Hit
d: 1d8=6 damage
=> [F:Thug A|HP-6|dead]

@(Thug B) Lunges at me with a knife
d: d20+3=14 vs AC 15 -> Miss
=> The knife whistles past my ear.
```

**Why not a new symbol for foe actions?**

Because `@` already means "action taken." The parenthetical prefix tells you *who*—that's all the disambiguation you need. Adding a new symbol (like `!` or `>>`) would break the Lonelog principle of minimal core symbols and add one more thing to remember mid-fight.

**Shorthand for fast combats:**

If you don't want to write out actor prefixes, just go chronological within each round. The context of foe tags makes it clear:

```
R1
[F:Thug A|Close] @ Slash -> d:14 vs AC 15 -> Miss
[PC] @ Riposte -> d:18 vs AC 12 -> Hit => [F:Thug A|HP-6|dead]
[F:Thug B|Close] @ Stab -> d:11 vs AC 15 -> Miss
```

This is terser. Use it when speed matters more than readability.


### C.5 Position and Range

Many systems track distance or positioning. Log it as a tag attribute on foe (or PC) tags.

**Common range bands:**

```
[F:Archer|HP 5|Far]
[F:Thug|HP 6|Close]
[F:Wolf|HP 4|Engaged]     (in melee / "In Reach")
```

**Tracking movement:**

When a combatant moves, show the change:

```
@(Thug A) Move Close -> Engaged
[F:Thug A|Engaged]
```

Or inline:

```
@(Thug A) Rushes in [Far->Close]
```

**Position shorthand** (when tracking grid or zone positions):

```
[F:Thug A|HP 6|Zone:Alley]
[F:Thug B|HP 4|Zone:Rooftop]
[PC:Alex|Zone:Street]
```

**When to skip position tracking:** If your system doesn't use range/zones, or if combat is purely abstract, just leave positions out. They're only useful when distance affects mechanics.


### C.6 Multi-Combatant Encounters

When more than two sides clash, structure matters most. Here's the pattern for complex fights.

**Encounter setup** (before R1, establish the battlefield):

```
S9 *Dockside ambush* [COMBAT]
[PC:Alex|HP 12|Engaged]
[N:Jordan|ally|HP 8|Close]
[F:Pirate Captain|HP 10|Close|armed|sword]
[F:Pirate×2|HP 4 each|Medium|armed|crossbow]
[F:Dock Rat|HP 2|Engaged|knife]
```

List all combatants with initial positions and key stats. This is your "combat snapshot"—the state of the field when initiative starts.

**Round structure** for multiple combatants:

```
R1
@ Slash at Dock Rat
d: d20+4=17 vs AC 10 -> Hit, 1d8=5
=> [F:Dock Rat|dead]

@(Pirate Captain) Charges at me [Close->Engaged]
d: d20+6=19 vs AC 14 -> Hit, 1d8+2=7
=> [PC:Alex|HP-7|HP 5|wounded]

@(Jordan) Fires crossbow at Pirate Captain
d: d20+3=12 vs AC 13 -> Miss
=> Bolt splinters a crate.

@(Pirate×2) Fire crossbows at Jordan
d: d20+2=15, d20+2=9 vs AC 11 -> 1 Hit, 1 Miss
d: 1d6=4 damage
=> [N:Jordan|HP-4|HP 4]

R2
...
```

**Scaling tips for many combatants:**

- **Group identical foes.** `[F:Pirate×2]` beats tracking Pirate A and Pirate B separately—unless they're in different positions or have different status.
- **Split groups when needed.** If one pirate moves and the other doesn't: `[F:Pirate 1|Close]` `[F:Pirate 2|Medium]`.
- **Kill the tags, keep the story.** Don't track HP for mooks if one hit kills them. Just note `[F:Rat|dead]`.
- **Use a roster.** For truly large battles (5+ combatants), write a roster block at the start and update it each round:

```
R3 Roster: [PC:Alex|HP 3] [N:Jordan|HP 4] [F:Captain|HP 4] [F:Pirate×1|HP 4]
```

### C.7 Combat Consequences and Aftermath

When combat ends, bridge back to the narrative:

```
[/COMBAT]
=> Two pirates dead, the captain fled into the fog. Jordan is wounded.
[N:Jordan|wounded|HP 4]
[Thread:Pirate Captain's Revenge|Open]
[PC:Alex|HP 5|Stress+1]
```

Use `=>` to summarize the outcome, update persistent tags, and open any new threads. This reconnects the mechanical combat to your ongoing story.

**Loot and rewards:**

```
=> I search the bodies.
tbl: d100=67 -> "Captain's sea chart"
=> A map showing a hidden cove. [E:PirateCove 1/4]
[PC:Alex|Gear+Sea Chart]
```


### C.8 Putting It All Together

Here's the same encounter at three levels of detail, so you can find your comfort zone.

#### Ultra-compact (shorthand)

```
S9 *Dock ambush* [COMBAT]
[PC:HP 12] [F:Captain|HP 10] [F:Pirate×2|HP 4] [F:Rat|HP 2]
R1 @Rat d:17≥10 S =>dead @(Cap) d:19≥14 Hit HP-7 @(Pir×2) d:15,9 vs11 1Hit [ally:Jordan HP-4]
R2 @Cap d:20≥13 S =>HP-6 @(Pir) d:8≥14 F @(Jordan) d:16≥11 Hit =>Pir dead
R3 @Cap d:15≥13 Hit =>Cap HP-4, flees [/COMBAT] =>Captain escapes
```

#### Standard (balanced)

```
S9 *Dockside ambush* [COMBAT]
[PC:Alex|HP 12] [N:Jordan|ally|HP 8]
[F:Pirate Captain|HP 10|Close] [F:Pirate×2|HP 4|Medium] [F:Dock Rat|HP 2|Engaged]

R1
@ Slash at Dock Rat
d: d20+4=17 vs AC 10 -> Hit => [F:Dock Rat|dead]

@(Captain) Charges, swings cutlass [Close->Engaged]
d: d20+6=19 vs AC 14 -> Hit, 7 dmg => [PC:Alex|HP 5]

@(Jordan) Crossbow at Captain
d: d20+3=12 vs AC 13 -> Miss

@(Pirate×2) Crossbows at Jordan
d: d20+2=15,9 vs AC 11 -> 1 Hit, 4 dmg => [N:Jordan|HP 4]

R2
@ Power attack on Captain
d: d20+4=20 vs AC 13 -> Hit, 8 dmg => [F:Captain|HP 2|wounded]

@(Captain) Desperate slash
d: d20+6=11 vs AC 14 -> Miss

@(Jordan) Second shot at remaining Pirate
d: d20+3=16 vs AC 11 -> Hit => [F:Pirate×1 dead]

@(Pirate) Drops crossbow, flees

R3
@ Chase the Captain
d: Athletics d6=3 vs TN 5 -> Fail
=> He leaps off the dock into a rowboat and vanishes into the fog.

[/COMBAT]
=> Two pirates dead, one fled, Captain escaped by sea.
[N:Jordan|wounded] [PC:Alex|HP 5|Stress+1]
[Thread:Pirate Captain's Revenge|Open]
```

#### Narrative-rich (detailed)

```
S9 *Dockside, fog rolling in off the harbor*

The crates provide cover, but not for long. A rat-faced man with a 
knife lunges from behind a barrel. Behind him, the Pirate Captain 
draws his cutlass with a grin. Two crossbowmen take position on the 
cargo stack.

[COMBAT]
[PC:Alex|HP 12|Engaged] [N:Jordan|ally|HP 8|Close]
[F:Pirate Captain|HP 10|Close|cutlass]
[F:Pirate×2|HP 4 each|Medium|crossbow]
[F:Dock Rat|HP 2|Engaged|knife]

R1
@ Sidestep the Dock Rat and slash
d: d20+4=17 vs AC 10 -> Hit, 1d8=5
=> The rat-faced man crumples. [F:Dock Rat|dead]

But I've left my flank open.

@(Pirate Captain) Charges across the dock, cutlass high [Close->Engaged]
d: d20+6=19 vs AC 14 -> Hit, 1d8+2=7
=> His blade bites deep across my ribs. I stagger back. [PC:Alex|HP 5|wounded]

PC: "Jordan—the crossbows!"

@(Jordan) Snaps off a shot at the Captain
d: d20+3=12 vs AC 13 -> Miss
=> The bolt sparks off a mooring chain.

@(Pirate×2) Fire at Jordan from the cargo stack
d: d20+2=15, d20+2=9 vs AC 11 -> 1 Hit, 1 Miss
d: 1d6=4
=> A bolt punches through Jordan's shoulder. [N:Jordan|HP 4|wounded]

N (Jordan): "I'm hit—still in it!"

R2
The Captain is close, bleeding confidence. I press the advantage.

@ Power attack on Captain
d: d20+4=20 vs AC 13 -> Critical Hit, 1d8×2=8
=> My sword catches him across the chest. He stumbles. [F:Captain|HP 2|staggered]

@(Captain) Wild swing in desperation
d: d20+6=11 vs AC 14 -> Miss
=> His cutlass sweeps wide—I duck under it.

@(Jordan) Pivots and fires at the crossbowmen
d: d20+3=16 vs AC 11 -> Hit, 1d6=5
=> One pirate tumbles off the cargo stack. [F:Pirate×1|dead]

The surviving pirate drops his crossbow and bolts into the fog.
[F:Pirate×1|fled]

R3
@ Chase the Captain before he escapes
d: Athletics d6=3 vs TN 5 -> Fail
=> He's too fast—vaults the dock railing and drops into a hidden 
rowboat. The fog swallows him in seconds.

[/COMBAT]

I press a hand to my ribs, breathing hard. Jordan limps over, 
shoulder dark with blood. The dock is quiet except for lapping water 
and the creak of ropes.

PC (Alex): "He'll be back."
N (Jordan): "Then we'd better be ready."

=> Two pirates dead, one fled, Captain escaped by sea.
[N:Jordan|wounded|HP 4] [PC:Alex|HP 5|Stress+1]
[Thread:Pirate Captain's Revenge|Open]
```


### C.9 Quick Reference

| Element | Format | Example |
|---------|--------|---------|
| Combat block | `[COMBAT]` / `[/COMBAT]` | Scene-level delimiters |
| Round | `R#` | `R1`, `R2`, `R3` |
| Foe tag | `[F:Name\|stats]` | `[F:Thug\|HP 6\|Close]` |
| Foe group | `[F:Name×#\|stats]` | `[F:Goblin×3\|HP 3 each]` |
| PC action | `@ Action` | `@ Slash at Thug` |
| Other actor | `@(Name) Action` | `@(Thug) Attacks PC` |
| Movement | `[Range->Range]` | `[Far->Close]` |
| Round roster | `R# Roster: [tags]` | `R3 Roster: [PC:HP 3] [F:Boss\|HP 4]` |
| Kill | `[F:Name\|dead]` | `[F:Thug A\|dead]` |
| Aftermath | `=> Summary` | `=> Captain fled, two thugs down.` |

### C.10 Choosing Your Level

**Use core notation only** (no module) when:
- Combat resolves in one or two rolls
- Your system is narrative-first (PbtA, Ironsworn)
- The fight isn't the interesting part

**Use rounds + actor prefixes** when:
- Combat lasts 3+ rounds
- Multiple combatants act each round
- Turn order matters to the story

**Use full foe tags + position tracking** when:
- Range/zones affect mechanics
- You're tracking 3+ combatants with different stats
- You want to reconstruct the fight later

**Use rosters** when:
- 5+ combatants on the field
- Stats are changing fast
- You need a snapshot at each round for clarity

### FAQ

**Q: Should I track initiative order?**
A: Only if your system uses it and it matters. Most solo players just go in logical order (threats first, then PC, then allies) or follow their system's initiative rules. If you want to note it: `R1 (Init: Captain 18, Alex 15, Jordan 12, Pirates 8)`.

**Q: What about reactions, interrupts, or out-of-turn actions?**
A: Log them where they happen, with a note: `@(Alex) Riposte (reaction)` or `@ Opportunity attack (interrupt)`. The parenthetical keeps it clear.

**Q: Do I need `[F:]` tags, or can I just use `[N:]`?**
A: Use whichever you prefer. `[F:]` is a convenience for separating combat stats from narrative NPC tags—it keeps your NPC index cleaner in long campaigns. For simple fights, `[N:]` works fine.

**Q: How do I handle area effects or multi-target attacks?**
A: List the targets and roll for each, or roll once and apply to all:

```
@ Fireball targeting Goblin×3
d: 8d6=28, DC 14 Dex save
d: Goblin 1: 12≤14 F, Goblin 2: 17≥14 S, Goblin 3: 8≤14 F
=> Two goblins incinerated. One dodged, half damage. [F:Goblin×1|HP 2|singed]
```

**Q: What about vehicle combat, chase scenes, or mass battles?**
A: This module covers personal-scale combat. Those scenarios may warrant their own modules—but the principles here (round markers, actor prefixes, position tracking) will apply.

### Credits

This module was written to address some [clarifications asked](https://www.reddit.com/r/Solo_Roleplaying/comments/1qxkee5/comment/o4808nn/) by u/Electorcountdonut and it's built upon [the excellent examples](https://www.reddit.com/r/Solo_Roleplaying/comments/1qxkee5/comment/o4dmk5p/) of u/AvernusIsAFurnace.