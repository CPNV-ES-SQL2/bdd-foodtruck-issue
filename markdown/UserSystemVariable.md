# Sujet d'étude

## Introduction

Ce sujet d'étude à pour objectif d'approfondir sur l'utilisation d'une variable d'utilisateur et système

## Objectifs

Il s'agit de prouver par la pratique ces points suivant:

- Identifier la portée et le rôle d'une variable user-defined
- Identifier la portée et le rôle d'une variable system 
- Identifier les différents types de valeur qu'une variable user-defined peut contenir.
- Debugger un script en pleine exécution afin de vérifier le contenu d'une variable
## Scénario pratique 

#### Scénario 1 : Démontrer la portée et le rôle des variables user-defined 

* __Given__ :  Je prépare deux sessions différentes :
	- Session 1 : Doit avoir exécuté le **script setup** et défini une variable user-defined @total_grade.
	- Session 2 : Doit avoir exécuté le **premier script** et défini une variable user-defined @total_point.

J'initialise la base de données avec des données de test, je définis la somme des notes et je crée 2 procédures qui vont vérifier les variables.

```sql
-- Script setup, session 1 uniquement
DROP DATABASE IF EXISTS sql2Sce1;
CREATE DATABASE sql2Sce1;
USE sql2Sce1;
DROP TABLE IF EXISTS resultstudent;
CREATE TABLE resultstudent(
	id int NOT NULL AUTO_INCREMENT,
    test varchar(40),
	firstname varchar(20), 
	points int,
    grade decimal (2,1),
	PRIMARY KEY (id)
);
INSERT INTO resultstudent(firstname,points,grade) VALUES 
("Jean",10,5.5),
("Mike",12,6.0),
("Rudy",2,1.5),
("Karl",5,3.5),

DELIMITER //
CREATE PROCEDURE check_total_point()
BEGIN
    IF @total_point IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The variable @total_point is empty';
	ELSE
        SELECT ROUND(@total_point / (SELECT COUNT(DISTINCT firstname) FROM resultstudent), 1) AS average_point;
    END IF;
END //
CREATE PROCEDURE check_total_grade()
BEGIN
	IF @total_grade IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The variable @total_grade is empty';
	ELSE
        SELECT ROUND(@total_grade / (SELECT COUNT(DISTINCT firstname) FROM resultstudent), 1) AS average_grade;
    END IF; 
END //
DELIMITER ;
SET @total_grade  := (select sum(grade) from resultstudent);
```

Je vérifie que j'ai bien les deux sessions actives via SHOW PROCESSLIST:

| Id  | User | Host            | db       | Command | Time | State | Info             |
|-----|------|------------------|----------|---------|------|-------|------------------|
| 197 | sql2 | localhost:58561 | sql2sce1 | Sleep   | 56   |       | NULL             |
| 198 | sql2 | localhost:65124 | sql2sce1 | Query   | 0    | init  | SHOW PROCESSLIST |

J'exécute le script 1 dans la session 2

```sql
-- Script 1, session 2 seulement :
INSERT INTO resultstudent(firstname,points,grade) VALUES
("Molly",7,4.0);

SET @total_grade := (select sum(grade) from resultstudent);
SET @total_point := (select sum(points) from resultstudent);
```


- __When__ : J'exécute le second script sur les deux sessions.

```sql
-- Script 2
SELECT @total_point / (SELECT COUNT(DISTINCT firstname) FROM resultstudent) AS result
SELECT ROUND(@total_grade / (SELECT COUNT(DISTINCT firstname) FROM resultstudent), 1) AS average_grade;
```

* __Then__ : 
	* Session 1 : Je m'attends à ce que cette session me renvoie une erreur 1644 pour @total_point et une moyenne de notes erronée.
	* Session 2 : Je m'attends à ce que cette session me renvoie le nombre de points et la note moyenne par élève.

```sql
-- Session 2 :
+---------------+
| average_point |
+---------------+
|           7.2 |
+---------------+
-- et
+---------------+
| average_grade |
+---------------+
|           4.1 |
+---------------+

-- Session 1 :
ERROR 1644 (45000): The variable @total_point is empty

+---------------+
| average_grade |
+---------------+
|           3.3 |
+---------------+
```

* [ma vidéo de démonstration](https://www.youtube.com/watch?v=1jY8VqpmeZg)

### Scénario 2 : Définir et utiliser une variable "multi-session"

* __Given__ : J'aimerai que le résultat de ma procédure "get_average_grade()" soit accessible par n'importe quelle session

Je réinitialise la base de données via le script setup (*différent du setup du scénario 1*).

```sql
-- Script setup
DROP DATABASE IF EXISTS sql2Sce2;
CREATE DATABASE sql2Sce2;
USE sql2Sce2;
DROP TABLE IF EXISTS resultstudent;
CREATE TABLE resultstudent(
	id int NOT NULL AUTO_INCREMENT,
    test varchar(40),
	firstname varchar(20), 
	points int,
    grade decimal (2,1),
	PRIMARY KEY (id)
);
INSERT INTO resultstudent(firstname,points,grade) VALUES 
("Jean",10,5.5),
("Mike",12,6.0),
("Rudy",2,1.5),
("Karl",5,3.5);

DELIMITER //
CREATE PROCEDURE get_average_grade()
BEGIN
	IF (SELECT value FROM config WHERE name = 'total_grade') IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The variable total_grade is empty';
	ELSE
       SELECT ROUND((SELECT value FROM config WHERE name = 'total_grade') / (SELECT COUNT(DISTINCT firstname) FROM resultstudent), 1) AS average_grade;
    END IF; 
END //
DELIMITER ;

CREATE TABLE config(
	name varchar(50) PRIMARY KEY,
	value VARCHAR(100)
);
INSERT INTO config(name) VALUES ('total_grade');

DELIMITER //
CREATE PROCEDURE update_variable(
    IN u_variable VARCHAR(50),
    IN u_value VARCHAR(100)
)
BEGIN
    UPDATE config
    SET value = u_value
    WHERE name = u_variable;
END //
DELIMITER ;
```

Je lance le script 1 afin de stocker la somme totale des notes des élèves dans ma table config.

```sql
-- Seulement Session 1, Script 1
SET @total_grade := select sum(grade) from resultstudent;
CALL update_variable('total_grade', @total_grade)
```

Je prépare une seconde session connectée à la base de données.

* __When__ : J'exécute le second script sur la session 2.

```sql
-- Script 2
call get_average_grade;

-- Ce qui exécutera la procédure get_average_grade() :
BEGIN
	IF (SELECT value FROM config WHERE name = 'total_grade') IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The variable total_grade is empty';
	ELSE
       SELECT ROUND((SELECT value FROM config WHERE name = 'total_grade') / (SELECT COUNT(DISTINCT firstname) FROM resultstudent), 1) AS average_grade;
    END IF; 
END //
```

* __Then__ : Je m'attends à ce que la session 2 me renvoie la moyenne de notes exacte par élève.

```sql
-- Résultat du script 2 sur Session 2
+---------------+
| average_grade |
+---------------+
|           4.1 |
+---------------+
```

* [ma vidéo de démonstration](https://www.youtube.com/watch?v=U5fzLqZUA0s)
## Théorie et Sources WIP

## Source

- Variable user-defined :
	- [Document officiel MySQL](https://dev.mysql.com/doc/refman/8.4/en/user-variables.html) 
	- [Différence entre variable local et user-defined](https://www.geeksforgeeks.org/mysql/user-defined-variables-vs-local-variables-in-mysql/)
	- [Example d'utilisation](https://www.codecademy.com/resources/docs/mysql/user-defined-variables)
- Variable système :
	- [Document officiel MySQL](https://dev.mysql.com/doc/refman/8.4/en/using-system-variables.html)
	- [Tableau des variables systèmes, officiel MySQL](http://dev.mysql.com/doc/refman/8.4/en/dynamic-system-variables.html)
- Autre :
	- [Liste des codes d'erreurs, officiel MySQL](https://downloads.mysql.com/docs/mysql-errors-8.0-en.a4.pdf)
	- [Signal et SQLSTATE 45000, officiel MySQL](https://dev.mysql.com/doc/refman/8.4/en/signal.html)
	- [Table temporaires, officiel MySQL](https://dev.mysql.com/doc/refman/8.4/en/create-temporary-table.html)