---
title: Star Hauler - Derelict Run
ruleset: Ironsworn Starforged
genre: Sci-fi / Space horror
player: Roberto
pcs: Captain Rey [PC:Captain Rey|Health 5|Supply 3|Spirit 5]
start_date: 2025-12-15
tools: Ironsworn oracles, Starforged sector generation
themes: Survival, isolation, corporate greed
tone: Tense, claustrophobic
notes: One-shot salvage mission gone wrong
---

# Star Hauler - Derelict Run

The *Vagrant's Hope* limps through the Outer Reach, fusion drive sputtering. We need parts. The derelict freighter *Meridian's Grace* floats dead ahead—corporate ship, abandoned three months ago. Perfect salvage. Or so I thought.

## Session 1
*Date: 2025-12-15 | Duration: 3h | Scenes: S1-S8*

### S1 *Bridge of the Vagrant's Hope*

```
> Scan the derelict for life signs
d: Action d6=4+Wits=2 vs Challenge d10=3,7 => Weak Hit
=> No life signs, but the scan is fuzzy. Something's interfering with sensors.

[Timer:OxygenSupply 8] (hours of reserve O2)
[E:ShipDamage 3/6]
[L:Vagrant's Hope|damaged|low power|desperate]

? Is the derelict's airlock functional?
-> Yes, but... (d10=4 on oracle)
=> Functional, but running on backup power. It might fail.
```

I suit up. This has to work. We're three jumps from the nearest port, and the ship's falling apart.

```
[PC:Captain Rey|Supply 3|Gear:Breather,Plasma Cutter,Scanner]
```

### S2 *Docking with the Meridian's Grace*

```
> Carefully dock with the derelict
d: Action d6=5+Edge=1 vs Challenge d10=4,8 => Weak Hit
=> Docking clamps engage, but I hear metal groaning. Not a stable connection.

[Clock:Docking Instability 1/4]

> Board through the airlock
```

The airlock cycles. Green light. The door slides open with a hiss of stale air.

```
[L:Meridian's Grace|dark|silent|corporate freighter|derelict]

? Are there any immediate hazards?
-> No, but... (d10=3)
=> The corridor lights are out. Emergency strips only. And it's cold—life support is offline.

[Timer:OxygenSupply 7] (1 hour used exploring)
```

### S3 *Main corridor, Meridian's Grace*

```
> Head to engineering to find replacement parts
d: Action d6=3+Wits=2 vs Challenge d10=6,4 => Weak Hit
=> I find the engineering bay, but the door is sealed. Security lockdown.

> Bypass the security lock
d: Action d6=8+Shadow=2 vs Challenge d10=5,3 => Strong Hit
=> My bypass rig hums. Click. The door slides open.
```

Engineering bay is a mess. Consoles smashed. Cabling ripped out. This wasn't an accident—this was sabotage.

```
? Do I find the parts I need?
-> Yes, and... (d10=8)
=> Not just parts—I find a functioning power cell. Jackpot!

[Track:Salvage Mission 3/6]
[Timer:OxygenSupply 6]
```

But something's wrong. The damage is too deliberate. Too violent.

```
? Do I find any clues about what happened?
-> Yes, but... (d10=5)
=> A datapad, cracked screen. Last log entry: "It's in the cargo hold. Don't let it out. Jettison if—" Message cuts off.

[Thread:What's in the Cargo Hold?|Open]
[N:Log Author|deceased|warning]
```

### S4 *Engineering bay, continued*

My suit radio crackles. Wait. There's no one else here.

```
? Am I picking up a signal?
-> Yes, and... (d10=7)
=> A distress beacon. Automated. From the cargo hold.

> Make a decision: investigate the cargo hold or just take the parts and leave
```

(note: I should leave. But that beacon... someone might still be alive)

```
> Head toward the cargo hold
[PC:Captain Rey|Spirit-1] (dread building)
[Timer:OxygenSupply 5]
```

### S5 *Parallel timeline - Flashback: Cargo hold, 3 months ago*

```
S5a *Flashback: Meridian's Grace cargo hold, three months ago*

(Showing what happened here - narrative device)
```

The crew of the *Meridian's Grace* stands around a strange pod. Xenotech. Illegal salvage from a dead civilization.

```
N (Dr. Venn): "We shouldn't open it. Company protocol says—" [N:Dr. Venn|scientist|cautious]

N (Captain Morris): "Protocol doesn't pay bonuses. Open it." [N:Captain Morris|greedy|deceased]
```

They cut through the pod's seals. Something moves inside. Something that shouldn't exist.

```
S5b *Flashback: 72 hours later*

(The final transmission)

N (Dr. Venn): "Emergency log. The specimen... it's not dead. It's dormant. And it wakes when it senses higher brain functions. Captain is gone. Chen is gone. I'm sealing the cargo hold. If anyone finds this—"
```

Screaming. Silence. End transmission.

```
[Thread:Xenotech Horror|Open]
[Clock:Creature Dormant 0/6] (fills when creature wakes)
```

### S6 *Present: Approaching cargo hold*

Back to now. I float through zero-g corridors toward the cargo hold. My helmet lamp cuts through the darkness.

```
> Approach the cargo hold carefully
d: Action d6=5+Shadow=2 vs Challenge d10=7,9 => Miss
=> The floor plating gives way! I tumble into a sub-level maintenance shaft!

[PC:Captain Rey|Health-1]
[Timer:OxygenSupply 4]

> Climb back up
d: Action d6=6+Iron=2 vs Challenge d10=4,5 => Strong Hit
=> I haul myself up, muscles screaming
```

I need to be more careful. Oxygen is running low.

```
[E:ShipDamage 4/6] (Vagrant is deteriorating while I'm away)
```

### S7 *Cargo hold entrance*

The cargo hold doors are sealed. Red emergency lights pulse. Beyond the reinforced window, I see it.

```
> Look through the window
```

The pod is open. Empty. And there's something in the shadows. Something moving.

```
? Is the creature aware of me?
-> No, but... (d10=4)
=> Not yet. But it's stirring. My thoughts—my brain activity—it can sense it.

[Clock:Creature Dormant 2/6]

(note: Building tension - the more I think, the more it wakes)
```

I have a choice. Leave now with the parts I have, or go in there and destroy that thing before someone else finds this ship.

```
> Make a vow to destroy the creature and prevent it spreading
d: Iron d6=5 vs Challenge d10=3,8 => Weak Hit
=> I swear it. But doubt creeps in. Can I really do this?

[Thread:Destroy the Creature|Open]
[Track:Creature Elimination 0/8]
```

### S8 *Inside the cargo hold*

```
> Enter the cargo hold quietly
d: Action d6=3+Shadow=2 vs Challenge d10=6,3 => Weak Hit
=> I slip inside. The creature is in the far corner, pulsing slowly. Breathing? Or something else.

[Clock:Creature Dormant 3/6]

> Set up plasma charges around the hold
d: Action d6=7+Wits=2 vs Challenge d10=5,4 => Strong Hit
=> Perfect placement. Remote detonator ready. This will work.

[Track:Creature Elimination 4/8]

? Does the creature react to my presence?
-> Yes, and... (d10=8)
=> It unfurls. Tentacles? Limbs? Hard to tell. And it's fast.

[Clock:Creature Dormant 6/6] => CREATURE AWAKENS!
[PC:Captain Rey|Spirit-2] (terror)
```

Oh god. It sees me.

```
> Fire at the creature to slow it down
d: Action d6=4+Iron=2 vs Challenge d10=7,6 => Miss
=> My plasma cutter sparks uselessly against its hide. The beam just... absorbs.

> Run for the exit and trigger the charges
d: Action d6=8+Edge=1 vs Challenge d10=2,5 => Strong Hit!
=> I sprint, hit the detonator. BOOM!

[Track:Creature Elimination 8/8] => Success!
```

The cargo hold erupts in flame. I'm thrown through the doorway, slamming into the corridor wall.

```
[PC:Captain Rey|Health-2]
[Timer:OxygenSupply 2] (running critical)

? Did the explosion destroy the creature?
-> Yes, but... (d10=4)
=> It's dead. Burning. But the explosion breached the hull. The derelict is venting atmosphere—and pulling my ship with it!

[Clock:Docking Instability 4/4] => CRITICAL!
```

I have minutes. Maybe less.

```
> Sprint back to my ship with the salvaged parts
d: Action d6=6+Edge=1 vs Challenge d10=3,4 => Strong Hit
=> I run faster than I've ever run. Grab the power cell. Dive through the airlock.

> Emergency undock before the derelict tears my ship apart
d: Action d6=5+Edge=1 vs Challenge d10=6,7 => Miss
=> The docking clamps won't release! The derelict's tumbling, dragging the Vagrant with it!

[E:ShipDamage 6/6] => CRITICAL DAMAGE!

> Override the clamps manually (dangerous)
d: Action d6=8+Iron=2 vs Challenge d10=3,5 => Strong Hit!
=> I rip the panel open, cut the clamps with my plasma cutter. We break free!
```

The *Vagrant's Hope* spins away from the dying derelict. I scramble to the bridge, slam the new power cell into place.

```
> Fire engines and get clear
d: Action d6=7+Edge=1 vs Challenge d10=4,6 => Strong Hit
=> Engines roar to life. We accelerate away as the Meridian's Grace tumbles into the void, burning.

[Timer:OxygenSupply 1] (almost gone)
[Track:Salvage Mission 6/6] => Success!
```

I collapse in the pilot's chair, gasping. The parts are installed. The ship is running. I'm alive.

```
[Thread:Destroy the Creature|Closed]
[Thread:What's in the Cargo Hold?|Closed]
[Thread:Report or Stay Silent?|Open]
```

But now I have a choice. Report this to the authorities? Or stay silent and pretend I was never here?

```
(note: Ending on moral ambiguity - typical for the genre)
```

The company will want to know what happened to their ship. And what happened to that xenotech specimen. But if I tell them... they'll send salvage teams. And maybe whatever killed the Meridian's crew wasn't unique.

```
[PC:Captain Rey|Health 2|Supply 1|Spirit 2|Status:Traumatized but alive]
```

I set course for the next port. I'll decide when I get there.

---

**Session End**

**This example demonstrated:**
- ✅ Different game system (Ironsworn Starforged)
- ✅ Different dice mechanics (Action + Stat vs Challenge dice)
- ✅ Timers counting down (Oxygen Supply)
- ✅ Events/Clocks tracking danger
- ✅ Parallel timeline with flashbacks (S5a, S5b)
- ✅ Tracks for long-term progress
- ✅ PC with different stats (Health, Supply, Spirit)
- ✅ Vows and moral choices
- ✅ Tension and horror elements
- ✅ One-shot complete story arc
- ✅ Open-ended conclusion
