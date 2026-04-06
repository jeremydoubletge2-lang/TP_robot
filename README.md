# TP3 — Contrôle moteur : explication détaillée du code VHDL

## Objectif du montage

Ce code VHDL réalise la **chaîne complète de commande des moteurs du robot** :

1. le **Nios II calcule les consignes moteur** en C ;
2. les consignes sont exportées par deux PIO :

   * `s_writedatar_export`
   * `s_writedatal_export`
3. ces valeurs sont récupérées dans les signaux :

   * `cmd_R`
   * `cmd_L`
4. le bloc `PWM_generation` transforme ces consignes en **PWM de puissance** ;
5. les sorties PWM pilotent le **pont en H des moteurs**.

Le code gère également la **connexion SDRAM**, utilisée par le programme C du Nios II.

---

# 1) Déclaration des ports moteurs

```vhdl
MTRL_N : OUT STD_LOGIC;
MTRL_P : OUT STD_LOGIC;
MTRR_N : OUT STD_LOGIC;
MTRR_P : OUT STD_LOGIC;
MTR_Sleep_n : OUT STD_LOGIC;
MTR_Fault_n : IN STD_LOGIC
```

Ces ports correspondent aux **broches physiques reliées au driver moteur**.

### Rôle de chaque signal

* `MTRR_P` → commande positive moteur droit
* `MTRR_N` → commande négative moteur droit
* `MTRL_P` → commande positive moteur gauche
* `MTRL_N` → commande négative moteur gauche
* `MTR_Sleep_n` → activation du driver moteur
* `MTR_Fault_n` → retour défaut du driver

Le couple `_P` / `_N` permet de gérer le **sens de rotation**.

---

# 2) Sorties de consigne venant du Nios II

```vhdl
s_writedatar_export : out std_logic_vector(13 downto 0);
s_writedatal_export : out std_logic_vector(13 downto 0);
```

Ces deux ports sont les **PIO créés dans Platform Designer**.

Ils permettent au programme C d’écrire directement les consignes moteurs.

* `writedatar` → roue droite
* `writedatal` → roue gauche

Chaque valeur est codée sur **14 bits**.

---

# 3) Signaux internes de liaison

```vhdl
signal cmd_R : STD_LOGIC_VECTOR(13 DOWNTO 0);
signal cmd_L : STD_LOGIC_VECTOR(13 DOWNTO 0);
```

Ces signaux servent de **liaison interne entre le Nios II et le bloc PWM**.

👉 Très important :
ils transportent la **valeur numérique de vitesse** calculée par le programme C.

Exemple :

```c
IOWR(WRITEDATAR_BASE, 0, 1200);
IOWR(WRITEDATAL_BASE, 0, 1180);
```

Le FPGA récupère alors :

```text
cmd_R = 1200
cmd_L = 1180
```

---

# 4) Activation du driver moteur

```vhdl
MTR_Sleep_n <= '1';
```

Cette ligne réveille le **driver de puissance moteur**.

Comme le signal est actif à l’état bas (`Sleep_n`) :

* `0` → veille
* `1` → moteur actif

Donc ici le driver est **toujours activé**.

---

# 5) Liaison Nios II → commandes moteur

```vhdl
s_writedatar_export => cmd_R,
s_writedatal_export => cmd_L
```

C’est la partie la plus importante du TP3.

Cette liaison signifie :

> les valeurs calculées par le programme C sont copiées dans `cmd_R` et `cmd_L`.

Le Nios II envoie donc les commandes via les PIO, sans interaction directe avec le PWM.

Le VHDL sert ici de **pont entre le logiciel et le matériel**.

---

# 6) Génération PWM

```vhdl
PWM0 : PWM_generation
```

Ce bloc transforme les consignes numériques en **signaux PWM exploitables par les moteurs**.

## Entrées

```vhdl
s_writedataR => cmd_R,
s_writedataL => cmd_L
```

Le rapport cyclique dépend directement des valeurs `cmd_R` et `cmd_L`.

👉 Plus la valeur est grande, plus le moteur tourne vite.

---

# 7) Sorties vers les moteurs

```vhdl
dc_motor_p_R => MTRR_P,
dc_motor_n_R => MTRR_N,
dc_motor_p_L => MTRL_P,
dc_motor_n_L => MTRL_N
```

Les PWM calculés sont envoyés au **driver du robot**.

Le driver fournit ensuite la puissance nécessaire aux moteurs DC.

Le changement entre `P` et `N` permet :

* marche avant
* marche arrière
* freinage
* roue libre

---

# 8) Chaîne complète de commande

La chaîne complète est donc :

```text
Programme C
   ↓
PIO writedatar / writedatal
   ↓
cmd_R / cmd_L
   ↓
PWM_generation
   ↓
MTRR_P / MTRR_N / MTRL_P / MTRL_N
   ↓
Driver moteur
   ↓
Roues du robot
```

---

# 9) Lien avec la caractérisation moteur

Ce code est directement utilisé pour le TP de caractérisation :

* recherche de la vitesse minimale de démarrage
* seuil hors sol
* seuil au sol
* seuil avec piles
* correction roue droite / gauche
* mise en ligne droite
* mesure de l’hystérésis

Les valeurs trouvées expérimentalement sont envoyées par le programme C dans :

```c
IOWR(WRITEDATAR_BASE, 0, seuil_R + vitesse);
IOWR(WRITEDATAL_BASE, 0, seuil_L + vitesse);
```

Le VHDL se charge ensuite de transformer ces consignes en PWM.

---

# Conclusion

Ce code VHDL implémente une **architecture matérielle propre de commande moteur**, où le Nios II calcule les vitesses, les PIO exportent les consignes, et le bloc `PWM_generation` génère les signaux de puissance pour chaque roue. Cette séparation entre logiciel et matériel facilite la calibration, la caractérisation des seuils et l’amélioration de la trajectoire du robot.
