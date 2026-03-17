# Lonelog

**Une Notation Standard pour les Comptes-rendus de Sessions de JdR Solo**

[![Licence : CC BY-SA 4.0](https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-sa/4.0/)

Lonelog est un système de notation léger pour enregistrer les sessions de jeu de rôle sur table en solo. Il offre une manière standardisée de capturer les mécaniques de jeu, les questions aux oracles et les issues narratives—tout en gardant vos journaux de session lisibles, consultables et partageables.

## Qu'est-ce que Lonelog ?

Si vous avez joué à des JdR en solo, vous connaissez le défi : vous êtes plongé dans une scène passionnante, les dés roulent, les oracles répondent aux questions, et vous devez tout capturer sans rompre le flux.

Lonelog propose une **sténographie modulaire** qui :

- Sépare les mécaniques de la narration
- Fonctionne avec n'importe quel système de JdR (Ironsworn, Mythic GME, Thousand Year Old Vampire, etc.)
- S'adapte aussi bien aux sessions rapides qu'aux longues campagnes
- Fonctionne aussi bien dans des fichiers numériques Markdown que dans des carnets papier

### Notation de Base (5 symboles)

```
@ Action du joueur
? Question à l'oracle
d: Jet de dés/mécaniques
-> Résultat/réponse
=> Conséquence/issue
```

### Exemple Rapide

```
S1 *Ruelle sombre, minuit*
@ Se faufiler devant le garde
d: Discrétion 4 vs ND 5 -> Échec
=> Le garde m'aperçoit et donne l'alerte

? Des renforts arrivent-ils ? (Probable)
-> Oui, et ils ont des chiens
=> Je dois courir—vite
```

C'est l'intégralité du système de base. Tout le reste (scènes, fils conducteurs, horloges de progression, etc.) est optionnel.

## Documentation Disponible

La documentation est disponible dans plusieurs formats et langues :

### Anglais (English)

- [PDF](../../output/en/lonelog.pdf) - Version prête pour l'impression
- [EPUB](../../output/en/lonelog.epub) - Format liseuse
- [ODT](../../output/en/lonelog.odt) - Format LibreOffice/Word

### Italien (Italiano)

- [PDF](../../output/it/lonelog-it.pdf) - Version pour l'impression
- [EPUB](../../output/it/lonelog-it.epub) - Format liseuse
- [ODT](../../output/it/lonelog-it.odt) - Format LibreOffice/Word

### Français

- [PDF](../../output/fr/lonelog-fr.pdf) - Version imprimable
- [EPUB](../../output/fr/lonelog-fr.epub) - Format liseuse
- [ODT](../../output/fr/lonelog-fr.odt) - Format LibreOffice/Word

### Extensions Optionnelles (Add-ons)

Notation étendue pour des besoins de jeu spécifiques :

- [Extension de Combat](lonelog-combat-addon-fr.md) - Notation pour rencontres tactiques
- [Extension d'Exploration de Donjon](lonelog-dungeon-crawling-addon-fr.md) - Notation pour l'exploration
- [Extension de Suivi des Ressources](lonelog-resource-tracking-addon-fr.md) - Inventaire et ressources
- [Directives pour les Extensions](lonelog-addon-guidelines-fr.md) - Comment écrire votre propre extension
- [Modèle d'Extension](lonelog-addon-template-fr.md) - Modèle de départ

## Fonctionnalités

- **Agnostique du système** - Fonctionne avec n'importe quel système de JdR en solo
- **Modulaire** - N'utilisez que ce dont vous avez besoin
- **Compatible Markdown** - Outils numériques et carnets de notes en texte brut
- **Consultable** - Les balises et les symboles facilitent la recherche d'événements passés
- **Partageable** - La notation standard signifie que d'autres peuvent lire vos journaux de session
- **Multilingue** - Documentation disponible en anglais, italien et français

## Génération de la Documentation

Ce dépôt utilise [Quarto](https://quarto.org/) pour générer la documentation à partir des fichiers sources Markdown.

### Prérequis

Installer Quarto :

- **Windows** : `choco install quarto` (via Chocolatey)
- **macOS** : `brew install quarto`
- **Linux** : Télécharger depuis [quarto.org](https://quarto.org/docs/get-started/)

### Commandes de Génération

Générer toutes les langues :

```bash
for lang in en it fr; do
  quarto render docs/$lang/lonelog*.md --output-dir output/$lang/
done
```

Générer une langue spécifique :

```bash
quarto render docs/en/lonelog.md --output-dir output/en/      # Anglais
quarto render docs/it/lonelog-it.md --output-dir output/it/   # Italien
quarto render docs/fr/lonelog-fr.md --output-dir output/fr/   # Français
```

Générer pour un format spécifique :

```bash
quarto render docs/en/lonelog.md --to pdf --output-dir output/en/
quarto render docs/en/lonelog.md --to epub --output-dir output/en/
```

Prévisualisation avec rechargement en direct :

```bash
quarto preview docs/en/lonelog.md
```

## Structure du Projet

```
/
├── index.html                              # Point d'entrée Docsify
├── _quarto.yml                             # Configuration Quarto
├── docs/                                   # Fichiers sources Markdown
│   ├── README.md                           # Accueil du site (sélecteur de langue)
│   ├── en/                                 # Documentation anglaise
│   │   ├── lonelog.md                      # Spécification principale
│   │   ├── lonelog-addon-guidelines.md     # Lignes directrices des extensions
│   │   ├── lonelog-addon-template.md       # Modèle d'extension
│   │   ├── lonelog-combat-addon.md         # Extension de combat
│   │   ├── lonelog-dungeon-crawling-addon.md # Extension d'exploration
│   │   ├── lonelog-resource-tracking-addon.md # Extension de suivi des ressources
│   │   └── _sidebar.md                     # Barre latérale Docsify (EN)
│   ├── it/                                 # Traduction italienne
│   │   ├── lonelog-it.md
│   │   └── _sidebar.md
│   └── fr/                                 # Traduction française
│       ├── lonelog-fr.md
│       └── _sidebar.md
│       ├── lonelog-addon-guidelines-fr.md     # Lignes directrices des extensions
│       ├── lonelog-addon-template-fr.md       # Modèle d'extension
│       ├── lonelog-combat-addon-fr.md         # Extension de combat
│       ├── lonelog-dungeon-crawling-addon-fr.md # Extension d'exploration
│       ├── lonelog-resource-tracking-addon-fr.md # Extension de suivi des ressources
├── output/                                 # Documents générés (Quarto)
│   ├── en/                                 # Rendus anglais
│   ├── it/                                 # Rendus italiens
│   └── fr/                                 # Rendus français
├── _extensions/                            # Modèles et filtres personnalisés
│   ├── typst-template.typ                  # Style Typst personnalisé
│   ├── typst-show.typ                      # Partiel du modèle
│   └── pagebreak.lua                       # Filtre de saut de page
├── assets/                                 # Ressources partagées (images, polices)
├── legacy/                                 # Anciennes versions
└── .readthedocs.yaml                       # Configuration de build Read the Docs
```

## Contribuer

Les contributions sont les bienvenues ! Voici comment vous pouvez aider :

### Traductions

Aidez à traduire Lonelog dans d'autres langues. Utilisez `docs/en/lonelog.md` comme source et maintenez la même structure de frontmatter.

### Améliorations

Vous avez trouvé une faute de frappe ou une explication peu claire ? Ouvrez une issue ou soumettez une pull request.

### Extensions de Modules

Vous avez créé une extension optionnelle pour un type de jeu spécifique ? Partagez-la avec la communauté !

### Exemples

Les comptes-rendus de sessions réelles utilisant Lonelog sont précieux pour démontrer la notazione. Pensez à partager des exemples anonymisés.

## Historique des Versions

- **v1.3.0** (Actuelle) - Écosystème d'extensions et notation étendue
- **v1.1.0** - Licence et définitions en ligne
- **v1.0.0** - Renommé de "Solo TTRPG Notation" à "Lonelog"

## Licence

Ce travail est sous licence [Creative Commons Attribution-ShareAlike 4.0 International](https://creativecommons.org/licenses/by-sa/4.0/).

Vous êtes libre de :

- **Partager** — copier, distribuer et communiquer le matériel par tous moyens et sous tous formats
- **Adapter** — remixer, transformer et créer à partir du matériel

Selon les conditions suivantes :

- **Attribution** — Vous devez créditer l'œuvre
- **Partage dans les Mêmes Conditions** — Si vous modifiez, transformez ou vous basez sur ce matériel, vous devez distribuer votre contribution sous la même licence que l'original.

## Auteur

**Roberto Bisceglie**

## Communauté

- Partagez vos comptes-rendus de session avec le hashtag `#lonelog`
- Posez des questions ou suggérez des améliorations via les Issues GitHub
- Rejoignez les discussions sur la notation des JdR en solo et les meilleures pratiques

## Remerciements

Merci à la communauté des JdR en solo pour les retours, les suggestions et l'utilisation réelle qui ont façonné ce système de notation depuis ses origines sous le nom de "Solo TTRPG Notation" jusqu'à Lonelog v1.0.0.

---

*Réalisé avec [Quarto](https://quarto.org/) • Mis en forme avec [Typst](https://typst.app/)*
