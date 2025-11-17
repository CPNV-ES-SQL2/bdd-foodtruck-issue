# Formes normales (par la pratique)
## Introduction

Ce document vise à expliquer les formes normales en bases de données relationnelles à travers des exemples pratiques. Nous allons explorer les 3 dernières formes normales (BCNF, 4NF et 5NF) en utilisant des exemples concrets pour illustrer chaque concept.

## Objectifs

- Comprendre les concepts de BCNF, 4NF et 5NF.
- Savoir repérer les violations des différentes formes normales.
- Pratiquer la normalisation des bases de données relationnelles.

## Théorie et Sources

- https://www.datacamp.com/fr/tutorial/normalization-in-sql?dc_referrer=https://www.google.com/
- https://cpnv-es-ngy.gitbook.io/sql2/theorie-et-concept/formes-normales

Chaque forme normale suppose que la forme précédente est respectée.  
Autrement dit : 1NF → 2NF → 3NF → BCNF → 4NF → 5NF.  
Pour être en n‑NF, une relation doit d'abord être en (n‑1)‑NF.

### BCNF (Boyce-Codd Normal Form)

Une relation est en BCNF est une forme normale stricte de la 3NF. Pour rappel la 3NF exige qu'aucune dépendance fonctionnelle non triviale ne doit exister entre des attributs non clés. Une relation est en BCNF si, pour chaque dépendance fonctionnelle X -> Y, X est une superclé. Cela signifie que chaque déterminant doit être une clé candidate.

### 4NF

Une relation est en 4NF lorsqu'elle ne contient pas de dépendances multivaluées non triviales. Une dépendance multivaluée se produit lorsque, pour une valeur donnée d'un attribut, il existe plusieurs valeurs associées pour un autre attribut, indépendamment des autres attributs de la relation. Pour qu'une relation soit en 4NF, chaque dépendance multivaluée doit être une conséquence d'une clé candidate.

### 5NF

## Validation pratique

### BCNF

```sql
-- Table de référence
CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    Name VARCHAR(100)
);

CREATE TABLE Courses (
    course_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE Instructors (
    instructor_id INT PRIMARY KEY,
    name VARCHAR(100)
);

-- Table initiale
CREATE TABLE Students_Courses (
    student_id INT,
    course_id INT,
    instructor_id INT,
    PRIMARY KEY (student_id, course_id),
    CONSTRAINT fk_Students_Courses_student FOREIGN KEY (student_id) REFERENCES Students(student_id),
    CONSTRAINT fk_Students_Courses_course FOREIGN KEY (course_id) REFERENCES Courses(course_id),
    CONSTRAINT fk_Students_Courses_instructor FOREIGN KEY (instructor_id) REFERENCES Instructors(instructor_id)
);
```

![Diagramme de la table Students_Courses avant normalisation](img/BCNF_before.png)

Problème : Un étudiant peut suivre plusieurs cours, et chaque cours peut être enseigné par plusieurs instructeurs. Cela crée une dépendance fonctionnelle où course_id -> instructor_id, mais course_id n'est pas une superclé.
Solution : Diviser la table en deux tables pour éliminer la dépendance fonctionnelle.

```sql
-- Tables normalisées en BCNF
CREATE TABLE Students_Courses (
    student_id INT,
    course_id INT,
    PRIMARY KEY (student_id, course_id),
    CONSTRAINT fk_Students_Courses_student FOREIGN KEY (student_id) REFERENCES Students(student_id),
    CONSTRAINT fk_Students_Courses_course FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);

CREATE TABLE Courses_Instructors (
    course_id INT,
    instructor_id INT,
    PRIMARY KEY (course_id, instructor_id),
    CONSTRAINT fk_Courses_Instructors_course FOREIGN KEY (course_id) REFERENCES Courses(course_id),
    CONSTRAINT fk_Courses_Instructors_instructor FOREIGN KEY (instructor_id) REFERENCES Instructors(instructor_id)
);
```

![Diagramme des tables après normalisation en BCNF](img/BCNF_after.png)

### 4NF

```sql
-- Table initiale (mauvaise conception pour un réseau social)
CREATE TABLE Posts (
    post_id INT PRIMARY KEY,
    content TEXT,
    image_url VARCHAR(255),
    tag VARCHAR(100)
);
```

![Diagramme de la table Posts avant normalisation](img/4NF_social_before.png)

Problème (concret) : Une publication peut contenir plusieurs images et plusieurs tags indépendamment l'un de l'autre. Si on stocke image_url et tag dans la même table, on obtient un produit cartésien implicite : pour une publication avec 3 images et 4 tags, la table nécessite 12 lignes redondantes. Cela provoque :
- duplication des champs content et post_id,
- anomalies à l'insertion/suppression (difficile d'ajouter une image sans dupliquer les tags, ou de supprimer un tag sans perdre une image),
- violation de la 4NF car il existe deux dépendances multivaluées non triviales : post_id -> image_url et post_id -> tag, indépendantes l'une de l'autre.

Exemple de lignes problématiques (illustratif) :
- post_id=1, content="...", image_url="img1.jpg", tag="sport"
- post_id=1, content="...", image_url="img1.jpg", tag="vacances"
- post_id=1, content="...", image_url="img2.jpg", tag="sport"
- post_id=1, content="...", image_url="img2.jpg", tag="vacances"
(duplication du content)

Solution : séparer chaque dépendance multivaluée dans sa propre relation. Conserver la table principale Posts pour les attributs scalaires et créer Post_Images et Post_Tags pour les valeurs multiples.

```sql
-- Tables normalisées en 4NF pour un réseau social
CREATE TABLE Posts (
    post_id INT PRIMARY KEY,
    content TEXT,
    created_at TIMESTAMP
);

CREATE TABLE Post_Images (
    post_id INT,
    image_url VARCHAR(255),
    PRIMARY KEY (post_id, image_url),
    CONSTRAINT fk_Post_Images_post FOREIGN KEY (post_id) REFERENCES Posts(post_id)
);

CREATE TABLE Post_Tags (
    post_id INT,
    tag VARCHAR(100),
    PRIMARY KEY (post_id, tag),
    CONSTRAINT fk_Post_Tags_post FOREIGN KEY (post_id) REFERENCES Posts(post_id)
);
```

![Diagramme des tables Posts normalisées en 4NF](img/4NF_social_after.png)
