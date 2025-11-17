# Sujet d'étude

(temp) User and System variables - [Tâche](https://github.com/CPNV-ES-SQL2/bdd-foodtruck-issue/issues/9)

## Introduction

Ce sujet d'étude à pour objectif d'approfondir l'utilisation des variables en allant soit de crée ou modifier des variables d'utilisateurs et du système tout en ayant consciente du contexte a les utiliser et ainsi l'effet sur la persistance du contenu des variables 


## Objectifs

Il s'agit de prouver par la pratique ce point suivant:

- De savoir dans quel contexte devrons nous utiliser soit les variables d'environnement d'un utilisateur, soit du système ou soit les 2 en même temps
- La portée entre les 3 types de variables (user, system et dynamic)
- La persistance des variables aux travers de changement de session 

## Théorie et Sources

Résumé des sources (un résumé produit par chat gpt est ok, pour autant que vous le remettiez en page et le validiez)

En autre, les variables d'environnement d'utilisateur peuvent être utiliser pour stocker une valeur d'une requête puis de la référer dans une autre requête
Ces valeurs commencent avec un @ et sont défini via un SET comme ceci :
```sql
SET @var_name = expr
```
Les variables ne peuvent qu'avoir les types suivant : integer, decimal, float, binaire or nonbinaire string, ou une valeur `NULL` 

Quelque soit le type de variables, __ils ne peuvent être pas utiliser *directement* dans une requête SQL__
```sql
SET @col1 = "c1";

SELECT @col1 from t;
```
Le code du haut donnera quelque chose comme ceci :

| @col1 |
| ----- |
| c1    |

Cependant, préparer une requête avec une/des variables puis de l'exécuter fonctionne 
*add exemple in MySQL*
Source MySQL :
[User-defined variable](https://dev.mysql.com/doc/refman/8.4/en/user-variables.html)
[System variable](https://dev.mysql.com/doc/refman/8.4/en/using-system-variables.html)
[Variable dynamiques du système + tableau](http://dev.mysql.com/doc/refman/8.4/en/dynamic-system-variables.html)
## Validation pratique

* (Given) Importer ce script d'initalisation de la base de données de tests

[file to import testdb](fichier.sql)

* (Wheb) Ajouter un index sur l'attribut X

```sql
INSERT INTO 'permet de .....
```

* (Then) La même requête en consommant moitié moins de RAM

```
Comment mesure le temps de la requête
```


* [ma vidéo de démonstartion](lien-vers-une-vidéo)
