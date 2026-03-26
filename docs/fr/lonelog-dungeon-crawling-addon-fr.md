---
title: "Lonelog : Extension d'Exploration de Donjon"
subtitle: "Suivi de Pièces Optionnel pour l'Exploration de Donjon"
author: Roberto Bisceglie
version: 1.1.0
license: CC BY-SA 4.0
lang: fr
parent: Lonelog v1.3.0
requires: Notation de Base (§3)
Création: 2026-03-10 10:26
Modification: 2026-03-17 10:00
---

# Extension d'Exploration de Donjon

## Présentation

Lonelog a été conçu pour un jeu en solo axé sur la narration — le genre où vous vous souciez plus de *ce qui s'est passé et pourquoi* que de *où je suis et ce qu'il me reste*. L'exploration de donjon (dungeon crawling) tire dans une direction différente : les relations spatiales comptent, les pièces accumulent des états, et vous vous demandez constamment "ai-je déjà fouillé ce coffre ?".

Cette tension est réelle. Une notation textuelle ne remplacera jamais une bonne carte. Mais elle *peut* vous aider à suivre l'**état des pièces** — ce que vous avez trouvé, ce que vous avez nettoyé, ce qui attend encore derrière une porte verrouillée — aux côtés de la narration que Lonelog gère déjà bien.

Cette extension introduit un nouvel élément persistant : la balise de Pièce `[P:]` (Pièce). C'est tout. Tout le reste — actions, jets, questions à l'oracle, conséquences, fils conducteurs, horloges — reste exactement pareil. Vous ajoutez simplement les pièces au vocabulaire des choses que Lonelog peut suivre.

Si le donjon est plus un décor narratif qu'un défi mécanique, ou si vous vous déplacez rapidement dans des espaces sans suivre leur état, restez avec le cœur de Lonelog. La balise de lieu `[L:]` gère très bien le contexte spatial simple. Cette extension prouve son utilité lorsque les pièces ont un état significatif qui change au fil du temps.

---

### Ce que cette extension ajoute

| Ajout | Objectif | Exemple |
|-------|----------|---------|
| `[P:ID\|statut]` | Suivre l'état d'exploration actuel d'une pièce | `[P:3\|nettoyée]` |
| `[P:ID\|statut\|desc]` | Balise de pièce avec description optionnelle | `[P:3\|nettoyée\|bibliothèque]` |
| `sorties DIR:ID` | Enregistrer les connexions entre les pièces (optionnel) | `sorties N:P2, E:P3` |
| `[#P:ID]` | Faire référence à une pièce établie précédemment | `[#P:3]` |
| `[STATUT DU DONJON]` / `[/STATUT DU DONJON]` | Instantané de début de session de tous les états des pièces | Plusieurs balises `[P:]` groupées |

**Aucun nouveau symbole de base.** Cette extension n'introduit aucun ajout à `@`, `?`, `d:`, `->` ou `=>`.

---

### Principes de conception

**L'état avant l'espace.** Une carte gère les relations spatiales mieux que le texte ne le fera jamais. Les balises de pièces suivent ce qui a *changé* — nettoyé, fouillé, verrouillé — et non la position relative des pièces. Utilisez le bon outil pour chaque tâche.

**Vocabulaire minimal.** Une seule nouvelle balise couvre toute l'extension. Tous les autres éléments — en-têtes de scène, questions à l'oracle, conséquences, horloges — utilisent la notation de base que vous connaissez déjà. La charge cognitive pour ajouter l'exploration de donjon à une session Lonelog se résume à un format de balise.

**Conçu pour les cartes.** Les balises de pièces sont conçues pour fonctionner aux côtés d'une carte visuelle, pas pour la remplacer. Les identifiants de pièces (ID) relient votre journal à votre carte. Marquez-les sur du papier millimétré ; faites référence aux mêmes identifiants dans vos balises. Les deux systèmes se renforcent mutuellement.

**Les balises de bloc suivent la convention de base.** Les blocs structurels utilisent la syntaxe entre crochets `[BLOC]` / `[/BLOC]` — identique à `[COMBAT]` / `[/COMBAT]` dans l'Extension de Combat. Pour les carnets papier, utilisez des séparateurs en pointillés `--- BLOC ---` / `--- FIN BLOC ---` à la place.

---

## 1. La Balise de Pièce

La balise de Pièce `[P:]` (Pièce) suit l'état actuel d'une pièce. Elle fonctionne comme tout autre élément persistant de Lonelog : vous la balisez quand quelque chose change, vous la mettez à jour au fur et à mesure que la situation évolue, et vous y faites référence plus tard.

**Format :**

```
[P:ID|statut|description|sorties DIR:ID, DIR:ID]
```

**Champs :**

- `ID` — identifiant unique de la pièce, généralement un numéro (`1`, `2`, `3`) correspondant à votre carte
- `statut` — état d'exploration actuel (voir ci-dessous)
- `description` — étiquette brève optionnelle pour vous rafraîchir la mémoire
- `sorties` — connexions optionnelles vers les pièces adjacentes

#### 1.1 Statut de la Pièce

Le statut vous indique d'un coup d'œil l'état actuel d'une pièce. Utilisez les termes qui conviennent à votre jeu :

```
[P:1|inexplorée]          Pas encore entré
[P:1|active]              En cours d'exploration
[P:1|nettoyée]            Ennemis vaincus ou menaces résolues
[P:1|nettoyée, fouillée]  Nettoyée et trésor récupéré
[P:1|verrouillée]         Impossible d'entrer pour le moment
[P:1|piégée]              Danger connu présent
[P:1|sûre]                Vérifiée, utilisable comme refuge
[P:1|effondrée]           Plus accessible
```

Combinez les statuts quand cela fait sens : `nettoyée, fouillée` vous indique à la fois que le combat est terminé *et* qu'il n'y a plus rien à prendre.

**Exemple — minimal :**

```
[P:4|active]
```

**Exemple — développé :**

```
S5 *Couloir nord*

@ Ouvrir la porte avec précaution
? Est-elle verrouillée ?
-> Non (d6=5)
=> La porte s'ouvre facilement.

[P:4|active|salle de stockage, étagères poussiéreuses|sorties S:P2, E:P5]

@ Fouiller les étagères
d: Investigation d6=5 vs ND 4 -> Succès
=> Je trouve une clé rouillée derrière une brique desserrée.
(note : pourrait ouvrir P5 ?)

? Y a-t-il des ennemis ?
-> Non, et... (d6=6)
=> La pièce est totalement calme. Des années de poussière.

[P:4|nettoyée, fouillée]
```

#### 1.2 Mise à jour du statut d'une pièce

Quand l'état d'une pièce change, répétez la balise avec le nouveau statut :

```
[P:1|inexplorée]

... vous entrez et combattez ...

[P:1|nettoyée]

... vous fouillez ...

[P:1|nettoyée, fouillée]
```

Ou utilisez le raccourci intégré pour un ajout de statut unique :

```
[P:1|+fouillée]
```

#### 1.3 Descriptions des pièces

Le champ de description est optionnel et bref — juste assez pour vous rafraîchir la mémoire :

```
[P:1|nettoyée|salle de garde]
[P:2|active|bibliothèque, bougies encore allumées]
[P:3|inexplorée|bruits d'eau]
```

Pour des descriptions plus riches, utilisez la narration régulière de Lonelog après la balise :

```
[P:4|active|chambre rituelle]
=> L'air vibre d'énergie. Un cercle de runes brille faiblement sur le sol.
```

#### 1.4 Balises de référence

Utilisez `#` pour faire référence à une pièce que vous avez déjà décrite, exactement comme pour les PNJ et les lieux dans le cœur de Lonelog :

```
[P:3|nettoyée|armurerie|sorties N:P2, O:P4]    (première mention)

... plus tard ...

[#P:3]                                         (référence à celle-ci)
```

---

## 2. Connexions entre les pièces

Pour enregistrer quelles pièces sont connectées, utilisez le mot-clé `sorties` à l'intérieur de la balise :

```
[P:1|nettoyée|salle de garde|sorties N:P2, E:P3, S:P4]
```

Lisez ceci comme : "La pièce 1 est nettoyée, c'est une salle de garde, avec des sorties au nord vers la pièce 2, à l'est vers la pièce 3, et au sud vers la pièce 4."

**Raccourcis de direction :** `N` (Nord), `S` (Sud), `E` (Est), `O` (Ouest), `NE`, `NO`, `SE`, `SO`, `H` (Haut), `B` (Bas).

Si la direction n'a pas d'importance, listez simplement les connexions :

```
[P:5|inexplorée|sorties P4, P6, P7]
```

**Vous n'êtes pas obligé d'enregistrer les sorties.** Si vous tenez une carte visuelle, les sorties y figurent et vous n'avez besoin de la balise de pièce que pour le statut. Le mot-clé `sorties` est utile lorsque vous voulez un enregistrement entièrement textuel, ou lorsque vous découvrez une connexion spécifique en cours de jeu :

```
=> Je trouve un passage secret derrière la bibliothèque !
[P:3|sorties E:P7(secret)]
```

**Exemple — minimal :**

```
[P:6|inexplorée|sorties P5, P8]
```

**Exemple — développé :**

```
@ Vérifier s'il y a des sorties sur le mur du fond
d: Perception d6=6 vs ND 4 -> Succès
=> Une porte dissimulée — bien cachée mais pas verrouillée.
[P:6|active|crypte|sorties O:P5, N:P8, E:P9(secret)]
(note : mettre à jour la carte avec P9)
```

---

## 3. Le Bloc de Statut du Donjon

Lorsque vous reprenez une session au milieu d'un donjon, vous avez besoin d'un instantané : quelles pièces sont nettoyées, où n'êtes-vous pas encore allé, qu'est-ce qui est encore verrouillé. Le **Bloc de Statut du Donjon** vous donne cela d'un coup d'œil.

**Format :**

```
[STATUT DU DONJON]
[P:1|statut|description]
[P:2|statut|description]
...
[/STATUT DU DONJON]
```

**Quand ouvrir un bloc :** Au début d'une session lors de la reprise d'une exploration de donjon, avant votre première scène.

**Quand le mettre à jour :** À la fin de la session, ou au début de la session suivante, pour refléter les changements.

**Exemple numérique :**

```
[STATUT DU DONJON]
[P:1|nettoyée, fouillée|grotte d'entrée|sorties N:P2, E:P3]
[P:2|nettoyée|salle de garde|sorties S:P1, O:P5]
[P:3|active|bibliothèque|sorties O:P1]
[P:4|inexplorée]
[P:5|verrouillée|porte lourde|sorties E:P2]
[/STATUT DU DONJON]
```

**Exemple analogique :**

```
--- STATUT DU DONJON ---
P1 : nettoyée, fouillée (grotte d'entrée)
P2 : nettoyée (salle de garde)
P3 : active (bibliothèque)
P4 : inexplorée
P5 : verrouillée
--- FIN STATUT ---
```

**C'est une commodité, pas une exigence.** Si votre donjon ne compte que trois pièces, vous n'avez pas besoin d'un bloc de statut — balisez simplement les pièces au fur et à mesure. Pour les donjons plus vastes, ou lors de la reprise d'une session après une pause, c'est un moyen rapide de s'orienter.

---

## 4. Les Balises de Pièces en Jeu

#### 4.1 Pièces comme en-têtes de scène

Utilisez une balise de pièce directement dans votre en-tête de scène pour un contexte compact :

```
S5 [P:4|active] *Salle de stockage, étagères poussiéreuses*
```

Cela vous indique exactement où se déroule la scène sans ligne de balise séparée. Certains joueurs préfèrent cela pour séparer les descriptions de scène et les balises de pièces.

#### 4.2 Donjons générés

Si vous générez le donjon au fur et à mesure (en utilisant des tables aléatoires ou un oracle), enregistrez la génération aux côtés de la balise de pièce :

```
@ Ouvrir la porte est
tbl: d20=14 -> "Grande pièce, deux sorties"

? Qu'y a-t-il à l'intérieur ?
tbl: d100=67 -> "Bibliothèque avec un coffre piégé"

[P:6|active|bibliothèque, coffre piégé|sorties O:P3, N:P7]
```

Les jets de génération vous indiquent *comment* vous avez découvert la pièce. La balise de pièce vous indique *ce qu'elle est maintenant*.

#### 4.3 Cartes et Lonelog

Soyons directs : **une carte visuelle est presque toujours meilleure que le texte pour les relations spatiales.** Papier millimétré, outil numérique, croquis rapide sur une serviette — peu importe ce qui fonctionne. Le rôle de la balise de pièce n'est pas de remplacer votre carte. C'est de suivre un état qu'une carte gère mal : si une pièce est nettoyée, ce que vous y avez trouvé, comment son statut a changé au cours du jeu.

La répartition recommandée :

- **La carte** gère la disposition, les relations spatiales et la navigation.
- **Les balises de pièces** gèrent l'état, les changements de statut et le contexte narratif.
- **Le cœur de Lonelog** gère tout le reste (actions, jets, conséquences, histoire).

Marquez les numéros de pièces sur votre carte. Utilisez ces mêmes numéros dans vos balises de pièces. Votre carte et votre journal se font maintenant mutuellement référence de manière transparente :

```
S7 [P:4] *Examen de l'autel*

@ Fouiller l'autel
d: Investigation d6=6 vs ND 4 -> Succès
=> Compartiment secret ! [Fil:Rituel du Culte|Ouvert]
[P:4|nettoyée, fouillée]

(note : marquer P4 comme nettoyée sur la carte)
```

Si vous voulez un journal de donjon **entièrement textuel** sans carte séparée, le mot-clé `sorties` vous permet de reconstruire la disposition à partir de vos notes. Mais c'est l'exception, pas la recommandation.

---

## Interactions entre extensions

| Situation | Extension(s) utilisée(s) | Balises/Blocs clés |
|-----------|--------------------------|--------------------|
| Un combat éclate dans une pièce | Exploration de Donjon + Combat | `[P:]`, `[COMBAT]`, `[F:]` |
| Suivi des torches et rations par pièce | Exploration de Donjon + Suivi des Ressources | `[P:]`, `[Inv:Nom\|#]` |
| Combat tout en suivant les ressources | Les trois extensions | `[P:]`, `[COMBAT]`, `[Inv:]` |

**Exemple combiné — Exploration de Donjon + Combat :**

```
S6 *Approche des casernes*

@ Se déplacer silencieusement dans le couloir
d: Discrétion d6=4 vs ND 4 -> Succès
=> Je rampe vers l'avant sans être vu.

[P:5|active|casernes, odeur de sueur|sorties S:P3, O:P6, N:P7]

? Combien de gardes ?
tbl: d6=3 -> "Trois ennemis"
=> Deux mangent, un aiguise une lame.

[COMBAT]
[PJ:Alex|PV 12|Engagé]
[F:Garde 1|PV 5|Proche|mange]
[F:Garde 2|PV 5|Proche|mange]
[F:Garde 3|PV 5|Proche|alerte]

@ Embusquer le garde alerte en premier
d: d20+4=18 vs CA 12 -> Touche, 1d8=7
=> [F:Garde 3|mort]

@(Garde 1) Attrape son arme et charge
d: d20+3=11 vs CA 14 -> Échec

P2
@ Frapper les deux gardes restants
d: d20+4=15 vs CA 12 -> Touche, 1d8=5 => [F:Garde 1|mort]
d: d20+4=12 vs CA 12 -> Touche, 1d8=3 => [F:Garde 2|mort]

[/COMBAT]
=> Pièce nettoyée avant qu'ils ne puissent sonner l'alarme.
[P:5|nettoyée]

@ Fouiller les casernes
tbl: d20=8 -> "Rations et une carte rudimentaire"
=> Une carte grossière tracée sur une peau. Indique des pièces à l'ouest !
[P:5|nettoyée, fouillée]
[P:6|inexplorée|indiquée sur la carte orc]
(note : mettre à jour ma carte avec P6)
```

---

## Adaptations du système

### Systèmes OSR (Old School Essentials, Basic/Expert D&D)

Les procédures classiques d'exploration de donjon s'adaptent naturellement à cette extension. L'exploration au tour par tour, les tests de monstres errants et la structure de tour de dix minutes génèrent des points de mise à jour de balises naturels. Utilisez des balises de pièces à la fin de chaque tour ou quand quelque chose d'important change.

```
[STATUT DU DONJON]
[P:1|nettoyée, fouillée|hall d'entrée|sorties N:P2, E:P3]
[P:2|nettoyée|salle de garde|sorties S:P1, O:P5]
[P:3|active|crypte|sorties O:P1, B:P8]
[/STATUT DU DONJON]

S4 *P3 – Crypte, tour 3*

@ Fouiller les sarcophages
d: Test de porte secrète 1-sur-6 : d6=2 -> Rien trouvé
? Test de monstre errant
-> Non (d6=5)

@ Allumer les appliques murales et examiner les inscriptions
d: Test INT d20=8 vs DD 12 -> Échec
=> L'écriture est trop archaïque — je n'arrive pas à la comprendre.
[P:3|nettoyée]
(note : réserve de torches -1 pour ce tour)
```

### Ironsworn / Starforged

La mécanique *Delve* d'Ironsworn utilise des secteurs thématiques plutôt que des pièces numérotées. Faites correspondre les secteurs aux ID de pièces et utilisez le résultat de la manœuvre `Delve the Depths` pour déterminer ce que vous trouvez. Les jauges de progression fonctionnent naturellement aux côtés du statut de la pièce.

```
[Jauge:Tertre de Fer|Progression 2/10]

[STATUT DU DONJON]
[P:1|nettoyée|Seuil – grille rouillée|sorties N:P2]
[P:2|active|Ombre – couloir effondré]
[/STATUT DU DONJON]

@ Delve the Depths (thème Ombre)
d: d6+2=7 vs d10=4, d10=9 -> Succès Faible
tbl: Élément d'Ombre : d100=44 -> "Symboles d'un dieu oublié"
=> Je trouve des marquages rituels. Progression, mais à un prix.
[Jauge:Tertre de Fer|Progression+2|4/10]
[P:2|nettoyée|Ombre – marquages oubliés|sorties N:P3]
[P:3|inexplorée]
[Fil:Le Dieu Oublié|Ouvert]
```

---

## Bonnes pratiques

**À faire : Utiliser les balises de pièces pour l'état, votre carte pour l'espace**

```
✔ [P:4|nettoyée, fouillée]
  (note : marquer P4 nettoyée sur la carte)
```

**À éviter : Essayer de remplacer votre carte par des chaînes de sorties**

```
✗ [P:1|nettoyée|sorties N:P2, E:P3]
  [P:2|nettoyée|sorties S:P1, N:P4, E:P5]
  [P:3|active|sorties O:P1, N:P6, E:P7, SE:P8]
  (C'est plus difficile à naviguer qu'un croquis)

✔ Dessinez la carte. Utilisez les balises de pièces uniquement pour l'état.
```

**À faire : Mettre à jour le statut immédiatement quand il change**

```
✔ @ Fouiller la pièce après le combat
  d: Investigation d6=5 vs ND 4 -> Succès
  => Je trouve une clé et quelques pièces.
  [P:3|nettoyée, fouillée]
```

**À éviter : Laisser le statut ambigu et reconstruire plus tard**

```
✗ (Trois scènes d'exploration sans mise à jour de balises)
  (note : je crois que P3 et P4 sont nettoyées ? à vérifier)

✔ Balisez chaque changement au fur et à mesure qu'il se produit.
```

**À faire : Ouvrir un Bloc de Statut du Donjon lors de la reprise d'une session**

```
✔ [STATUT DU DONJON]
  [P:1|nettoyée, fouillée|entrée]
  [P:2|nettoyée|casernes]
  [P:3|inexplorée]
  [P:4|verrouillée|porte de fer]
  [/STATUT DU DONJON]
```

**À éviter : Reconstruire l'état du donjon en scannant tout le journal**

```
✗ (Faire défiler deux sessions de notes pour savoir quelles
   pièces sont nettoyées)

✔ Écrivez le bloc de statut à la fin de la session. Commencez la session
  suivante avec une image actuelle.
```

---

## Référence rapide

### Nouvelles balises

| Balise | Objectif | Exemple |
|--------|----------|---------|
| `[P:ID\|statut]` | Pièce avec statut uniquement | `[P:3\|nettoyée]` |
| `[P:ID\|statut\|desc]` | Pièce avec description | `[P:3\|nettoyée\|bibliothèque]` |
| `[P:ID\|statut\|desc\|sorties]` | Pièce avec connexions | `[P:3\|nettoyée\|bibliothèque\|sorties O:P1]` |
| `[P:ID\|+statut]` | Ajouter un statut intégré | `[P:3\|+fouillée]` |
| `[#P:ID]` | Faire référence à une pièce établie | `[#P:3]` |

### Termes de statut

| Statut | Signification |
|--------|---------------|
| `inexplorée` | Pas encore entré |
| `active` | En cours d'exploration |
| `nettoyée` | Menaces résolues |
| `nettoyée, fouillée` | Nettoyée et fouillée |
| `verrouillée` | Impossible d'entrer pour le moment |
| `piégée` | Danger connu présent |
| `sûre` | Vérifiée, utilisable comme refuge |
| `effondrée` | Plus accessible |

### Blocs structurels

| Bloc | S'ouvre quand | Se ferme quand |
|------|---------------|----------------|
| `[STATUT DU DONJON]` / `[/STATUT DU DONJON]` | Début de session lors de la reprise d'un donjon | Remplacé par le bloc mis à jour à la session suivante |

### Raccourcis de direction

`N` `S` `E` `O` `NE` `NO` `SE` `SO` `H` (haut) `B` (bas)

### Exemple complet

```
[STATUT DU DONJON]
[P:1|nettoyée, fouillée|grotte d'entrée|sorties N:P2, E:P3]
[P:2|inexplorée] [P:3|inexplorée]
[/STATUT DU DONJON]

S7 *Passage nord*

@ S'approcher de P2 silencieusement
d: Discrétion d6=4 vs ND 4 -> Succès

[P:2|active|casernes|sorties S:P1, O:P4]
? Ennemis ? -> Oui (d6=2) => Deux gardes, armés.
...combat...
[P:2|nettoyée, fouillée]
[P:4|inexplorée|indiquée sur la carte du garde]
```

---

## FAQ

**Q : Ai-je besoin d'une carte séparée, ou puis-je utiliser les sorties pour suivre la disposition ?**
R : Une carte visuelle est presque toujours meilleure pour la disposition et la navigation. Utilisez les sorties dans vos balises de pièces uniquement quand vous voulez un enregistrement entièrement textuel, ou quand vous découvrez une connexion spécifique (comme une porte secrète) qui mérite d'être notée dans le journal. Pour tout le reste, dessinez la carte.

**Q : Quel système d'ID de pièce dois-je utiliser ?**
R : Les chiffres sont les plus simples (`P1`, `P2`, `P3`) et correspondent naturellement à une carte numérotée. Vous pouvez aussi utiliser des codes qui reflètent la structure (`P1-A`, `P1-B` pour des sous-pièces, ou `N1-1`, `N1-2` pour niveau-et-pièce). Utilisez ce qui vous aide à relier les balises à votre carte d'un coup d'œil.

**Q : Puis-je utiliser ceci avec l'Extension de Combat ?**
R : Oui — elles sont conçues pour fonctionner ensemble. Lorsqu'un combat éclate dans une pièce, ouvrez un bloc `[COMBAT]` dans la scène. Quand il se termine, fermez-le et mettez à jour le statut de la balise de pièce. La section Interactions entre extensions propose un exemple complet.

**Q : Que faire si j'utilise un donjon publié avec sa propre numérotation des pièces ?**
R : Utilisez les numéros de pièces du document publié comme ID. `[P:12|nettoyée|Terriers Gobelins p.4]` fonctionne parfaitement — la carte publiée gère la disposition, la balise gère l'état.

**Q : Comment le Bloc de Statut du Donjon fonctionne-t-il dans un carnet analogique ?**
R : Écrivez-le avec des séparateurs en pointillés : `--- STATUT DU DONJON ---`. Listez une pièce par ligne avec son statut et une brève étiquette. Rayez ou mettez à jour les entrées au fur et à mesure que les pièces changent. Au début de chaque nouvelle session, écrivez un nouveau bloc de statut avec les informations actuelles plutôt que de corriger l'ancien.

**Q : Dois-je baliser chaque pièce que je traverse ?**
R : Uniquement les pièces où il se passe quelque chose qui mérite d'être suivi. Si vous marchez dans un couloir vide, vous n'avez pas besoin de balise — décrivez-le simplement en prose. Balisez les pièces quand leur statut a une signification : quand vous les nettoyez, trouvez quelque chose, les verrouillez ou devez y revenir plus tard.

**Q : Qu'en est-il des éléments du donjon qui ne sont pas des pièces — couloirs, pièges, portes ?**
R : Utilisez la notation de base de Lonelog. Les portes et les pièges sont des événements (`[E:]`) ou un contexte temporaire en prose. Les couloirs n'ont généralement pas besoin d'un suivi persistant. La balise de pièce est spécifiquement destinée aux espaces ayant un état continu qui compte sur plusieurs scènes ou sessions.

---

## Crédits & License

© 2025 Roberto Bisceglie

Cette extension complète [Lonelog](https://zeruhur.itch.io/lonelog) par Roberto Bisceglie.

**Historique des versions :**

- v 1.1.0 : Les balises de bloc sont unifiées avec la convention `[BLOC]`/`[/BLOC]` ; principes de conception mis à jour
- v 1.0.0 : Réécrit comme une extension conforme (auparavant "Module d'Exploration de Donjon")
