# Documentation des modules de contrôle (VHDL)

Ce document décrit le fonctionnement des unités de contrôle pour la rotation et le suivi de ligne.

---

## 1. Module : CTL_Rot (Contrôleur de Rotation)
Ce module est responsable de la rotation pivot du robot jusqu'à la détection d'une ligne centrale.

### Fonctions Clés :
- **Machine d'États :** Gère la transition entre l'attente (`IDLE`), la rotation active (`ROTATE`) et la fin de tâche (`DONE`).
- **Détection de Centre :** Utilise une fonction `is_centered` qui vérifie si le bit central du capteur de position est à '1'.
- **Commandes Moteurs :** Génère un signal de 14 bits incluant l'activation (bit 13), la direction (bit 12) et le rapport cyclique (bits 11 à 0).
- **Synchronisation (CDC) :** Intègre des bascules de synchronisation pour le signal `data_ready` afin de sécuriser le passage entre les domaines d'horloge.

---

## 2. Module : CTL_SL (Suiveur de Ligne)
Ce module assure le maintien du robot sur la ligne en ajustant dynamiquement la vitesse des roues.

### Fonctions Clés :
- **Calcul d'Erreur Pondéré :** Attribue des poids allant de -3 à +3 selon la position de la ligne sous les 7 capteurs infrarouges.
- **Correction par BIAS :** - `Vitesse_Droite = Base - (BIAS * Erreur)`
  - `Vitesse_Gauche = Base + (BIAS * Erreur)`
- **Protection "Clamp" :** Une fonction `clamp12` garantit que la valeur de commande reste entre 0 et 4095, évitant les dépassements de capacité (overflow).
- **Sécurité de Perte de Ligne :** Si le capteur ne détecte plus rien (`"0000000"`), le robot s'arrête immédiatement et lève le drapeau `fin_SL`.

---

## Structure de la Commande Moteur (14 bits)
| Bit | Fonction | Description |
| :--- | :--- | :--- |
| **13** | Enable | '1' pour activer le moteur, '0' pour l'arrêt. |
| **12** | Direction | Définit le sens de rotation. |
| **11-0** | Duty Cycle | Valeur PWM (0 à 4095). |


## 3. Logiciel de Pilotage (C)

Le matériel VHDL est piloté par un processeur embarqué (type NIOS II) via des adresses mémoires spécifiques (Memory-Mapped I/O).

### A. Algorithme de Demi-tour (`Demi_tour.c`)
Ce programme gère l'intelligence de navigation en alternant entre le suivi de ligne et la rotation.

* **Gestion des États :** Le système utilise une structure `switch/case` pour passer d'un comportement à l'autre selon les capteurs.
* **Handshake Matériel/Logiciel :** * Le logiciel active les modules via `PORT_S`.
    * Il attend les signaux de retour `FIN_SL` ou `FIN_ROT` (provenant du VHDL) pour passer à l'étape suivante.
* **Inversion de Direction :** À chaque fin de ligne, le logiciel alterne le sens du demi-tour (gauche/droite) grâce à une opération XOR (`dir ^= 1`).

### B. Interface de Calibration (`SL_Str.c`)
Ce programme permet de tester les performances du robot en direct via un terminal série.

* **Commandes Temps Réel :**
    * `g` / `s` : Pilotage manuel du bit `start_SL`.
    * `b <valeur>` : Ajuste la vitesse `BASE_DUTY` (0 à 4095).
    * `n <valeur>` : Ajuste le seuil de détection `NIVEAU` pour l'ADC.
* **Validation des Données :** Le code inclut des protections pour que les valeurs saisies ne dépassent pas les capacités des registres matériels (ex: clamp à 4095 pour le duty cycle).

---

## Cartographie des Registres (Mapping)

| Symbole | Adresse | Direction | Description |
| :--- | :--- | :--- | :--- |
| **VECT_POS** | `0x100` | Entrée | État des 7 capteurs (bit 0 à 6). |
| **NIVEAU** | `0x110` | Sortie | Seuil de sensibilité des capteurs. |
| **PORT_S** | `0x120` | Sortie | Commandes (bit 0=Start_SL, bit 1=Start_Rot, bit 2=Direction). |
| **BASE_DUTY**| `0x130` | Sortie | Vitesse de croisière du robot. |
| **PORT_E** | `0x140` | Entrée | Retours d'état (bit 0=Fin_SL, bit 1=Fin_Rot). |
