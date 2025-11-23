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

## autocommit
### Scénario : Transfert d’argent entre deux comptes avec autocommit désactivé (deux sessions avec commit)

#### Given
- La base de données `bank` existe.
- La table `users` existe et est vide.
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

--When

--Then
```

### Scénario : Transfert d’argent entre deux comptes avec autocommit désactivé (deux sessions avec rollback)

#### Given
- La base de données `bank` existe.
- La table `users` existe et est vide.
- Diogo possède un compte avec un solde de 100 CHF.
- Ralf possède un compte avec un solde de 125 CHF.
- La session 1 a l’autocommit désactivé.
- La session 2 utilise l’autocommit activé.
- La somme totale des soldes est de 225 CHF.

#### When
- Dans la session 1, j’effectue un transfert de 50 CHF du compte d’Ralf vers le compte de Diogo, sans encore valider la transaction.
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

--When

--Then
```

## transaction
### Scénario : Transfert d’argent avec transaction explicite entre deux sessions

#### Given
- La base de données `bank` existe.
- La table `users` existe et est vide.
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

--When

--Then
```

## save point
### Scénario : Transfert avec savepoint et rollback partiel

#### Given
- La base de données `bank` existe.
- La table `users` existe et est vide.
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

--When

--Then
```

### Scénario : Transfert avec savepoint, rollback partiel et finaliter avec rollback complet.
Ce test vérifie qu’avec l’autocommit activé, les modifications effectuées dans une transaction (y compris celles entourées d’un savepoint et d’un `ROLLBACK TO`) sont entièrement annulées par un `ROLLBACK` global.

#### Given
- La base de données `bank` existe.
- La table `users` existe et est vide.
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

--When

--Then
```

## IMPLICIT commit
### Scénario : Transfert avec autocommit désactivé et commit implicite dû à une commande DDL

#### Given
- La base de données `bank` existe.
- La table `users` existe et est vide.
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
