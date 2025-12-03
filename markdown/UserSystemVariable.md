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

* __Given__ : J'initialise la db avec des données de test ainsi que la vérification de la variable par une procédure

```sql
DROP DATABASE IF EXISTS sql2Sce1;
CREATE DATABASE sql2Sce1;
USE sql2Sce1;
DROP TABLE IF EXISTS resultstudent;
CREATE TABLE resultstudent(
	id int NOT NULL AUTO_INCREMENT,
    test varchar(40),
	firstname varchar(20), 
	points int,
    grade decimal (1,1),
	PRIMARY KEY (id)
);
INSERT INTO resultstudent(firstname,points) VALUES 
("Jean",10),
("Mike",12),
("Rudy",2),
("Karl",5),
("Molly",7);

DELIMITER //
CREATE PROCEDURE check_total_point()
BEGIN
    IF @total_point IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The variable is empty';
    END IF;

    SELECT ROUND(@total_point / (SELECT COUNT(DISTINCT firstname) FROM resultstudent), 1) AS result;
END //
DELIMITER ;
```

Je prépare 2 sessions différentes :
- Session 1 : Doit avoir exécuté le 1er script et set une user-defined variable @total_point.
- Session 2 : Ne doit pas exécuter le 1er script et n'a pas de variable user-defined @total_point définie.

```sql
-- Session 1 seulement :
SET @total_point := (SELECT sum(points) FROM resultstudent);
```

- Je vérifie que j'ai bien les 2 sessions actifs via SHOW PROCESSLIST:

| Id  | User | Host            | db       | Command | Time | State | Info             |
|-----|------|------------------|----------|---------|------|-------|------------------|
| 197 | sql2 | localhost:58561 | sql2sce1 | Sleep   | 56   |       | NULL             |
| 198 | sql2 | localhost:65124 | sql2sce1 | Query   | 0    | init  | SHOW PROCESSLIST |
* __When__ : J'exécute le 2ème script sur les 2 sessions.

```sql
SELECT @total_point / (SELECT COUNT(DISTINCT firstname) FROM resultstudent) AS result
```

* __Then__ : 
	* Session 1 : J'attends que cette session me renvoie le nombre de point moyenne par élève
	* Session 2 : J'attends que cette session me renvoie une erreur indiquant que la variable user-defined est vide

```sql
-- Session 1 :
+--------+
| result |
+--------+
|    7.2 |
+--------+

-- Session 2 :
ERROR 1644 (45000): The variable is empty
```

* [ma vidéo de démonstartion](https://www.youtube.com/watch?v=uuN_KMPYwGg)

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
Source MySQL :
- [User-defined variable](https://dev.mysql.com/doc/refman/8.4/en/user-variables.html)
- [System variable](https://dev.mysql.com/doc/refman/8.4/en/using-system-variables.html)
- [Variable dynamiques du système + tableau](http://dev.mysql.com/doc/refman/8.4/en/dynamic-system-variables.html)

