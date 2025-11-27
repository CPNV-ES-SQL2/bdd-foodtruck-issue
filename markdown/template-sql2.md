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

> Pour les différents scénarios, les sessions sont réalisé avec le même utilisateur. Cela n'affecte aucunement les scénarios car l'isolation se fait par connexion/session, pas par utilisateur.

# Initialisation de la base de données (commune à tous les scénarios)
[Vidéo youtube](https://youtu.be/HH3pXFejI3s)
- La base de données `bank` existe.
- La table `users` existe et est vide.

```mysql
-- GIVEN : la base de données `bank` existe
SELECT @@autocommit;
DROP DATABASE IF EXISTS bank;
CREATE DATABASE bank;
USE bank;

-- Table users
DROP TABLE IF EXISTS users;
CREATE TABLE users (
   user_id INT AUTO_INCREMENT PRIMARY KEY,
   name    VARCHAR(100) NOT NULL,
   balance DECIMAL(10,2) NOT NULL
);

```

## autocommit
### Scénario : Transfert d’argent entre deux comptes avec autocommit désactivé (deux sessions avec commit)
[Vidéo youtube](https://youtu.be/9tH-AWtS1ek?si=1gTMaIzyYuUrjGIr)
#### Given
- Bob possède un compte avec un solde de 100 CHF.
- Alice possède un compte avec un solde de 125 CHF.
- La session 1 a l’autocommit désactivé.
- La session 2 utilise l’autocommit activé.
- La somme totale des soldes est de 225 CHF.

#### When
- Dans la session 1, j’effectue un transfert de 50 CHF du compte d’Alice vers le compte de Bob, sans encore valider la transaction.
- Dans la session 1, je consulte les soldes de Bob et Alice.
- Dans la session 2, je consulte les soldes de Bob et Alice.
- Dans la session 1, je valide la transaction avec `COMMIT`.
- Dans la session 2, je consulte à nouveau les soldes de Bob et Alice.

#### Then
- Avant le `COMMIT` :
    - En session 1, Bob a 150 CHF et Alice a 75 CHF.
    - En session 2, Bob a 100 CHF et Alice a 125 CHF.
    - Le solde total reste 225 CHF dans chaque session.
- Après le `COMMIT` :
    - Les sessions 1 et 2 voient le même état : Bob a 150 CHF, Alice a 75 CHF.
    - Le solde total de 225 CHF est toujours respecté.
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

### Scénario : Transfert d’argent entre deux comptes avec autocommit désactivé (deux sessions avec rollback)

#### Given
- Diogo possède un compte avec un solde de 100 CHF.
- Ralf possède un compte avec un solde de 125 CHF.
- La session 1 a l’autocommit désactivé.
- La session 2 utilise l’autocommit activé.
- La somme totale des soldes est de 225 CHF.

#### When
- Dans la session 1, j’effectue un transfert de 50 CHF du compte de Ralf vers le compte de Diogo, sans encore valider la transaction.
- Dans la session 1, je consulte les soldes de Diogo et Ralf.
- Dans la session 2, je consulte les soldes de Diogo et Ralf.
- Dans la session 1, je valide la transaction avec `ROLLBACK`.
- Dans la session 2, je consulte à nouveau les soldes de Diogo et Ralf.

#### Then
- Avant le `ROLLBACK` :
    - En session 1, Diogo a 150 CHF et Ralf a 75 CHF.
    - En session 2, Diogo a 100 CHF et Ralf a 125 CHF.
    - Le solde total reste 225 CHF dans chaque session.
- Après le `ROLLBACK` :
    - Les sessions 1 et 2 voient le même état : Diogo a 100 CHF, Ralf a 125 CHF.
    - Le solde total de 225 CHF est toujours respecté.

```sql
-- Given
INSERT INTO users (name, balance)
VALUES
    ('Diogo',   100.00),
    ('Ralf', 125.00);

SELECT SUM(balance) AS total_balance
FROM users;

SELECT @@autocommit;
SET autocommit = 0;
SELECT @@autocommit;

--When
-- SESSION 1

UPDATE users
SET balance = balance - 50
WHERE name = 'Ralf';

UPDATE users
SET balance = balance + 50
WHERE name = 'Diogo';

SELECT name, balance
FROM users;

SELECT SUM(balance) AS total_balance
FROM users;

-- SESSION 2

SELECT name, balance
FROM users;

SELECT SUM(balance) AS total_balance
FROM users;

-- SESSION 1
ROLLBACK;

--Then

-- SESSION 1

SELECT name, balance
FROM users;

-- SESSION 2

SELECT name, balance
FROM users;
```

## transaction
### Scénario : Transfert d’argent avec transaction explicite entre deux sessions

#### Given
- Mark possède un compte avec un solde de 100 CHF.
- Brigitte possède un compte avec un solde de 125 CHF.
- La session 1 utilise l’autocommit activé par défaut.
- La session 2 utilise également l’autocommit activé.
- La somme totale des soldes est de 225 CHF.

#### When
- Dans la session 1, je commence une `TRANSACTION`.
- Dans la session 1, j’effectue un transfert de 50 CHF du compte de Brigitte vers le compte de Mark, sans encore valider la transaction.
- Dans la session 1, je consulte les soldes de Mark et Brigitte.
- Dans la session 2, je consulte les soldes de Mark et Brigitte.
- Dans la session 1, je valide la transaction avec `COMMIT`.
- Dans la session 2, je consulte à nouveau les soldes de Mark et Brigitte.

#### Then
- Avant le `COMMIT` :
    - En session 1, Mark a 150 CHF et Brigitte a 75 CHF.
    - En session 2, Mark a 100 CHF et Brigitte a 125 CHF.
    - Le solde total reste 225 CHF dans chaque session.
- Après le `COMMIT` :
    - Les sessions 1 et 2 voient le même état : Mark a 150 CHF, Brigitte a 75 CHF.
    - Le solde total de 225 CHF est toujours respecté.


```sql
-- Given
INSERT INTO users (name, balance)
VALUES
    ('Mark',   100.00),
    ('Brigitte', 125.00);

SELECT SUM(balance) AS total_balance
FROM users;

SELECT @@autocommit;

--When
-- SESSION 1
START TRANSACTION;

UPDATE users
SET balance = balance - 50
WHERE name = 'Brigitte';

UPDATE users
SET balance = balance + 50
WHERE name = 'Mark';

SELECT name, balance
FROM users;

SELECT SUM(balance) AS total_balance
FROM users;

-- SESSION 2
SELECT name, balance
FROM users;

SELECT SUM(balance) AS total_balance
FROM users;

-- SESSION 1
COMMIT;

--Then
-- SESSION 1
SELECT name, balance
FROM users;

SELECT SUM(balance) AS total_balance
FROM users;

-- SESSION 2
SELECT name, balance
FROM users;

SELECT SUM(balance) AS total_balance
FROM users;

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

### Scénario : Transfert avec savepoint, rollback partiel et finaliter avec rollback complet.
Ce test vérifie qu’avec l’autocommit activé, les modifications effectuées dans une transaction (y compris celles entourées d’un savepoint et d’un `ROLLBACK TO`) sont entièrement annulées par un `ROLLBACK` global.

#### Given

- Chris possède un compte avec un solde de 50 CHF.
- Arnold possède un compte avec un solde de 200 CHF.
- Charlotte possède un compte avec un solde de 150 CHF.
- La session utilise l’autocommit activé par défaut.
- La somme totale des soldes est de 400 CHF.

#### When
- Je commence une `TRANSACTION`.
- J’effectue un transfert de 50 CHF du compte de Charlotte vers le compte de Chris.
- Je crée un savepoint nommé `backup_one`.
- J’effectue un transfert de 25 CHF du compte de Charlotte vers le compte d'Arnold.
- Je consulte les soldes de Chris, Arnold et Charlotte.
- J’exécute `ROLLBACK TO backup_one`.
- Je consulte les soldes de Chris, Arnold et Charlotte.
- J’annule la transaction avec `ROLLBACK`.

#### Then
- Avant le `ROLLBACK TO backup_one` (après les deux transferts) :
    - Chris a 100 CHF, Arnold a 225 CHF et Charlotte a 75 CHF.
    - Le solde total reste 400 CHF.

- Après le `ROLLBACK TO backup_one` (seul le premier transfert est conservé) :
    - Chris a 100 CHF, Arnold a 200 CHF et Charlotte a 100 CHF.
    - Le solde total reste 400 CHF.

- Après le `ROLLBACK` :
    - La transaction est complètement annulée, retour à l’état initial : Chris a 50 CHF, Arnold a 200 CHF et Charlotte a 150 CHF.
    - Le solde total de 400 CHF est toujours respecté.



```sql
-- Given
INSERT INTO users (name, balance)
VALUES
    ('Chris',   50.00),
    ('Arnold', 200.00),
    ('Charlotte', 150.00);

SELECT SUM(balance) AS total_balance
FROM users;

SELECT @@autocommit;
--When
START TRANSACTION;

UPDATE users
SET balance = balance - 50
WHERE name = 'Charlotte';

UPDATE users
SET balance = balance + 50
WHERE name = 'Chris';

SELECT name, balance
FROM users;

SAVEPOINT backup_one;

UPDATE users
SET balance = balance - 25
WHERE name = 'Charlotte';

UPDATE users
SET balance = balance + 25
WHERE name = 'Arnold';

SELECT name, balance
FROM users;

ROLLBACK TO backup_one;

SELECT name, balance
FROM users;

ROLLBACK;

-- THEN
SELECT name, balance
FROM users;

SELECT SUM(balance) AS total_balance
FROM users;
```

## IMPLICIT commit
### Scénario : Transfert avec autocommit désactivé et commit implicite dû à une commande DDL

#### Given
- Bernard possède un compte avec un solde de 100 CHF.
- Alfred possède un compte avec un solde de 125 CHF.
- La session 1 a l’autocommit désactivé.
- La session 2 utilise l’autocommit activé.
- La somme totale des soldes est de 225 CHF.

#### When
- Dans la session 1, j’effectue un transfert de 50 CHF du compte d’Alfred vers le compte de Bernard, sans encore valider la transaction.
- Dans la session 1, je consulte les soldes de Bernard et Alfred.
- Dans la session 2, je consulte les soldes de Bernard et Alfred.
- Dans la session 1, je crée une nouvelle table `contracts`.
- Dans la session 1, je consulte les tables de la base de données `bank`.
- Dans la session 1, je consulte les soldes de Bernard et Alfred.
- Dans la session 2, je consulte les tables de la base de données `bank`.
- Dans la session 2, je consulte les soldes de Bernard et Alfred.
- Dans la session 1, j’annule la transaction avec `ROLLBACK`.
- Dans la session 1, je consulte à nouveau les soldes de Bernard et Alfred.
- Dans la session 2, je consulte à nouveau les soldes de Bernard et Alfred.

#### Then
- Après le transfert et avant le `CREATE TABLE contracts` :
    - En session 1, Bernard a 150 CHF et Alfred a 75 CHF.
    - En session 2, Bernard a 100 CHF et Alfred a 125 CHF.
    - Le solde total reste 225 CHF dans chaque session.

- Après le `CREATE TABLE contracts` et avant le `ROLLBACK` :
    - En session 1, Bernard a 150 CHF et Alfred a 75 CHF.
    - En session 1, la base `bank` possède une table `contracts`.
    - En session 2, Bernard a 150 CHF et Alfred a 75 CHF.
    - En session 2, la base `bank` possède une table `contracts`.
    - Le solde total reste 225 CHF dans chaque session.

- Après le `ROLLBACK` :
    - Les sessions 1 et 2 voient toujours le même état : Bernard a 150 CHF, Alfred a 75 CHF.
    - Les sessions 1 et 2 possèdent la table `contracts`.
    - Le solde total de 225 CHF est toujours respecté.
    - Le `ROLLBACK` n’a pas annulé le transfert ni la création de la table, car `CREATE TABLE` a provoqué un commit implicite.

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
