# Index en Varchar

* [Critères d'évaluation](https://cpnv-es-ngy.gitbook.io/sql2/evaluations)

## Introduction

Ce sujet d'étude a pour objectif d'approfondir si l'utilisation d'index sur des colonnes de type VARCHAR ont un impact significatif sur les performances dans une base de données MySQL.

## Objectifs

Il s'agit de prouver par la pratique les points suivants:

* Comparer le poids de requêtes similaires, mais avec 2 tables différentes (une avec un index INT et l'autre un index VARCHAR)
  * Mesurer les performances en termes de temps d'exécution.
  * Mesurer la consommation de mémoire.
  * Mesurer l'espace disque utilisé par les index.
* Ne pas se contenter de tester des requêtes de lecture, mais aussi des requêtes d'insertion et de suppression.
* Analyser les résultats pour déterminer si l'indexation sur des colonnes VARCHAR est aussi efficace que sur des colonnes INT.

## Scénario

### Select where with indexed INT vs indexed VARCHAR
#### (Given) Importer ce script d'initalisation de la base de données de tests

[file to import testdb](../appendices/mysqlscript.sql)

#### (When) Je compare les performances de cette requête sur les 2 tables

```sql
SET PROFILING = 1;
SELECT * FROM users_int WHERE id = 543210;
SELECT * FROM users_varchar WHERE id = '543210';

SHOW PROFILES;

SELECT database_name, table_name, index_name,
ROUND(stat_value * @@innodb_page_size / 1024, 2) size_in_kb
FROM mysql.innodb_index_stats
WHERE stat_name = 'size' AND table_name LIKE "%users%"
ORDER BY size_in_kb DESC;
```

#### (Then) Le temps d'exécution de la requête en varchar devrait prendre plus de temps.
Puisque l'inex INT est plus petit en taille, il est plus rapide à parcourir car moins d'IO à effectuer.

### Insert into indexed INT vs indexed VARCHAR
#### (Given) la base de données de tests est initialisée par le test précédent.
#### (When) Je compare les performances de cette requête sur les 2 tables
```sql
SET PROFILING = 1;

INSERT INTO users_int (id, data) VALUES (1000001, 'Test User');
INSERT INTO users_int (id, data) VALUES (1000002, 'Test User');
INSERT INTO users_varchar (id, data) VALUES ('1000001', 'Test User');
INSERT INTO users_varchar (id, data) VALUES ('1000002', 'Test User');

SHOW PROFILES;
```
#### (Then) Le temps d'exécution de la requête en varchar devrait prendre plus de temps.
Puisque l'inex VARCHAR est plus grand en taille, il est plus lent à mettre à jour car plus d'IO à effectuer et potentiellement plus de fragmentation.


### Delete from indexed INT vs indexed VARCHAR

#### (Given) la base de données de tests est initialisée par le test précédent.

#### (When) Je compare les performances de cette requête sur les 2 tables

```sql
SET PROFILING = 1;
DELETE FROM users_int WHERE id = 101;
DELETE FROM users_varchar WHERE id = '101';
DELETE FROM users_int WHERE id = 1001;
DELETE FROM users_varchar WHERE id = '1001';
SHOW PROFILES;
```
#### (Then) Le temps d'exécution de la requête en varchar devrait prendre plus de temps.
Puisque l'inex VARCHAR est plus grand en taille, il est plus lent à mettre à jour car plus d'IO à effectuer et potentiellement plus de fragmentation.

### Utilisation de la ram
Je n'ai pas réussi à mesurer de manière fiable la consommation de RAM entre les deux types d'index. Les variations sont trop importantes et les outils disponibles ne permettent pas une mesure précise dans ce contexte, mais l'allocation de RAM globale du serveur.

[ma vidéo de démonstration](lien-vers-une-vidéo)

## Théorie et Sources

Résumé des sources (un résumé produit par chat gpt est ok, pour autant que vous le remettiez en page et le validiez)

Source MySQL !!!!

```
Comment mesure le temps de la requête
```
