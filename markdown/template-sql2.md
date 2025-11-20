# Sujet d'étude

* [Critères d'évaluation](https://cpnv-es-ngy.gitbook.io/sql2/evaluations)

## Introduction

Ce sujet d'étude à pour objectif d'approfondir les liens et les dépendances entre "autocommit", "commit" et "rollback" et les "transactions".

## Objectifs

- Démontré l'utilité de l'autocommit et la dépendance qu'il a avec TRANSACTION


## Définition de dépendances

>La dépendence entre "autocommit", "commit" et "rollback" et les "transactions", et le qu'elles sont utilisé afin de 
faire d'assurer l'atomicité d'une base de données.

**_Définition à faire valider._**

--- 

Il s'agit de prouver par la pratique les points suivants :



## Scénario

* (Given) Importer ce script d'initalisation de la base de données de tests

[file to import testdb](fichier.sql)

* (Wheb) Ajouter un index sur l'attribut X

```sql
INSERT INTO 'permet de .....
```

* (Then) La même requête en consommant moitié moins de RAM

* [ma vidéo de démonstartion](lien-vers-une-vidéo)

## Théorie et Sources

Résumé des sources (un résumé produit par chat gpt est ok, pour autant que vous le remettiez en page et le validiez)

Source MySQL !!!!

```
Comment mesure le temps de la requête
```

## Mes questions :
- Dans quels cas utiliser une transaction ou un autocommit = OFF ?
- Découvrir les savepoint
- Rollback essayer de le valider en voyant les log ?
- Est-ce que l'on peut voir les commandes pas encore commit ? (dans un fichier temporaire ?)
- Définir ce qu'est la dépendance.

### Source

* [Dev MySQL - autocommit, commit and rollback](https://dev.mysql.com/doc/refman/8.4/en/innodb-autocommit-commit-rollback.html)
* [Dev MySQL - commit](https://dev.mysql.com/doc/refman/8.4/en/commit.html)
* [Dev MySQL - Rollback and savepoint](https://dev.mysql.com/doc/refman/9.0/en/savepoint.html)
* [Dev MySQL - Rollback and savepoint](https://dev.mysql.com/doc/refman/8.4/en/implicit-commit.html)
