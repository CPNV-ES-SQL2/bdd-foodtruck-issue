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

### Mesurer le poids d'une requête (RAM)

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

-   (Given) Mettre en place la configuration de base et la DBB test avec une query dans l'historique

```sql
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
    LIMIT 5000
) AS workload_multiplier
WHERE users.email LIKE '%example%'
ORDER BY RAND();
```

-   (When) Rechercher la requête pour le temps en milliseconde

```sql
SELECT EVENT_ID, TRUNCATE(TIMER_WAIT/1000000000,6) as Duration_MS, SQL_TEXT
FROM performance_schema.events_statements_history_long WHERE SQL_TEXT like '%example%';
```

-   (Then) Constater le temps d'exécution

Le temps en milisecondes devrait être affiché des requêtes contenant "example"

## Vidéo

-   [Vidéo de démonstartion](lien-vers-une-vidéo)

## Théorie et Sources

Résumé des sources (un résumé produit par chat gpt est ok, pour autant que vous le remettiez en page et le validiez)

Source MySQL !!!!

```
Comment mesure le temps de la requête
```
