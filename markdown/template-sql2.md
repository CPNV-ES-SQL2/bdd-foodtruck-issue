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

## Scénario

* (Given) 

* (When)

* (Then)

## Mes questions :
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

### Définition autocommit
* [Dev MySQL - Autocommit](https://dev.mysql.com/doc/refman/8.4/en/glossary.html#glos_autocommit)
