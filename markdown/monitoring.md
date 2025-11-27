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
    -   Diagnostiquer des requêtes pour les optimiser
-   Comment utiliser `sys Schema` pour :
    -   Synthétiser les données de `Performance Schema`
    -   Utiliser les procédures `sys Schema`
    -   Générer des rapports de diagnostiques

## Scénario

Ces scripts sql doivent etre executer pour le bon fonctionnement des scénarios:

-   [fichier pour importer la testdb](../appendices/initDummyDatabase.sql)

-   [fichier pour importer la configuration performance schema](../appendices/configurePerformanceSchema.sql)

[source](https://dev.mysql.com/doc/mysql-perfschema-excerpt/8.0/en/performance-schema-query-profiling.html)

### Mesurer le poids d'une requête (RAM)

Source:
https://planetscale.com/blog/profiling-memory-usage-in-mysql

-   (Given) créer une nouvelle session

Dans un nouveau terminal :

```sql
mysql -u username -p
```

```sql
SET @cid = (SELECT CONNECTION_ID());
SET @tid = (SELECT thread_id
    FROM performance_schema.threads
    WHERE PROCESSLIST_ID=@cid);
```

-   (When) évaluer la mémoire initial avant la requête et effectuer la requête

La requête suivante est utilisé pour connaitre la consommation mémoire par les différents event MySQL. Ceci devrait être utilisé constament durant l'execution d'une requête (par un script par exemple) pour pouvoir monitorer la consommation mémoire.

```sql
SELECT
    event_name,
    current_number_of_bytes_used
FROM performance_schema.memory_summary_by_thread_by_event_name
WHERE thread_id = @tid
ORDER BY current_number_of_bytes_used DESC
```

-   (Then) Rassembler la mémoire utilisé pendant l'exécution de la requête

### Use case : Mesurer le temps d'exécution d'une requête (ms)

Source:
https://dev.mysql.com/doc/mysql-perfschema-excerpt/8.0/en/performance-schema-query-profiling.html

-   (Given) Mettre en place la configuration de base et la DBB test avec une query dans l'historique

```sql
USE demo_db;
SELECT
    users.first_name,
    users.last_name,
    products.name AS product_name,
    products.price,
    orders.quantity,
    (products.price * orders.quantity) AS total_price,
    SHA2(CONCAT(users.email, products.name, orders.quantity), 256) AS hash
FROM users
JOIN orders
    ON users.id = orders.user_id
JOIN products
    ON products.id = orders.product_id
CROSS JOIN (
    SELECT 1 AS x
    FROM orders
    LIMIT 10000
) AS workload_multiplier
```

-   (When) Rechercher la requête pour le temps en milliseconde

```sql
SELECT EVENT_ID, TRUNCATE(TIMER_WAIT/1000000000,6) as Duration_MS, SQL_TEXT
FROM performance_schema.events_statements_history_long WHERE SQL_TEXT like '%workload_multiplier%';
```

-   (Then) Constater le temps d'exécution

Le temps en milisecondes devrait être affiché des requêtes contenant "example"

### Comparer des requêtes sur leur temps d'exécution

Source:
https://dev.mysql.com/doc/mysql-perfschema-excerpt/8.0/en/performance-schema-query-profiling.html

-   (Given) Exécuter les deux requêtes à comparer

```sql
USE demo_db;
SELECT
    users.first_name,
    users.last_name,
    products.name AS product_name,
    products.price,
    orders.quantity,
    (products.price * orders.quantity) AS total_price,
    SHA2(CONCAT(users.email, products.name, orders.quantity), 256) AS hash
FROM users
JOIN orders
    ON users.id = orders.user_id
JOIN products
    ON products.id = orders.product_id
CROSS JOIN (
    SELECT 1 AS x
    FROM orders
    LIMIT 10000
) AS workload1_multiplier
```

```sql
SELECT
    users.first_name,
    users.last_name,
    products.name AS product_name,
    products.price,
    orders.quantity,
    (products.price * orders.quantity) AS total_price,
    SHA2(SHA2(CONCAT(users.email, products.name, orders.quantity), 256), 256) AS double_hash
FROM users
JOIN orders
    ON users.id = orders.user_id
JOIN products
    ON products.id = orders.product_id
CROSS JOIN (
    SELECT 1 AS x
    FROM orders
    LIMIT 10000
) AS workload2_multiplier
WHERE users.email LIKE '%example%';
```

-   (When) Récupérer l'event id des deux requêtes et récupérer le temps d'éxecution par étapes

```sql
SELECT EVENT_ID
FROM performance_schema.events_statements_history_long WHERE SQL_TEXT LIKE '%workload1_multiplier%';
```

```sql
SELECT EVENT_ID
FROM performance_schema.events_statements_history_long WHERE SQL_TEXT LIKE '%workload2_multiplier%';
```

```sql
SET @event_q1 = <event_id_from_first_query>;
SET @event_q2 = <event_id_from_second_query>;
```

```sql
WITH
statement AS (
  SELECT EVENT_ID, SQL_TEXT, TRUNCATE(TIMER_WAIT/1e9, 3) AS total_ms
  FROM performance_schema.events_statements_history_long
  WHERE EVENT_ID IN (@event_q1, @event_q2)
),
stages AS (
  SELECT NESTING_EVENT_ID AS event_id,
         EVENT_NAME AS stage,
         TRUNCATE(TIMER_WAIT/1e9, 3) AS ms
  FROM performance_schema.events_stages_history_long
  WHERE NESTING_EVENT_ID IN (@event_q1, @event_q2)
),
all_stages AS (
  SELECT DISTINCT stage FROM stages
)

SELECT
  a.stage,
  COALESCE(s1.ms, 0) AS q1_ms,
  COALESCE(s2.ms, 0) AS q2_ms,
  (COALESCE(s2.ms, 0) - COALESCE(s1.ms, 0)) AS diff_ms
FROM all_stages a
LEFT JOIN (SELECT stage, ms FROM stages WHERE event_id = @event_q1) s1 USING (stage)
LEFT JOIN (SELECT stage, ms FROM stages WHERE event_id = @event_q2) s2 USING (stage)

UNION ALL

SELECT
  'TOTAL' AS stage,
  (SELECT total_ms FROM statement WHERE EVENT_ID = @event_q1) AS q1_ms,
  (SELECT total_ms FROM statement WHERE EVENT_ID = @event_q2) AS q2_ms,
  (SELECT total_ms FROM statement WHERE EVENT_ID = @event_q2)
    - (SELECT total_ms FROM statement WHERE EVENT_ID = @event_q1)
  AS diff_ms

ORDER BY
  CASE WHEN stage = 'TOTAL' THEN 2 ELSE 1 END,
  stage;
```

-   (Then) Comparer les résultats du temps d'exécution par étapes

### Diagnostiquer des requêtes pour les optimiser

Sources:
https://dev.mysql.com/doc/refman/8.4/en/performance-schema-examples.html

-   (Given) Une série de requêtes sont exécuté

-   (When) Inspecter les requêtes pour voir les plus couteuse

```sql
SELECT
  digest_text,
  COUNT_STAR AS exec_count,
  ROUND(AVG_TIMER_WAIT/1e9, 3) AS avg_ms,
  ROUND(SUM_TIMER_WAIT/1e9, 3) AS total_ms
FROM performance_schema.events_statements_summary_by_digest
ORDER BY avg_ms DESC
LIMIT 5;
```

-   (Then) Optimiser la requête et voir le résultat

## Vidéo

-   [Vidéo de démonstartion](lien-vers-une-vidéo)

## Théorie et Sources

Résumé des sources (un résumé produit par chat gpt est ok, pour autant que vous le remettiez en page et le validiez)

Source MySQL !!!!

```
Comment mesure le temps de la requête
```
