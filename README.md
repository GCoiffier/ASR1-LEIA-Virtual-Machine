# LEIA Virtual Machine
## Guillaume Coiffier, Nicolas Champseix
## ASR1 2016 @ENS de Lyon

## Notes

- Pour être lus par le fichier python asm.py, les fichiers .s doivent se trouver dans le dossier ASM.

- Le fichier sign_extension.cpp contient des fonctions conversion entier-complétement à deux ainsi qu'une fonction qui permet l'extension de signe de n à p bits.

- La multiplication (mult.s) multiplie les valeurs des registres r0 et r1 et place le résultat dans r2.

- La division (div.s) place dans r2 le quotient de la division de r0 par r1.

- Quelques fonctionnalités ont été ajoutées au fichier asm.py pour permettre d'écrire plus facilement des fichiers.s :
      - le mot-clé ".include" qui inclut un autre fichier dans le bytecode
      - l'instruction "let" suivie d'un nombre sur 16 bits qui effectue un letl suivi d'un leth. Le nombre peut être décimal, binaire ou hexadécimal (utiliser les préfixes 0x ou 0b).
      - la possibilité d'executer let avec des couleurs prédéfinies (mots-clés white, black, red, blue, green)
      - l'instruction write suivie de deux registres ri et rj qui est un raccourcis pour :
      		wmem ri rj
      		add rj rj 1


le fichier execute.sh (opt) file permet de lancer à la fois asm.py et le simulateur. (opt étant s, r ou f comme pour l'option du simulateur)

## Gestion d'images

Le script python picture.py prend une image de taille inférieure à 160*128 en .png, stockée dans le dossier IMG, et crée le fichier .s qui permet d'afficher cette image dans la mémoire.

Pour afficher directement une image "nom.png" dans la mémoire, utilisez la commande :
`build_pic.sh nom`

Attention : il vaut mieux que l'image utilise moins de 16 couleurs, sinon il y a un risque de débordement du programme (plus de 45056 lignes de code). Certes, cela limite grandement le nombre d'images que l'on peut afficher...

PS : Ce script nous a permis de générer procéduralement la fonction putchar, grâce aux images de lettres du dossier IMG/lettres (faites à la main !) (executez le fichier allchar.s)

## Demonstration graphique

Pour la démonstration, la suggestion est :
`./build_pic.sh nyan` (ou lancez nyan.s)  puis   house.s
