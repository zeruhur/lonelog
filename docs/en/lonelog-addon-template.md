---
title: "Lonelog: [Add-on Name] Add-on"
subtitle: "[One-line description of what this add-on enables]"
author: [Your name or handle]
version: 0.1.0
license: CC BY-SA 4.0
lang: en
parent: Lonelog v1.1.0
requires: Core Notation (§3)
---

<!--
  LONELOG ADD-ON TEMPLATE
  ========================
  Replace all [bracketed] placeholders with your content.
  Delete instruction comments (like this one) before publishing.
  
  Required sections: Overview, What This Add-on Adds, at least one
  core feature section, Best Practices, Quick Reference, FAQ.
  
  Optional sections: Design Principles, Cross-Add-on Interactions,
  System Adaptations. Include them if they apply.
  
  See the Community Add-on Guidelines for full guidance.
-->

# [Add-on Name] Add-on

## Overview

<!--
  2–4 paragraphs. Answer:
  - What gap in core Lonelog does this fill?
  - What type of play or game system is it for?
  - When should players reach for this add-on vs. staying with core?
  
  Don't sell it. Describe it honestly, including its limits.
-->

[Describe the situation core Lonelog doesn't fully handle — the moment
a player realizes they need more structure than the five core symbols
alone provide.]

[Explain what the add-on provides concretely: new tags, structural
blocks, or formatting conventions. Keep it brief here — the sections
below go into detail.]

[State when *not* to use this add-on. Honesty here builds trust and
prevents players from adopting notation they don't need.]

---

### What This Add-on Adds

<!--
  One table summarizing every new element. This is the first thing
  an experienced Lonelog player will read. Be precise.
-->

| Addition | Purpose | Example |
|----------|---------|---------|
| `[TAG:Name\|props]` | [What it tracks] | `[TAG:Example\|prop1]` |
| [Structural block] | [What it delimits] | `[BLOCK] ... [/BLOCK]` |
| [Convention name] | [What it standardizes] | [brief example] |

**No new core symbols.** This add-on introduces no additions to `@`, `?`, `d:`, `->`, or `=>`.

---

### Design Principles

<!--
  Optional but valuable. 3–5 short principles that explain the *why*
  behind the design. Helps future maintainers and derivative authors
  understand the intent.
  
  Model on the Resource Tracking Add-on's "Design Principles" section.
-->

**[Principle 1 — short title].** [One or two sentences explaining the
principle and why it matters for this add-on's domain.]

**[Principle 2 — short title].** [One or two sentences.]

**[Principle 3 — short title].** [One or two sentences.]

---

## 1. [First Major Feature]

<!--
  One section per major feature. Title it after what it does, not
  what it's called. E.g., "Tracking Room State" not "The R: Tag".
  
  Each section needs:
  - Format specification
  - At least two examples (minimal and expanded)
  - Guidance on when to use and when to skip
-->

[Brief intro: what problem does this feature solve within the add-on's
domain?]

**Format:**

```
[TAG:Name|required-field|optional-field]
```

**Fields:**

- `Name` — [what it identifies]
- `required-field` — [what it means, expected values]
- `optional-field` — [what it means, when to include it]

#### [1.1 Subfeature or Common Use Case]

[Explain the most common way this feature is used.]

**Example — minimal:**

```
[Compact single-line showing the feature in fast-play context]
```

**Example — expanded:**

```
[Full sequence showing the feature in a realistic play log:
action, roll, consequence, tag update. At least 5–8 lines.]
```

#### [1.2 Another Subfeature or Edge Case]

[Cover the next most important variation or edge case.]

```
[Example]
```

---

## 2. [Second Major Feature]

<!--
  Repeat the structure from Section 1 for each major feature.
  Most add-ons have 2–4 major features.
-->

[Intro paragraph.]

**Format:**

```
[Format specification]
```

**Example — minimal:**

```
[Compact example]
```

**Example — expanded:**

```
[Full sequence example]
```

---

## 3. [Structural Block — if applicable]

<!--
  If your add-on introduces a structural block (like [COMBAT]...[/COMBAT]
  or --- RESOURCES ---), give it its own section.
  
  Explain: what goes inside it, when to open/close it, and what it
  means when reading a log.
-->

[Some add-ons benefit from a structural block that clearly delimits
a mode of play within the log. If yours does, explain it here. If not,
delete this section.]

**Format:**

```
[BLOCKNAME]
[Contents of the block]
[/BLOCKNAME]
```

**When to open a block:** [Specific trigger — e.g., "when initiative
is declared" or "at session start when resources matter".]

**When to close it:** [Specific condition — e.g., "when all combatants
are resolved" or "at session end".]

**Digital format:**

```
[Example in markdown context]
```

**Analog format:**

```
[Example for paper notebooks]
```

---

## Cross-Add-on Interactions

<!--
  Optional. Include if your add-on is designed to work alongside
  other add-ons, or if there are known interaction patterns.
  
  Include at least one combined example showing both add-ons
  in the same log sequence.
-->

| Situation | Add-on(s) Used | Key Tags/Blocks |
|-----------|---------------|----------------|
| [Common combined scenario] | [This add-on] + [Other add-on] | [Main elements] |

**Combined example — [This Add-on] + [Other Add-on]:**

```
[A realistic 10–15 line log sequence showing both add-ons working
together. Should feel like actual play, not a demonstration.]
```

---

## System Adaptations

<!--
  Optional but recommended. Show how the add-on adapts to 2–4
  specific RPG systems that players commonly use with Lonelog.
  
  Cover at least one OSR/traditional system and one narrative/PbtA system
  if your add-on is broadly applicable.
-->

### [System Name 1]

[One paragraph on how this system's mechanics map to the add-on's notation.]

```
[System-specific example]
```

### [System Name 2]

[One paragraph.]

```
[System-specific example]
```

---

## Best Practices

<!--
  Do/Don't pairs in the style of Lonelog §7.
  Aim for 4–6 pairs covering the most common mistakes and the
  clearest positive patterns.
  
  Each pair should have working code examples, not just prose.
-->

**Do: [Positive pattern title]**

```
✔ [Positive example — complete, realistic, clearly correct]
```

**Don't: [Anti-pattern title]**

```
✗ [What to avoid — complete, realistic, clearly wrong]

✔ [The corrected version]
```

**Do: [Positive pattern title]**

```
✔ [Example]
```

**Don't: [Anti-pattern title]**

```
✗ [Wrong]

✔ [Right]
```

---

## Quick Reference

<!--
  Required. Tables covering every new element. This is what players
  return to during actual play after reading the add-on once.
  
  One table per category of element.
-->

### New Tags

| Tag | Purpose | Example |
|-----|---------|---------|
| `[TAG:Name\|field]` | [What it tracks] | `[TAG:Example\|value]` |
| `[#TAG:Name]` | Reference to previously established element | `[#TAG:Example]` |

### [Structural Blocks — if applicable]

| Block | Opens When | Closes When |
|-------|-----------|------------|
| `[BLOCKNAME]` | [Trigger] | [Condition] |

### [Other element category — if applicable]

[Table or compact list of any remaining new elements.]

### Complete Example

<!--
  One compact line or short sequence showing the add-on's
  main elements together. The "cheat sheet" line that captures
  the whole add-on in miniature.
-->

```
[The most useful single example for quick reference during play]
```

---

## FAQ

<!--
  4–8 questions covering anticipated edge cases, design decisions,
  and interactions with other systems. Write the questions in the
  voice of a player who has read the add-on once and is now
  trying to use it.
-->

**Q: [Most common anticipated question]**  
A: [Direct, practical answer. Point to the relevant section if appropriate.]

**Q: [Design rationale question — "why did you..."]**  
A: [Explain the reasoning. This builds trust and helps players adapt the convention.]

**Q: [Edge case question]**  
A: [Specific answer. If the edge case has no good answer, say so and suggest an approach.]

**Q: [Integration question — "can I use this with..."]**  
A: [Yes/no/depends, with brief explanation.]

**Q: [Analog question — "how does this work on paper?"]**  
A: [Practical analog adaptation.]

---

<!--
  CREDITS & VERSION HISTORY
  =========================
  Keep this section even if you're the sole author — it establishes
  the history and makes attribution clear for derivatives.
-->

## Credits & License

© [Year] [Your name or handle]

This add-on extends [Lonelog](https://[link to core document]) by Roberto Bisceglie.

<!--
  If you were inspired by or built on someone else's work, credit them:
  
  Inspired by [Name]'s [work] at [link].
  
  Thanks to [community member] for [specific contribution].
-->

**Version History:**

- v 0.1.0: Initial draft

This work is licensed under the **Creative Commons Attribution-ShareAlike 4.0 International License**.

You are free to share and adapt this material, provided you give appropriate credit and distribute adaptations under the same license. Session logs and play records created using this add-on's notation are your own work and are not subject to this license.
