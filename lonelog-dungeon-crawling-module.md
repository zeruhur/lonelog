---
title: "Lonelog: Dungeon Crawling Module"
subtitle: "Optional Room Tracking for Dungeon Exploration"
author: Roberto Bisceglie
version: 0.1.0
status: draft
license: CC BY-SA 4.0
lang: en
requires: Lonelog Core 1.0.0
---

## Dungeon Crawling Module

### Why a Separate Module?

Lonelog was built for **narrative-driven solo play**—the kind where you care more about *what happened and why* than *where am I and what do I have left*. Dungeon crawling pulls in a different direction: spatial relationships matter, rooms accumulate state, and you're constantly asking "did I already loot that chest?"

That tension is real. Text notation is never going to replace a good map. But it *can* help you track **room state**—what you found, what you cleared, what's still waiting behind a locked door—alongside the narrative Lonelog already handles well.

That's what this module does. One new tag, a few conventions, and you're set.

### What This Module Adds

A single new persistent element: the **Room tag** `[R:]`. That's it.

Everything else—actions, rolls, oracle questions, consequences, threads, clocks—stays exactly the same. You're just adding rooms to the vocabulary of things Lonelog can track.

### The Room Tag

**Format:** `[R:ID|status|description]`

```
[R:1|unexplored|guard room]
[R:2|cleared|library]
[R:3|locked|heavy iron door]
```

The Room tag works like any other Lonelog persistent element. It has an ID, a status, and optional descriptive details. You tag it when something changes, and you can search for it later.

#### Room Status

Status tells you the current state of a room at a glance. Use whatever terms fit your game, but here are common ones:

```
[R:1|unexplored]          Haven't entered yet
[R:1|active]              Currently exploring
[R:1|cleared]             Enemies defeated
[R:1|cleared, looted]     Enemies defeated, treasure taken
[R:1|locked]              Can't get in yet
[R:1|trapped]             Known hazard
[R:1|safe]                Verified clear
[R:1|collapsed]           No longer accessible
```

You can combine statuses when it makes sense: `cleared, looted` tells you both that the fight is over *and* there's nothing left to grab.

#### Updating Room Status

Same patterns as other Lonelog tags. When a room's state changes, restate it:

```
[R:1|unexplored]

... you enter and fight ...

[R:1|cleared]

... you search ...

[R:1|cleared, looted]
```

Or use the `+`/`-` shorthand from core Lonelog if you prefer:

```
[R:1|+looted]
```

#### Room Connections

To record which rooms connect where, use the `exits` keyword inside the tag:

```
[R:1|cleared|guard room|exits N:R2, E:R3, S:R4]
```

Read this as: "Room 1 is cleared, it's a guard room, and it has exits north to Room 2, east to Room 3, and south to Room 4."

**Directional shortcuts:** `N`, `S`, `E`, `W`, `NE`, `NW`, `SE`, `SW`, `U` (up), `D` (down).

If direction doesn't matter, just list the connections:

```
[R:5|unexplored|exits R4, R6, R7]
```

**You don't have to record exits at all.** If you're keeping a visual map (and you probably should—see *Maps and Lonelog* below), the exits live on the map and you only need the Room tag for status. The `exits` keyword is there for when you want a fully text-based record, or when you need to note a specific connection in your log:

```
=> I find a hidden passage behind the bookshelf!
[R:3|exits E:R7(secret)]
```

#### Room Descriptions

The description field is optional and brief—just enough to jog your memory:

```
[R:1|cleared|guard room]
[R:2|active|library, candles still lit]
[R:3|unexplored|sounds of water]
```

For richer descriptions, use regular Lonelog narrative:

```
[R:4|active|ritual chamber]
=> The air hums with energy. A circle of runes glows faintly on the floor.
```

#### Reference Tags

Just like NPCs and locations in core Lonelog, use `#` to reference a room you've already described:

```
[R:3|cleared|armory|exits N:R2, W:R4]    (first mention)

... later ...

[#R:3]                                    (reference)
```

### The Dungeon Status Block

When you sit down for a new session, you probably want a snapshot: which rooms have I cleared? Where haven't I been? What's still locked? The **Dungeon Status Block** gives you that at a glance.

Place it at the top of a session, before your first scene:

```
=== Dungeon Status ===
[R:1|cleared, looted|entry hall|exits N:R2, E:R3]
[R:2|cleared|guard room|exits S:R1, W:R5]
[R:3|active|library|exits W:R1]
[R:4|unexplored]
[R:5|locked|heavy door|exits E:R2]
```

**This is a convenience, not a requirement.** If your dungeon has three rooms, you don't need a status block—just tag rooms as you go. But for larger dungeons, or when you're picking up a session after a break, it's a quick way to orient yourself.

Update the block at session end (or at the start of the next session) to reflect what changed.

### Using Room Tags in Play

Here's how Room tags fit into a normal Lonelog scene:

```
S5 *Entering the north corridor*

@ Open the door to the next room
? Is it locked?
-> No (d6=5)
=> The door swings open easily.

[R:4|active|storage room, dusty shelves|exits S:R2, E:R5]

@ Search the shelves
d: Investigation d6=5 vs TN 4 -> Success
=> I find a rusty key behind a loose brick.
(note: might open R5?)

? Are there enemies here?
-> No, and... (d6=6)
=> The room is completely undisturbed. Looks like nobody's been here in years.

[R:4|cleared, looted]
```

Notice how the Room tag fits naturally among the other notation. You're not learning a new system—you're adding one more trackable element to the system you already know.

#### Rooms as Scene Headers

You can use a Room tag directly in your scene header for context:

```
S5 [R:4|active] *Storage room, dusty shelves*
```

This is compact and tells you exactly where the scene takes place. Some players prefer this to separate scene descriptions and room tags.

#### Generated Dungeons

If you're generating the dungeon as you go (using random tables or an oracle), record the generation alongside the Room tag:

```
@ Open the east door
tbl: d20=14 -> "Large room, two exits"

? What's inside?
tbl: d100=67 -> "Library with a trapped chest"

[R:6|active|library, trapped chest|exits W:R3, N:R7]
```

The generation rolls tell you *how* you discovered the room. The Room tag tells you *what it is now*.

### Maps and Lonelog

Let's be direct: **a visual map is almost always better than text for spatial relationships.** Graph paper, a digital tool, a quick sketch on a napkin—whatever works. The Room tag's job isn't to replace your map. It's to track **state** that a map handles poorly: whether a room is cleared, what you found there, how its status changed over the course of play.

**The recommended approach:**

- **Map** handles layout, spatial relationships, and navigation
- **Room tags** handle state, status changes, and narrative context
- **Core Lonelog** handles everything else (actions, rolls, consequences, story)

Mark room numbers on your map. Use those same numbers in your Room tags. Now your map and your log reference each other seamlessly.

```
S7 [R:4] *Checking my map for Room 4*

@ Search the altar
d: Investigation d6=6 vs TN 4 -> Success
=> Secret compartment! [Thread:Cult Ritual|Open]
[R:4|cleared, looted]

(note: mark R4 as cleared on map)
```

If you really want a **fully text-based** dungeon log with no separate map, the `exits` keyword lets you reconstruct the layout from your notes. But this is the exception, not the recommendation.

### Complete Example

```
=== Session 3: The Orc Warren ===
[Date]        2025-10-15
[Duration]    1h30
[Recap]       Found the warren entrance. Need to recover the stolen relic.

=== Dungeon Status ===
[R:1|cleared, looted|entry cave|exits N:R2, E:R3]
[R:2|unexplored]
[R:3|unexplored]

S7 *North passage from entry cave*

@ Approach Room 2 quietly
d: Stealth d6=4 vs TN 4 -> Success
=> I creep forward unseen.

[R:2|active|barracks, stench of sweat|exits S:R1, W:R4, N:R5]

? How many orcs are inside?
tbl: d6=3 -> "Three enemies"
=> Three orcs, two eating, one sharpening a blade.
[N:Orc1|armed|eating]
[N:Orc2|armed|eating]
[N:Orc3|armed|alert]

@ Ambush the alert orc first
d: Attack 2d6=9 vs TN 7 -> Success
=> Solid hit! He staggers back.

@ Press the attack before the others react
d: Attack 2d6=6 vs TN 7 -> Fail
=> He parries! The other two grab their weapons.

? Do they fight or flee?
-> Yes, and... (d6=6)
=> They fight AND one blows a horn. Reinforcements coming!
[Clock:Reinforcements 0/4]

@ Finish the fight quickly
d: Attack 2d6=10 vs TN 7 -> Success
=> I cut through them before help arrives.
[R:2|cleared]
[Clock:Reinforcements 1/4]

@ Search the barracks
? Anything useful?
tbl: d20=8 -> "Rations and a crude map"
=> A rough map scratched on hide. Shows rooms to the west!
[R:2|cleared, looted]
[R:4|unexplored|marked on orc map]
[R:5|unexplored|marked on orc map]
(note: update my map with R4 and R5)

S8 *Heading west toward Room 4*

@ Move quickly before reinforcements arrive
[Clock:Reinforcements 2/4]

[R:4|active|crude shrine, flickering torches|exits E:R2, N:R6]

? Is the relic here?
-> No, but... (d6=3)
=> Not the relic, but ritual markings on the walls. The orcs are
worshipping something deeper in the warren.
[Thread:What do the orcs worship?|Open]

@ Search the shrine
d: Investigation d6=3 vs TN 5 -> Fail
=> Nothing else useful. I need to press on.
[R:4|cleared]

? Do I hear reinforcements yet?
-> Yes, but... (d6=4)
=> Distant shouts from the south. They went to R1 first—I have a little time.
[Clock:Reinforcements 3/4]

@ Rush north to R6
=> I have to find that relic before they find me.
```

### When to Use This Module

**Use Room tags when:**

- Running a published dungeon or generated dungeon
- You want to track which rooms are cleared, looted, or locked
- You're picking up a session mid-dungeon and need a status recap
- You want a text-searchable record of dungeon state

**Use a visual map (with or without Room tags) when:**

- Spatial relationships and navigation matter
- The dungeon is large or complex
- Tactical positioning is important
- You enjoy the mapping part of dungeon crawling

**Stick to standard Lonelog when:**

- The dungeon is more narrative backdrop than mechanical challenge
- You're moving through spaces quickly without tracking state
- Room-by-room status doesn't matter to your game

### Quick Reference

```
[R:ID|status|description|exits DIR:ID, DIR:ID]    Room tag (full)
[R:ID|status]                                      Room tag (minimal)
[#R:ID]                                            Room reference

Status: unexplored, active, cleared, looted, locked, trapped, safe

Exits: N, S, E, W, NE, NW, SE, SW, U, D
       or just list room IDs without direction
```

### What This Module Doesn't Cover

This module focuses on room state. Two related areas—**combat tracking** (multiple enemies, HP, initiative) and **resource management** (torches, rations, ammunition)—are common in dungeon crawling but apply broadly to other styles of play too. They deserve their own modules and will be addressed separately.

For now, use core Lonelog's existing tools: NPC tags for enemies (`[N:Orc1|wounded]`), PC tags for your resources (`[PC:Alex|HP 12|Torches 3]`), and clocks or timers for ongoing pressures (`[Clock:Reinforcements 2/4]`, `[Timer:Torchlight 3]`).

### Credits

This module is designed to address the [request](https://www.reddit.com/r/Solo_Roleplaying/comments/1qxkee5/comment/o4v01rk/) of u/Jollto13 on r/Solo_Roleplaying