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
	- Session 1 : Doit avoir exécuté le **script setup** et défini une variable user-defnied @total_grade.
	- Session 2 : Doit avoir exécuté le **premier script** et défini une variable user-defined @total_point.

J'initialise la base de données avec des données de test, je set la somme des notes et je crée 2 vérifications des variables via des procédures via le script setup dans la session 1.

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
    grade decimal (5,1),
	PRIMARY KEY (id)
);
SET @total_grade  := (select sum(grade) from resultstudent);
INSERT INTO resultstudent(firstname,points,grade) VALUES 
("Jean",10,5.5),
("Mike",12,6.0),
("Rudy",2,1.5),
("Karl",5,3.5),
("Molly",7,4.0);

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
```

J'execute le script 1 dans la session 2

```sql
-- Script 1, session 2 seulement :
SET @total_point := (SELECT sum(points) FROM resultstudent);
```

Je vérifie que j'ai bien les deux sessions actives via SHOW PROCESSLIST:

| Id  | User | Host            | db       | Command | Time | State | Info             |
|-----|------|------------------|----------|---------|------|-------|------------------|
| 197 | sql2 | localhost:58561 | sql2sce1 | Sleep   | 56   |       | NULL             |
| 198 | sql2 | localhost:65124 | sql2sce1 | Query   | 0    | init  | SHOW PROCESSLIST |

- __When__ : J'exécute le second script sur les deux sessions.

```sql
-- Script 2
SELECT @total_point / (SELECT COUNT(DISTINCT firstname) FROM resultstudent) AS result
SELECT ROUND(@total_grade / (SELECT COUNT(DISTINCT firstname) FROM resultstudent), 1) AS average_grade;
```

* __Then__ : 
	* Session 1 : J'attends que cette session me renvoie une erreur 1644 indiquant que les 2 variables user-defined sont vides.
	* Session 2 : J'attends que cette session me renvoie le nombre de points et la note moyen par élève.

```sql
-- Session 1 :
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

-- Session 2 :
ERROR 1644 (45000): The variable @total_point is empty
ERROR 1644 (45000): The variable @total_grade is empty
```

* [ma vidéo de démonstration](https://www.youtube.com/watch?v=uuN_KMPYwGg)

### Scénario 2 : Définir et utiliser une variable "multi-session"


* __Given__ : J'aimerai que la variable @total_grade puisse être accessible dans n'importe que session. 
Je re-initialise la db via le script setup 

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
    grade decimal (5,1),
	PRIMARY KEY (id)
);
INSERT INTO resultstudent(firstname,points,grade) VALUES 
("Jean",10,5.5),
("Mike",12,6.0),
("Rudy",2,1.5),
("Karl",5,3.5),
("Molly",7,4.0);

DELIMITER //
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
```

Je prépare deux sessions différentes :
	- Session 1 : Doit avoir exécuter le premier script et défini la variable "multi-session" @total_grade
	- Session 2 : **NE** doit **PAS** exécuté le premier script et donc n'a pas défini la variable @total_grade

```sql
-- Seulement Session 1, Script 1

```

* __When__ :  J'execute le second script sur les 2 sessions

```sql
-- Script 2
SELECT ROUND(@total_grade / (SELECT COUNT(DISTINCT firstname) FROM resultstudent), 1) AS average_grade;
```

* __Then__ : Les 2 sessions devrait avoir la même note en moyenne par élèves.

```sql
-- Session 1


-- Session 2
```

* [ma vidéo de démonstration](https://www.youtube.com/watch?v=uuN_KMPYwGg)

### Démontrer la portée et le rôle des variables système  WIP


*idée : 2 scripts, l'un défini une variable system, le 2nd utilise. 2 DIFFERENT résultat si on/off. 2 sessions nécessaire*
*system var utilisable : auto_increment_offset, offline_mode *
* (Given) J'ai 2 scripts qui me permet comparer les 3 types de variables. Le premier déclare des variables a utiliser dans le second mais avec des portées différents

[file to import testdb](fichier.sql)

* (When) Quand je change de session 

```sql
--do file sql
```

* (Then) 

```sql
--result of the transaction for each context after changing session
```


* [ma vidéo de démonstartion](lien-vers-une-vidéo)
### Démontrer les différents types de valeurs qu'une variable user-defined peut avoir WIP

* (Given) Je veux exécuter ce script remplie de fill-in de valeur dans les variables afin de voir la conversion en cas de type non valide
[Fichier des types de valeurs d'une variable](\appendices\types_variables.sql) *fix path*

* (When) Dès lorsque l'exécution de ce script

```sql
SET @varInt = 1;
SET @varDec = 1234.764;
SET @varString = "Hello";
SET @varJSON = '{
  "accountno": "123456",
  "funds": 250.75
}';

SELECT @varInt, @varDec, @varNULL, @varString, @varJSON,JSON_VALID(@varJSON);


drop temporary table if exists foo;
create temporary table foo select @varInt, @varDec, @varNULL, @varString, @varJSON; 
desc foo;
```

* (Then) Je peux remarquer que la variable @varJSON a été converti en un type string à la place d'avoir un type JSON

Résultat du select pour voir le contenu et ainsi de vérifier si le JSON est valide

| @varInt | @varDec  | @varNULL | @varString | @varJSON                                   | JSON_VALID(@varJSON) |
| ------- | -------- | -------- | ---------- | ------------------------------------------ | -------------------- |
| 1       | 1234.764 | NULL     | Hello      | { "accountno": "123456", "funds": 250.75 } | 1                    |

Résultat des différent types qui ont était associé aux variables :

| Field      | Type           | Null |
| ---------- | -------------- | ---- |
| @varInt    | bigint         | YES  |
| @varDec    | decimal(65,30) | YES  |
| @varNULL   | longtext       | YES  |
| @varString | longtext       | YES  |
| @varJSON   | longtext       | YES  |

### Vérifier le contenu d'une variable durant l'exécution WIP

 (Given) J'ai à disposition un script qui modifie une variable en hexa et j'aimerai vérifier que la valeur est correctement défini dans la variable avant chaque action 

*utiliser plusieurs methode?*
[Fichier des types de valeurs d'une variable](types_variables.sql) *fix path*

* (When) Dès lorsque j'execute l'entièreté du script

```sql
--blabla code, go check https://dev.mysql.com/doc/refman/8.4/en/show-variables.html for more info
-- maybe go get debug or smth too
```

* (Then) Je peux remarqué que la variable @varJSON a un type string à la place de JSON

```sql
-- show result of EACH before-stepn°X
```

## Théorie et Sources WIP
Résumé des sources (un résumé produit par chat gpt est ok, pour autant que vous le remettiez en page et le validiez)


En autre, les variables d'environnement d'utilisateur peuvent être utiliser pour stocker une valeur d'une requête puis de la référer dans une autre requête
Ces valeurs commencent avec un @ et sont défini via un SET comme ceci :
```sql
SET @var_name = expr
```
Le code du haut donnera quelque chose comme ceci :

| @col1 |
| ----- |
| c1    |

Cependant, préparer une requête avec une/des variables puis de l'exécuter fonctionne comme l'exemple ci-dessous :
```sql

```
*add exemple in MySQL*

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