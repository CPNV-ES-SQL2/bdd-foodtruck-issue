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

## Scénario
### Scénario 1: Identification de la violation de la BCNF.
#### Given
Prenons le contexte d'une base de données de gestion des cours par example pour le CPNV. Exutons le script `given.sql` pour créer la base de données en 3NF mais violant la BCNF. Imaginons que `Ethann`, `Julien` et `Nathan` participe au cours `MAW` et que leur instructeur est `Nicolas`. 

Imaginons maintenant que `Nicolas` donne le cours `MAW` en paralèle avec un autre instructeur `Julien`. 
```sql
INSERT INTO Students_Courses (student_id, course_id, instructor_id) VALUES
(1, 1, 2),
(2, 1, 2),
(3, 1, 2);
```
*note: ERROR 1062 (23000): Duplicate entry '1-1' for key 'Students_Courses.PRIMARY'*

#### When

Nous remarquons que la table `Students_Courses` viole la BCNF car la dépendance fonctionnelle `instructor_id -> course_id` n'est pas basée sur une clé candidate. En effet, un instructeur peut enseigner plusieurs cours, mais chaque cours ne peut être enseigné que par un seul instructeur dans cette table.
Executons la migration `bcnf_migration.sql` pour normaliser la base de données en BCNF.

#### Then
Après avoir appliqué la migration, nous avons créé une nouvelle table `Instructors_Courses` pour gérer la relation entre les instructeurs et les cours. La table `Students_Courses` ne contient plus l'instructeur, ce qui élimine la dépendance fonctionnelle problématique.
```sql
INSERT INTO Courses_Instructors (instructor_id, course_id) VALUES
(2, 1);
```

[Vidéo](https://youtu.be/r1RSDEOmlvg)

## Théorie et Sources

- [Principes de base de la normalisation des bases de données](https://learn.microsoft.com/fr-fr/office/troubleshoot/access/database-normalization-description)
- [Normalization in SQL (1NF - 5NF): A Beginner’s Guide](https://www.datacamp.com/tutorial/normalization-in-sql)
- [Database normalization](https://en.wikipedia.org/wiki/Database_normalization)
- [Qu’est-ce que la normalisation des bases de données ?](https://www.ibm.com/fr-fr/think/topics/database-normalization)