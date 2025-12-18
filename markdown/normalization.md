# Formes normales (par la pratique)
## Introduction

Ce document vise à expliquer les formes normales en bases de données relationnelles à travers des exemples pratiques. Nous allons explorer les 3 dernières formes normales (BCNF, 4NF et 5NF) en utilisant des exemples concrets pour illustrer chaque concept.

## Objectifs

Il s'agit de prouver par la pratique les points suivants:

- Comment identifier les violations des trois dernières formes normales ?
  - Es-ce que certaines dépendances fonctionnelles ne sont pas basées sur des clés candidates ?
  - Es-ce que certaines dépendances multivaluées existent ? 
  - Es-ce que certaines dépendances jointives existent ?
- Comment normaliser une base de données pour respecter ces formes normales ?
  - Définir des scénarios d'une base de données non normalisée puis appliquer les migrations nécessaires pour atteindre la forme normale souhaitée.

## Scénario
### Scénario 1: Identification de la violation de la BCNF.
#### Given

Prenons le contexte d'une base de données de gestion des cours par example pour le CPNV. Exutons le script `given.sql` pour créer la base de données en 3NF mais violant la BCNF. Imaginons que 4 éléve participe au cours `Database Systems` et que leur instructeur est `Nicolas`. 

Imaginons maintenant que `Nicolas` donne le cours `Database Systems` en paralèle avec un autre instructeur `Julien`. 
```sql
INSERT INTO Students_Courses (student_id, course_id, instructor_id) VALUES
(1, 1, 2),
(2, 1, 2),
(3, 1, 2),
(4, 1, 2);
```
*note: ERROR 1062 (23000): Duplicate entry '1-1' for key 'Students_Courses.PRIMARY'*

#### When

Nous remarquons que la table `Students_Courses` viole la BCNF car la dépendance fonctionnelle `instructor_id -> course_id` n'est pas basée sur une clé candidate. En effet, un instructeur peut enseigner plusieurs cours, mais chaque cours ne peut être enseigné que par un seul instructeur dans cette table.
Executons la migration `bcnf_migration.sql` pour normaliser la base de données en BCNF.

#### Then

Après avoir appliqué la migration, nous avons créé une nouvelle table `Instructors_Courses` pour gérer la relation entre les instructeurs et les cours. La table `Students_Courses` ne contient plus l'instructeur, ce qui élimine la dépendance fonctionnelle problématique.
```sql
INSERT INTO Courses_Instructors (instructor_id, course_id) VALUES
(2, 1);
```

[Vidéo](https://youtu.be/r1RSDEOmlvg)

### Scénario 2: Identification de la violation de la 4NF.
#### Given

Continuons avec le contexte de la base de données de gestion des cours mais que nous voulons ajouté un champ `phonenumber` pour les étudiants et laissons les éléves entrer leur numéro de téléphone pendant un certains temps. Exutons le script `given.sql` pour créer la base de données en BCNF mais violant la 4NF ainsi que la simulation.
Imaginons que certains étudiants ont plusieurs numéros de téléphone. Par example, l'étudiant avec `Ethann` a les numéros `+1234567890` et `+0987654322`. Par example, pour de jeune étudiant donc le numéro de téléphone des parents est aussi enregistré.
```sql
INSERT INTO Students (student_id, name, phonenumber) VALUES
(1, 'Ethann', '+0987654321');
```
*note: ERROR 1062 (23000): Duplicate entry '1' for key 'Students.PRIMARY'*

#### When

Nous remarquons que la table `Students` viole la 4NF car il existe une dépendance multivaluée entre `student_id` et `phonenumber`. Car un étudiant peut avoir plusieurs numéros de téléphone indépendamment des autres attributs.
Executons la migration `4nf_migration.sql` pour normaliser la base de données en 4NF.

#### Then

Après avoir appliqué la migration, nous avons créé une nouvelle table `Students_Phonenumbers` pour gérer la relation entre les étudiants et leurs numéros de téléphone. La table `Students` ne contient plus le champ `phonenumber`, ce qui élimine la dépendance multivaluée problématique.
```sql
INSERT INTO Students_Phonenumbers (student_id, phonenumber) VALUES
(1, '+0987654322');
```

### Scénario 3: Identification de la violation de la 5NF.
#### Given

Pour celle ci prenons un contexte différent, car rare sont les cas d'utilisation de la 5NF. Imaginons une base de données de gestion des projets où chaque projet peut être associé à plusieurs employés et chaque employé peut travailler sur plusieurs projets. De plus, chaque employé peut avoir plusieurs rôles dans un projet. Exutons le script `given.sql` pour créer la base de données en 4NF mais violant la 5NF. Imaginons que l'employé `Bob` travaille sur le projet `Alpha` en tant que `Developer` et `Manager`.
```sql
-- list all roles of Bob in project Alpha
SELECT role
FROM Employees_Projects_Roles
WHERE employee_id = 2 AND project_id = 1;

INSERT INTO Employees_Projects_Roles (project_id, employee_id, role) VALUES
(1, 2, 'Developer');
```

*note: la colone s'insère correctement*

#### When

Nous remarquons que la table `Projects_Employees_Roles` viole la 5NF car il existe une dépendance jointe entre `project_id`, `employee_id` et `role`. Car un employé peut avoir plusieurs rôles dans un projet indépendamment des autres attributs.
Executons la migration `5nf_migration.sql` pour normaliser la base de données en 5NF.

#### Then

Après avoir appliqué la migration, nous avons créé trois nouvelles tables: `Projects_Employees`, `Employees_Roles` et `Projects_Roles` pour gérer les relations entre les projets, les employés et leurs rôles. La table `Projects_Employees_Roles` a été supprimée, ce qui élimine la dépendance jointe problématique. Maintenant, `Bob` la query si bob devient `Tester` aussi dans le projet `Alpha`:
```sql
-- list all roles of Bob in project Alpha
SELECT pr.role
FROM Employees_Roles er
JOIN Projects_Roles pr ON er.project_role_id = pr.project_role_id
WHERE er.employee_id = 2 AND pr.project_id = 1;

INSERT INTO Projects_Roles (project_id, role) VALUES
(1, 'Tester');

INSERT INTO Employees_Roles (employee_id, project_role_id) VALUES
(2, (SELECT project_role_id FROM Projects_Roles WHERE project_id = 1 AND role = 'Tester'));
```

## Théorie et Sources

- [Principes de base de la normalisation des bases de données](https://learn.microsoft.com/fr-fr/office/troubleshoot/access/database-normalization-description)
- [Normalization in SQL (1NF - 5NF): A Beginner’s Guide](https://www.datacamp.com/tutorial/normalization-in-sql)
- [Database normalization](https://en.wikipedia.org/wiki/Database_normalization)
- [Qu’est-ce que la normalisation des bases de données ?](https://www.ibm.com/fr-fr/think/topics/database-normalization)

### Formes normales
Une forme normale est un ensemble de règles utilisées pour organiser les données dans une base de données relationnelle. L'objectif principal de la normalisation est de minimiser la redondance des données et d'améliorer l'intégrité des données.

### 3NF
La troisième forme normale (3NF) est une forme normale qui vise à éliminer les dépendances transitives. Une relation est en 3NF si, pour chaque dépendance fonctionnelle X -> Y, soit X est une superclé, soit Y est un attribut primaire. Cela signifie qu'aucun attribut non clé ne doit dépendre d'un autre attribut non clé.

### BCNF
Boyce-Codd Normal Form (BCNF) est une forme normale plus stricte que la troisième forme normale (3NF). Une relation est en BCNF si, pour chaque dépendance fonctionnelle X -> Y, X est une superclé. Cela signifie que chaque déterminant doit être une clé candidate.

### 4NF
La quatrième forme normale (4NF) traite des dépendances multivaluées. Une relation est en 4NF si, pour chaque dépendance multivaluée X ->> Y, X est une superclé. Cela signifie qu'une table ne doit pas contenir de dépendances multivaluées non triviales.  

### 5NF
La cinquième forme normale (5NF), également connue sous le nom de forme normale de projection-join, traite des dépendances joinives. Une relation est en 5NF si, pour chaque dépendance joinive, la relation peut être décomposée en relations plus petites sans perte d'information. Cela signifie que toutes les dépendances joinives doivent être basées sur des clés candidates.

## Glossaire

- **clé candidate**: Un ensemble minimal d'attributs qui peut identifier de manière unique une ligne dans une table.
- **dépendance fonctionnelle**: Une relation entre deux ensembles d'attributs dans une base de données, où la valeur d'un ensemble (le déterminant) détermine la valeur de l'autre ensemble.
- **superclé**: Un ensemble d'attributs qui peut identifier de manière unique une ligne dans une table, mais qui peut contenir des attributs supplémentaires non nécessaires pour l'identification unique.
- **dépendance multivaluée**: Une situation où un attribut dans une table dépend de manière indépendante d'un autre attribut, ce qui peut entraîner des redondances.
- **dépendance joinive**: Une situation où une table peut être décomposée en plusieurs tables plus petites sans perte d'information, mais où la recomposition des tables originales nécessite une jointure complexe.
- **normalisation**: Le processus d'organisation des données dans une base de données pour minimiser la redondance et améliorer l'intégrité des données.
- **dépendance transitive**: Une situation où un attribut dépend d'un autre attribut qui, à son tour, dépend d'un troisième attribut.
