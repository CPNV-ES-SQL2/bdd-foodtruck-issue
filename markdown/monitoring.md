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

-   (Given) Mettre en place la configuration de base et la DBB test avec une query dans l'historique

[file to import testdb](../appendices/initDummyDatabase.sql)
[file to import performance schema configuration](../appendices/configurePerformanceSchema.sql)

```sql
SELECT
    users.first_name,
    users.last_name,
    products.name AS product_name,
    products.price,
    orders.quantity,
    (products.price * orders.quantity) AS total_price
FROM users
JOIN orders
    ON users.id = orders.user_id
JOIN products
    ON products.id = orders.product_id
WHERE users.email LIKE '%example.com'
ORDER BY users.last_name;
```

-   (When) Récupérer la requête pour le temps en milliseconde

```sql
SELECT EVENT_ID, TRUNCATE(TIMER_WAIT/1000000000,6) as Duration_MS, SQL_TEXT
FROM performance_schema.events_statements_history_long WHERE SQL_TEXT like '%example.com%';
```

```sql
SELECT event_name AS Stage, TRUNCATE(TIMER_WAIT/1000000000,6) AS Duration_MS
FROM performance_schema.events_stages_history_long WHERE NESTING_EVENT_ID={Id_de_la_query_precedente};
```

-   (Then) Constater la liste des étapes et leur temps d'exécution

-   [ma vidéo de démonstartion](lien-vers-une-vidéo)

## Théorie et Sources

Résumé des sources (un résumé produit par chat gpt est ok, pour autant que vous le remettiez en page et le validiez)

Source MySQL !!!!

```
Comment mesure le temps de la requête
```
