ETE414 : Exemples de modèles d'apprentissage automatique ⚙️
================================================================================

+ Un projet de [**Jérémie Boudreault**](http://jeremieboudreault.github.io) dans le cadre de l'enseignement du cours ETE414 à l'INRS.
+ Les scripts et les données sont rendus disponibles sous la license [Creative Common License ![](https://i.creativecommons.org/l/by-nc-nd/4.0/80x15.png)](http://creativecommons.org/licenses/by-nc-nd/4.0/)
+ Les question peuvent être addressées directement à l'adresse : [Prenom.Nom@inrs.ca](mailto:Prenom.Nom@inrs.ca)


Historique 
--------------------------------------------------------------------------------

+ **Automne 2022** : Deuxième édition du cours

    + Modélisation de l'ouverte/fermeture de la pêche (classification) avec arbre de décision en *R*
    + Modélisation la température de l'eau (régression) avec bagging, forêt aléatoire et boosting en *R*
    + Modélisation de la température de l'eau (régression) avec les réseaux de neurones en *R* et *Python*

+ **Automne 2021** : Première édition du cours

    + Modélisation de la température de l'eau (régression) avec les réseaux de neurones en *R*

Données
--------------------------------------------------------------------------------


Les données sont observations hydrologiques sur la Missouri près de Toston (proviennent de USGS) et des observations météorologiques à une station à proximité (proviennent de la NOAA). 

Pour les exemples de régression, on cherche à prédire la température (moyenne) de l'eau avec les variables hydrométéorologiques.

Pour la classification, un seuil de la température de l'eau de Tmax > `20ºC` a été défini pour la fermeture de la pêche. On cherche à prédire la fermeture/ouverture de la pêche avec deux variables : la température de l'air et le débit.


Scripts R
--------------------------------------------------------------------------------

Script de base :

+ `R/s01_prepare_data.R` : préparation des jeux de données, fusion et traitements des NAs.
+ `R/s02_models_linear_reg.R` : modèles de régression linéaire simple avec la température de l'air.
+ `R/s03_models_neural_net.R` : réseaux de neurones pour modéliser la température de l'eau.
+ `R/s04_models_tree.R` : abre de décision pour prédire l'ouverture ou la fermeture de la pêche.

Documents Rmarkdown :

+ `rmd/exemples_R_arbres_forets_boosting.Rmd` : Document d'exemples en R présentant les arbres de décision, le bagging, les forêts aléatoires et le boosting


Scripts Python
--------------------------------------------------------------------------------

+ `python/01_mlp_sklearn.py` : réseaux de neurones pour modéliser la température de l'eau.


___Enjoy !___ ✌🏻
