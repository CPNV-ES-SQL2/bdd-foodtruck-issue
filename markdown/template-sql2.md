# Sujet d'étude

* [Critères d'évaluation](https://cpnv-es-ngy.gitbook.io/sql2/evaluations)

## Introduction

Ce sujet d'étude à pour objectif d'approfondir les liens et les dépendances entre "autocommit", "commit" et "rollback" et les "transactions".

## Objectifs
  - [ ] Tester le comportement de MySQL lorsque l’autocommit est activé ou désactivé, et les conditions afin de choisir l’un ou l’autre mode.
  - [ ] Présenter une transaction en illustrant les différents cas de figure.
    - COMMIT : Qu'il permet de valider une transaction ou un groupe de requête.
    - ROLLBACK et SAVEPOINT : tester les savepoint et les différents rollback.
    - IMPLICIT COMMIT : Les déclarations qui peu importe la config MySQL fait un commit.


## Définition de dépendances

>Pour garantir l’atomicité des opérations sur la base de données, on peut utiliser les transactions et le mode autocommit, qui sont étroitement liés car tous deux servent à assurer que les modifications sont appliquées de manière cohérente et indivisible.

**_Définition à faire valider._**

--- 

## Scénario autocommit
### ROLLBACK
#### Description
Ce test vérifie qu’après avoir désactivé l’autocommit, un ROLLBACK annule uniquement l’insertion non validée d’Alice tout en conservant la ligne déjà présente de Bob dans la table students.
#### UserStory
Given :
- L'autocommit est activé par défaut.
- La base de données school existe et est vide.
- La table students(name, phone) existe et est vide.
- J’insère Bob avec 076 666 66 66 dans students.
- Je désactive l’autocommit.

When :
- J’insère Alice avec 079 999 99 99 dans students.
- J'effectue un rollback'.

Then :
- La table students contient exactement 1 ligne.
- La table students contient un étudiant Bob avec le téléphone 076 666 66 66.
- La table students ne doit pas contenir un étudiant Alice avec le téléphone 079 999 99 99.

´´´sql
-- Given

--When

--Then
´´´

### COMMIT
#### Description
Ce test vérifie qu’après désactivation de l’autocommit, l’insertion d’un nouvel étudiant suivie d’un COMMIT persiste correctement Bob et Alice dans la table students, qui contient alors exactement deux lignes.
#### UserStory
Given :
- L'autocommit est activé par défaut.
- La base de données school existe et est vide.
- La table students(name, phone) existe et est vide.
- J’insère Bob avec 076 666 66 66 dans students.
- Je désactive l’autocommit.

When :
- J’insère Alice avec 079 999 99 99 dans students.
- Je valide avec un commit.

Then :
- La table students contient exactement 2 lignes. 
- La table students contient un étudiant Bob avec le téléphone 076 666 66 66. 
- La table students contient un étudiant Alice avec le téléphone 079 999 99 99.

´´´sql
-- Given

--When

--Then
´´´

## Scénario transaction
### Intéruption de session
#### Description
Ce test vérifie que, sans validation explicite de transaction, l’insertion d’un nouvel étudiant (Alice) n’est pas persistée après la fermeture de la session et que seul l’étudiant initial (Bob) reste présent dans la table students.
#### UserStory
Given :
- L'autocommit est activé par défaut.
- La base de données school existe et est vide.
- La table students(name, phone) existe et est vide.
- J’insère Bob avec 076 666 66 66 dans students.

When :
- Je commence ma transaction.
- J’insère Alice avec 079 999 99 99 dans students.
- La table students contient un étudiant Alice avec le téléphone 079 999 99 99.
- Je coupe ma session actuelle.
- Je lance une nouvelle session.

Then :
- La table students contient exactement 1 ligne.
- La table students contient un étudiant Bob avec le téléphone 076 666 66 66.
- La table students ne doit pas contenir un étudiant Alice avec le téléphone 079 999 99 99.

´´´sql
-- Given

--When

--Then
´´´

### SAVE POINT
#### COMMIT
##### Description
Ce test vérifie que, dans la base school, l’utilisation d’un savepoint et d’un ROLLBACK TO au sein d’une transaction permet d’annuler uniquement l’insertion de Chris tout en conservant et validant définitivement les étudiants Bob (inséré avec autocommit) et Alice (validée par COMMIT) dans la table students.
##### UserStory
Given :
- L'autocommit est activé par défaut.
- La base de données school existe et est vide.
- La table students(name, phone) existe et est vide.
- J’insère Bob avec 076 666 66 66 dans students.

When :
- Je commence ma transaction.
- J’insère Alice avec 079 999 99 99 dans students.
- J'ajoute une savepoint nommé backup_one
- J’insère Chris avec 078 888 88 88 dans students.
- Je rollback to mon savepoint backup_one.
- Je commit afin de cloturer la transaction.

Then :
- La table students contient exactement 2 ligne.
- La table students contient un étudiant Bob avec le téléphone 076 666 66 66.
- La table students contient un étudiant Alice avec le téléphone 079 999 99 99.
- La table students ne doit pas contenir un étudiant Chris avec le téléphone 078 888 88 88.

´´´sql
-- Given

--When

--Then
´´´

#### ROLLBACK
##### Description
Ce test vérifie qu’avec l’autocommit activé, les insertions effectuées dans une transaction (y compris celles entourées d’un savepoint et d’un ROLLBACK TO) sont entièrement annulées par un ROLLBACK global, tandis que la ligne insérée avant la transaction (Bob) reste persistante dans la table.
##### UserStory
Given :
- L'autocommit est activé par défaut.
- La base de données school existe et est vide.
- La table students(name, phone) existe et est vide.
- J’insère Bob avec 076 666 66 66 dans students.

When :
- Je commence ma transaction.
- J’insère Alice avec 079 999 99 99 dans students.
- J'ajoute une savepoint nommé backup_one
- J’insère Chris avec 078 888 88 88 dans students.
- Je rollback to mon savepoint backup_one.
- Je rollback afin de cloturer la transaction.

Then :
- La table students contient exactement 1 ligne.
- La table students contient un étudiant Bob avec le téléphone 076 666 66 66.
- La table students ne doit pas contenir un étudiant Alice avec le téléphone 079 999 99 99.
- La table students ne doit pas contenir un étudiant Chris avec le téléphone 078 888 88 88.


´´´sql
-- Given

--When

--Then
´´´

### IMPLICIT COMMIT
#### Description
Ce test vérifie qu’un CREATE TABLE classrooms provoque un COMMIT implicite qui persiste la table, tandis qu’en l’absence de COMMIT explicite la fermeture de la session annule l’insertion d’Alice mais laisse Bob présent dans students.
#### UserStory
Given :
- L'autocommit est activé par défaut.
- La base de données school existe et est vide.
- La table students(name, phone) existe et est vide.
- J’insère Bob avec 076 666 66 66 dans students.
- Je désactive l’autocommit.

When :
- J’insère Alice avec 079 999 99 99 dans students.
- Je crée une nouvelle table classrooms
- Je coupe ma session actuelle.
- Je lance une nouvelle session.

Then :
- La table students contient exactement 1 ligne.
- La table students contient un étudiant Bob avec le téléphone 076 666 66 66.
- La table students ne doit pas contenir un étudiant Alice avec le téléphone 079 999 99 99.
- La table classrooms existe et est vide.



´´´sql
-- Given

--When

--Then
´´´

## Mes questions (notes personnelle) :
- Dans quels cas utiliser une transaction ou un autocommit = OFF ?
- Découvrir les savepoint
- Rollback essayer de le valider en voyant les log ?
- Est-ce que l'on peut voir les commandes pas encore commit ? (dans un fichier temporaire ?)
- Définir ce qu'est la dépendance.

## Théorie et Sources
* [Dev MySQL - autocommit, commit and rollback](https://dev.mysql.com/doc/refman/8.4/en/innodb-autocommit-commit-rollback.html)
* [Dev MySQL - commit](https://dev.mysql.com/doc/refman/8.4/en/commit.html)
* [Dev MySQL - Savepoint](https://dev.mysql.com/doc/refman/9.0/en/savepoint.html)
* [Dev MySQL - Implicit Commit](https://dev.mysql.com/doc/refman/8.4/en/implicit-commit.html)
* [Dev MySQL - Undo logs](https://dev.mysql.com/doc/refman/8.4/en/innodb-undo-logs.html)

### Définition autocommit
* [Dev MySQL - Autocommit](https://dev.mysql.com/doc/refman/8.4/en/glossary.html#glos_autocommit)
