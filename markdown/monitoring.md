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

-   (Given) Importer ce script d'initalisation de la base de données de tests

[file to import testdb](fichier.sql)

-   (When) Ajouter un index sur l'attribut X

```sql
INSERT INTO 'permet de .....
```

-   (Then) La même requête en consommant moitié moins de RAM

-   [ma vidéo de démonstartion](lien-vers-une-vidéo)

## Théorie et Sources

Résumé des sources (un résumé produit par chat gpt est ok, pour autant que vous le remettiez en page et le validiez)

Source MySQL !!!!

```
Comment mesure le temps de la requête
```
