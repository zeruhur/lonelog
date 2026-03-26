---
title: "Lonelog : Extension [Nom de l'Extension]"
subtitle: "[Description d'une ligne de ce que cette extension permet]"
author: [Votre nom ou pseudo]
version: 0.1.0
license: CC BY-SA 4.0
lang: fr
parent: Lonelog v1.1.0
requires: Notation de Base (§3)
---

<!--
  MODÈLE D'EXTENSION LONELOG
  ==========================
  Remplacez tous les espaces réservés entre [crochets] par votre contenu.
  Supprimez les commentaires d'instructions (comme celui-ci) avant de publier.
  
  Sections requises : Présentation, Ce que cette extension ajoute, au moins une
  section de fonctionnalité principale, Bonnes pratiques, Référence rapide, FAQ.
  
  Sections facultatives : Principes de conception, Interactions entre extensions,
  Adaptations du système. Incluez-les si elles s'appliquent.
  
  Consultez les Directives pour les Extensions de la Communauté pour un guide complet.
-->

# Extension [Nom de l'Extension]

## Présentation

<!--
  2 à 4 paragraphes. Répondez à :
  - Quelle lacune du cœur de Lonelog cette extension comble-t-elle ?
  - Pour quel type de jeu ou de système est-elle conçue ?
  - Quand les joueurs devraient-ils utiliser cette extension plutôt que de rester sur le cœur ?
  
  Ne cherchez pas à "vendre". Décrivez honnêtement, y compris ses limites.
-->

[Décrivez la situation que le cœur de Lonelog ne gère pas totalement — le moment
où un joueur réalise qu'il a besoin de plus de structure que les cinq symboles
de base seuls.]

[Expliquez ce que l'extension apporte concrètement : nouvelles balises,
blocs structurels ou conventions de formatage. Restez bref ici — les sections
ci-dessous entreront dans les détails.]

[Précisez quand *ne pas* utiliser cette extension. L'honnêteté ici renforce la
confiance et évite aux joueurs d'adopter une notation dont ils n'ont pas besoin.]

---

### Ce que cette extension ajoute

<!--
  Un tableau résumant chaque nouvel élément. C'est la première chose
  qu'un joueur expérimenté de Lonelog lira. Soyez précis.
-->

| Ajout | Objectif | Exemple |
|-------|----------|---------|
| `[BALISE:Nom\|prop]` | [Ce qu'elle suit] | `[BALISE:Exemple\|prop1]` |
| [Bloc structurel] | [Ce qu'il délimite] | `[BLOC] ... [/BLOC]` |
| [Nom de convention] | [Ce qu'elle standardise] | [exemple bref] |

**Aucun nouveau symbole de base.** Cette extension n'introduit aucun ajout à `@`, `?`, `d:`, `->` ou `=>`.

---

### Principes de conception

<!--
  Facultatif mais précieux. 3 à 5 principes courts qui expliquent le *pourquoi*
  derrière la conception. Aide les futurs contributeurs et auteurs dérivés
  à comprendre l'intention.
  
  Prenez modèle sur la section "Principes de conception" de l'Extension de Suivi des Ressources.
-->

**[Principe 1 — titre court].** [Une ou deux phrases expliquant le
principe et pourquoi il est important pour le domaine de cette extension.]

**[Principe 2 — titre court].** [Une ou deux phrases.]

**[Principe 3 — titre court].** [Une ou deux phrases.]

---

## 1. [Première fonctionnalité majeure]

<!--
  Une section par fonctionnalité majeure. Titrez-la en fonction de ce qu'elle fait,
  pas de son nom technique. Ex: "Suivi de l'état des pièces" plutôt que "La balise P:".
  
  Chaque section nécessite :
  - Spécification du format
  - Au moins deux exemples (minimal et développé)
  - Conseils sur quand l'utiliser et quand s'en passer
-->

[Brève introduction : quel problème cette fonctionnalité résout-elle au sein
du domaine de l'extension ?]

**Format :**

```
[BALISE:Nom|champ-requis|champ-optionnel]
```

**Champs :**

- `Nom` — [ce qu'il identifie]
- `champ-requis` — [sa signification, valeurs attendues]
- `champ-optionnel` — [sa signification, quand l'inclure]

#### [1.1 Sous-fonctionnalité ou Cas d'utilisation courant]

[Expliquez la manière la plus courante d'utiliser cette fonctionnalité.]

**Exemple — minimal :**

```
[Ligne compacte unique montrant la fonctionnalité dans un contexte de jeu rapide]
```

**Exemple — développé :**

```
[Séquence complète montrant la fonctionnalité dans un journal de jeu réaliste :
action, jet, conséquence, mise à jour de balise. Au moins 5 à 8 lignes.]
```

#### [1.2 Autre sous-fonctionnalité ou Cas limite]

[Couvrez la variante ou le cas limite le plus important suivant.]

```
[Exemple]
```

---

## 2. [Deuxième fonctionnalité majeure]

<!--
  Répétez la structure de la Section 1 pour chaque fonctionnalité majeure.
  La plupart des extensions ont 2 à 4 fonctionnalités majeures.
-->

[Paragraphe d'introduction.]

**Format :**

```
[Spécification du format]
```

**Exemple — minimal :**

```
[Exemple compact]
```

**Exemple — développé :**

```
[Exemple de séquence complète]
```

---

## 3. [Bloc structurel — si applicable]

<!--
  Si votre extension introduit un bloc structurel (comme [COMBAT]...[/COMBAT]
  ou --- RESSOURCES ---), consacrez-lui sa propre section.
  
  Expliquez : ce qui va à l'intérieur, quand l'ouvrir/le fermer, et ce que
  cela signifie lors de la lecture d'un journal.
-->

[Certaines extensions bénéficient d'un bloc structurel qui délimite clairement
un mode de jeu au sein du journal. Si c'est votre cas, expliquez-le ici.
Sinon, supprimez cette section.]

**Format :**

```
[NOMDUBLOC]
[Contenu du bloc]
[/NOMDUBLOC]
```

**Quand ouvrir un bloc :** [Déclencheur spécifique — ex: "quand l'initiative
est déclarée" ou "au début de la session quand les ressources comptent".]

**Quand le fermer :** [Condition spécifique — ex: "quand tous les combattants
sont résolus" ou "à la fin de la session".]

**Format numérique :**

```
[Exemple dans un contexte markdown]
```

**Format analogique :**

```
[Exemple pour les carnets papier]
```

---

## Interactions entre extensions

<!--
  Facultatif. Incluez cette section si votre extension est conçue pour fonctionner
  avec d'autres extensions, ou s'il existe des modèles d'interaction connus.
  
  Incluez au moins un exemple combiné montrant les deux extensions
  dans la même séquence de journal.
-->

| Situation | Extension(s) utilisée(s) | Balises/Blocs clés |
|-----------|-------------------------|--------------------|
| [Scénario combiné courant] | [Cette extension] + [Autre extension] | [Éléments principaux] |

**Exemple combiné — [Cette Extension] + [Autre Extension] :**

```
[Une séquence de journal réaliste de 10 à 15 lignes montrant les deux extensions
fonctionnant ensemble. Doit ressembler à du jeu réel, pas à une démonstration.]
```

---

## Adaptations du système

<!--
  Facultatif mais recommandé. Montrez comment l'extension s'adapte à 2–4
  systèmes de JDR spécifiques que les joueurs utilisent couramment avec Lonelog.
  
  Couvrez au plus moins un système OSR/traditionnel et un système narratif/PbtA
  si votre extension est largement applicable.
-->

### [Nom du Système 1]

[Un paragraphe sur la façon dont les mécaniques de ce système correspondent
à la notation de l'extension.]

```
[Exemple spécifique au système]
```

### [Nom du Système 2]

[Un paragraphe.]

```
[Exemple spécifique au système]
```

---

## Bonnes pratiques

<!--
  Paires "À faire / À éviter" dans le style de Lonelog §7.
  Visez 4 à 6 paires couvrant les erreurs les plus courantes et les
  modèles positifs les plus clairs.
  
  Chaque paire doit avoir des exemples de code fonctionnels, pas seulement de la prose.
-->

**À faire : [Titre du modèle positif]**

```
✔ [Exemple positif — complet, réaliste, clairement correct]
```

**À éviter : [Titre de l'anti-modèle]**

```
✗ [Ce qu'il faut éviter — complet, réaliste, clairement erroné]

✔ [La version corrigée]
```

**À faire : [Titre du modèle positif]**

```
✔ [Exemple]
```

**À éviter : [Titre de l'anti-modèle]**

```
✗ [Mauvais]

✔ [Bon]
```

---

## Référence rapide

<!--
  Requis. Tableaux couvrant chaque nouvel élément. C'est ce vers quoi les joueurs
  reviennent pendant le jeu après avoir lu l'extension une fois.
  
  Un tableau par catégorie d'élément.
-->

### Nouvelles balises

| Balise | Objectif | Exemple |
|--------|----------|---------|
| `[BALISE:Nom\|champ]` | [Ce qu'elle suit] | `[BALISE:Exemple\|valeur]` |
| `[#BALISE:Nom]` | Référence à un élément établi précédemment | `[#BALISE:Exemple]` |

### [Blocs structurels — si applicable]

| Bloc | S'ouvre quand | Se ferme quand |
|------|---------------|----------------|
| `[NOMDUBLOC]` | [Déclencheur] | [Condition] |

### [Autre catégorie d'élément — si applicable]

[Tableau ou liste compacte de tout nouvel élément restant.]

### Exemple complet

<!--
  Une ligne compacte ou une courte séquence montrant les éléments
  principaux de l'extension ensemble. La "ligne aide-mémoire" qui
  capture toute l'extension en miniature.
-->

```
[L'exemple unique le plus utile pour une référence rapide pendant le jeu]
```

---

## FAQ

<!--
  4 à 8 questions couvrant les cas limites anticipés, les décisions de conception
  et les interactions avec d'autres systèmes. Écrivez les questions avec la
  voix d'un joueur qui a lu l'extension une fois et essaie maintenant de l'utiliser.
-->

**Q : [Question anticipée la plus courante]**  
R : [Réponse directe et pratique. Pointez vers la section concernée si approprié.]

**Q : [Question sur la justification de la conception — "pourquoi avez-vous..."]**  
R : [Expliquez le raisonnement. Cela renforce la confiance et aide les joueurs à adapter la convention.]

**Q : [Question sur un cas limite]**  
R : [Réponse spécifique. Si le cas limite n'a pas de bonne réponse, dites-le et suggérez une approche.]

**Q : [Question d'intégration — "puis-je utiliser ceci avec..."]**  
R : [Oui/non/ça dépend, avec une brève explication.]

**Q : [Question sur l'analogique — "comment ça marche sur papier ?"]**  
R : [Adaptation pratique pour l'analogique.]

---

<!--
  CRÉDITS & HISTORIQUE DES VERSIONS
  ================================
  Conservez cette section même si vous êtes le seul auteur — elle établit
  l'historique et rend l'attribution claire pour les dérivés.
-->

## Crédits & Licence

© [Année] [Votre nom ou pseudo]

Cette extension étend [Lonelog](https://[lien vers le document principal]) par Roberto Bisceglie.

<!--
  Si vous avez été inspiré par ou si vous avez construit sur le travail de quelqu'un d'autre, citez-le :
  
  Inspiré par le travail de [Nom] ([travail]) sur [lien].
  
  Merci à [membre de la communauté] pour [contribution spécifique].
-->

**Historique des versions :**

- v 0.1.0 : Brouillon initial

Ce travail est sous licence **Creative Commons Attribution-ShareAlike 4.0 International**.

Vous êtes libre de partager et d'adapter ce matériel, à condition de donner le crédit approprié et de distribuer les adaptations sous la même licence. Les journaux de session et les enregistrements de jeu créés à l'aide de la notation de cette extension sont votre propre travail et ne sont pas soumis à cette licence.
