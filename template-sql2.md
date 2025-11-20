# Sujet d'étude

* [Critères d'évaluation](https://cpnv-es-ngy.gitbook.io/sql2/evaluations)

## Introduction

Ce sujet d'étude à pour objectif d'approfondir les outils et stratégie de tests en présence d'un SGBDR.

## Objectifs

Mise en place d'un prototype de framework de test pour valider aussi bien le modèle (DDL) que les requêtes (DML) en respectant les critères suivantes:

- [ ] En limitant la charge de travail pour préparer, nettoyer et supprimer la base de données de test - mode mémoire ?
- [ ] En étant le plus proche possible de l'environnement du client.
- [ ] Exploitable à moindre effort dans tout le Pipeline CI/CD/CD.

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

* [Dev MySQL - Memory use](https://dev.mysql.com/doc/refman/8.4/en/memory-use.html)
* [Dev MySQL - Test Framework](https://dev.mysql.com/doc/dev/mysql-server/latest/PAGE_TESTING_TOOLS.html)

```
Comment mesure le temps de la requête
```
