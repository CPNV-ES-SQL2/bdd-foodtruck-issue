# Sujet d'étude Julien Schneider

* [Critères d'évaluation](https://cpnv-es-ngy.gitbook.io/sql2/evaluations)

## Introduction

Ce sujet d'étude a pour objectif d'approfondir les liens et les dépendances entre "autocommit", "commit" et "rollback" et les "transactions".

## Objectifs
  - [ ] Tester le comportement de MySQL lorsque l’autocommit est activé ou désactivé, et les conditions afin de choisir l’un ou l’autre mode.
  - [ ] Présenter une transaction en illustrant les différents cas de figure.
    - commit : Qu'il permet de valider une transaction ou un groupe de requête.
    - rollback et SAVEPOINT : tester les savepoint et les différents rollback.
    - IMPLICIT commit : Les déclarations qui peu importent la config MySQL fait un commit.

---

## Ouverture de session
Une session est une connexion entre le client (terminal) et le serveur (mariadb).

Chaque connexion cliente est servie par un thread côté serveur. L’ID de ce thread identifie la session et permet,
par exemple, de la tuer avec KILL <Id>.

Un thread ne fait pas que “stocker la requête et le résultat”, il porte tout le contexte de session + transaction + 
exécution : 
- utilisateur
- variables de session
- transaction courante
- locks
- erreurs/état, etc.

Le serveur écoute les interfaces réseau, accepte les nouvelles connexions, 
et leur associe un thread (ou un thread du cache de threads). Ce mécanisme global est parfois désigné 
comme “connection/thread manager”.

Nous n'avons pas de pouvoir de décision sur les threads utiliser, par contre, nous pouvons modifier des paramètres :
- `SHOW PROCESSLIST;` permet de lister les threads utiliser.
- `max_connections` nombre maximal de connexions simultanées, “un thread par connexion” nombre maximum de threads de traitement.
- `thread_cache_size` combien de threads inactifs MySQL garde en cache pour les réutiliser.

Pour s'y connecter :
```bash
mysql -h localhost -u julienschneider
```

Pour afficher la liste des sessions en cours :
```mysql
SHOW PROCESSLIST;
```
> Attention au droit des users, si un user ne possède pas les droits de voir les sessions, il ne verra que la sienne.

Verifier les droits :
```mysql
CREATE USER 'monuser'@'localhost' IDENTIFIED BY 'motdepasseFort';
SHOW GRANTS FOR 'monuser'@'localhost';
```
Mettre les droits :
```mysql
GRANT ALL PRIVILEGES ON *.* TO 'monuser'@'localhost';
FLUSH PRIVILEGES;
```

`ON *.*` droit sur toutes les bases et toutes les tables.

## Niveau d'isolation
Les Transaction Isolation Levels son des niveaux d'isolation, qui servent à gérer comment plusieurs transactions
peuvent lire et modifier les données en même temps.
MySQL propose les niveaux standards : READ UNCOMMITTED, READ COMMITTED, REPEATABLE READ (par défaut) et SERIALIZABLE.

Nous travaillons avec le mode par defaut :
`REPEATABLE READ` offre une forte cohérence en donnant à chaque transaction une vision stable des données (un snapshot).
Pendant toute la transaction, les SELECT récupère toujours les mêmes données, même si d’autres transactions modifient la base en parallèle.

## autocommit
### Scénario : Modification de plafond de carte bancaire en mode brouillon (autocommit désactivé, sans transaction explicite)

Un conseiller veut tester une augmentation du plafond de carte bancaire d’un client en production, sans que cette
modification soit visible pour les autres utilisateurs (Test en production).

On utilise `autocommit = 0` dans sa session, sans `START TRANSACTION`.

#### Given

- La base de données `bank` existe.
- La table `customers` existe avec les colonnes : `(id, name)`.
- La table `cards` existe avec les colonnes : `(id, customer_id, status, limit_amount)`.
- Le client `Alice` existe dans `customers` avec `id = 1`.
- La carte de crédit d’Alice existe dans `cards` avec :
    - `customer_id = 1`
    - `status = 'active'`
    - `limit_amount = 2000` (plafond actuel : 2000 CHF).
- La session 1 (conseiller) a l’autocommit désactivé :
    - `SET autocommit = 0;`
- La session 2 (autre utilisateur) utilise l’autocommit activé :
    - `SET autocommit = 1;`
- Tous les autres clients et cartes ne sont pas pertinents pour ce test.

#### When
- Session 1 (conseiller, mode brouillon)
    - Je mets à jour la carte d’Alice pour augmenter son plafond de 2000 CHF à 5000 CHF.
    - Je consulte la carte d’Alice en session 1 (table `cards`).
- Session 2 (Autre utilisateur de l'application)
    - Consulte la carte d’Alice (plafond et statut).
- Session 1
    - Finalement, je décide que ce n’était qu’un test et je ne veux pas garder cette modification.
    - Je consulte à nouveau la carte.
- Session 2
    - Consulte à nouveau la carte d’Alice.

#### Then

- Avant le `ROLLBACK` :
    - En session 1 :
        - La table `cards` montre la carte d’Alice avec `limit_amount = 5000` et `status = 'active'`.
        - Le conseiller voit donc le plafond testé (5000 CHF).
    - En session 2 :
        - La table `cards` montre toujours la carte d’Alice avec `limit_amount = 2000` et `status = 'active'`.
        - Les autres utilisateurs voient encore le plafond officiel (2000 CHF).
    - La modification de plafond est visible uniquement dans la session 1, tant que le conseiller n’a ni `COMMIT` ni `ROLLBACK`.
- Après le `ROLLBACK` en session 1 :
    - En session 1 :
        - La carte d’Alice revient à `limit_amount = 2000`, `status = 'active'`.
    - En session 2 :
        - La carte d’Alice est toujours à `limit_amount = 2000`, `status = 'active'`.
    - Aucune trace du test de plafond à 5000 CHF n’a été laissée en base :
        - le conseiller a pu tester en prod,
        - puis tout annuler proprement sans impacter les autres utilisateurs.
        -
## transaction
### Scénario : Transfert d’argent avec transaction explicite entre deux sessions
#### Given
- La base de données `bank` existe.
- La table `users` existe avec les colonnes : `(id, name, balance)`.
- La table `transfers` existe avec les colonnes : `(id, from_user_id, to_user_id, amount, status)`.
- Aucun transfert n’existe encore dans la table `transfers`.
- Mark existe dans `users` avec un solde de 100 CHF.
- Brigitte existe dans `users` avec un solde de 125 CHF.
- La session 1 utilise l’autocommit activé par défaut.
- La session 2 utilise également l’autocommit activé.
- La somme totale des soldes de Mark et Brigitte est de 225 CHF.

#### When
- Dans la session 1, je commence une `TRANSACTION`.
- Dans la session 1, j’enregistre un nouveau transfert dans `transfers` :
    - `from_user_id` = Brigitte,
    - `to_user_id` = Mark,
    - `amount` = 50,
    - `status` = 'PENDING'.
- Dans la session 1, je mets à jour les soldes dans `users` :
    - je déduis 50 CHF du solde de Brigitte,
    - j’ajoute 50 CHF au solde de Mark.
- Dans la session 1, je consulte :
    - les soldes de Mark et Brigitte dans `users`,
    - le transfert que je viens de créer dans `transfers`.
- Dans la session 2, je consulte :
    - les soldes de Mark et Brigitte dans `users`,
    - la table `transfers`.
- Dans la session 1, je valide la transaction avec `COMMIT`.
- Dans la session 2, je consulte à nouveau :
    - les soldes de Mark et Brigitte dans `users`,
    - la table `transfers`.

#### Then
- Avant le `COMMIT` :
    - En session 1 :
        - Dans `users`, Mark a 150 CHF et Brigitte a 75 CHF.
        - Dans `transfers`, il existe un transfert :
            - de Brigitte vers Mark,
            - pour un montant de 50 CHF,
            - avec `status = 'PENDING'`.
        - Le solde total reste 225 CHF.
    - En session 2 :
        - Dans `users`, Mark a 100 CHF et Brigitte a 125 CHF.
        - Dans `transfers`, aucun transfert n’est visible.
        - Le solde total reste 225 CHF.
- Après le `COMMIT` :
    - En session 1 et en session 2 :
        - Dans `users`, Mark a 150 CHF et Brigitte a 75 CHF.
        - Dans `transfers`, le transfert de 50 CHF de Brigitte vers Mark est visible par les deux sessions, avec `status = 'PENDING'` (ou éventuellement mis à jour à 'COMPLETED' dans la même transaction).
        - Le solde total de 225 CHF est toujours respecté.


## IMPLICIT commit
### Scénario : Transfert avec transaction et commit implicite dû à une commande [DDL](https://dev.mysql.com/doc/refman/8.4/en/glossary.html#glos_ddl)
#### Given
- La base de données `bank` existe.
- La table `users` existe avec les colonnes : `(id, name, balance)`.
- La table `transfers` existe avec les colonnes : `(id, from_user_id, to_user_id, amount, status)`.
- Aucun transfert n’existe encore dans la table `transfers`.
- Bernard existe dans `users` avec un solde de 100 CHF.
- Alfred existe dans `users` avec un solde de 125 CHF.
- La session 1 utilise l’autocommit activé (`SET autocommit = 1`).
- La session 2 utilise l’autocommit activé (`SET autocommit = 1`).
- La somme totale des soldes de Bernard et Alfred est de 225 CHF.

#### When
- Dans la session 1, je commence une `TRANSACTION`.
- Dans la session 1, j’enregistre un nouveau transfert dans `transfers` :
    - `from_user_id` = Alfred,
    - `to_user_id` = Bernard,
    - `amount` = 50,
    - `status` = 'PENDING'.
- Dans la session 1, je mets à jour les soldes dans `users` :
    - je déduis 50 CHF du solde d’Alfred,
    - j’ajoute 50 CHF au solde de Bernard.
- Dans la session 1, je consulte :
    - les soldes de Bernard et Alfred dans `users`,
    - la table `transfers` pour voir le transfert créé.
- Dans la session 2, je consulte :
    - les soldes de Bernard et Alfred dans `users`,
    - la table `transfers`.
- Dans la session 1, je crée une nouvelle table `contracts`.
- Dans la session 1, je consulte :
    - la liste des tables de la base `bank`,
    - les soldes de Bernard et Alfred dans `users`,
    - la table `transfers`.
- Dans la session 2, je consulte :
    - la liste des tables de la base `bank`,
    - les soldes de Bernard et Alfred dans `users`,
    - la table `transfers`.
- Dans la session 1, j’annule la transaction avec `ROLLBACK`.
- Dans la session 1, je consulte à nouveau :
    - les soldes de Bernard et Alfred dans `users`,
    - la table `transfers`.
- Dans la session 2, je consulte à nouveau :
    - les soldes de Bernard et Alfred dans `users`,
    - la table `transfers`.

#### Then
- Après le transfert (insert dans `transfers` + mises à jour dans `users`) et avant le `CREATE TABLE contracts` :
    - En session 1 :
        - Dans `users`, Bernard a 150 CHF et Alfred a 75 CHF.
        - Dans `transfers`, il existe un transfert de 50 CHF d’Alfred vers Bernard avec `status = 'PENDING'`.
        - Le solde total reste 225 CHF.
    - En session 2 :
        - Dans `users`, Bernard a 100 CHF et Alfred a 125 CHF.
        - La table `transfers` ne contient aucun transfert.
        - Le solde total reste 225 CHF.

- Après le `CREATE TABLE contracts` et avant le `ROLLBACK` :
    - En session 1 :
        - Dans `users`, Bernard a 150 CHF et Alfred a 75 CHF.
        - Dans `transfers`, le transfert de 50 CHF d’Alfred vers Bernard est présent avec `status = 'PENDING'`.
        - La base `bank` possède une table `contracts`.
    - En session 2 :
        - Dans `users`, Bernard a 150 CHF et Alfred a 75 CHF.
        - Dans `transfers`, le transfert de 50 CHF d’Alfred vers Bernard est également visible avec `status = 'PENDING'`.
        - La base `bank` possède une table `contracts`.
        - Le solde total reste 225 CHF dans chaque session.
    - Le `CREATE TABLE contracts` a provoqué un commit implicite de la transaction en session 1.

- Après le `ROLLBACK` exécuté en session 1 :
    - En session 1 et en session 2 :
        - Dans `users`, Bernard a toujours 150 CHF et Alfred a 75 CHF.
        - Dans `transfers`, le transfert de 50 CHF d’Alfred vers Bernard est toujours présent.
        - La table `contracts` existe toujours dans la base `bank`.
        - Le solde total de 225 CHF est toujours respecté.
    - Le `ROLLBACK` n’a annulé ni le transfert ni la création de la table, car le `CREATE TABLE` a déjà validé ces modifications via un commit implicite.

## Théorie et Sources
* [Dev MySQL - autocommit, commit and rollback](https://dev.mysql.com/doc/refman/8.4/en/innodb-autocommit-commit-rollback.html)
* [Dev MySQL - commit](https://dev.mysql.com/doc/refman/8.4/en/commit.html)
* [Dev MySQL - Savepoint](https://dev.mysql.com/doc/refman/9.0/en/savepoint.html)
* [Dev MySQL - Implicit commit](https://dev.mysql.com/doc/refman/8.4/en/implicit-commit.html)
* [Dev MySQL - Undo logs](https://dev.mysql.com/doc/refman/8.4/en/innodb-undo-logs.html)

### Définition autocommit
* [Dev MySQL - autocommit](https://dev.mysql.com/doc/refman/8.4/en/glossary.html#glos_autocommit)
### Thread et Session
* [Dev MySQL - Thread](https://dev.mysql.com/doc/refman/8.4/en/connection-interfaces.html)
* [Dev MySQL - Thread table](https://dev.mysql.com/doc/refman/8.4/en/performance-schema-threads-table.html)

### Isolation
* [Dev MySQL - Isolation](https://dev.mysql.com/doc/refman/8.4/en/innodb-transaction-isolation-levels.html)
