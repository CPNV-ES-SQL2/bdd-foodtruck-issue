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
##### Pour activer le performance schema

Activer le performance schema dans le fichier de configuration my.cnf ou my.ini

```
[mysqld]
performance_schema=ON
performance-schema-instrument='memory/%=COUNTED'
```   

#### (When) Je compare les performances de cette requête sur les 2 tables

```sql
SET PROFILING = 1;
SELECT * FROM users_int WHERE id = 54310;
SELECT * FROM users_int WHERE id = 54311;
SELECT * FROM users_int WHERE id = 54312;
SELECT * FROM users_int WHERE id = 54313;
SELECT * FROM users_int WHERE id = 54314;
SELECT * FROM users_int WHERE id = 54315;
SELECT * FROM users_int WHERE id = 54316;
SELECT * FROM users_int WHERE id = 54317;
SELECT * FROM users_int WHERE id = 54318;
SELECT * FROM users_varchar WHERE id = '54310';
SELECT * FROM users_varchar WHERE id = '54311';
SELECT * FROM users_varchar WHERE id = '54312';
SELECT * FROM users_varchar WHERE id = '54313';
SELECT * FROM users_varchar WHERE id = '54314';
SELECT * FROM users_varchar WHERE id = '54315';
SELECT * FROM users_varchar WHERE id = '54316';
SELECT * FROM users_varchar WHERE id = '54317';
SELECT * FROM users_varchar WHERE id = '54318';

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

INSERT INTO users_int (id, data) VALUES (420000001, 'Test User');
INSERT INTO users_int (id, data) VALUES (420000002, 'Test User');
INSERT INTO users_int (id, data) VALUES (420000003, 'Test User');
INSERT INTO users_int (id, data) VALUES (420000004, 'Test User');
INSERT INTO users_int (id, data) VALUES (420000005, 'Test User');
INSERT INTO users_int (id, data) VALUES (420000006, 'Test User');
INSERT INTO users_int (id, data) VALUES (420000007, 'Test User');
INSERT INTO users_int (id, data) VALUES (420000008, 'Test User');
INSERT INTO users_int (id, data) VALUES (420000009, 'Test User');
INSERT INTO users_varchar (id, data) VALUES ('420000001', 'Test User');
INSERT INTO users_varchar (id, data) VALUES ('420000002', 'Test User');
INSERT INTO users_varchar (id, data) VALUES ('420000003', 'Test User');
INSERT INTO users_varchar (id, data) VALUES ('420000004', 'Test User');
INSERT INTO users_varchar (id, data) VALUES ('420000005', 'Test User');
INSERT INTO users_varchar (id, data) VALUES ('420000006', 'Test User');
INSERT INTO users_varchar (id, data) VALUES ('420000007', 'Test User');
INSERT INTO users_varchar (id, data) VALUES ('420000008', 'Test User');
INSERT INTO users_varchar (id, data) VALUES ('420000009', 'Test User');

SHOW PROFILES;
```
#### (Then) Le temps d'exécution de la requête en varchar devrait prendre plus de temps.
Puisque l'inex VARCHAR est plus grand en taille, il est plus lent à mettre à jour car plus d'IO à effectuer et potentiellement plus de fragmentation.


### Delete from indexed INT vs indexed VARCHAR

#### (Given) la base de données de tests est initialisée par le test précédent.

#### (When) Je compare les performances de cette requête sur les 2 tables

```sql
SET PROFILING = 1;
DELETE FROM users_int WHERE id = 420000001;
DELETE FROM users_int WHERE id = 420000002;
DELETE FROM users_int WHERE id = 420000003;
DELETE FROM users_int WHERE id = 420000004;
DELETE FROM users_int WHERE id = 420000005;
DELETE FROM users_int WHERE id = 420000006;
DELETE FROM users_int WHERE id = 420000007;
DELETE FROM users_int WHERE id = 420000008;
DELETE FROM users_int WHERE id = 420000009;
DELETE FROM users_varchar WHERE id = '420000001';
DELETE FROM users_varchar WHERE id = '420000002';
DELETE FROM users_varchar WHERE id = '420000003';
DELETE FROM users_varchar WHERE id = '420000004';
DELETE FROM users_varchar WHERE id = '420000005';
DELETE FROM users_varchar WHERE id = '420000006';
DELETE FROM users_varchar WHERE id = '420000007';
DELETE FROM users_varchar WHERE id = '420000008';
DELETE FROM users_varchar WHERE id = '420000009';
SHOW PROFILES;
```
#### (Then) Le temps d'exécution de la requête en varchar devrait prendre plus de temps.
Puisque l'inex VARCHAR est plus grand en taille, il est plus lent à mettre à jour car plus d'IO à effectuer et potentiellement plus de fragmentation.

### Utilisation de la ram
Je n'ai pas réussi à mesurer de manière fiable la consommation de RAM entre les deux types d'index. Les variations sont trop importantes et les outils disponibles ne permettent pas une mesure précise dans ce contexte, mais l'allocation de RAM globale du serveur.
#### Outils etudies pour mesurer la RAM
| Outil                                                        | Retenu   | Justification                                                         |
| ------------------------------------------------------------ | -------- | --------------------------------------------------------------------- |
| performance_schema                                           | Non      | Effectue de mesures de l'usage de memoir non spécifique à une requête |
| https://docs.percona.com/percona-monitoring-and-management/2 | Non      | Outil de monitoring global, pas de mesure par requête                 |
| https://profilesql.com/use/                                  | A tester | Outil tiers prometteur pour des analyses plus fines                   |
| EXPLAIN ANALYZE                                              | Non      | Ne fournit pas d'information sur la RAM utilisée                      |

### Vidéo de démonstration

[Mise en place de la database](https://youtu.be/cSMaOUgi2As)
[Tests de performance](https://youtu.be/7YIYA1VJKf0)

### Résultats hors vidéo
Les tests peuvent être impactés par les processus concurrents de la machine. Notamment lors de l'enregistrement d'écran.

Voici un rapport des différences de temps d'executions effectués en dehors d'un enregistrement d'écran.
- Tests de select
  - Les select dans un index int ont duré en moyenne 0,12 ms
  - Les select dans un index varchar ont duré en moyenne 0,14 ms
- Tests d'insert
  - Les insert dans un index int ont duré en moyenne 0,164 ms
  - Les insert dans un index varchar ont duré en moyenne 0,166 ms
- Tests de delete
  - Les delete dans un index int ont duré en moyenne 15,01 ms
  - Les insert dans un index varchar ont duré en moyenne 12,26 ms
  - Lors de la video les deletes ont duré 13,52 ms pour les int et 14,42 ms pour les varchar. Nous pouvons donc voir ici une grande variance dans les résultats...
## Théorie et Sources

Résumé des sources (un résumé produit par chat gpt est ok, pour autant que vous le remettiez en page et le validiez)

Source MySQL !!!!
