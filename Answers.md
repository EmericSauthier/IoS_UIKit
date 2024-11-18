SAUTHIER Emeric

# 1 - Environnement
## Exercice 1
### Qu'est-ce que les targets ?
Les targets sont les paramètres généraux de l'application : sur quels appareils elle fonctionne, la version d'IOS, les différentes orientations autorisées, l'écran par défaut ...

### Quels sont les fichiers de bases et quelle est leur utilité ?
Les fichiers créés de base sont : "AppDelegate.swift", "SceneDelegate.swift", "ViewController.swift", "Main.storyboard", "LaunchScreen.storyboard" et "Info.plist".  
Les fichiers "AppDelegate.swift", "SceneDelegate.swift" et "ViewController.swift" oeuvrent au fonctionnement de l'application (gestion des scènes, des vues ...).  
Les fichiers "Main.storyboard" et "LaunchScreen.storyboard" permettent de personnaliser l'affichage de l'application (disposition des éléments ...).  
Le fichier "Info.plist" permet de définir les services dont l'application a besoin pour fonctionner (accès à la localisation, aux contacts ...).  

### A quoi sert le dossier "Assets.xcassets" ?
Le dossier "Assets.xcassets" contient l'ensemble des thèmes de couleur, des icônes, images et sources de données de l'application.  

### Qu'est-ce que le storyboard ?
Le storyboard est l'aperçu de l'application que nous développons. Cet aperçu est paramétrable grâce au menu situé sur la droite.  

### Qu'est-ce que le simulateur ?
Le simulateur permet de lancer et de tester l'application sur le type d'appareil de son choix (Iphone 15 ...)

## Exercice 2
### A quoi sert le raccourci Cmd + R ?
Ce raccourci permet de builder l'application et de lancer le simulateur.

### A quoi sert le raccourci Cmd + Shift + O ?
Ce raccourci permet de rechercher rapidement des fichiers, fonctions ou autre dans le projet.

### Trouver le raccourci pour indenter le code automatiquement.
Ctrl + i

### Trouver le raccourci pour commenter la selection.
Cmd + /

## Exercice 3
Tester avec Iphone 15 et Ipad Pro.

# 3 - Delegation
## Exercice 1
### Expliquer l’intérêt d’une propriété statique en programmation.
L'intérêt d'une propriété statique est de pouvoir y accéder grâce à la classe/structure et non par l'intermédiaire d'un objet.  
Dans notre cas, nous accéderons à la liste de documents comme ceci : _DocumentFile.documents_

## Exercice 2
### Expliquer pourquoi dequeueReusableCell est important pour les performances de l’application.
L'utilisation de dequeueReusableCell est important pour les performances car il permet de réutiliser les cellules déjà existantes, cela évite de recréer les mêmes cellules et de les stocker en double par exemple.

# 4 - Navigation
## Exercice 1
### Que venons nous de faire en réalité ? Quel est le rôle du NavigationController ?
Nous venons d'ajouter un outil de navigation. Le NavigationController permet de gérer la navigation entre les vues.

### Est-ce que la NavigationBar est la même chose que le NavigationController ?
La NavigationBar est une barre de navigation qui contient des icônes ou des textes qui permettent de renvoyer sur d'autre vues. Le NavigationController contient seulement les vues et gère leur affichage.

# 5 - Bundle
## Exercice 1
### Liste des fichiers de Bundle.main
- "alimentation-equilibree.png"
- "du-vin.png"
- "burger.png"
- "ramen.png"
- "pizza.png"

# 6 - Ecran Detail
## Exercice 1
### Expliquer ce qu’est un Segue et à quoi il sert.
Un Segue est un lien entre deux controlleurs. Il permet de renvoyer d'une vue à une autre.

## Exercice 2
### Qu’est-ce qu’une constraint ? A quoi sert-elle ? Quel est le lien avec AutoLayout ?
Une constraint est une contrainte d'affichage entre un objet graphique et un référentiel. Dans notre cas, l'image (=objet) se positionne par rapport à l'écran de l'appareil (=référentiel).
Les constraints permettent donc de gérer l'affichage (position, taille ...) des éléments graphiques.
AutoLayout gère ces contraintes automatiquement, afin de centrer l'élément par exemple.

# 9 - QLPreview
## Questions
### Pourquoi serait-il plus pertinent de changer l’accessory de nos cellules pour un disclosureIndicator ?
Parce que
