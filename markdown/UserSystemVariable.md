# Sujet d'étude

(temp) User and System variables - [Tâche](https://github.com/CPNV-ES-SQL2/bdd-foodtruck-issue/issues/9)

## Introduction

Ce sujet d'étude à pour objectif d'approfondir l'utilisation des variables en allant soit de crée ou modifier des variables d'utilisateurs et du système tout en ayant consciente du contexte a les utiliser et ainsi l'effet sur la persistance du contenu des variables 


## Objectifs

Il s'agit de prouver par la pratique ces points suivant:

- De savoir dans quel contexte devrons nous utiliser soit les variables d'environnement d'un utilisateur, soit du système ou soit les 2 en même temps
- La portée entre les 2 types de variables système (user-defined/session, global et dynamic)
- Les différents types de valeur d'une variable peut avoir (erroné inclus)
- De vérifier le contenu d'une variable en plein script 
## Scénario pratique WIP

 ###  Transaction en déclarant une variable globale vs session vs dynamic 
* (Given) J'ai 2 scripts qui me permet comparer les 3 types de variables. Le premier déclare des variables a utiliser dans le second mais avec des portées différents

[file to import testdb](fichier.sql)

* (When) Quand je change de session 

```sql
--do file
```

* (Then) 

```sql
--result of the transaction depending of changed session
```


* [ma vidéo de démonstartion](lien-vers-une-vidéo)
### Convertion des types erronés de valeurs des variables

* (Given) J'execute ce script remplie de différent type de valeur dans une variable dont une qui ne fait
[Fichier des types de valeurs d'une variable](types_variables.sql) (fix path)

* (When) Dès lorsque j'execute l'entièreté du script

```sql
SET @varInt = 1;
SET @varDec = 1234.764;
SET @varFloa = 0.12;
SET @varNULL = NULL ;
SET @varString = "Hello";
SET @varJSON = 1; #todo


SELECT @varInt, @varDec, @varFloa, @varNULL, @varString, @varJSON
```

* (Then) Je peux remarqué que la variable @varJSON a un type string à la place de JSON

```sql
drop temporary table if exists foo;
create temporary table foo select @varJSON; --add the rest 
desc foo;

--show result when done by table
```


### Vérifier le contenu d'une variable durant l'exécution
 (Given) J'ai à disposition un script qui modifie une variable en hexa et j'aimerai vérifier que la valeur est correctement défini dans la variable avant chaque action 
[Fichier des types de valeurs d'une variable](types_variables.sql) (fix path)

* (When) Dès lorsque j'execute l'entièreté du script

```sql
--blabla code, go check https://dev.mysql.com/doc/refman/8.4/en/show-variables.html for more info
-- maybe go get debug or smth too
```

* (Then) Je peux remarqué que la variable @varJSON a un type string à la place de JSON

```sql
-- show result of EACH before-stepn°X
```
(temp)Résumé des sources (un résumé produit par chat gpt est ok, pour autant que vous le remettiez en page et le validiez)


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

