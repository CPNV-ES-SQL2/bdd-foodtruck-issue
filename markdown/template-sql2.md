# Sujet d'étude

## Introduction

Ce sujet d'étude à pour objectif d'approfondir .....

## Objectifs

Il s'agit de prouver par la pratique les points suivants:

1. Comprendre le rôle du Buffer Pool dans InnoDB : observer comment InnoDB utilise la mémoire pour stocker les pages de données et d’index afin d’améliorer les performances.

2. Mesurer l’impact de la taille du Buffer Pool : comparer les temps de lecture/écriture sur une table volumineuse avec différentes tailles de `innodb_buffer_pool_size`.

3. Observer la réduction des accès disque grâce au Buffer Pool : analyser le nombre de lectures logiques vs physiques (Buffer Pool hit ratio) à l’aide de `SHOW ENGINE INNODB STATUS` ou des métriques `INNODB_BUFFER_POOL_HIT_RATIO`.

4. Identifier des problèmes de performance liés à un Buffer Pool trop petit : simuler une charge importante sur une table InnoDB et constater les ralentissements dus aux lectures fréquentes depuis le disque.

5. Optimiser les performances de requêtes : expérimenter avec différentes configurations du Buffer Pool pour constater l’impact sur les temps de requête et la charge I/O.

## Scénarios

1. Démarrer le service Docker :

```bash
docker compose up -d
```

2. Se connecter au service MySQL dans Docker :

```bash
docker exec -it mysql8 mysql -uroot -proot
```

### Scénario 1 : Comprendre le rôle du Buffer Pool

- (Given) Importer le script d'initialisation d'une base de données de test

[file to import](../appendices/script.sql)

- (When) Lancer une requête SELECT sur une table volumineuse pour charger des données dans le Buffer Pool

```sql
SELECT * FROM transactions LIMIT 10000;
```

- (Then) Observer dans le statut InnoDB que les pages sont en mémoire

```sql
SHOW ENGINE INNODB STATUS\G
-- Vérifier la section "BUFFER POOL AND MEMORY"
```

### Scénario 2 : Mesurer l’impact de la taille du Buffer Pool

- (Given) Table transactions avec plusieurs miliers de lignes
- (When) Modifier la taille du Buffer Pool et relancer des requêtes

```sql
SHOW ENGINE INNODB STATUS\G

-- 512 Mo
SET GLOBAL innodb_buffer_pool_size = 536870912;

-- 384 Mo
SET GLOBAL innodb_buffer_pool_size = 402653184;

-- 256 Mo
SET GLOBAL innodb_buffer_pool_size = 268435456;

-- 16 Mo
SET GLOBAL innodb_buffer_pool_size = 16777216;

-- 4 Mo
SET GLOBAL innodb_buffer_pool_size = 4194304;

SELECT COUNT(*) FROM transactions WHERE amount > 1;
```

- (Then) Comparer le temps de requête et le nombre de lectures physiques

```sql
SHOW ENGINE INNODB STATUS\G
```

### Scénario 3 : Observer la réduction des accès disque

- (Given) Table transactions déjà chargée dans le Buffer Pool
- (When) Exécuter plusieurs fois la même requête SELECT

```sql
SELECT * FROM transactions WHERE id = 4;
```

- (Then) Vérifier que les lectures logiques augmentent et les lectures physiques restent faibles

```sql
SHOW GLOBAL STATUS LIKE 'Innodb_buffer_pool%';
-- Vérifier les hits vs reads
```

### Scénario 4 : Identifier des problèmes de performance avec un Buffer Pool trop petit

- (Given) Réduire la taille du Buffer Pool à une valeur très faible

```sql
SET GLOBAL innodb_buffer_pool_size = 4194304;
```

- (When) Lancer des requêtes sur la table volumineuse

```sql
SELECT * FROM transactions WHERE montant > 10;
```

- (Then) Observer un grand nombre de lectures depuis le disque et des temps de réponse élevés

```sql
SHOW ENGINE INNODB STATUS\G
```

### Scénario 5 : Optimiser les performances de requêtes

- (Given) Buffer Pool correctement dimensionné (par ex. 1GB)
- (When) Exécuter une requête complexe sur plusieurs colonnes indexées

```sql
SELECT client_id, SUM(montant) 
FROM transactions 
WHERE date >= '2025-01-01' 
GROUP BY client_id;
```

- (Then) Observer une diminution des temps de réponse et un meilleur hit ratio

```sql
SHOW GLOBAL STATUS LIKE 'Innodb_buffer_pool%';
```

---

* [ma vidéo de démonstartion](lien-vers-une-vidéo)

## Théorie et Sources

Source : [MySQL Buffer Pool](https://dev.mysql.com/doc/refman/8.4/en/innodb-buffer-pool.html)

> Résumé des sources (un résumé produit par chat gpt est ok, pour autant que vous le remettiez en page et le validiez)  
> **Source MySQL !!!!**

---

## Vidéo donnée dans l'issue

### Importation des données (Importing the data)

#### 1. Utiliser le shell MySql

Pour les dumps (sauvegardes) logiques, l'utilitaire MySQL Shell Dump & Load est préférable à l'ancien mysqldump à thread unique.

MySQL Shell Dump & Load peut sauvegarder une instance complète, un ou plusieurs schémas ou tables. Vous pouvez également ajouter une clause where.

Cet outil sauvegarde et charge les données en parallèle !

Les données peuvent être stockées sur le système de fichiers, Object Storage, S3 et Azure Blob Storage.

```js
JS > util.dumpInstance("/opt/dump/", {threads: 32})
```

La sauvegarde peut être importée dans MySQL en utilisant `util.loadDump()`. `loadDump()` est la méthode utilisée pour charger des sauvegardes qui ont été crées par :
- `util.dumpInstance()`
- `util.dumpSchemas()`
- `util.Tables()`

#### 2. Accélérer l'importation

Nous pouvons accélérer encore davantage le processus ! Lors d'un chargement initial, la **durabilité n'est pas un problème**. En cas de plantage, le processus peut être redémarré. Par conséquent, si la durabilité n'est pas importante, nous pouvons la réduire afin d'accélérer encore davantage le chargement.

Nous pouvons désactiver les journaux binaires (binary logs), dés activer les journaux de reprise (redo logs) et régler InnoDB en modifiant quelques paramètres.

Notez que la désactivation et l'activation des journaux binaires nécessitent un redémarrage de MySQL.

```sql
start mysqld with --disable-log-bin

MySQL > ALTER INSTANCE DISABLE INNODB REDO_LOG;
MySQL > set global innodb_extend_and_initialize=OFF;
MySQL > set global innodb_max_dirty_pages_pct=10;
MySQL > set global innodb_max_dirty_pages_pct_lwm=10;
```

### Conception de la DB (Schema design)

#### 3. Clés primaires

Pour InnoDB, une clé primaire est requise, et une bonne clé est encore mieux.

InnoDB stocke les données dans des espaces de table. Les enregistrements sont stockés et triés à l'aide de l'index clusterisé (PK).

Tous les index secondaires contiennent également la clé primaire comme colonne la plus à droite dans l'index (même si celle-ci n'est pas exposée). Cela signifie que lorsqu'un index secondaire est utilisé pour récupérer un enregistrement, deux index sont utilisés : d'abord l'index secondaire pointant vers la clé primaire qui sera utilisée pour récupérer finalement l'enregistrement.

La clé primaire a une incidence sur la manière dont les valeurs sont insérées et sur la taille des index secondaires. Une clé primaire non séquentielle peut entraîner de nombreux IOPS aléatoires.

> **IOPS** signifie **Input/Output Operations Per Second**, soit le nombre d’opérations d’entrée/sortie par seconde que peut effectuer un système de stockage (disque dur, SSD, SAN, etc.).

De plus, il est de plus en plus courant d'utiliser des applications qui génèrent des clés primaires totalement aléatoires... Cela signifie que si la clé primaire n'est pas séquentielle, InnoDB devra rééquilibrer considérablement toutes les pages lors des insertions.

**Séquentiel vs Aléatoire**

| Type d’accès   | Exemple                                   | Impact                                                                  |
| -------------- | ----------------------------------------- | ----------------------------------------------------------------------- |
| **Séquentiel** | Clés auto-incrémentées (`AUTO_INCREMENT`) | Inserts toujours à la fin → très peu de fragmentation → très performant |
| **Aléatoire**  | UUID, GUID, clés générées côté app        | Inserts partout dans l’arbre B+ → beaucoup d’IOPS et de réorganisation  |

Une autre erreur courante lors de l'utilisation d'InnoDB consiste à ne définir aucune clé primaire.

Lorsqu'aucune clé primaire n'est définie, la première clé unique non nulle est utilisée Et s'il n'y en a aucune de disponible, InnoDB créera une clé primaire cachée (6 octets).

Le problème avec une telle clé est que vous n'avez aucun contrôle sur elle et, pire encore, cette valeur est globale à toutes les tables, sans clés primaires, et peut poser un problème de contention si vous effectuez plusieurs écritures simultanées sur ces tables (dict_sys->mutex).

Et si vous prévoyez une haute disponibilité, les tables sans clé primaire ne sont PAS prises en charge.

#### 4. index

#### 5. Création d'index parallèle

### Configuration

#### 6. La bonne configuration pour la charge de travail

### Mémoire (Memory)

#### 7. Consommation

#### 8. Allocateur de mémoire Linux

### Requêtes (All about queries)

#### 9. Charge de travail

#### 10. Ugly duckling

### Machine Learning

#### Autopilot indexing