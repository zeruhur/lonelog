---
title: "Lonelog : Extension de Combat"
subtitle: "Notation Optionnelle pour les Rencontres Tactiques"
author: Roberto Bisceglie
version: 1.1.0
license: CC BY-SA 4.0
lang: fr
parent: Lonelog v1.3.0
requires: Notation de Base (§3)
Création: 2026-03-10 10:26
Modification: 2026-03-15 17:05
---

# Extension de Combat

## Présentation

Le combat est le moment où le jeu en solo devient dense. Les dés volent, les points de vie chutent, les positions changent — et vous gérez les deux côtés. Sans structure, votre journal se transforme en un mur de texte où vous ne pouvez plus dire qui a frappé qui ni quand les choses ont mal tourné.

Cette extension vous propose une notation optionnelle pour les rencontres tactiques. Elle se superpose au cœur de Lonelog — en utilisant les mêmes symboles `@`, `d:`, `->`, `=>` — et ajoute juste assez de structure pour garder les combats lisibles sans transformer votre session en tableur.

Tous les jeux en solo n'ont pas de combat tactique. *Thousand Year Old Vampire* n'a pas besoin de suivi par tour. Une enquête menée par *Mythic GME* pourrait résoudre une bagarre de bar en une seule question à l'oracle. Si votre système résout le combat en un seul jet, la notation de base convient parfaitement :

```
@ Combattre les bandits
d: Combat 2d6=9 -> Succès Majeur
=> Je me fraye un chemin à travers eux et m'échappe dans la ruelle.
```

Cette extension est destinée à tout ce qui est plus complexe que cela — les jeux où vous suivez des tours, plusieurs combattants, des distances et des points de vie changeants.

---

### Ce que cette extension ajoute

| Ajout                    | Objectif                                                        | Exemple                               |
| ------------------------ | --------------------------------------------------------------- | ------------------------------------- |
| `[F:Nom\|stats]`         | Suivre les stats et le statut des combattants                   | `[F:Brute\|PV 6\|Proche]`             |
| `[COMBAT]` / `[/COMBAT]` | Délimiter une rencontre tactique dans une scène                 | `[COMBAT] ... [/COMBAT]`              |
| `T#` marqueurs de tour   | Séparer les tours d'initiative dans un bloc de combat           | `T1`, `T2`, `T3`                      |
| `@(Nom) Action`          | Attribuer des actions à des acteurs autres que le PJ            | `@(Brute A) Se jette sur moi`         |
| `T# Liste : [balises]`   | Instantané de l'état de tous les combattants au début d'un tour | `T3 Liste : [PJ:PV 3] [F:Boss\|PV 4]` |

**Aucun nouveau symbole de base.** Cette extension n'introduit aucun ajout à `@`, `?`, `d:`, `->` ou `=>`.

---

### Principes de conception

**Aucun nouveau symbole de base.** Le combat utilise `@`, `d:`, `->`, `=>` exactement comme défini dans le cœur de Lonelog. Les nouveaux éléments sont uniquement des marqueurs structurels et des conventions de formatage — pas des raccourcis symboliques.

**S'adapter à la complexité.** Une escarmouche rapide nécessite moins de notation qu'une bataille de cinq tours avec six combattants. N'utilisez que la structure que la rencontre exige. L'extension prend en charge les deux extrêmes.

**Clarté de l'acteur avant tout.** Le problème central de la journalisation des combats est de savoir qui fait quoi. Chaque ajout ici sert cet objectif — les marqueurs de tour séparent les tours, le préfixe `@(Nom)` identifie les acteurs non-PJ, les balises d'ennemis suivent les états changeants.

---

## 1. Blocs de Combat

Certaines rencontres bénéficient d'une limite structurelle qui signale un changement de mode — notation plus dense, suivi tour par tour, changements d'état mécaniques. Le bloc `[COMBAT]` fournit cette limite.

**Format :**

```
[COMBAT]
...notation de combat...
[/COMBAT]
```

#### 1.1 Dans les en-têtes de scène

Lorsque toute la scène est un combat, placez `[COMBAT]` dans l'en-tête de la scène :

```
S5 *Embuscade dans l'entrepôt* [COMBAT]
```

Aucune balise de fermeture n'est nécessaire — le marqueur de scène suivant met fin à la rencontre.

#### 1.2 Au sein d'une scène

Lorsque le combat commence au milieu d'une scène, ouvrez et fermez le bloc autour de la section tactique :

```
S5 *Entrepôt, minuit*
@ Fouiller les caisses pour trouver des preuves
d: Investigation d6=5 vs ND 4 -> Succès
=> Je trouve des manifestes d'expédition — mais j'entends des pas derrière moi.

[COMBAT]
...notation de combat ici...
[/COMBAT]

=> Les brutes étant inconscientes, je saisis les manifestes et m'enfuis.
```

Les délimiteurs `[COMBAT]` / `[/COMBAT]` vous permettent de séparer visuellement la section tactique de la narration, de retrouver les combats lors du balayage d'un journal et de signaler à votre futur "vous" qu'une notation plus dense suit.

#### 1.3 Format analogique

Pour les carnets papier, utilisez des séparateurs en pointillés :

```
--- COMBAT ---
...notation de combat...
--- FIN COMBAT ---
```

Ou ignorez complètement les délimiteurs — les marqueurs de tour ci-dessous signalent déjà le combat.

**Quand ignorer le bloc :** Si le combat se résout en un ou deux jets, la notation de base le gère sans aucune structure de bloc.

---

## 2. Suivi des Tours

Les tours de combat distincts reçoivent des marqueurs `T#`. Considérez-les comme des mini-scènes au sein du combat.

**Format :**

```
T1
...actions...

T2
...actions...
```

**Numérotation :** Commencez à `T1` à chaque combat. Les tours sont locaux à la rencontre, pas à la session.

**Exemple — minimal :**

```
T1 @ Frapper d:17≥12 Touche PV-5 @(Brute) d:9≥15 Échec
T2 @ L'achever d:20≥12 Touche => [F:Brute|mort]
```

**Exemple — développé :**

```
T1
@ Dégainer mon épée et attaquer la Brute A
d: d20+5=17 vs CA 12 -> Touche
d: 1d8=5 dégâts
=> [F:Brute A|PV-5|PV 1|chancelant]

@(Brute A) Riposte sauvage
d: d20+3=9 vs CA 15 -> Échec
=> Il perd l'équilibre — je profite de l'avantage.

T2
@ Frapper à nouveau
d: d20+5=14 vs CA 12 -> Touche
d: 1d8=6 dégâts
=> [F:Brute A|mort]
```

**Quand ignorer les marqueurs de tour :** Si le combat est rapide (un ou deux jets) ou si votre système n'utilise pas de tours discrets, enregistrez les actions de manière séquentielle sans marqueurs.

---

## 3. Suivi des Combattants

Le cœur de Lonelog suit les PNJ avec `[N:Nom|balises]`. En combat, vous avez souvent besoin d'un suivi plus serré — points de vie, position, effets de statut qui changent à chaque tour. La **balise d'ennemi** (foe tag) `[F:Nom|stats]` est une variante spécifique au combat conçue pour cela.

**Format :**

```
[F:Nom|stats clés|position|statut]
```

**Champs :**

- `Nom` — identifiant du combattant ; utilisez les suffixes A/B pour distinguer les individus du même type
- `stats clés` — valeurs mécaniques : `PV 6`, `CA 12`, `ATK +3`
- `position` — distance ou zone : `Proche`, `Moyen`, `Loin`, `Engagé`, `Zone:Ruelle`
- `statut` — conditions : `blessé`, `chancelant`, `mort`, `fui`

#### 3.1 Ennemis individuels

```
[F:Brute A|PV 6|Proche|armé]
[F:Chef du Culte|PV 12|Loin|sorcier]
```

Mettez à jour les balises d'ennemis au fur et à mesure que les stats changent — soit sur une nouvelle ligne, soit de manière intégrée :

```
[F:Brute A|PV 6|Proche]
...la Brute A subit 3 dégâts...
[F:Brute A|PV 3|Proche|blessé]

...ou en raccourci :
[F:Brute A|PV-3]
```

#### 3.2 Ennemis groupés

Lorsque les individus n'ont pas besoin d'un suivi séparé, groupez-les :

```
[F:Gobelins×4|PV 3 chacun|Proche]
...l'un d'eux meurt...
[F:Gobelins×3|Proche]
```

Divisez les groupes lorsqu'ils divergent en position ou en statut :

```
[F:Pirate 1|Proche|blessé]
[F:Pirate 2|Moyen|arbalète]
```

#### 3.3 Position et mouvement

Suivez la distance comme un attribut de balise. Bandes de distance courantes :

```
[F:Archer|PV 5|Loin]
[F:Brute|PV 6|Proche]
[F:Loup|PV 4|Engagé]     (au corps à corps)
```

Montrez le mouvement avec une notation en flèche :

```
@(Brute A) Se précipite [Loin->Proche]
[F:Brute A|Proche]
```

Pour les systèmes basés sur une grille ou des zones :

```
[F:Brute A|PV 6|Zone:Ruelle]
[F:Brute B|PV 4|Zone:Toit]
[PJ:Alex|Zone:Rue]
```

**Pourquoi `[F:]` au lieu de `[N:]` ?** `[N:]` est pour les PNJ persistants qui comptent pour votre histoire. `[F:]` est pour les combattants — souvent jetables, définis par des stats mécaniques plutôt que par des balises narratives. La distinction garde votre index de PNJ propre. Un méchant récurrent pourrait être `[N:Viktor|ambitieux|impitoyable]` dans les scènes narratives et devenir un `[F:Viktor|PV 15|Loin|armuré]` quand les épées sont sorties.

**Quand ignorer les balises d'ennemis :** Pour les combats simples (un ennemi, pas de suivi de position), `[N:]` ou nommer l'ennemi en prose fonctionne très bien. Les balises d'ennemis prouvent leur utilité quand vous devez suivre plusieurs combattants avec des stats changeantes.

---

## 4. Actions des Acteurs

Dans le jeu normal, `@` signifie toujours "Moi, le personnage joueur, je fais quelque chose". En combat, les ennemis et les alliés agissent aussi. **`@` reste l'action du PJ. Pour les autres acteurs, préfixez l'action avec le nom de l'acteur entre parenthèses.**

| Acteur | Format | Exemple |
|--------|--------|---------|
| PJ (par défaut) | `@ Action` | `@ Frapper la Brute A` |
| Ennemi nommé | `@(Nom) Action` | `@(Brute A) Coup d'épée sur PJ` |
| Groupe | `@(Groupe) Action` | `@(Gobelins) Attaque en essaim` |
| PNJ allié | `@(Nom) Action` | `@(Jordan) Tir de couverture` |

**Exemple — minimal :**

```
T1
@ Frapper d:18≥12 Touche PV-6 => [F:Brute A|mort]
@(Brute B) Poignarder d:14≥15 Échec
```

**Exemple — développé :**

```
T1
@ Dégainer mon épée et attaquer la Brute A
d: d20+5=18 vs CA 12 -> Touche
d: 1d8=6 dégâts
=> [F:Brute A|PV-6|mort]

@(Brute B) Se jette sur moi avec un couteau
d: d20+3=14 vs CA 15 -> Échec
=> Le couteau siffle à mes oreilles.
```

**Pourquoi pas un nouveau symbole pour les actions des ennemis ?** Parce que `@` signifie déjà "action entreprise". Le préfixe entre parenthèses identifie qui — c'est tout ce dont on a besoin pour lever l'ambiguïté. Ajouter un symbole (comme `!` ou `>>`) briserait le principe de Lonelog de symboles de base minimaux et ajouterait une chose de plus à retenir en plein combat.

**Réactions et interruptions :** Notez-les là où elles se produisent avec une note entre parenthèses :

```
@(Alex) Riposte (réaction)
@ Attaque d'opportunité (interruption)
```

**Raccourci pour les combats rapides :** Quand la vitesse compte plus que la lisibilité, allez-y chronologiquement dans chaque tour et laissez les balises d'ennemis fournir le contexte :

```
T1
[F:Brute A|Proche] @(A) Frapper -> d:14≥15 Échec
[PJ] @ Riposte -> d:18≥12 Touche => [F:Brute A|PV-6|mort]
[F:Brute B|Proche] @(B) Poignarder -> d:11≥15 Échec
```

**Contexte de jet :** Lorsqu'une balise ou un statut d'un combattant affecte directement la mécanique d'un jet, notez-les à la suite en utilisant le contexte de jet (Cœur de Lonelog §4.1.9) :

```
@(Capitaine Pirate) Accentue l'attaque
d: d20+6 [contre: chancelant] = 11 vs CA 14 -> Échec

@ Frapper le Capitaine affaibli
d: d20+5 [+flanc, +hauteur] = 18 vs CA 13 -> Touche
```

C'est très utile dans les systèmes riches en balises (*City of Mist*, *Fate*) où les balises nommées modifient mécaniquement les jets. Dans les systèmes d20 traditionnels, la ligne de jet seule est généralement suffisante.

---

## 5. Rencontres Complexes

Lorsque plus de deux camps s'affrontent, la structure est primordiale.

#### 5.1 Mise en place de la rencontre

Avant `T1`, établissez le champ de bataille avec un instantané de combat listant tous les combattants avec leurs positions initiales et leurs stats clés :

```
S9 *Embuscade sur les quais* [COMBAT]
[PJ:Alex|PV 12|Engagé]
[N:Jordan|allié|PV 8|Proche]
[F:Capitaine Pirate|PV 10|Proche|armé|épée]
[F:Pirate×2|PV 4 chacun|Moyen|armé|arbalète]
[F:Rat de quai|PV 2|Engagé|couteau]
```

Ceci est votre instantané de combat — l'état du terrain au moment où l'initiative commence.

#### 5.2 Listes de tour

Pour les combats avec de nombreux combattants et des stats qui changent rapidement, ouvrez chaque tour avec une ligne de liste (roster) :

```
T3 Liste : [PJ:Alex|PV 3] [N:Jordan|PV 4] [F:Capitaine|PV 4] [F:Pirate×1|PV 4]
```

Cela vous donne un instantané à chaque tour sans avoir à chercher en arrière dans le journal.

**Conseils pour l'échelle :**

- **Groupez les ennemis identiques.** `[F:Pirate×2]` vaut mieux que de suivre le Pirate A et le Pirate B séparément — à moins qu'ils ne soient dans des positions différentes ou qu'ils aient des statuts différents.
- **Divisez les groupes quand nécessaire.** Si un pirate bouge et l'autre non : `[F:Pirate 1|Proche]` `[F:Pirate 2|Moyen]`.
- **Éliminez les balises, gardez l'histoire.** Ne suivez pas les PV pour les sbires si un seul coup les tue. Notez simplement `[F:Rat|mort]`.
- **Utilisez des listes** quand vous avez 5 combattants ou plus, ou quand les stats changent assez vite pour que vous perdiez le fil sans résumé.

---

## 6. Après le Combat

Quand le combat se termine, revenez à la narration avec `=>`, mettez à jour les balises persistantes et ouvrez tout nouveau fil conducteur :

```
[/COMBAT]
=> Deux pirates morts, le capitaine s'est enfui dans le brouillard. Jordan est blessé.
[N:Jordan|blessé|PV 4]
[Fil:Vengeance du Capitaine Pirate|Ouvert]
[PJ:Alex|PV 5|Stress+1]
```

Cela reconnecte le combat mécanique à votre histoire en cours.

**Butin et récompenses :**

```
=> Je fouille les corps.
tbl: d100=67 -> "Carte maritime du Capitaine"
=> Une carte montrant une crique cachée. [E:CriquePirate 1/4]
[PJ:Alex|Équipement+Carte maritime]
```

---

## 7. Assembler le Tout

Voici la même rencontre à trois niveaux de détail — trouvez votre zone de confort.

#### Ultra-compact

```
S9 *Embuscade quais* [COMBAT]
[PJ:PV 12] [F:Capitaine|PV 10] [F:Pirate×2|PV 4] [F:Rat|PV 2]
T1 @Rat d:17≥10 Touche =>mort @(Cap) d:19≥14 Touche PV-7 @(Pir×2) d:15,9 vs11 1Touche [N:Jordan PV-4]
T2 @Cap d:20≥13 Touche =>PV-6 @(Pir) d:8≥14 Échec @(Jordan) d:16≥11 Touche =>Pir mort
T3 @Cap d:15≥13 Touche =>Cap PV-4, s'enfuit
[/COMBAT] =>Le Capitaine s'échappe
```

#### Standard

```
S9 *Embuscade sur les quais* [COMBAT]
[PJ:Alex|PV 12] [N:Jordan|allié|PV 8]
[F:Capitaine Pirate|PV 10|Proche] [F:Pirate×2|PV 4|Moyen] [F:Rat de quai|PV 2|Engagé]

T1
@ Frapper le Rat de quai
d: d20+4=17 vs CA 10 -> Touche => [F:Rat de quai|mort]

@(Capitaine) Charge, brandit son coutelas [Proche->Engagé]
d: d20+6=19 vs CA 14 -> Touche, 7 dégâts => [PJ:Alex|PV 5]

@(Jordan) Arbalète sur le Capitaine
d: d20+3=12 vs CA 13 -> Échec

@(Pirate×2) Arbalètes sur Jordan
d: d20+2=15,9 vs CA 11 -> 1 Touche, 4 dégâts => [N:Jordan|PV 4]

T2
@ Attaque puissante sur le Capitaine
d: d20+4=20 vs CA 13 -> Touche, 8 dégâts => [F:Capitaine|PV 2|blessé]

@(Capitaine) Coup désespéré
d: d20+6=11 vs CA 14 -> Échec

@(Jordan) Deuxième tir sur le Pirate restant
d: d20+3=16 vs CA 11 -> Touche => [F:Pirate×1|mort]

@(Pirate) Lâche son arbalète, s'enfuit => [F:Pirate×1|fui]

T3
@ Poursuivre le Capitaine
d: Athlétisme d6=3 vs ND 5 -> Échec
=> Il saute du quai dans une barque et disparaît dans le brouillard.

[/COMBAT]
=> Deux pirates morts, un en fuite, le Capitaine s'est échappé par mer.
[N:Jordan|blessé] [PJ:Alex|PV 5|Stress+1]
[Fil:Vengeance du Capitaine Pirate|Ouvert]
```

#### Riche en narration

```
S9 *Quais, le brouillard envahit le port*

Les caisses offrent une couverture, mais pas pour longtemps. Un homme à face de rat avec un couteau surgit de derrière un tonneau. Derrière lui, le Capitaine Pirate dégaine son coutelas avec un sourire. Deux arbalétriers prennent position sur la pile de marchandises.

[COMBAT]
[PJ:Alex|PV 12|Engagé] [N:Jordan|allié|PV 8|Proche]
[F:Capitaine Pirate|PV 10|Proche|coutelas]
[F:Pirate×2|PV 4 chacun|Moyen|arbalète]
[F:Rat de quai|PV 2|Engagé|couteau]

T1
@ Esquiver le Rat de quai et frapper
d: d20+4=17 vs CA 10 -> Touche, 1d8=5
=> L'homme à face de rat s'effondre. [F:Rat de quai|mort]

Mais j'ai laissé mon flanc exposé.

@(Capitaine Pirate) Traverse le quai en courant, coutelas haut [Proche->Engagé]
d: d20+6=19 vs CA 14 -> Touche, 1d8+2=7
=> Sa lame s'enfonce profondément dans mes côtes. Je chancelle. [PJ:Alex|PV 5|blessé]

PJ : "Jordan — les arbalètes !"

@(Jordan) Tire un carreau sur le Capitaine
d: d20+3=12 vs CA 13 -> Échec
=> Le carreau fait jaillir des étincelles d'une chaîne d'amarrage.

@(Pirate×2) Tirent sur Jordan depuis la pile de marchandises
d: d20+2=15, d20+2=9 vs CA 11 -> 1 Touche, 1 Échec
d: 1d6=4
=> Un carreau transperce l'épaule de Jordan. [N:Jordan|PV 4|blessé]

N (Jordan) : "Je suis touché — mais je reste dans la course !"

T2
Le Capitaine est proche, débordant de confiance. Je profite de l'avantage.

@ Attaque puissante sur le Capitaine
d: d20+4=20 vs CA 13 -> Coup Critique, 1d8×2=8
=> Mon épée le frappe en pleine poitrine. Il titube. [F:Capitaine|PV 2|chancelant]

@(Capitaine) Coup sauvage de désespoir
d: d20+6=11 vs CA 14 -> Échec
=> Son coutelas passe largement à côté — je plonge dessous.

@(Jordan) Pivote et tire sur les arbalétriers
d: d20+3=16 vs CA 11 -> Touche, 1d6=5
=> Un pirate tombe de la pile de marchandises. [F:Pirate×1|mort]

Le pirate survivant lâche son arbalète et s'enfuit dans le brouillard.
[F:Pirate×1|fui]

T3
@ Poursuivre le Capitaine avant qu'il ne s'échappe
d: Athlétisme d6=3 vs ND 5 -> Échec
=> Il est trop rapide — saute par-dessus la rambarde du quai et tombe dans une
barque cachée. Le brouillard l'engloutit en quelques secondes.

[/COMBAT]

Je plaque une main sur mes côtes, respirant bruyamment. Jordan s'approche en boitant, l'épaule sombre de sang. Le quai est silencieux, à l'exception du clapotis de l'eau et du grincement des cordes.

PJ (Alex) : "Il reviendra."
N (Jordan) : "Alors on ferait mieux d'être prêts."

=> Deux pirates morts, un en fuite, le Capitaine s'est échappé par mer.
[N:Jordan|blessé|PV 4] [PJ:Alex|PV 5|Stress+1]
[Fil:Vengeance du Capitaine Pirate|Ouvert]
```

---

## Interactions entre extensions

| Situation | Extension(s) utilisée(s) | Balises/Blocs clés |
|-----------|--------------------------|--------------------|
| Suivi des consommables utilisés pendant le combat | Combat + Suivi des Ressources | `[F:]`, `[Inv:Nom\|#]` |
| Combat dans une pièce de donjon explorée | Combat + Exploration de Donjon | `[COMBAT]`, `[R:Pièce\|état]` |

**Exemple combiné — Combat + Suivi des Ressources :**

```
S7 *Salle de garde* [COMBAT]
[PJ:Alex|PV 10|Engagé] [Inv:Potion de soin|2]
[F:Garde×2|PV 5 chacun|Proche|armé]

T1
@ Frapper le Garde 1
d: d20+4=19 vs CA 12 -> Touche, 1d8=7
=> [F:Garde 1|mort]

@(Garde 2) Contre-attaque
d: d20+3=16 vs CA 14 -> Touche, 1d6=4
=> [PJ:Alex|PV-4|PV 6]

T2
@ Boire une potion de soin (action)
=> [PJ:Alex|PV+4|PV 10] [Inv:Potion de soin|1]

@(Garde 2) Retraite et sonne l'alarme
=> [F:Garde 2|fui]

[/COMBAT]
=> Salle de garde dégagée, une potion utilisée, alarme sonnée.
[Fil:Alarme Sonnée|Ouvert]
```

---

## Adaptations du système

### D&D 5e / Systèmes OSR

Ces systèmes utilisent la CA (AC), des jets d'attaque au d20 et des dés de dégâts explicites — l'extension de combat s'y adapte naturellement. Utilisez la convention `vs CA #` dans les lignes `d:` et incluez les dégâts sur la même ligne ou la suivante.

```
[F:Squelette|PV 13|CA 13|Proche]

T1
@ Attaque à l'épée courte
d: d20+4=17 vs CA 13 -> Touche
d: 1d6+2=7 dégâts
=> [F:Squelette|PV-7|PV 6|endommagé]

@(Squelette) Coup de griffes
d: d20+4=11 vs CA 15 -> Échec
```

### Ironsworn / Starforged

Ces systèmes utilisent une résolution basée sur des manœuvres (moves) sans initiative traditionnelle. Les marqueurs de tour sont optionnels — chaque manœuvre génère son propre résultat. Concentrez-vous sur les noms des manœuvres comme étiquettes d'action et utilisez les balises d'ennemis pour suivre les dégâts infligés (harm) et l'état de la menace.

```
[COMBAT]
[F:Brisé|Menace 3|Engagé]

@ Frapper (Strike)
d: d6+3=8 vs d10=5, d10=3 -> Succès Fort
=> +1 élan. [F:Brisé|Menace-2|Menace 1|chancelant]

@(Brisé) Contre
d: d10=7 -> Encaisser les dégâts (Endure Harm)
d: d6+2=6 vs d10=8, d10=4 -> Succès Faible
=> -1 santé, continuer.
[PJ:Alex|santé-1]

[/COMBAT]
```

### Powered by the Apocalypse (PbtA)

Les jeux PbtA utilisent rarement des tours discrets — les manœuvres résolvent la fiction, pas les tours. Utilisez `[COMBAT]` uniquement pour les conflits prolongés où le suivi des dégâts ou des niveaux de menace apporte une valeur ajoutée. Enregistrez les manœuvres avec leurs noms et résultats comme d'habitude.

```
[COMBAT]
[F:Gang×6|Menace 3|Proche]

@ En découdre (Seize by Force) — me jeter sur eux
d: 2d6+2=9 -> 7–9 Succès Faible
=> Je subis des dégâts : choisissez l'une de leurs balises.
[PJ:Alex|dégâts-1] [F:Gang×6|Menace-1|Menace 2]

[/COMBAT]
```

---

## Bonnes pratiques

**À faire : Adapter la notation à la complexité de la rencontre**

```
✔ Combat simple :
@ Frapper le garde
d: d20+4=15 vs CA 12 -> Touche, 1d8=5
=> Il tombe. Zone dégagée.

✔ Combat complexe :
S5 *Embuscade dans l'entrepôt* [COMBAT]
[F:Capitaine|PV 10|Proche] [F:Garde×2|PV 4 chacun|Moyen]
T1
@ Charger le Capitaine...
```

**À éviter : Sur-interpréter les rencontres simples**

```
✗ [COMBAT]
  T1 Liste : [PJ:Alex|PV 10] [F:Garde|PV 4|Proche|armé|alerte]
  @ Attaquer le garde
  d: d20+4=15 vs CA 10 -> Touche
  => [F:Garde|PV-6|mort]
  [/COMBAT]

✔ @ Abattre le garde solitaire avant qu'il ne puisse crier.
  d: d20+4=15 -> Touche, 6 dégâts. Mort.
```

**À faire : Utiliser `@(Nom)` pour tous les acteurs non-PJ**

```
✔ @(Brute B) Me prend de flanc
  d: d20+3=17 vs CA 15 -> Touche, 1d6=4
  => [PJ:Alex|PV-4]

✔ @(Jordan) Riposte
  d: d20+3=14 vs CA 11 -> Touche
  => [F:Pirate 1|mort]
```

**À éviter : Inventer de nouveaux symboles pour les actions des ennemis**

```
✗ ! La brute attaque : d20+3=17 -> Touche => PJ PV-4
✗ >> Le garde se jette sur moi : d20+2=12 -> Échec

✔ @(Brute) Attaque
  d: d20+3=17 -> Touche => [PJ:Alex|PV-4]
```

**À faire : Mettre à jour les balises d'ennemis à mesure que les stats changent**

```
✔ [F:Capitaine|PV 10|Proche]
  ...après 7 dégâts...
  [F:Capitaine|PV 3|chancelant]
```

**À éviter : Reconstruire l'état rétroactivement**

```
✗ (Cinq tours sans mises à jour intermédiaires)
  => Le capitaine est à 3 PV d'une manière ou d'une autre.

✔ Suivre les changements par tour : [F:Capitaine|PV-7|PV 3|chancelant]
```

**À faire : Écrire la conclusion comme une narration, pas seulement des balises**

```
✔ [/COMBAT]
  => Deux pirates morts, un en fuite, le capitaine s'est échappé par la mer.
  Jordan est blessé mais marche. J'ai des questions sur ce navire.
  [N:Jordan|blessé|PV 4] [Fil:Vengeance du Capitaine Pirate|Ouvert]
```

**À éviter : Terminer le combat avec seulement des mises à jour de balises**

```
✗ [/COMBAT]
  [N:Jordan|blessé|PV 4]
  [PJ:Alex|PV 5]
```

---

## Référence rapide

### Nouvelles balises

| Balise | Objectif | Exemple |
|--------|----------|---------|
| `[F:Nom\|stats]` | Suivre l'état d'un combattant individuel | `[F:Brute A\|PV 6\|Proche\|armé]` |
| `[F:Nom×#\|stats]` | Suivre un groupe de combattants identiques | `[F:Gobelin×3\|PV 3 chacun\|Proche]` |
| `[F:Nom\|PV-#]` | Raccourci de dégâts intégré | `[F:Brute A\|PV-3]` |
| `[F:Nom\|mort]` | Marquer un combattant comme éliminé | `[F:Brute A\|mort]` |
| `[F:Nom\|fui]` | Marquer un combattant comme ayant fui | `[F:Capitaine\|fui]` |

### Blocs structurels

| Bloc | S'ouvre quand | Se ferme quand |
|------|---------------|----------------|
| `[COMBAT]` | L'initiative est déclarée ou le combat commence | Tous les combattants sont résolus ou le combat prend fin |
| `[/COMBAT]` | — | Ferme le bloc `[COMBAT]` ouvert |

### Conventions

| Convention | Format | Exemple |
|------------|--------|---------|
| Marqueur de tour | `T#` | `T1`, `T2`, `T3` |
| Préfixe d'acteur | `@(Nom) Action` | `@(Brute A) Coup d'épée sur PJ` |
| Mouvement | `[Zone->Zone]` | `[Loin->Proche]` |
| Liste de tour | `T# Liste : [balises]` | `T3 Liste : [PJ:PV 3] [F:Boss\|PV 4]` |
| Note d'initiative | `T1 (Init : Nom #, …)` | `T1 (Init : Capitaine 18, Alex 15)` |

### Exemple complet

```
S9 *Embuscade sur les quais* [COMBAT]
[PJ:Alex|PV 12] [N:Jordan|allié|PV 8] [F:Capitaine Pirate|PV 10|Proche] [F:Pirate×2|PV 4|Moyen]

T1
@ Frapper le Capitaine d:19≥13 Touche 7 dégâts => [F:Capitaine|PV 3|chancelant]
@(Capitaine) Coup désespéré d:11≥14 Échec
@(Jordan) Tire sur un Pirate d:16≥11 Touche => [F:Pirate×1|mort]
@(Pirate) Lâche son arbalète, s'enfuit => [F:Pirate×1|fui]

[/COMBAT]
=> Le Capitaine s'est enfui par mer. Jordan blessé. Deux pirates à terre.
[N:Jordan|blessé|PV 4] [Fil:Vengeance du Capitaine Pirate|Ouvert]
```

---

## FAQ

**Q : Quand dois-je utiliser cette extension au lieu de la notation de base ?**
R : Lorsque le combat dure trois tours ou plus, quand plusieurs combattants agissent à chaque tour, ou quand l'ordre des tours et la position comptent pour l'histoire. Pour les combats à un seul jet, la notation de base suffit.

**Q : Dois-je suivre l'ordre d'initiative ?**
R : Seulement si votre système l'utilise et que cela a de l'importance. La plupart des joueurs solo suivent un ordre logique (menaces d'abord, puis PJ, puis alliés) ou suivent les règles de leur système. Pour le noter : `T1 (Init : Capitaine 18, Alex 15, Jordan 12, Pirates 8)`.

**Q : Ai-je besoin des balises `[F:]` ou puis-je simplement utiliser `[N:]` ?**
R : Les deux fonctionnent. `[F:]` est une commodité pour séparer les stats de combat des balises narratives de PNJ — cela garde votre index de PNJ plus propre dans les longues campagnes. Pour les combats simples, `[N:]` convient très bien.

**Q : Qu'en est-il des réactions, des interruptions ou des actions hors tour ?**
R : Enregistrez-les là où elles se produisent avec une note entre parenthèses : `@(Alex) Riposte (réaction)` ou `@ Attaque d'opportunité (interruption)`.

**Q : Comment gérer les effets de zone ou les attaques multi-cibles ?**
R : Listez les cibles et lancez les dés pour chacune, ou lancez une fois et appliquez à toutes :

```
@ Boule de feu ciblant Gobelin×3
d: 8d6=28, jet de sauvegarde Dex DD 14
d: Gobelin 1: 12≤14 Échec, Gobelin 2: 17≥14 Réussite, Gobelin 3: 8≤14 Échec
=> Deux gobelins incinérés. Un a esquivé, demi-dégâts. [F:Gobelin×1|PV 2|grillé]
```

**Q : Qu'en est-il du combat de véhicules, des scènes de poursuite ou des batailles de masse ?**
R : Cette extension couvre le combat à l'échelle individuelle. Ces scénarios peuvent justifier leurs propres extensions — mais les principes ici (marqueurs de tour, préfixes d'acteur, suivi de position) s'appliqueront.

**Q : Comment cela fonctionne-t-il dans un carnet analogique ?**
R : Utilisez `--- COMBAT ---` et `--- FIN COMBAT ---` comme délimiteurs. Les marqueurs de tour (`T1`, `T2`) fonctionnent tels quels. Pour les balises d'ennemis, écrivez-les dans la marge ou dans une colonne à côté du texte du tour. Mettez à jour les PV avec des ratures : ~~PV 6~~ PV 3.

**Q : Quand dois-je utiliser les listes de tour ?**
R : Quand vous avez cinq combattants ou plus et que les stats changent assez vite pour que vous perdiez le fil sans résumé. Pour les combats plus petits, le suivi des changements de manière intégrée avec les balises d'ennemis suffit.

---

## Crédits & Licence

© 2026 Roberto Bisceglie

Cette extension complète [Lonelog](https://zeruhur.itch.io/lonelog) par Roberto Bisceglie.

Écrit pour répondre aux clarifications soulevées par u/Electorcountdonut, basé sur des exemples fournis par u/AvernusIsAFurnace.

**Historique des versions :**

- v 1.1.0 : Les marqueurs de tour (T#) sont utilisés pour éviter les collisions avec d'autres extensions (comme [P:] pour les pièces dans l'Extension de Donjon). Alignement sur la logique de la version anglaise 1.1.0.
- v 1.0.0 : Première version

Ce travail est publié sous la licence **Creative Commons Attribution-ShareAlike 4.0 International**.

Vous êtes libre de partager et d'adapter ce matériel, à condition de donner le crédit approprié et de distribuer les adaptations sous la même licence. Les journaux de session et les enregistrements de jeu créés à l'aide de la notation de cette extension sont votre propre travail et ne sont pas soumis à cette licence.


