# Idle After Death Clicker - Roadmap (The "Juice" Update)

Ce document trace les étapes pour transformer le prototype (MVP) en un jeu hautement addictif et satisfaisant ("Dopamine-inducing").

## 🔲 Étape 1 : Les Effets Visuels (Dopamine immédiate) — TERMINÉE (100% Fait)
- [x] **Nombres Flottants (Floating Text)** : Affichage animé de l'essence gagnée (ex: "+10", "CRITIQUE x5 !") s'envolant à chaque clic.
- [x] **Particules** : Émetteurs de particules (âmes, étincelles) en arrière-plan (génération de CPUParticles2D violettes mystiques en arrière-plan).
- [x] **Screen Shake** : Tremblement d'écran lors des coups critiques (secousse douce et amortie de l'interface).

## 🔲 Étape 2 : Le Prestige et l'Ascension
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

## 🔲 Étape 5 : Les Graphismes Finaux — À COMMENCER
- [ ] **Remplacement des Emojis** : Création et intégration d'icônes 2D réelles.
- [ ] **Arrière-plans** : Illustrations pour la Vie, la Mort, et l'Ascension.
