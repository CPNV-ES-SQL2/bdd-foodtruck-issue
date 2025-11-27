# Formes normales (par la pratique)
## Introduction

Ce document vise à expliquer les formes normales en bases de données relationnelles à travers des exemples pratiques. Nous allons explorer les 3 dernières formes normales (BCNF, 4NF et 5NF) en utilisant des exemples concrets pour illustrer chaque concept.

## Objectifs

Il s'agit de prouver par la pratique les points suivants:

- Comment identifier les violations des trois dernières formes normales ?
  - Es-ce que certaines dépendances fonctionnelles ne sont pas basées sur des clés candidates ?
  - Es-ce que certaines dépendances multivaluées existent ? 
  - Es-ce que certaines dépendances jointives existent ?
- Comment normaliser une base de données pour respecter ces formes normales ?
  - Définir des scénarios d'une base de données non normalisée puis appliquer les migrations nécessaires pour atteindre la forme normale souhaitée.
- Quel est l'impact de la normalisation sur les performances (temps de réponse) et la taille des requêtes ?
  - Définir les différence entre un SELECT avant et après normalisation. (ex: nombre de jointures nécessaires)
  - Définir les différence entre un INSERT, UPDATE avant et après normalisation.

## Scénario
### Scénario 1: Identification de la violation de la BCNF.
#### Given
Prenons le contexte d'une base de données de gestion des cours par example pour le CPNV. Exutons le script `given.sql` pour créer la base de données en 3NF mais violant la BCNF. Imaginons que `Ethann`, `Julien` et `Nathan` participe au cours `MAW` et que leur instructeur est `Nicolas`. 

#### When
Imaginons maintenant que `Nicolas` donne le cours `MAW` en paralèle avec un autre instructeur `Julien`. 
Executons le script `when.sql` pour insérer cette donnée.

#### Then
Le résultat est que le moteur de base donnée n'acceptera pas cette insertion car elle viole la contrainte d'unicité sur la table `Students_Courses` (la clé primaire est composée de `student_id` et `course_id`). 

## Théorie et Sources

- [Principes de base de la normalisation des bases de données](https://learn.microsoft.com/fr-fr/office/troubleshoot/access/database-normalization-description)
- [Normalization in SQL (1NF - 5NF): A Beginner’s Guide](https://www.datacamp.com/tutorial/normalization-in-sql)
- [Database normalization](https://en.wikipedia.org/wiki/Database_normalization)
- [Qu’est-ce que la normalisation des bases de données ?](https://www.ibm.com/fr-fr/think/topics/database-normalization)