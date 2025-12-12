# Sujet d'étude

-   [Critères d'évaluation](https://cpnv-es-ngy.gitbook.io/sql2/evaluations)

## Introduction

Ce sujet d'étude à pour objectif d'approfondir comment monitorer des requêtes SQL au plus proche du moteur de BDD.

## Objectifs

Il s'agit de prouver par la pratique les points suivants:

-   Comment utiliser `Performance Schema` pour :
    -   Mesurer le poids d'une requête (RAM)
    -   Mesurer le temps d'exécution d'une requête (ms)
    -   Comparer des requêtes sur leur poids et leur temps d'exécution

## Scénario

Ces scripts sql doivent être exécuté pour le bon fonctionnement des scénarios :

-   [fichier pour importer la testdb](../appendices/initDummyDatabase.sql)

-   [fichier pour importer la configuration performance schema](../appendices/configurePerformanceSchema.sql)

Avant chaque nouveau scénario, nettoyer l'historique de performance_schema :

```sql
TRUNCATE TABLE performance_schema.events_statements_history_long;
```

> modifier le script `configurePerformanceSchema.sql` avec votre host et utilisateur pour les acteurs.

-    [source](https://dev.mysql.com/doc/mysql-perfschema-excerpt/8.0/en/performance-schema-query-profiling.html)

### Mesurer le poids d'une requête (RAM)

-   (Given) créer une nouvelle session en récupérant le thread id de la session

```bash
mysql -u username -p
```

```sql
SET @cid = (SELECT CONNECTION_ID());
SET @tid = (SELECT thread_id
    FROM performance_schema.threads
    WHERE PROCESSLIST_ID=@cid);
```

Noter le connection_id

```sql
SELECT @cid;
```

-   (When) évaluer la mémoire utilise par une requête en utilisant un script python

> La requête suivante est utilisée pour connaître la consommation mémoire par les différents event MySQL. Ceci est utilisé constamment dans le script python utilisé pour pouvoir monitorer la consommation mémoire.

```sql
SELECT event_name, current_number_of_bytes_used
FROM performance_schema.memory_summary_by_thread_by_event_name
WHERE thread_id = @tid
ORDER BY event_name DESC;
```

Lancer le [script python](appendices\sqlMonitor.py) :

```bash
py ./appendices/sqlMonitor.py --connection-id <connection-id> --frequency 250
```

Effectuer la requête à analyser :

```sql
USE demo_db;
SELECT
    products.category_id,
    SUM(order_items.quantity * order_items.unit_price) AS revenue
FROM order_items
JOIN products ON products.id = order_items.product_id
JOIN orders ON orders.id = order_items.order_id
GROUP BY products.category_id
ORDER BY revenue DESC;
```

-   (Then) Observer le nombre indiquer pour la memoire minimum et maximum

Sources :
-    https://dev.mysql.com/doc/refman/8.4/en/monitor-mysql-memory-use.html
-    https://dev.mysql.com/doc/refman/8.4/en/performance-schema-memory-summary-tables.html
-    https://planetscale.com/blog/profiling-memory-usage-in-mysql

[Vidéo](https://youtu.be/hcIktgakZYU)

### Mesurer le temps d'exécution d'une requête (ms)

-   (Given) Executer la requête à mesurer

```sql
USE demo_db;

/* most profitable category */
SELECT
    products.category_id,
    SUM(order_items.quantity * order_items.unit_price) AS revenue
FROM order_items
JOIN products ON products.id = order_items.product_id
JOIN orders ON orders.id = order_items.order_id
GROUP BY products.category_id
ORDER BY revenue DESC;
```

-   (When) Rechercher la requête pour le temps en milliseconde

```sql
SELECT EVENT_ID, TRUNCATE(TIMER_WAIT/1e9,6) as Duration_MS, SQL_TEXT
FROM performance_schema.events_statements_history_long WHERE SQL_TEXT like '%most profitable category%'\G
```

-   (Then) Constater le temps d'exécution

Sources :
-    https://dev.mysql.com/doc/mysql-perfschema-excerpt/8.0/en/performance-schema-query-profiling.html
-    https://dev.mysql.com/doc/mysql-perfschema-excerpt/8.0/en/performance-schema-events-statements-history-long-table.html

[Vidéo](https://youtu.be/hGmmd-n1EN0)

### Comparer des requêtes sur leur temps d'exécution

-   (Given) Exécuter les deux requêtes à comparer

Effacer les données dans la table d'historique :

```sql
USE demo_db;

/* First query */
SELECT
    products.category_id,
    SUM(order_items.quantity * order_items.unit_price) AS revenue
FROM order_items
JOIN products ON products.id = order_items.product_id
JOIN orders ON orders.id = order_items.order_id
GROUP BY products.category_id
ORDER BY revenue DESC;
```

-   (When) Récupérer l'event id des deux requêtes et récupérer le temps d'éxecution par étapes

Analyser ou la latence a optimiser se trouve dans la requête :

```sql
SELECT EVENT_ID, SQL_TEXT
FROM performance_schema.events_statements_history_long WHERE SQL_TEXT LIKE '%First query%'\G
```

```sql
SELECT event_name AS Stage, TRUNCATE(TIMER_WAIT/1e9,6) AS Duration_MS
FROM performance_schema.events_stages_history_long WHERE NESTING_EVENT_ID=<unoptimized id>;
```

Tenter une optimisation de la requête :

```sql
USE demo_db;

/* Second query */
SELECT
    products.category_id,
    SUM(order_items.quantity * order_items.unit_price) AS revenue
FROM order_items
JOIN products ON products.id = order_items.product_id
GROUP BY products.category_id
ORDER BY revenue DESC;
```

-   (Then) Comparer les résultats du temps d'exécution par étapes

```sql
SELECT EVENT_ID, SQL_TEXT
FROM performance_schema.events_statements_history_long WHERE SQL_TEXT LIKE '%Second query%'\G
```

```sql
SELECT event_name AS Stage, TRUNCATE(TIMER_WAIT/1e9,6) AS Duration_MS
FROM performance_schema.events_stages_history_long WHERE NESTING_EVENT_ID=<optimized id>;
```

Sources :
-    https://dev.mysql.com/doc/mysql-perfschema-excerpt/8.0/en/performance-schema-query-profiling.html
-    https://dev.mysql.com/doc/mysql-perfschema-excerpt/8.0/en/performance-schema-events-stages-history-long-table.html

[Vidéo](https://youtu.be/VYNvJ1GvweY)

## Théorie et Sources

Résumé des sources (un résumé produit par chat gpt est ok, pour autant que vous le remettiez en page et le validiez)

-    [Performance Schema](https://dev.mysql.com/doc/refman/8.4/en/performance-schema.html)
-    [Events](https://dev.mysql.com/doc/refman/8.4/en/performance-schema-statement-tables.html)
-    [Threads](https://dev.mysql.com/doc/refman/8.4/en/performance-schema-threads-table.html)
-    [Instruments](https://dev.mysql.com/doc/refman/8.4/en/performance-schema-setup-instruments-table.html)
-    [Consumers](https://dev.mysql.com/doc/refman/8.4/en/performance-schema-setup-consumers-table.html)
-    [Actors](https://dev.mysql.com/doc/refman/8.4/en/performance-schema-setup-actors-table.html)
