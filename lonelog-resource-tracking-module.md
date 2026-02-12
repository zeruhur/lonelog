---
title: "Lonelog: Resource Tracking Module"
subtitle: "Inventory, Supplies, and Wealth Notation"
author: Roberto Bisceglie
version: 0.1.0 (Draft)
license: CC BY-SA 4.0
lang: en
parent: Lonelog v1.0.0
requires: Core Notation (§3), Persistent Elements (§4.1), Progress Tracking (§4.2)
---

## Resource Tracking Module

### Overview

Some games don't care what's in your pack. Others treat every torch, every ration, every last arrow as a decision that matters. This module is for the second kind.

Core Lonelog already handles light resource tracking — you can put `Gear:Flashlight,Notebook` inside a `[PC:]` tag and call it a day. That works fine when resources are flavor. But when your game makes resource management a *mechanic* — when running out of torches in a dungeon means something, when the Usage Die ticking down creates real tension, when you need to know exactly how many silver pieces you have left — you need more structure.

That's what this module provides: a dedicated notation layer for tracking resources as they flow in and out of your game.

### What This Module Adds

One new tag and three conventions:

| Addition | Purpose | Example |
|----------|---------|---------|
| `[Inv:]` tag | Track individual items with quantity and properties | `[Inv:Torch\|3]` |
| Supply notation | Abstract resource levels inside `[PC:]` | `[PC:Kael\|Supply d8]` |
| Wealth notation | Currency and trade tracking | `[Wealth:Gold 45\|Silver 12]` |
| Resource Status Block | Snapshot of current resources at session boundaries | See §RSB |

**No new core symbols.** Everything works with `@`, `d:`, `->`, `=>`, and existing tag syntax.

### Design Principles

**Track what the game tracks.** If your system uses Usage Dice, use the Usage Die notation. If it counts individual arrows, count individual arrows. If it handwaves supplies, don't invent tracking that isn't there.

**Separate what you carry from who you are.** The `[PC:]` tag describes your character — HP, stress, conditions, abstract resources that feel like stats. The `[Inv:]` tag describes your stuff — concrete, countable things that come and go. This separation keeps both tags readable as your campaign grows.

**Record changes at the point of fiction.** Don't maintain a separate inventory spreadsheet that you update silently. Show resources changing *when they change*, inline with the actions and consequences that cause it. Your log should tell the story of your resources, not just their current state.

---

### 1. The Inventory Tag: `[Inv:]`

The `[Inv:]` tag tracks a specific, concrete item or resource. It's the thing you can pick up, use, drop, trade, or lose.

**Format:**

```
[Inv:Item|quantity|properties]
```

**Simple items:**

```
[Inv:Torch|3]
[Inv:Rope|1|50ft]
[Inv:Healing Potion|2|magical|restores d8 HP]
[Inv:Rations|5|days]
[Inv:Arrow|12]
```

**Unique or singular items** (no quantity needed):

```
[Inv:Skeleton Key|unique]
[Inv:Father's Compass|quest]
[Inv:Map to the Ruins]
```

The `quantity` field is a plain number. Properties after the quantity are freeform — use them for anything your game cares about: weight, condition, magical status, ammunition type, whatever matters.

#### 1.1 Gaining Items

When you acquire something, introduce it with a full `[Inv:]` tag, just like introducing an NPC with `[N:]`:

```
@ Search the chest
d: Investigation d6=5 vs TN 4 -> Success
=> I find supplies! [Inv:Torch|4] [Inv:Rope|1|50ft] [Inv:Gold|25]

@ Loot the fallen guard
=> [Inv:Short Sword|1|rusty] [Inv:Rations|2|days]

tbl: d100=67 -> "A strange amulet"
=> [Inv:Bone Amulet|1|unknown|magical?]
```

**Multiple items at once** — just list them. No special syntax needed:

```
=> The merchant's pack contains:
   [Inv:Torch|6] [Inv:Rope|2|50ft each] [Inv:Rations|10|days]
   [Inv:Flint & Steel|1] [Inv:Waterskin|1|full]
```

#### 1.2 Consuming and Losing Items

This is where the module stays deliberately flexible. Two approaches, same result — choose what fits your flow.

**Approach A: Inline with consequences**

Depletion happens *inside* the `=>` line, as part of the fiction:

```
=> The tunnel is pitch dark. I light a torch. [Inv:Torch|3→2]
=> I bandage the wound with my last healing potion. [Inv:Healing Potion|0|depleted]
=> Arrow flies true. [Inv:Arrow|12→11]
```

**Approach B: Standalone update**

Depletion gets its own line, separate from narrative:

```
=> The tunnel is pitch dark. I light a torch.
[Inv:Torch-1]

=> I bandage the wound.
[Inv:Healing Potion-1]
```

**Which to use?** Approach A is more compact and keeps resource flow visible within the fiction. Approach B is clearer when multiple things change at once, or when you want to visually separate narrative from bookkeeping. Many players mix both depending on context.

**Shorthand for quantity changes:**

```
[Inv:Torch-1]         (consumed one — quantity decreases by 1)
[Inv:Torch+2]         (found two more — quantity increases by 2)
[Inv:Torch|0]         (explicit: none left)
[Inv:Torch|3→1]       (explicit: was 3, now 1)
[Inv:Torch|depleted]  (out — marks the item as gone)
```

#### 1.3 Item State Changes

Items don't just appear and disappear — they break, get repaired, become cursed, run out of charges. Use properties to track this:

```
[Inv:Short Sword|1|rusty]              (initial state)
[Inv:Short Sword|1|rusty→repaired]     (state change with arrow)
[Inv:Short Sword|1|+enchanted]         (added property)
[Inv:Short Sword|1|-rusty|+sharpened]  (removed and added)
```

**Condition shorthand:**

```
[Inv:Lantern|1|broken]
[Inv:Shield|1|cracked]
[Inv:Rations|3|spoiled]
[Inv:Wand|1|charges 2/5]
```

This mirrors the `+`/`-` convention already used for NPC status updates in core Lonelog.

#### 1.4 Reference Tags for Items

Just like NPCs, use `#` for items already established:

```
[Inv:Bone Amulet|1|unknown|magical?]   (first mention — full details)

... later in the log ...

@ Examine the amulet more closely
d: Arcana d6=6 vs TN 5 -> Success
=> [#Inv:Bone Amulet] — it's a ward against undead!
[Inv:Bone Amulet|1|Ward of the Dead|+identified]
```

#### 1.5 Grouped and Bulk Items

Some games track bundles rather than individual items. Use the `×` multiplier or descriptive grouping:

```
[Inv:Arrow×20]                    (bundle notation)
[Inv:Adventuring Kit|1|contains: rope, pitons, torch×2, rations×3]
[Inv:Quiver|1|Arrow×15]          (container with contents)
```

For slot-based inventory systems:

```
[Inv:Slot 1|Short Sword]
[Inv:Slot 2|Shield|cracked]
[Inv:Slot 3|Torch×3]
[Inv:Slot 4|empty]
```

---

### 2. Abstract Supply Tracking

Not every game counts individual items. Many modern solo systems use abstract mechanics to represent "how well-supplied are you?" — Usage Dice (Black Hack, Macchiato Monsters), Supply tracks (Ironsworn), or simple levels (well-supplied / running low / desperate).

These feel more like character stats than inventory, so they live in the `[PC:]` tag alongside HP, Stress, and other abstract attributes.

#### 2.1 Usage Dice

The Usage Die is a staple of OSR-adjacent solo play. You have a die representing supply level — roll it when you use a resource. On a 1–2, the die steps down. When it steps below d4, the resource is gone.

**Format:**

```
[PC:Kael|Supply d8]
[PC:Kael|Torchlight d6]
[PC:Kael|Ammo d10]
```

**Stepping down:**

```
@ Make camp, use supplies
d: Supply d8=2 -> Step down!
=> Supplies dwindling. [PC:Kael|Supply d8→d6]

@ Fire another volley
d: Ammo d6=1 -> Step down!
=> Running low on arrows. [PC:Kael|Ammo d6→d4]

@ Light another torch
d: Torchlight d4=2 -> Depleted!
=> Last torch sputters out. [PC:Kael|Torchlight depleted]
```

**The step-down chain:** `d12 → d10 → d8 → d6 → d4 → depleted`

#### 2.2 Supply Tracks

Some systems use numbered tracks for supply — similar to progress tracks but counting down as resources are spent.

**Format:**

```
[PC:Kael|Supply 5/5]
[PC:Kael|Momentum 3/10]
```

**Spending and recovering:**

```
=> I make camp and eat. [PC:Kael|Supply 5→4]
=> I forage successfully. [PC:Kael|Supply 4→5]
=> Desperate — I eat the last of it. [PC:Kael|Supply 1→0|starving]
```

This is functionally the same as core Lonelog's `[Timer:]` used for resources. The difference is semantic: a Timer is a narrative pressure device, while a Supply track inside `[PC:]` is a character stat. Use whichever framing matches your game.

#### 2.3 Qualitative Levels

For games that don't use numbers at all — or when you want to track a resource loosely:

```
[PC:Kael|Supplies:abundant]
[PC:Kael|Supplies:adequate]
[PC:Kael|Supplies:low]
[PC:Kael|Supplies:critical]
[PC:Kael|Supplies:depleted]
```

**Updating:**

```
=> After three days in the wastes, food is scarce.
[PC:Kael|Supplies:abundant→low]
```

You can define your own levels. These aren't hard-coded — use whatever vocabulary your game provides or that feels right.

---

### 3. Wealth and Currency

Money behaves differently from gear. You don't usually track each coin as an "item" — you track totals, and those totals change through spending, earning, looting, and trading. This section provides notation for that.

#### 3.1 The Wealth Tag

For games with concrete currency, use the `[Wealth:]` tag:

**Format:**

```
[Wealth:Gold 45|Silver 12|Copper 30]
[Wealth:Credits 1500]
[Wealth:Caps 87]
```

**Earning and spending:**

```
@ Sell the jeweled dagger to the merchant
d: Persuasion d6=5 vs TN 4 -> Success
=> Good price! [Wealth:Gold+15]

@ Buy rations and a new rope
=> [Wealth:Gold-8] [Inv:Rations|5|days] [Inv:Rope|1|50ft]
```

**Full state vs. delta updates:**

```
[Wealth:Gold 45]       (explicit total)
[Wealth:Gold+15]       (earned 15)
[Wealth:Gold-8]        (spent 8)
[Wealth:Gold 45→52]    (was 45, now 52)
```

#### 3.2 Abstract Wealth

Some games don't count coins — they use wealth levels or resource rolls:

```
[PC:Kael|Wealth:comfortable]
[PC:Kael|Wealth d8]               (Usage Die for wealth)
[PC:Kael|Resources 3/5]           (track-based)
```

These live in `[PC:]` rather than `[Wealth:]`, because abstract wealth feels more like a stat than a ledger.

#### 3.3 Trade and Barter

For transactions, record both sides:

```
@ Trade the amulet for passage
=> [Inv:Bone Amulet|depleted] → [Thread:Passage to Northport|Open]

@ Barter rations for information
=> [Inv:Rations-2] The fisherman tells me about the sea caves.
```

No special syntax needed — the existing consequence notation handles trades naturally. The key is recording *what left* and *what arrived*.

---

### 4. Resource Events

Resources interact with the rest of your game. This section shows common patterns — how resources connect to actions, oracle questions, dungeon exploration, and combat.

#### 4.1 Resource Checks

When the game asks "do you have enough?":

```
@ Cross the frozen river
? Do I have enough rope?
-> Yes (checking: [#Inv:Rope] 50ft — river is ~30ft wide)
=> I anchor the rope and cross safely. [Inv:Rope|1|50ft|frayed]

@ Camp in the wilderness
d: Supply d8=1 -> Step down!
=> Food's running low. [PC:Kael|Supply d8→d6]
? Do I find water nearby?
-> No, but...
=> A dry streambed — if I follow it, maybe tomorrow.
[Timer:Dehydration 2]
```

#### 4.2 Scarcity as Oracle Modifier

Some systems modify oracle likelihood based on resource state. Note it:

```
? Can I find more arrows in the ruins? (Likelihood: Unlikely — remote area)
-> Yes, but... (d6=4)
=> I find a quiver with only 3 usable arrows. [Inv:Arrow+3]

? Is there food in this abandoned camp? (Likelihood: Very Unlikely — old camp)
-> No, and... (d6=1)
=> The food is rotted and the smell attracts something. [Clock:Predator 1/4]
```

#### 4.3 Resources in Combat

When the Combat Module is in use, resource consumption integrates naturally:

```
[COMBAT]
R1
@ Fire bow at Orc 1
d: Ranged d6=5 vs TN 4 -> Success
=> Arrow hits! [F:Orc 1|HP-3] [Inv:Arrow-1]

R2
@ Throw last flask of oil
d: Ranged d6=3 vs TN 4 -> Fail
=> Missed! The oil splatters uselessly. [Inv:Oil Flask|depleted]
[/COMBAT]
```

#### 4.4 Resources in Dungeon Crawling

When the Dungeon Crawling Module is in use, resource depletion tracks alongside room exploration:

```
[R:Room4|active|Fungal cavern|exits E:Room5, W:Room2]

@ Navigate the cavern carefully
d: Survival d6=4 vs TN 4 -> Success
=> I find a path through. Torch is getting low.
[Inv:Torch|2→1] [Timer:Torchlight 3]

@ Search for useful fungi
tbl: d6=5 -> "Glowing moss — edible"
=> [Inv:Edible Moss|3|restores 1 HP each]
[R:Room4|cleared|looted]
```

---

### 5. The Resource Status Block

For long sessions or campaigns where resources matter, a snapshot at session boundaries helps you pick up where you left off — like the Dungeon Status Block in the Dungeon Crawling Module, but for your pack and purse.

**Format:**

```
--- RESOURCES ---
[PC:Kael|HP 12/15|Supply d6|Stress 2]
[Wealth:Gold 52|Silver 8]
[Inv:Short Sword|1|sharpened]
[Inv:Shield|1|cracked]
[Inv:Torch|2]
[Inv:Rations|3|days]
[Inv:Rope|1|50ft|frayed]
[Inv:Healing Potion|1|restores d8 HP]
[Inv:Arrow|9]
[Inv:Bone Amulet|1|Ward of the Dead]
--- /RESOURCES ---
```

**When to use it:**

- At the **end of a session** to freeze state
- At the **start of next session** as a recap
- **Before a major expedition** (dungeon dive, long journey, dangerous mission)
- After **significant loot or loss** — a natural checkpoint

**When to skip it:**

- Resources aren't mechanically important in your game
- The session is short and changes are minimal
- You can reconstruct state easily from the log

**Analog format:**

```
=== RESOURCES ===
PC:  Kael | HP 12/15 | Supply d6 | Stress 2
Wealth: Gold 52 | Silver 8
Inv: Short Sword (sharpened), Shield (cracked)
     Torch ×2, Rations ×3 days
     Rope 50ft (frayed), Healing Potion ×1
     Arrow ×9, Bone Amulet (Ward of the Dead)
=== /RESOURCES ===
```

The analog format is more compact — you'll develop your own shorthand for paper. The important thing is capturing the snapshot, not matching the format exactly.

---

### 6. Cross-Module Interactions

This module is designed to work alongside the Combat Module and Dungeon Crawling Module. Here's how they fit together.

| Situation | Module(s) Used | Key Tags |
|-----------|---------------|----------|
| Dungeon exploration with supply pressure | DCM + Resource | `[R:]`, `[Inv:]`, `[Timer:]` |
| Combat with ammunition tracking | Combat + Resource | `[F:]`, `[Inv:]`, `@(Name)` |
| Trading in a settlement | Resource only | `[Inv:]`, `[Wealth:]`, `[N:]` |
| Full dungeon crawl with fights | All three | Everything |

**Example: Full dungeon crawl turn with all three modules**

```
--- RESOURCES ---
[PC:Kael|HP 12/15|Supply d6]
[Inv:Torch|2] [Inv:Arrow|9] [Inv:Healing Potion|1]
[Wealth:Gold 52]
--- /RESOURCES ---

S5 *Entering the crypt*
[R:Crypt1|active|Entry hall, bones everywhere|exits N:Crypt2, E:Crypt3]

@ Light a torch and move in
[Inv:Torch-1] [Timer:Torchlight 6]

? Are there enemies?
-> Yes, and... (d6=6)
=> Skeletons rise from the bone piles!
[F:Skeleton×3|HP 3 each|Close]

[COMBAT]
R1
@ Fire at nearest skeleton
d: Ranged d6=5 vs TN 4 -> Success
=> Arrow shatters its skull! [F:Skeleton×3→2] [Inv:Arrow-1]

@(Skeleton) Charge at me
d: Attack d6=3 vs TN 4 -> Fail
=> Clumsy swing, I dodge.

R2
@ Draw sword, attack
d: Melee d6=6 vs TN 4 -> Success
=> Cut clean through! [F:Skeleton×2→1]

@ Finish the last one
d: Melee d6=4 vs TN 4 -> Success
=> The crypt goes quiet. [F:Skeleton×0]
[/COMBAT]

@ Search the room
tbl: d20=14 -> "A locked chest"
? Can I pick the lock?
d: Lockpicking d6=5 vs TN 5 -> Success
=> Inside: [Inv:Gold Bracelet|1|valuable] [Wealth:Gold+10]
[R:Crypt1|cleared|looted]
[Timer:Torchlight-1]

@ Move north toward Crypt2
[R:Crypt2|active|Ritual chamber|exits S:Crypt1, D:CryptDeep]
```

---

### 7. System Adaptations

Different games handle resources differently. Here's how the module adapts to popular systems.

#### 7.1 The Black Hack / Usage Dice Systems

Usage Dice are the primary resource mechanic. Track them in `[PC:]`:

```
[PC:Varn|Torches d8|Rations d6|Ammo d10|HP 14/18]

@ Set up camp
d: Rations d6=2 -> Step down!
=> [PC:Varn|Rations d6→d4]
(note: one more step-down and they're gone)
```

#### 7.2 Ironsworn / Supply Track

Supply is a single stat from 0–5:

```
[PC:Kael|Supply 4/5|Health 4/5|Spirit 3/5|Momentum 6/10]

@ Undertake a Journey — Sojourn at the settlement
d: Action=5+Heart=2=7 vs Challenge=3,8 -> Weak Hit
=> I resupply but time passes. [PC:Kael|Supply+2|Momentum-1]
```

#### 7.3 OSR / Encumbrance Systems

Slot-based inventory is common in OSR games:

```
[Inv:Slot 1|Sword]
[Inv:Slot 2|Shield]
[Inv:Slot 3|Torch×3]
[Inv:Slot 4|Rations×4]
[Inv:Slot 5|Rope 50ft]
[Inv:Slot 6-10|empty]
(note: 10 slots max, STR-based encumbrance)

@ Pick up the golden idol
=> [Inv:Slot 6|Golden Idol|heavy|occupies 2 slots]
[Inv:Slot 7|occupied]
(note: at 7/10 slots — movement penalty at 8+)
```

#### 7.4 Fate / Narrative-First Systems

Resources are aspects or stress tracks, not inventories:

```
[PC:Sable|Aspect:Well-Provisioned]
[PC:Sable|Aspect:Well-Provisioned→Running Low]
[PC:Sable|Aspect:Running Low|invoked against me]
```

Or simply note it in prose and skip the `[Inv:]` tag entirely. If your game doesn't mechanize resources, neither should your notation.

#### 7.5 Survival Horror / Scarcity Games

When every bullet counts:

```
[Inv:9mm Round|7]
[Inv:First Aid Kit|1|uses 2/3]
[Inv:Flashlight|1|battery d4]

@ Fire at the creature
d: Firearms d6=4 vs TN 4 -> Success
=> Hit! [Inv:9mm Round-1]

@ Patch up the wound
=> [Inv:First Aid Kit|1|uses 2→1] [PC:Casey|HP+3]

@ Check the flashlight
d: Battery d4=1 -> Step down!
=> Flickering badly. [Inv:Flashlight|1|battery d4→depleted]
=> Darkness. [Clock:Panic 1/4]
```

---

### 8. Best Practices

**Do: Record resource changes at the point of fiction**

```
✔ @ Light a torch to see
  => The cavern reveals a narrow passage. [Inv:Torch-1]
```

**Do: Use the Resource Status Block at session boundaries**

```
✔ --- RESOURCES ---
  [PC:Kael|HP 12/15|Supply d6]
  [Inv:Torch|2] [Inv:Arrow|9]
  --- /RESOURCES ---
```

**Do: Match your notation to your system's resource model**

```
✔ Usage Die game → [PC:|Supply d8]
✔ Counting game → [Inv:Arrow|12]
✔ Narrative game → [PC:|Aspect:Well-Provisioned]
```

**Don't: Track resources the game doesn't care about**

```
✗ [Inv:Bootlaces|2|leather]     (unless your game literally tracks this)

✔ Only track what creates meaningful decisions or tension
```

**Don't: Let bookkeeping overwhelm the fiction**

```
✗ => I fight the orc.
  [Inv:Arrow-1] [Inv:Arrow|11] [PC:HP-2] [PC:HP 13]
  [F:Orc|HP-4] [Clock:Alert+1] [Timer:Torch-1]
  (This is a spreadsheet, not a story)

✔ => Arrow finds its mark — the orc staggers.
  [Inv:Arrow-1] [F:Orc|HP-4]
  (Track what matters this beat. Batch updates for the rest in a status block.)
```

**Don't: Silently update resources outside the log**

```
✗ (I subtracted 3 arrows but didn't write it down anywhere)

✔ Show the change, even briefly: [Inv:Arrow-3]
```

---

### 9. Quick Reference

#### Tags

| Tag | Purpose | Example |
|-----|---------|---------|
| `[Inv:Item\|qty\|props]` | Concrete inventory item | `[Inv:Torch\|3]` |
| `[#Inv:Item]` | Reference previously established item | `[#Inv:Bone Amulet]` |
| `[Inv:Item+N]` / `[Inv:Item-N]` | Quantity change (gain/lose) | `[Inv:Arrow-1]` |
| `[Inv:Item\|qty→qty]` | Explicit quantity transition | `[Inv:Torch\|3→2]` |
| `[Inv:Item\|depleted]` | Item fully consumed/gone | `[Inv:Oil Flask\|depleted]` |
| `[Wealth:Currency N]` | Concrete currency total | `[Wealth:Gold 45]` |
| `[Wealth:Currency+N]` | Currency earned | `[Wealth:Gold+15]` |
| `[Wealth:Currency-N]` | Currency spent | `[Wealth:Gold-8]` |

#### In `[PC:]` Tags (Abstract Resources)

| Pattern | Purpose | Example |
|---------|---------|---------|
| `Supply d8` | Usage Die resource | `[PC:Kael\|Supply d8]` |
| `Supply d8→d6` | Usage Die step-down | `[PC:Kael\|Supply d8→d6]` |
| `Supply 4/5` | Supply track | `[PC:Kael\|Supply 4/5]` |
| `Supplies:low` | Qualitative level | `[PC:Kael\|Supplies:low]` |
| `Wealth d8` | Abstract wealth (Usage Die) | `[PC:Kael\|Wealth d8]` |
| `Aspect:Running Low` | Narrative resource state | `[PC:Sable\|Aspect:Running Low]` |

#### Resource Status Block

```
--- RESOURCES ---
[PC:Name|stats]
[Wealth:currencies]
[Inv:items...]
--- /RESOURCES ---
```

#### Usage Die Step-Down Chain

```
d12 → d10 → d8 → d6 → d4 → depleted
```

---

### FAQ

**Q: When should I use `[Inv:]` vs. just putting gear in `[PC:]`?**
A: If resources are mechanically important and change often, use `[Inv:]`. If they're background flavor or you're only tracking one or two things, `[PC:Name|Gear:Sword,Shield]` is fine. There's no wrong answer — use what keeps your log clear.

**Q: Do I need the `[Wealth:]` tag, or can I put money in `[Inv:]`?**
A: Either works. `[Wealth:]` is cleaner for multi-currency systems (gold/silver/copper) and for tracking money that flows frequently. `[Inv:Gold|45]` works fine for simpler games or if you're already using `[Inv:]` for everything.

**Q: Should I write a Resource Status Block every session?**
A: Only if it helps you. If resources are central to your game (dungeon crawls, survival horror), a block at session start/end saves you from scrolling back. If resources rarely change or aren't mechanically important, skip it.

**Q: What if I'm playing a game with no resource mechanics at all?**
A: Then you probably don't need this module. Core Lonelog's `[PC:]` tag with a `Gear:` field is more than enough. This module exists for games where resources create tension and decisions.

**Q: Can I combine `[Inv:]` with the Dungeon Crawling Module's `[R:]` tags?**
A: Absolutely — they're designed to work together. Tag loot in the room where you find it: `[R:Room3|looted] [Inv:Gold Ring|1|valuable]`. The `[R:]` tag tracks what happened to the room; the `[Inv:]` tag tracks what happened to the loot.

**Q: How do I handle containers, bags of holding, saddlebags?**
A: Either nest descriptively — `[Inv:Bag of Holding|contains: Wand, Scrolls×3, Gold 100]` — or track the container and contents separately. For slot-based systems, just mark which slots are "in the bag." Don't over-engineer it.

**Q: The `×` symbol is hard to type. Can I use `x` instead?**
A: Yes. `[Inv:Arrow×12]` and `[Inv:Arrowx12]` are both fine. Readability over formality.
