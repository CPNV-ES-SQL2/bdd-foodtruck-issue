# Sujet d'étude

## Introduction

Ce sujet d'étude à pour objectif d'approfondir sur l'utilisation d'une variable d'utilisateur et système

## Objectifs

Il s'agit de prouver par la pratique ces points suivant:

- Identifier la portée et le rôle d'une variable user-defined
- Identifier la portée et le rôle d'une variable system 
- Identifier les différents types de valeur qu'une variable user-defined peut contenir.
- Debugger un script en pleine exécution afin de vérifier le contenu d'une variable
## Scénario pratique WIP

### Démontrer la portée et le rôle des variables user-defined 


*idée : 2 scripts, l'un fini via un set d'une variable, le 2nd commence avec l'utilisation de celui-ci. doit se foirer si NULL ou rien. 2 sessions nécessaire*

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

### Démontrer la portée et le rôle des variables système 


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
### Démontrer les différents types de valeurs qu'une variable user-defined peut avoir

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

| @varInt | @varDec  | @varNULL | @varString | @varJSON                                         | JSON_VALID(@varJSON) |
|---------|----------|----------|------------|-------------------------------------------------|--------------------|
| 1       | 1234.764 | NULL     | Hello      | { "accountno": "123456", "funds": 250.75 }     | 1                  |

Résultat des différent types qui ont était associé aux variables :

| Field      | Type           | Null |
| ---------- | -------------- | ---- |
| @varInt    | bigint         | YES  |
| @varDec    | decimal(65,30) | YES  |
| @varNULL   | longtext       | YES  |
| @varString | longtext       | YES  |
| @varJSON   | longtext       | YES  |

### Vérifier le contenu d'une variable durant l'exécution

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

## Théorie et Sources
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

