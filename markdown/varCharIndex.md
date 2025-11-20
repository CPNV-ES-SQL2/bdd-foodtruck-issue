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
