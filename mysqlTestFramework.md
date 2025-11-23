# Sujet d'étude

* [Critères d'évaluation](https://cpnv-es-ngy.gitbook.io/sql2/evaluations)

## Introduction

Ce sujet d'étude à pour objectif d'approfondir les outils et stratégie de tests en présence d'un SGBDR.

## Objectifs

Mise en place d'un prototype de framework de test pour valider aussi bien le modèle (MCD - MLD -> DDL) que les requêtes exploitant le modèle (DML) et en validant le comportement attendu en gérant soit des exceptions, soit des requêtes de type DQL.

Les contraintes (ou critères de validation) sont les suivantes:
- [ ] Limitant la charge de travail pour préparer, nettoyer et supprimer la base de données de test - mode mémoire ?
- [ ] En étant le plus proche possible de l'environnement du client.
- [ ] Exploitable au sein d'un Pipeline CI/CD/CD.

## Scénario

Les scénarios à réaliser seront écrits selon une approche BDD.

* GIVEN -> DDL
* WHEN -> DML
* THEN -> DQL (ou exception)

---

### Scénario 1

* (Given) TODO

[file todo](fichier.sql)

* (When) TODO

```sql
//TODO
```

* (Then) TODO

* [ma vidéo de démonstartion](lien-vers-une-vidéo)

## Théorie et Sources

//TODO Résumé

* [Dev MySQL - Memory use](https://dev.mysql.com/doc/refman/8.4/en/memory-use.html)
* [Dev MySQL - Test Framework](https://dev.mysql.com/doc/dev/mysql-server/latest/PAGE_TESTING_TOOLS.html)
