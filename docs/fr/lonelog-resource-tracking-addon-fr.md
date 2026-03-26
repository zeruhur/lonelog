---
title: "Lonelog : Extension de Suivi des Ressources"
subtitle: "Notation pour l'Inventaire, les Ravitaillements et la Richesse"
author: Roberto Bisceglie
version: 1.1.0
license: CC BY-SA 4.0
lang: fr
parent: Lonelog v1.3.0
requires: Notation de Base (§3), Éléments Persistants (§4.1), Suivi de la Progression (§4.2)
---

# Extension de Suivi des Ressources

## Présentation

Certains jeux ne se soucient pas de ce qu'il y a dans votre sac. D'autres traitent chaque torche, chaque ration, chaque dernière flèche comme une décision qui compte. Cette extension est destinée au deuxième type.

Le cœur de Lonelog gère déjà un suivi léger des ressources — vous pouvez mettre `Équipement:Lampe,Carnet` dans une balise `[PJ:]` et en rester là. Cela fonctionne bien quand les ressources sont purement narratives. Mais quand votre jeu fait de la gestion des ressources une *mécanique* — quand manquer de torches dans un donjon signifie quelque chose, quand le Dé d'Usage qui diminue crée une réelle tension, quand vous avez besoin de savoir exactement combien de pièces d'argent il vous reste — vous avez besoin de plus de structure.

C'est ce que cette extension apporte : une couche de notation dédiée au suivi des ressources au fur et à mesure qu'elles entrent et sortent de votre jeu.

Si votre système gère les ravitaillements de manière abstraite ou résout la rareté des ressources par une simple question à l'oracle, vous n'avez pas besoin de cette extension. La balise `[PJ:]` du cœur de Lonelog avec un champ `Équipement:` est plus que suffisante.

---

### Ce que cette extension ajoute

| Ajout | Objectif | Exemple |
|-------|----------|---------|
| `[Inv:Objet\|qté\|props]` | Suivre les objets individuels avec quantité et propriétés | `[Inv:Torche\|3]` |
| Notation de Ravitaillement | Niveaux de ressources abstraits dans `[PJ:]` | `[PJ:Kael\|Ravitaillement d8]` |
| `[Richesse:Monnaie N]` | Suivi de la monnaie et des échanges | `[Richesse:Or 45\|Argent 12]` |
| `[RESSOURCES]` / `[/RESSOURCES]` | Instantané des ressources actuelles aux limites de session | Voir §5 |

**Aucun nouveau symbole de base.** Cette extension n'introduit aucun ajout à `@`, `?`, `d:`, `->` ou `=>`.

---

### Principes de conception

**Suivez ce que le jeu suit.** Si votre système utilise des Dés d'Usage, utilisez la notation du Dé d'Usage. S'il compte les flèches individuelles, comptez les flèches individuelles. S'il ignore les ravitaillements, n'inventez pas un suivi qui n'existe pas.

**Séparez ce que vous portez de qui vous êtes.** La balise `[PJ:]` décrit votre personnage — PV, stress, conditions, ressources abstraites qui ressemblent à des stats. La balise `[Inv:]` décrit vos affaires — des choses concrètes, dénombrables, qui vont et viennent. Cette séparation maintient les deux balises lisibles au fur et à mesure que votre campagne progresse.

**Enregistrez les changements au point de fiction.** Ne tenez pas un tableur d'inventaire séparé que vous mettriez à jour silencieusement. Montrez le changement des ressources *quand elles changent*, au sein des actions et des conséquences qui le causent. Votre journal doit raconter l'histoire de vos ressources, pas seulement leur état actuel.

**Les balises de bloc suivent la convention de base.** Les blocs structurels utilisent la syntaxe entre crochets `[BLOC]` / `[/BLOC]` — identique à `[COMBAT]` / `[/COMBAT]` dans l'Extension de Combat. Pour les carnets papier, utilisez des séparateurs en pointillés `--- BLOC ---` / `--- FIN BLOC ---` à la place.

---

## 1. La Balise d'Inventaire

La balise `[Inv:]` suit un objet ou une ressource spécifique et concret. C'est la chose que vous pouvez ramasser, utiliser, lâcher, échanger ou perdre.

**Format :**

```
[Inv:Objet|quantité|propriétés]
```

**Champs :**

- `Objet` — le nom de l'objet, suffisamment unique pour être recherché dans un journal
- `quantité` — un nombre simple ; à omettre pour les objets uniques ou singuliers
- `propriétés` — format libre ; utilisez pour le poids, l'état, le statut magique, le type de munition ou tout ce qui importe à votre jeu

**Exemples :**

```
[Inv:Torche|3]
[Inv:Corde|1|15m]
[Inv:Potion de soin|2|magique|rend d8 PV]
[Inv:Rations|5|jours]
[Inv:Flèche|12]
```

**Objets uniques ou singuliers** (pas de quantité nécessaire) :

```
[Inv:Passe-partout|unique]
[Inv:Boussole paternelle|quête]
[Inv:Carte des Ruines]
```

#### 1.1 Acquérir des objets

Lorsque vous acquérez quelque chose, introduisez-le avec une balise `[Inv:]` complète, tout comme vous introduisez un PNJ avec `[N:]` :

**Exemple — minimal :**

```
=> Je trouve des fournitures ! [Inv:Torche|4] [Inv:Corde|1|15m] [Inv:Or|25]
```

**Exemple — développé :**

```
@ Fouiller le coffre
d: Investigation d6=5 vs ND 4 -> Succès
=> À l'intérieur : torches, corde, un peu de monnaie.
[Inv:Torche|4] [Inv:Corde|1|15m] [Inv:Or|25]

@ Fouiller le garde tombé
=> [Inv:Épée courte|1|rouillée] [Inv:Rations|2|jours]

tbl: d100=67 -> "Une étrange amulette"
=> [Inv:Amulette d'os|1|inconnue|magique ?]
```

#### 1.2 Consommer et perdre des objets

Deux approches, même résultat — choisissez ce qui convient à votre flux de jeu.

**Approche A : À la suite des conséquences**

L'épuisement se produit à l'intérieur de la ligne `=>`, dans le cadre de la fiction :

```
=> Le tunnel est d'un noir absolu. J'allume une torche. [Inv:Torche|3→2]
=> Je panse la blessure avec ma dernière potion de soin. [Inv:Potion de soin|0|épuisée]
=> La flèche atteint son but. [Inv:Flèche|12→11]
```

**Approche B : Mise à jour autonome**

L'épuisement a sa propre ligne, séparée de la narration :

```
=> Le tunnel est d'un noir absolu. J'allume une torche.
[Inv:Torche-1]

=> Je panse la blessure.
[Inv:Potion de soin-1]
```

**Laquelle utiliser ?** L'approche A est plus compacte et maintient le flux des ressources visible dans la fiction. L'approche B est plus claire lorsque plusieurs choses changent à la fois, ou lorsque vous voulez séparer visuellement la narration de la comptabilité. Beaucoup de joueurs mélangent les deux selon le contexte.

**Raccourcis pour les changements de quantité :**

```
[Inv:Torche-1]         (consommé une)
[Inv:Torche+2]         (trouvé deux de plus)
[Inv:Torche|0]         (explicite : il n'en reste aucune)
[Inv:Torche|3→1]       (explicite : était à 3, maintenant 1)
[Inv:Torche|épuisée]   (vide — marque l'objet comme disparu)
```

#### 1.3 Changements d'état des objets

Les objets n'apparaissent et ne disparaissent pas seulement — ils se cassent, sont réparés, deviennent maudits, épuisent leurs charges. Utilisez les propriétés pour suivre cela :

```
[Inv:Épée courte|1|rouillée]              (état initial)
[Inv:Épée courte|1|rouillée→réparée]      (changement d'état avec flèche)
[Inv:Épée courte|1|+enchantée]            (propriété ajoutée)
[Inv:Épée courte|1|-rouillée|+affûtée]    (retirée et ajoutée)
```

**Raccourcis de condition :**

```
[Inv:Lanterne|1|cassée]
[Inv:Bouclier|1|fissuré]
[Inv:Rations|3|avariées]
[Inv:Baguette|1|charges 2/5]
```

Cela reflète la convention `+`/`-` déjà utilisée pour les mises à jour de statut de PNJ dans le cœur de Lonelog.

#### 1.4 Balises de référence pour les objets

Tout comme les PNJ, utilisez `#` pour les objets déjà établis :

```
[Inv:Amulette d'os|1|inconnue|magique ?]   (première mention — détails complets)

... plus loin dans le journal ...

@ Examiner l'amulette de plus près
d: Arcanes d6=6 vs ND 5 -> Succès
=> [#Inv:Amulette d'os] — c'est une protection contre les morts-vivants !
[Inv:Amulette d'os|1|Protection des Morts|+identifiée]
```

#### 1.5 Objets groupés et en vrac

Certains jeux suivent des lots plutôt que des objets individuels. Utilisez le multiplicateur `×` ou le groupement descriptif :

```
[Inv:Flèche×20]                    (notation de lot)
[Inv:Kit d'aventure|1|contient : corde, pitons, torche×2, rations×3]
[Inv:Carquois|1|Flèche×15]         (contenant avec contenu)
```

Pour les systèmes d'inventaire basés sur des emplacements (slots) :

```
[Inv:Slot 1|Épée courte]
[Inv:Slot 2|Bouclier|fissuré]
[Inv:Slot 3|Torche×3]
[Inv:Slot 4|vide]
```

---

## 2. Suivi de Ravitaillement Abstrait

De nombreux systèmes solo utilisent des mécaniques abstraites pour représenter "à quel point êtes-vous bien ravitaillé ?" — Dés d'Usage (Black Hack, Macchiato Monsters), Jauges de Ravitaillement (Ironsworn) ou simples niveaux qualitatifs. Ceux-ci ressemblent plus à des statistiques de personnage qu'à de l'inventaire, ils vivent donc dans la balise `[PJ:]` aux côtés des PV, du Stress et d'autres attributs abstraits.

#### 2.1 Dés d'Usage (Usage Dice)

Le Dé d'Usage est un pilier du jeu solo de type OSR. Vous avez un dé représentant le niveau de ravitaillement — lancez-le quand vous utilisez une ressource. Sur un 1–2, le dé diminue d'un rang. Lorsqu'il descend en dessous de d4, la ressource est épuisée.

**Format :**

```
[PJ:Kael|Ravitaillement d8]
[PJ:Kael|Lumière d6]
[PJ:Kael|Munitions d10]
```

**Exemple — minimal :**

```
d: Ravitaillement d8=2 -> Diminution !
=> [PJ:Kael|Ravitaillement d8→d6]
```

**Exemple — développé :**

```
@ Établir le camp, utiliser des provisions
d: Ravitaillement d8=2 -> Diminution !
=> Les provisions s'amenuisent. [PJ:Kael|Ravitaillement d8→d6]

@ Tirer une autre salve
d: Munitions d6=1 -> Diminution !
=> À court de flèches. [PJ:Kael|Munitions d6→d4]

@ Allumer une autre torche
d: Lumière d4=2 -> Épuisé !
=> La dernière torche s'éteint. [PJ:Kael|Lumière épuisée]
```

**La chaîne de diminution :** `d12 → d10 → d8 → d6 → d4 → épuisé`

#### 2.2 Jauges de Ravitaillement

Certains systèmes utilisent des jauges numérotées pour le ravitaillement — similaires aux jauges de progression mais comptant à rebours au fur et à mesure que les ressources sont dépensées.

**Format :**

```
[PJ:Kael|Ravitaillement 5/5]
```

**Exemple — minimal :**

```
=> Je campe et je mange. [PJ:Kael|Ravitaillement 5→4]
```

**Exemple — développé :**

```
=> Je campe et je mange. [PJ:Kael|Ravitaillement 5→4]
=> Je cherche de la nourriture avec succès. [PJ:Kael|Ravitaillement 4→5]
=> Désespéré — je mange le dernier morceau. [PJ:Kael|Ravitaillement 1→0|affamé]
```

C'est fonctionnellement la même chose que le `[Compteur:]` du cœur de Lonelog utilisé pour les ressources. La différence est sémantique : un Compteur est un dispositif de pression narrative, tandis qu'une jauge de Ravitaillement à l'intérieur de `[PJ:]` est une statistique de personnage. Utilisez le cadre qui correspond à votre jeu.

#### 2.3 Niveaux qualitatifs

Pour les jeux qui n'utilisent pas de chiffres du tout — ou quand vous voulez suivre une ressource de manière lâche :

```
[PJ:Kael|Provisions : abondantes]
[PJ:Kael|Provisions : adéquates]
[PJ:Kael|Provisions : basses]
[PJ:Kael|Provisions : critiques]
[PJ:Kael|Provisions : épuisées]
```

**Mise à jour :**

```
=> Après trois jours dans les terres désolées, la nourriture est rare.
[PJ:Kael|Provisions : abondantes→basses]
```

Vous pouvez définir vos propres niveaux. Ils ne sont pas codés en dur — utilisez le vocabulaire que votre jeu fournit ou qui vous semble approprié.

---

## 3. Richesse et Monnaie

L'argent se comporte différemment de l'équipement. Vous ne suivez généralement pas chaque pièce comme un "objet" — vous suivez des totaux, et ces totaux changent par les dépenses, les gains, les pillages et les échanges.

#### 3.1 La Balise de Richesse

Pour les jeux avec une monnaie concrète, utilisez la balise `[Richesse:]` :

**Format :**

```
[Richesse:Or 45|Argent 12|Cuivre 30]
[Richesse:Crédits 1500]
[Richesse:Capsules 87]
```

**Exemple — minimal :**

```
=> Bon prix ! [Richesse:Or+15]
=> [Richesse:Or-8] [Inv:Rations|5|jours] [Inv:Corde|1|15m]
```

**Exemple — développé :**

```
@ Vendre la dague ornée au marchand
d: Persuasion d6=5 vs ND 4 -> Succès
=> Bon prix ! [Richesse:Or+15]

@ Acheter des rations et une nouvelle corde
=> [Richesse:Or-8] [Inv:Rations|5|jours] [Inv:Corde|1|15m]
```

**État complet vs mises à jour delta :**

```
[Richesse:Or 45]       (total explicite)
[Richesse:Or+15]       (gagné 15)
[Richesse:Or-8]        (dépensé 8)
[Richesse:Or 45→52]    (était à 45, maintenant 52)
```

#### 3.2 Richesse abstraite

Certains jeux ne comptent pas les pièces — ils utilisent des niveaux de richesse ou des jets de ressources :

```
[PJ:Kael|Richesse : aisé]
[PJ:Kael|Richesse d8]               (Dé d'Usage pour la richesse)
[PJ:Kael|Ressources 3/5]             (basé sur une jauge)
```

Ceux-ci vivent dans `[PJ:]` plutôt que dans `[Richesse:]`, car la richesse abstraite ressemble plus à une stat qu'à un grand livre de comptes.

#### 3.3 Échange et troc

Pour les transactions, enregistrez les deux côtés :

```
@ Échanger l'amulette contre le passage
=> [Inv:Amulette d'os|épuisée] -> [Fil : Passage vers Port-Nord|Ouvert]

@ Troquer des rations contre des informations
=> [Inv:Rations-2] Le pêcheur me parle des grottes marines.
```

Aucune syntaxe spéciale n'est nécessaire — la notation de conséquence existante gère naturellement les échanges. La clé est d'enregistrer *ce qui est parti* et *ce qui est arrivé*.

---

## 4. Événements de Ressources

Les ressources interagissent avec le reste de votre jeu. Ces modèles montrent comment les ressources se connectent aux actions, aux questions à l'oracle et aux pressions constantes.

#### 4.1 Tests de ressources

Quand le jeu demande "en avez-vous assez ?" :

```
@ Traverser la rivière gelée
? Ai-je assez de corde ?
-> Oui (vérification : [#Inv:Corde] 15m — la rivière fait environ 10m de large)
=> J'ancre la corde et je traverse en toute sécurité. [Inv:Corde|1|15m|effilochée]

@ Camper dans la nature sauvage
d: Ravitaillement d8=1 -> Diminution !
=> La nourriture vient à manquer. [PJ:Kael|Ravitaillement d8→d6]
? Trouvé-je de l'eau à proximité ?
-> Non, mais...
=> Un lit de ruisseau à sec — si je le suis, peut-être demain.
[Compteur:Déshydratation 2]
```

#### 4.2 La rareté comme modificateur d'Oracle

Certains systèmes modifient la probabilité de l'oracle en fonction de l'état des ressources. Notez-le :

```
? Puis-je trouver plus de flèches dans les ruines ? (Probabilité : Peu probable — zone isolée)
-> Oui, mais... (d6=4)
=> Je trouve un carquois avec seulement 3 flèches utilisables. [Inv:Flèche+3]

? Y a-t-il de la nourriture dans ce camp abandonné ? (Probabilité : Très peu probable — vieux camp)
-> Non, et... (d6=1)
=> La nourriture est pourrie et l'odeur attire quelque chose. [Horloge:Prédateur 1/4]
```

#### 4.3 Ressources en Combat

Lorsque l'Extension de Combat est utilisée, la consommation de ressources s'intègre naturellement :

```
[COMBAT]
R1
@ Tirer à l'arc sur l'Orc 1
d: Tir à distance d6=5 vs ND 4 -> Succès
=> La flèche touche ! [F:Orc 1|PV-3] [Inv:Flèche-1]

R2
@ Jeter la dernière flasque d'huile
d: Tir à distance d6=3 vs ND 4 -> Échec
=> Raté ! L'huile s'éclabousse inutilement. [Inv:Flasque d'huile|épuisée]
[/COMBAT]
```

#### 4.4 Ressources en Exploration de Donjon

Lorsque l'Extension d'Exploration de Donjon est utilisée, l'épuisement des ressources est suivi parallèlement à l'exploration des pièces :

```
[P:4|active|Caverne fongique|sorties E:R5, O:R2]

@ Naviguer prudemment dans la caverne
d: Survie d6=4 vs ND 4 -> Succès
=> Je trouve un chemin à travers. La torche faiblit.
[Inv:Torche|2→1] [Compteur:Lumière 3]

@ Chercher des champignons utiles
tbl: d6=5 -> "Mousse luminescente — comestible"
=> [Inv:Mousse comestible|3|rend 1 PV chacune]
[P:4|nettoyée, fouillée]
```

---

## 5. Le Bloc de Statut des Ressources

Pour les longues sessions ou les campagnes où les ressources comptent, un instantané aux limites de session vous aide à reprendre là où vous vous étiez arrêté.

**Format :**

```
[RESSOURCES]
[PJ:Nom|stats]
[Richesse:monnaies]
[Inv:objets...]
[/RESSOURCES]
```

**Exemple — numérique :**

```
[RESSOURCES]
[PJ:Kael|PV 12/15|Ravitaillement d6|Stress 2]
[Richesse:Or 52|Argent 8]
[Inv:Épée courte|1|affûtée]
[Inv:Bouclier|1|fissuré]
[Inv:Torche|2]
[Inv:Rations|3|jours]
[Inv:Corde|1|15m|effilochée]
[Inv:Potion de soin|1|rend d8 PV]
[Inv:Flèche|9]
[Inv:Amulette d'os|1|Protection des Morts]
[/RESSOURCES]
```

**Exemple — analogique :**

```
--- RESSOURCES ---
PJ :  Kael | PV 12/15 | Ravitaillement d6 | Stress 2
Richesse : Or 52 | Argent 8
Inv : Épée courte (affûtée), Bouclier (fissuré)
      Torche ×2, Rations ×3 jours
      Corde 15m (effilochée), Potion de soin ×1
      Flèche ×9, Amulette d'os (Protection des Morts)
--- FIN RESSOURCES ---
```

**Quand l'utiliser :**

- À la **fin d'une session** pour figer l'état.
- Au **début de la session suivante** comme rappel.
- **Avant une expédition majeure** (exploration de donjon, long voyage, mission dangereuse).
- Après un **pillage ou une perte significative** — un point de contrôle naturel.

**Quand l'ignorer :**

- Les ressources ne sont pas mécaniquement importantes dans votre jeu.
- La session est courte et les changements sont minimaux.
- Vous pouvez reconstruire l'état facilement à partir du journal.

---

## Interactions entre extensions

| Situation | Extension(s) utilisée(s) | Balises/Blocs clés |
|-----------|--------------------------|--------------------|
| Exploration de donjon avec pression sur les provisions | Exploration de Donjon + Suivi des Ressources | `[P:]`, `[Inv:]`, `[Compteur:]` |
| Combat avec suivi des munitions | Combat + Suivi des Ressources | `[F:]`, `[COMBAT]`, `[Inv:]` |
| Échange dans un campement | Suivi des Ressources uniquement | `[Inv:]`, `[Richesse:]`, `[N:]` |
| Exploration complète de donjon avec combats | Les trois extensions | `[P:]`, `[COMBAT]`, `[Inv:]`, `[Richesse:]` |

**Exemple combiné — les trois extensions :**

```
[RESSOURCES]
[PJ:Kael|PV 12/15|Ravitaillement d6]
[Inv:Torche|2] [Inv:Flèche|9] [Inv:Potion de soin|1]
[Richesse:Or 52]
[/RESSOURCES]

S5 *Entrée dans la crypte*
[P:1|active|Hall d'entrée, des os partout|sorties N:R2, E:R3]

@ Allumer une torche et entrer
[Inv:Torche-1] [Compteur:Lumière 6]

? Y a-t-il des ennemis ?
-> Oui, et... (d6=6)
=> Des squelettes s'élèvent des tas d'ossements !

[COMBAT]
[F:Squelette×3|PV 3 chacun|Proche]

R1
@ Tirer sur le squelette le plus proche
d: Tir à distance d6=5 vs ND 4 -> Succès
=> La flèche fracasse son crâne ! [F:Squelette×3→2] [Inv:Flèche-1]

@(Squelette) Me charge
d: Attaque d6=3 vs ND 4 -> Échec
=> Coup maladroit, j'esquive.

R2
@ Dégainer mon épée, accentuer l'attaque
d: Mêlée d6=6 vs ND 4 -> Succès
=> Je tranche net ! [F:Squelette×2→1]

@ Achever le dernier
d: Mêlée d6=4 vs ND 4 -> Succès
=> La crypte redevient silencieuse. [F:Squelette×0]
[/COMBAT]

@ Fouiller la pièce
tbl: d20=14 -> "Un coffre verrouillé"
? Puis-je crocheter la serrure ?
d: Crochetage d6=5 vs ND 5 -> Succès
=> À l'intérieur : [Inv:Bracelet en or|1|précieux] [Richesse:Or+10]
[P:1|nettoyée, fouillée]
[Compteur:Lumière-1]

@ Aller au nord vers R2
[P:2|active|Chambre rituelle|sorties S:R1, B:R3]
```

---

## Adaptations du système

### The Black Hack / Systèmes de Dés d'Usage

Les Dés d'Usage sont la principale mécanique de ressources. Suivez-les dans `[PJ:]` :

```
[PJ:Varn|Torches d8|Rations d6|Munitions d10|PV 14/18]

@ Installer le camp
d: Rations d6=2 -> Diminution !
=> [PJ:Varn|Rations d6→d4]
(note : encore une diminution et il n'y en a plus)
```

### Ironsworn / Jauge de Ravitaillement

Le Ravitaillement (Supply) est une statistique unique de 0 à 5 :

```
[PJ:Kael|Ravitaillement 4/5|Santé 4/5|Esprit 3/5|Élan 6/10]

@ Séjourner dans le campement (Sojourn)
d: Action=5+Cœur=2=7 vs Défi=3,8 -> Succès Faible
=> Je me ravitaille mais le temps passe. [PJ:Kael|Ravitaillement+2|Élan-1]
```

### OSR / Systèmes d'Encombrement

L'inventaire basé sur des emplacements est courant dans les jeux OSR :

```
[Inv:Slot 1|Épée]
[Inv:Slot 2|Bouclier]
[Inv:Slot 3|Torche×3]
[Inv:Slot 4|Rations×4]
[Inv:Slot 5|Corde 15m]
[Inv:Slot 6-10|vide]
(note : 10 slots max, encombrement basé sur la FOR)

@ Ramasser l'idole dorée
=> [Inv:Slot 6|Idole dorée|lourde|occupe 2 slots]
[Inv:Slot 7|occupé]
(note : à 7/10 slots — pénalité de mouvement à 8+)
```

### Fate / Systèmes Narratifs

Les ressources sont des aspects ou des jauges de stress, pas des inventaires :

```
[PJ:Sable|Aspect : Bien approvisionné]
[PJ:Sable|Aspect : Bien approvisionné→À court de provisions]
[PJ:Sable|Aspect : À court de provisions|invoqué contre moi]
```

Or notez-le simplement en prose et ignorez totalement `[Inv:]`. Si votre jeu ne mécanise pas les ressources, votre notation ne devrait pas le faire non plus.

### Survival Horror / Jeux de Rareté

Quand chaque balle compte :

```
[Inv:Munition 9mm|7]
[Inv:Trousse de secours|1|utilisations 2/3]
[Inv:Lampe torche|1|pile d4]

@ Tirer sur la créature
d: Armes à feu d6=4 vs ND 4 -> Succès
=> Touche ! [Inv:Munition 9mm-1]

@ Panser la blessure
=> [Inv:Trousse de secours|1|utilisations 2→1] [PJ:Casey|PV+3]

@ Vérifier la lampe torche
d: Pile d4=1 -> Diminution !
=> Scintille fortement. [Inv:Lampe torche|1|pile d4→épuisée]
=> Obscurité. [Horloge:Panique 1/4]
```

---

## Bonnes pratiques

**À faire : Enregistrer les changements de ressources au point de fiction**

```
✔ @ Allumer une torche pour voir
  => La caverne révèle un passage étroit. [Inv:Torche-1]
```

**À éviter : Mettre à jour silencieusement les ressources en dehors du journal**

```
✗ (J'ai soustrait 3 flèches mais je ne l'ai écrit nulle part)

✔ Montrez le changement, même brièvement : [Inv:Flèche-3]
```

**À faire : Utiliser le Bloc de Statut des Ressources aux limites de session**

```
✔ [RESSOURCES]
  [PJ:Kael|PV 12/15|Ravitaillement d6]
  [Inv:Torche|2] [Inv:Flèche|9]
  [/RESSOURCES]
```

**À éviter : Laisser la comptabilité submerger la fiction**

```
✗ => Je combats l'orc.
  [Inv:Flèche-1] [Inv:Flèche|11] [PJ:PV-2] [PJ:PV 13]
  [F:Orc|PV-4] [Horloge:Alerte+1] [Compteur:Torche-1]
  (C'est un tableur, pas une histoire)

✔ => La flèche atteint sa cible — l'orc chancelle.
  [Inv:Flèche-1] [F:Orc|PV-4]
  (Suivez ce qui compte à ce moment précis. Regroupez le reste dans un bloc de statut.)
```

**À faire : Faire correspondre votre notation au modèle de ressources de votre système**

```
✔ Jeu avec Dé d'Usage :     [PJ:Kael|Ravitaillement d8]
✔ Jeu avec décompte :       [Inv:Flèche|12]
✔ Jeu narratif :            [PJ:Sable|Aspect : Bien approvisionné]
```

**À éviter : Suivre des ressources dont le jeu ne se soucie pas**

```
✗ [Inv:Lacets|2|cuir]     (à moins que votre jeu ne suive littéralement cela)

✔ Ne suivez que ce qui crée des décisions significatives ou de la tension.
```

**À faire : Séparer les objets concrets des stats abstraites**

```
✔ [Inv:Potion de soin|2]        (objet concret, dénombrable)
✔ [PJ:Kael|Ravitaillement d6]    (niveau de ravitaillement abstrait)
```

**À éviter : Mélanger les deux au même endroit pour des raisons différentes**

```
✗ [PJ:Kael|PV 12|Torche 3|Flèche 9|Rations 5]
  (liste d'inventaire à l'intérieur d'une balise de stat de personnage)

✔ [PJ:Kael|PV 12|Ravitaillement d6]
  [Inv:Torche|3] [Inv:Flèche|9] [Inv:Rations|5]
```

---

## Référence rapide

### Nouvelles balises

| Balise | Objectif | Exemple |
|--------|----------|---------|
| `[Inv:Objet\|qté\|props]` | Objet d'inventaire concret | `[Inv:Torche\|3]` |
| `[#Inv:Objet]` | Référence à un objet déjà établi | `[#Inv:Amulette d'os]` |
| `[Inv:Objet+N]` / `[Inv:Objet-N]` | Changement de quantité (gain/perte) | `[Inv:Flèche-1]` |
| `[Inv:Objet\|qté→qté]` | Transition de quantité explicite | `[Inv:Torche\|3→2]` |
| `[Inv:Objet\|épuisé]` | Objet entièrement consommé ou disparu | `[Inv:Flasque d'huile\|épuisée]` |
| `[Richesse:Monnaie N]` | Total de monnaie concrète | `[Richesse:Or 45]` |
| `[Richesse:Monnaie+N]` | Monnaie gagnée | `[Richesse:Or+15]` |
| `[Richesse:Monnaie-N]` | Monnaie dépensée | `[Richesse:Or-8]` |

### Ressources abstraites dans `[PJ:]`

| Modèle | Objectif | Exemple |
|--------|----------|---------|
| `Ravitaillement d8` | Ressource avec Dé d'Usage | `[PJ:Kael\|Ravitaillement d8]` |
| `Ravitaillement d8→d6` | Diminution du Dé d'Usage | `[PJ:Kael\|Ravitaillement d8→d6]` |
| `Ravitaillement 4/5` | Jauge de ravitaillement | `[PJ:Kael\|Ravitaillement 4/5]` |
| `Provisions : basses` | Niveau qualitatif | `[PJ:Kael\|Provisions : basses]` |
| `Richesse d8` | Richesse abstraite comme Dé d'Usage | `[PJ:Kael\|Richesse d8]` |
| `Aspect : À court` | État de ressource narratif | `[PJ:Sable\|Aspect : À court]` |

### Blocs structurels

| Bloc | S'ouvre quand | Se ferme quand |
|------|---------------|----------------|
| `[RESSOURCES]` / `[/RESSOURCES]` | Début/fin de session, avant les expéditions | Après que toutes les balises `[Inv:]` et `[PJ:]` actuelles soient listées |

### Chaîne de diminution du Dé d'Usage

```
d12 → d10 → d8 → d6 → d4 → épuisé
```

### Exemple complet

```
[RESSOURCES]
[PJ:Kael|PV 10/15|Ravitaillement d6] [Richesse:Or 52]
[Inv:Torche|2] [Inv:Flèche|9] [Inv:Potion de soin|1]
[/RESSOURCES]

@ Allumer une torche
[Inv:Torche-1] [Compteur:Lumière 6]

@ Tirer sur l'orc
d: Tir à distance d6=5 vs ND 4 -> Succès
=> [F:Orc|PV-4] [Inv:Flèche-1]

=> Je me panse après le combat. [Inv:Potion de soin-1] [PJ:Kael|PV+5|PV 15]
```

---

## FAQ

**Q : Quand dois-je utiliser `[Inv:]` plutôt que de mettre simplement l'équipement dans `[PJ:]` ?**
R : Si les ressources sont mécaniquement importantes et changent souvent, utilisez `[Inv:]`. Si elles sont purement narratives ou si vous ne suivez qu'une ou deux choses, `[PJ:Nom|Équipement:Épée,Bouclier]` suffit. Il n'y a pas de mauvaise réponse — utilisez ce qui garde votre journal clair.

**Q : Ai-je besoin de la balise `[Richesse:]` ou puis-je mettre l'argent dans `[Inv:]` ?**
R : Les deux fonctionnent. `[Richesse:]` est plus propre pour les systèmes multi-monnaies (or/argent/cuivre) et pour l'argent qui circule fréquemment. `[Inv:Or|45]` fonctionne très bien pour les jeux plus simples ou si vous utilisez déjà `[Inv:]` pour tout le reste.

**Q : Dois-je écrire un Bloc de Statut des Ressources à chaque session ?**
R : Seulement si cela vous aide. Si les ressources sont au cœur de votre jeu (donjons, survival horror), un bloc au début et à la fin de la session vous évite de revenir en arrière. Si les ressources changent rarement ou ne sont pas mécaniquement importantes, ignorez-le.

**Q : Et si je joue à un jeu sans aucune mécanique de ressources ?**
R : Alors vous n'avez probablement pas besoin de cette extension. La balise `[PJ:]` du cœur de Lonelog avec un champ `Équipement:` est plus que suffisante. Cette extension existe pour les jeux où les ressources créent de la tension et des décisions.

**Q : Puis-je combiner `[Inv:]` avec les balises `[P:]` de l'Extension d'Exploration de Donjon ?**
R : Absolument — elles sont conçues pour fonctionner ensemble. Balisez le butin dans la pièce où vous le trouvez : `[P:3|fouillée] [Inv:Bague en or|1|précieuse]`. La balise `[P:]` suit ce qui est arrivé à la pièce ; la balise `[Inv:]` suit ce qui est arrivé au butin.

**Q : Comment gérer les contenants, les sacs sans fond, les sacoches de selle ?**
R : Soit imbriquez de manière descriptive — `[Inv:Sac sans fond|contient : Baguette, Parchemins×3, Or 100]` — soit suivez le contenant et le contenu séparément. Pour les systèmes par emplacements, marquez simplement quels emplacements sont "dans le sac". Ne compliquez pas trop les choses.

**Q : Le symbole `×` est difficile à taper. Puis-je utiliser `x` à la place ?**
R : Oui. `[Inv:Flèche×12]` et `[Inv:Flèchex12]` sont tous deux acceptables. La lisibilité prime sur la formalité.

**Q : Comment cela fonctionne-t-il dans un carnet analogique ?**
R : Le Bloc de Statut des Ressources fonctionne bien en analogique — écrivez-le dans un encadré ou en haut de la page. Pour les changements intégrés, utilisez des raccourcis dans la marge : `Torche -1`, `Flèche 9→8`. La notation `+`/`-` est assez rapide pour ne pas ralentir l'écriture manuscrite.

---

## Crédits & License

© 2025 Roberto Bisceglie

Cette extension complète [Lonelog](https://zeruhur.itch.io/lonelog) par Roberto Bisceglie.

**Historique des versions :**

- v 1.1.0 : Les balises de bloc sont unifiées avec la convention `[BLOC]`/`[/BLOC]` ; principes de conception mis à jour
- v 1.0.0 : Réécrit comme une extension conforme (auparavant "Module de Suivi des Ressources")
