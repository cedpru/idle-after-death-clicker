# Idle After Death Clicker - Roadmap (The "Juice" Update)

Ce document trace les étapes pour transformer le prototype (MVP) en un jeu hautement addictif et satisfaisant ("Dopamine-inducing").

## 🔲 Étape 1 : Les Effets Visuels (Dopamine immédiate) — TERMINÉE (100% Fait)
- [x] **Nombres Flottants (Floating Text)** : Affichage animé de l'essence gagnée (ex: "+10", "CRITIQUE x5 !") s'envolant à chaque clic.
- [x] **Particules** : Émetteurs de particules (âmes, étincelles) en arrière-plan (génération de CPUParticles2D violettes mystiques en arrière-plan).
- [x] **Screen Shake** : Tremblement d'écran lors des coups critiques (secousse douce et amortie de l'interface).

## 🔲 Étape 2 : Le Prestige et l'Ascension — TERMINÉE (100% Fait)
- [x] **Scène d'Ascension Finale** : Calcul visuel épique du score final après 10 cycles.
- [x] **Rangs Divins** : Attribution d'un rang (Âme Perdue -> Dieu Suprême) avec animations d'impact.
- [x] **Arbre/Bonus Permanent** : Gain de bonus permanents cumulatifs d'essence (+1% par 100 points de score total) conservés pour la prochaine ère.

## 🔲 Étape 3 : Le Design Sonore (Audio) — TERMINÉE (100% Fait)
- [x] **SFX (Bruitages) Procéduraux** : Génération en temps réel de vagues synthétiques (sans dépendances de fichiers externes !) pour un blip de clic, un blip de coup critique, un carillon pour les achats, et un arpeggio ascendant épique pour les passages de niveaux de mort.
- [x] **Musique d'ambiance** : Système de musique d'ambiance minimaliste générée programmatiquement qui joue doucement des notes aléatoires de la gamme pentatonique mineure d'A (A minor pentatonic) toutes les 1.5 secondes pour créer une atmosphère mystique et relaxante.
- [x] **Options de Contrôle** : Boutons Settings fonctionnels pour activer/désactiver individuellement la musique et les effets sonores avec sauvegarde automatique.

## 🔲 Étape 4 : L'Histoire et l'Imprévu (Pop-ups) — TERMINÉE (100% Fait)
- [x] **Événements Aléatoires** : Des parchemins magiques volants `📜` apparaissent aléatoirement toutes les 45 secondes. Les ignorer les fait disparaître après 15 secondes.
- [x] **Texte & Storytelling** : Cliquer sur le parchemin déclenche un événement textuel unique basé sur votre statistique de vie la plus élevée (richesse, intelligence, beauté, etc.) ou affiche une prière de descendant si c'est votre première vie !
- [x] **Pop-up Glassmorphism** : L'événement glisse depuis le haut de l'écran avec une transition fluide d'amorti et affiche les récompenses calculées dynamiquement selon votre niveau de mort.
- [x] **Outil de Debug** : Un bouton spécial de débogage rapide a été ajouté dans les options (Settings) pour tester les événements à la demande !

## 🔲 Étape 5 : Les Graphismes Finaux — TERMINÉE (100% Fait)
- [x] **Arrière-plans Célestes** : Génération et intégration d'arrière-plans thématiques HD personnalisés (`.jpg`) pour nos trois environnements principaux :
  - *La Mort* (`death_background.jpg`) : Un néant cosmique sombre avec une nébuleuse violette mystique.
  - *La Vie* (`life_background.jpg`) : Un horizon urbain vibrant sous un ciel de coucher de soleil coloré.
  - *L'Ascension* (`ascension_background.jpg`) : Un temple divin doré orné d'une énergie céleste lumineuse.
- [x] **Remplacement des Emojis de Fond** : Les émojis rudimentaires de fond de scène ont été remplacés par ces sublimes illustrations d'ambiance 2D professionnelles.

## 🔲 Étape 6 : Équilibres de Progression, Fins Multiples & Rapport Global — TERMINÉE (100% Fait)
- [x] **Barrière de Progression Anti-Speedrun** : Bloque l'Ascension Finale jusqu'à ce que le joueur ait vécu **exactement 10 vies** ET acheté **au moins 15 niveaux d'améliorations cumulés** auprès de la faucheuse.
- [x] **Fins Narratives Multiples (Ange, Démon, etc.)** : Les statistiques moyennes des 10 vies sont calculées lors de l'Ascension. Selon ces moyennes, une fin unique est débloquée avec texte personnalisé et icônes :
  - *Ange Céleste* 👼 (Beauté & Chance élevées)
  - *Seigneur des Ombres / Démon* 😈 (Richesse élevée, Beauté méprisée)
  - *Archimage Cosmique* 🧙 (Intelligence dominante)
  - *Souverain de l'Abondance* 👑 (Richesse dominante)
  - *Seigneur Multidimensionnel* 🌌 (Géographie dominante)
  - *Âme Éthérée Équilibrée* 👻 (Stats réparties)
- [x] **Rapport Nostalgique Scrollable** : Affiche une carte récapitulative de toutes vos 10 vies, affichant le statut social dominant de l'incarnation et la raison humoristique ou dramatique de sa mort terrestre.

---

## 🎨 PLAN D'AMÉLIORATION GRAPHIQUE PROFESSIONNELLE

Pour que le jeu dépasse le stade "amateur" et devienne visuellement digne d'un store professionnel, voici les directives artistiques à implémenter :

### 1. Remplacement des Émojis textuels par des Sprites 2D :
- **Nodes Cibles** : Remplacer les boutons et labels contenant des émojis (`🌾`, `🤴`, `🧙`, `🎰`, `🌍`, `🧝`) par des textures Sprite2D.
- **Style Artistique** : Utiliser un pixel art premium 32x32 ou du dessin vectoriel minimaliste (Flat design / Stylized cartoon) avec une palette de couleur harmonieuse (3 à 4 teintes majeures par scène).
- **Ressources** : Créer un dossier `res://assets/sprites/` et utiliser des spritesheets pour ajouter des micro-animations de respiration (Idle animations de 4-8 frames).

### 2. Typographie & Fonts Thématiques :
- **Police Actuelle** : Police par défaut de Godot (très rigide).
- **Amélioration** : Importer des polices Google Fonts gratuites :
  - *Pour l'écran des Morts / Événements* : Polices fantastiques type **Medieval / Gothic** (ex: *Cinzel*, *Lancelot*, ou *Almendra*).
  - *Pour la Renaissance / Statistiques* : Polices épurées de science-fiction ou modernes (ex: *Orbitron*, *Rajdhani*, ou *Outfit*).
- **Application** : Créer des fichiers `.ttf` dans `res://assets/fonts/` et les assigner dans les paramètres Theme Override de chaque label important.

### 3. Effets de Shaders & Post-Processing (Visual Polish) :
- **Shader de Vignette** : Appliquer un shader de vignette sombre sur l'écran des morts pour focaliser le regard vers le centre et accentuer le côté mystique et oppressant.
- **Chromatic Aberration (Distorsion)** : Activer un bref flash d'aberration chromatique et un effet d'explosion de particules lors d'un clic Critique ou du déclenchement d'un événement mystique.
- **Glitch Effect** : Lors de la mort ou de la transition de Renaissance, appliquer un shader de distorsion/glitch analogique très court (0.2s) pour symboliser le transfert de l'âme à travers le vide.

---

## 🔮 ÉTAPE 7 : ÉVOLUTIONS FUTURES - DOPAMINE, STRATÉGIE & PANTHÉON (Pistes Suggérées)

Pour continuer d'élever l'intérêt et la rejouabilité du jeu, voici les trois grands chantiers conceptuels proposés :

### 🔲 1. ⚡ La "Tempête d'Âmes" (Mécanique Active Dopaminergique)
- [ ] **Système de Rage** : Une jauge de fureur se remplit à chaque clic sur le bouton principal (ex: 40 clics nécessaires).
- [ ] **Mode Rage Actif** : Cliquer sur le bouton déclenche une tempête mystique pendant 10 secondes :
  - Tremblement d'écran continu doux (`screen shake`).
  - Pluie automatique de particules dorées (`CPUParticles2D`).
  - Multiplicateur de clic temporaire de **x5** et de passif de **x3**.

### 🔲 2. ⚖️ Les "Choix de Destinée" (Interactivité & Planification)
- [ ] **Renaissance Interactive** : Lors de l'écran de Renaissance, proposer deux parchemins de choix de vie cliquables.
- [ ] **Orientations Statistiques** : Permettre au joueur de forcer un bonus massif contre un malus (ex: *L'Ascète 🧘 (+40 Intel, -15 Beauté)* ou *Le Courtisan 🎭 (+40 Beauté, -15 Richesse)*) pour orienter stratégiquement sa run vers une fin d'Ascension spécifique.

### 🔲 3. 🏛️ Le "Panthéon des Âmes" (Hall of Fame & Collection)
- [ ] **Codex des Incarnations** : Menu accessible retraçant les statistiques éternelles de la partie (clics totaux accumulés, niveau maximal atteint).
- [ ] **Galerie des 6 Fins Uniques** : Une vitrine présentant les 6 fins célestes possibles (Ange, Démon, Mage, Souverain, Pionnier, Âme Équilibrée). Les fins déjà obtenues brillent dans leur couleur céleste respective, les autres restent grisées pour encourager la complétion.

