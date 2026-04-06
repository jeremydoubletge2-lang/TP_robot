Connexion du robot avec la SDRAM

La connexion avec la SDRAM est réalisée dans l’architecture Structure grâce à l’instanciation du composant nios_system.

1) Déclaration des broches SDRAM

Dans l’entité Lights, toutes les broches physiques de la mémoire sont déclarées :

DRAM_CLK, DRAM_CKE : OUT STD_LOGIC;
DRAM_ADDR : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
DRAM_BA : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
DRAM_CS_N, DRAM_CAS_N, DRAM_RAS_N, DRAM_WE_N : OUT STD_LOGIC;
DRAM_DQ : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
DRAM_DQM : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);

Chaque signal correspond à une vraie broche de la puce SDRAM présente sur la carte.

Rôle des signaux
DRAM_ADDR → adresse mémoire
DRAM_BA → sélection de banque mémoire
DRAM_DQ → bus de données 16 bits
DRAM_WE_N → écriture
DRAM_RAS_N / DRAM_CAS_N → sélection ligne/colonne
DRAM_CS_N → activation de la puce
DRAM_DQM → masquage des octets
DRAM_CLK → horloge SDRAM
DRAM_CKE → activation de l’horloge
