## Explication du programme : lecture des switches et affichage sur les LEDs

Ce programme en langage C utilise des **adresses mémoire mappées** pour lire l’état des interrupteurs (*switches*) et afficher cet état sur des LEDs.

### Déclaration des périphériques
```c
#define switches (volatile char *) 0x04003000
#define leds (char *) 0x04003010

switches pointe vers l’adresse mémoire des interrupteurs.
leds pointe vers l’adresse mémoire des LEDs.
Le mot-clé volatile est utilisé pour switches afin d’indiquer que cette valeur peut changer à tout moment en fonction du matériel.
Fonctionnement

Dans la fonction principale, une boucle infinie est utilisée :

void main()
{
    while (1)
        *leds = *switches;
}

Le programme effectue en continu les opérations suivantes :

lit la valeur actuelle des interrupteurs ;
copie cette valeur dans le registre des LEDs ;
met à jour instantanément l’affichage lumineux.
Résultat

Chaque LED représente l’état du switch correspondant :

switch activé → LED allumée ;
switch désactivé → LED éteinte.

Cela permet de visualiser directement sur les LEDs la position des interrupteurs en temps réel.
