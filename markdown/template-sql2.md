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


## Définition de dépendances

>Pour garantir l’atomicité des opérations sur la base de données, on peut utiliser les transactions et le mode autocommit, qui sont étroitement liés, car tous deux servent à assurer que les modifications sont appliquées de manière cohérente et indivisible.

**_Définition à faire valider._**

--- 

## Ouverture de session
[Vidéo youtube](https://www.youtube.com/watch?v=mlbRdRLwYV0)
Une session est une connexion entre le client (terminal) et le serveur (mariadb).
Ce qui défini l'unicité d'une connexion est son `Thread`.
Un thread ne fait pas que “stocker la requête et le résultat”, il porte tout le contexte de session + transaction + 
exécution : utilisateur, variables de session, transaction courante, locks, erreurs/état, etc.

Les threads sont géré par un `Connection manager`, il gère :
- Écouter les interfaces réseau
- Accepter les nouvelles connexions
- Quelle connexion sera lié avec quels threads.
- La réutilisation / fin des threads.

Nous avons pas de pouvoir de décision sur les threads utiliser, par contre nous pouvons modifier des paramètres :
- `SHOW PROCESSLIST;` permet de lister les threads utiliser.
- `max_connections` nombre maximal de connexions simultanées, “un thread par connexion” nombre maximum de threads de traitement.
- `thread_cache_size` combien de threads inactifs MySQL garde en cache pour les réutiliser.

Pour s'y connecter :
```bash
mysql -h localhost -u julienschneider
```

Pour afficher la liste des session en cours :
```mysql
SHOW PROCESSLIST;
```
> Attention au droit des users, si un user ne possède pas les droits de voir les session, il ne verra que la sienne.

Verifier les droits :
```mysql
SHOW GRANTS FOR 'exemple'@'localhost';
```
Mettre les droits :
```mysql
GRANT PROCESS ON *.* TO 'exemple'@'localhost';
FLUSH PRIVILEGES;
```

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
```sql
-- Given
INSERT INTO users (name, balance)
VALUES
    ('Bob',   100.00),
    ('Alice', 125.00);

-- Permet de calculer la somme des balances des users.
SELECT SUM(balance) AS total_balance
FROM users;

SELECT @@autocommit;
SET autocommit = 0;
SELECT @@autocommit;
    
--When
-- SESSION 1

UPDATE users
SET balance = balance - 50
WHERE name = 'Alice';

UPDATE users
SET balance = balance + 50
WHERE name = 'Bob';

SELECT name, balance
FROM users;

-- SESSION 2
SELECT name, balance
FROM users;

-- SESSION 1
COMMIT;

SELECT name, balance
FROM users;
-- SESSION 2

SELECT name, balance
FROM users;

```

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



```mysql


```

## IMPLICIT commit
### Scénario : Transfert avec autocommit désactivé et commit implicite dû à une commande DDL
#### Given
- La base de données `bank` existe.
- La table `users` existe avec les colonnes : `(id, name, balance)`.
- La table `transfers` existe avec les colonnes : `(id, from_user_id, to_user_id, amount, status)`.
- Aucun transfert n’existe encore dans la table `transfers`.
- Bernard existe dans `users` avec un solde de 100 CHF.
- Alfred existe dans `users` avec un solde de 125 CHF.
- La session 1 a l’autocommit désactivé (`SET autocommit = 0`).
- La session 2 utilise l’autocommit activé (`SET autocommit = 1`).
- La somme totale des soldes de Bernard et Alfred est de 225 CHF.

#### When
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


```sql
-- Given
INSERT INTO users (name, balance)
VALUES
    ('Bernard',   100.00),
    ('Alfred', 125.00);

SELECT SUM(balance) AS total_balance
FROM users;

SELECT @@autocommit;
SET autocommit = 0;
SELECT @@autocommit;

SELECT SUM(balance) AS total_balance
FROM users;

--When

--Then
```

## save point
### Scénario : Transfert avec savepoint et rollback partiel

#### Given
- Julien possède un compte avec un solde de 50 CHF.
- David possède un compte avec un solde de 200 CHF.
- Guillaume possède un compte avec un solde de 150 CHF.
- La session utilise l’autocommit activé par défaut.
- La somme totale des soldes est de 400 CHF.

#### When
- Je commence une `TRANSACTION`.
- J’effectue un transfert de 50 CHF du compte de Guillaume vers le compte de Julien.
- Je crée un savepoint nommé `backup_one`.
- J’effectue un transfert de 25 CHF du compte de Guillaume vers le compte de David.
- Je consulte les soldes de Julien, David et Guillaume.
- J’exécute `ROLLBACK TO backup_one`.
- Je consulte les soldes de Julien, David et Guillaume.
- Je valide la transaction avec `COMMIT`.

#### Then
- Avant le `ROLLBACK TO backup_one` (après les deux transferts) :
    - Julien a 100 CHF, David a 225 CHF et Guillaume a 75 CHF.
    - Le solde total reste 400 CHF.

- Après le `ROLLBACK TO backup_one` (seul le premier transfert est conservé) :
    - Julien a 100 CHF, David a 200 CHF et Guillaume a 100 CHF.
    - Le solde total reste 400 CHF.

- Après le `COMMIT` :
    - La transaction est validée avec l’état courant : Julien a 100 CHF, David a 200 CHF et Guillaume a 100 CHF.
    - Le solde total de 400 CHF est toujours respecté.


```sql
-- Given
INSERT INTO users (name, balance)
VALUES
    ('Julien',   50.00),
    ('David', 200.00),
    ('Guillaume', 150.00);

SELECT SUM(balance) AS total_balance
FROM users;

SELECT @@autocommit;
--When
START TRANSACTION;

UPDATE users
SET balance = balance - 50
WHERE name = 'Guillaume';

UPDATE users
SET balance = balance + 50
WHERE name = 'Julien';

SELECT name, balance
FROM users;

SAVEPOINT backup_one;

UPDATE users
SET balance = balance - 25
WHERE name = 'Guillaume';

UPDATE users
SET balance = balance + 25
WHERE name = 'David';

SELECT name, balance
FROM users;

ROLLBACK TO backup_one;

SELECT name, balance
FROM users;

COMMIT;

-- THEN
SELECT name, balance
FROM users;

SELECT SUM(balance) AS total_balance
FROM users;
```


## Mes questions (notes personnelle) :
- Dans quels cas utiliser une transaction ou un autocommit = OFF ?
- Découvrir les savepoint
- rollback essayer de le valider en voyant les log ?
- Est-ce que l'on peut voir les commandes pas encore commit ? (dans un fichier temporaire ?)
- Définir ce qu'est la dépendance.

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

