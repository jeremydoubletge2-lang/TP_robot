#include <stdint.h>

#define moteuright (*(volatile uint16_t *)0x00000010u)
#define moteurleft  (*(volatile uint16_t *)0x00000000u)

int main(void)
{
    uint16_t compteur12 = 750u;
    uint16_t commande;
    volatile int i;   // volatile pour éviter l’optimisation de la boucle

    while (1)
    {
        // incrémentation sur 12 bits (pas de +10)
        compteur12 = (uint16_t)((compteur12 + 100) & 0x0FFFu);

        // commande 0x3000 + compteur12
        commande = (uint16_t)(0x3000u | compteur12);

        moteuright = commande;
        moteurleft  = commande;
		printf(commande);
        // petite temporisation
        for (i = 0; i < 100; i++)
        {
        }
    }

    return 0;
}
