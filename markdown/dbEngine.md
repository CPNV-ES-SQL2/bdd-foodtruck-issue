# Sujet d'étude

* [Critères d'évaluation](https://cpnv-es-ngy.gitbook.io/sql2/evaluations)

## Introduction

Ce sujet d'étude à pour objectif d'approfondir .....

## Objectifs

Il s'agit de prouver par la pratique les points suivants:

* Filtrer et répliquer des données entre 2 serveurs MySQL grâce à l'**engine** ``BLACKHOLE``
![Blackhole Schema](../appendices/blackhole/schema.png)
* Accéder à des données d'une autre instance de MySQL sans réplication/cluster grâce à l'**engine** ``FEDERATED``
![Federated Schema](../appendices/federated/schema.png)
* Perte de données possible avec l'**engine** ``MyISAM`` et comparaison avec ``InnoDB``

## Scénarios

### Scénario 1 - Réplication entre 2 serveurs grâce au FEDERATED

> **GIVEN**

2 instances de MySQL sont lancées. ([docker-compose]())

[Ce script]() doit être exécuté sur l'instance 1

[Ce script]() doit être exécuté sur l'instance 2

> **WHEN**

On ajoute un utilisateur sur la table _users_ sur l'instance 1

```sql
INSERT INTO sql2.users(name, email) VALUES ("test", "test@test.com");
```

> **THEN**

L'utilisateur est présent sur l'instance 1 et l'instance 2

<video controls>
    <source src="../appendices/federated/video.mov" type="video/mp4">
</video>

## Théorie et Sources

Résumé des sources (un résumé produit par chat gpt est ok, pour autant que vous le remettiez en page et le validiez)

Source MySQL !!!!

```
Comment mesure le temps de la requête
```
