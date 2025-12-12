# Index en Varchar

* [Critères d'évaluation](https://cpnv-es-ngy.gitbook.io/sql2/evaluations)

## Introduction

Ce sujet d'étude avait pour objectif d'approfondir si l'utilisation d'index sur des colonnes de type VARCHAR ont un impact significatif sur les performances dans une base de données MySQL. Mais suite à des résultats non concluents, le nouveau but de ce sujet est d'étudier l'impact que peut avoir le bon usage des index MySQL sur des requêtes.

## Objectifs

Il s'agit de prouver par la pratique les points suivants:

* Comparer le poids de requêtes identiques, mais avec des index différents. Tout ceci en surveillant les métriques suivantes :
  * Mesurer les performances en termes de temps d'exécution.
  * Analyser la consommation de mémoire du thread MySQL en temps réel.
  * Mesurer l'espace disque utilisé par les index.

## Scénario

### Scénario 1 - Comparaison de requêtes sans index optimisés
#### Given
Une base de données de test est initialisée avec les scripts suivants :


[file to import testdb](../appendices/schema.sql)
```bash
mysql -u USERNAME -p'PASSWORD' -h MYSQL_IP -P MYSQL_PORT < appendices/schema.sql
```
now that you have an empty table, you can use [this seeder](../appendices/populate_data.py) to populate it with test data. (Change the config at line 13 of the script to connect to your db)

```bash
python3 appendices/populate_data.py
```

##### Pour activer le performance schema

Activer le performance schema dans le fichier de configuration my.cnf ou my.ini

```
[mysqld]
performance_schema=ON
performance-schema-instrument='memory/%=COUNTED'
```   

#### When
J’exécute et mesure les performances (temps, mémoire, I/O) des requêtes suivantes :
1. Recherche par prénom :

   ```sql
   SELECT COUNT(*) FROM personas WHERE first_name = 'Pierre';
   ```
2. Recherche par nom :

   ```sql
   SELECT COUNT(*) FROM personas WHERE last_name = 'Müller';
   ```
3. Recherche combinée prénom + nom :

   ```sql
   SELECT COUNT(*) FROM personas WHERE first_name = 'Pierre' AND last_name = 'Müller';
   ```
4. Recherche combinée prénom + nom + ville :

   ```sql
   SELECT COUNT(*) FROM personas WHERE first_name = 'Pierre' AND last_name = 'Müller' AND city = 'Genève';
   ```

Et j'observe le plan d’exécution pour la requête 3 :

```sql
EXPLAIN SELECT COUNT(*) FROM personas WHERE first_name = 'Pierre' AND last_name = 'Müller';
```

### Then

* Les requêtes provoquent un "full table scan".
* Le temps d’exécution est élevé.
* La consommation mémoire et l'I/O sont significatives.


## Scénario 2 — Ajout d’un index simple et comparaison des performances

### Given

* Les conditions du scénario 1.
* Un index simple ajouté sur `first_name` :

  ```sql
  CREATE INDEX idx_first_name ON personas(first_name);
  ```

### When

Je relance les requêtes de sélection :

* Requêtes 1 à 4 (identiques au scénario précédent).
* Je compare les nouveaux temps d’exécution.
* J' observe les nouveaux plans d’exécution.

### Then

* Les recherches filtrant par `first_name` deviennent nettement plus rapides.
* Une partie des full scans disparaît.
* Certaines requêtes filtrant par plusieurs colonnes restent sous-optimisées.
* Un usage de ram réduit devrait être observé

## Scénario 3 — Utilisation d’un index composite `first_name + last_name`

### Given

* Un index composite est créé :

  ```sql
  CREATE INDEX idx_full_name ON personas(first_name, last_name);
  ```

### When

J’exécute :

* Requête 3 et 4 (prénom + nom, puis prénom + nom + ville).
* Analyse du plan d’exécution :

  ```sql
  EXPLAIN SELECT COUNT(*) 
  FROM personas 
  WHERE first_name = 'Pierre' AND last_name = 'Müller';
  ```

### Then

* Les requêtes utilisant `first_name` et `last_name` deviennent plus simples.
* Le plan utilise plus de full scan, et doit filter parmis moins de lignes.

## Scénario 4 — Analyse de l'espace disque
### Given
* Les index créés dans les scénarios précédents.
### When
* J’utilise la commande suivante pour mesurer l’espace disque utilisé par les index :
```sql
SELECT database_name, table_name, index_name,
ROUND(stat_value * @@innodb_page_size / 1024, 2) size_in_kb
FROM mysql.innodb_index_stats
WHERE stat_name = 'size' AND table_name LIKE "%personas%"
ORDER BY size_in_kb DESC;
```
### Then
* L’espace disque utilisé par chaque index est affiché, et les index qui contiennent plus de colonnes complexes sont plus lourds que les index simples.

### Vidéo de démonstration

[Lien vers une playlist YouTube avec les différentes étapes du test](https://youtube.com/playlist?list=PLsLGSX1UKwhp0UH9aw8ZHuAhlLIvL-QQ9&si=iZH25RgzK47snMRp)
Lien des vidéos individuelles :
 - [Mise en place de la database](https://youtu.be/DgztFLnYqkY)
 - [Test 1](https://youtu.be/cTjeNzNvNOA)
 - [Test 2](https://youtu.be/8T5NmEBE7Vs)
 - [Test 3](https://youtu.be/EJiwWyjsdss)
 - [Test 4](https://youtu.be/0ICXNKU13n8)
## Théorie et Sources

Résumé des sources (un résumé produit par chat gpt est ok, pour autant que vous le remettiez en page et le validiez)

Source MySQL !!!!
 - [How MySQL Uses Indexes](https://dev.mysql.com/doc/refman/8.4/en/mysql-indexes.html)
 - [Column Indexes](https://dev.mysql.com/doc/refman/8.4/en/column-indexes.html)
 - [Multiple column indexes](https://dev.mysql.com/doc/refman/8.4/en/multiple-column-indexes.html)

## Sources non MySQL
 - [planetscale, explication et animation B-Tree utilisée durant la présentation](https://planetscale.com/blog/btrees-and-database-indexes)
 - [Wikipedia](https://en.wikipedia.org/wiki/B-tree)

