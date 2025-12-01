CREATE TABLE Students (
  student_id INT PRIMARY KEY,
  name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE Instructors (
  instructor_id INT PRIMARY KEY,
  name VARCHAR(100) NOT NULL
);

CREATE TABLE Courses (
  course_id INT PRIMARY KEY,
  title VARCHAR(100)
);

CREATE TABLE Students_Courses (
  student_id INT,
  course_id INT,
  instructor_id INT,
  PRIMARY KEY (student_id, course_id),
  FOREIGN KEY (student_id) REFERENCES Students(student_id),
  FOREIGN KEY (course_id) REFERENCES Courses(course_id),  
  FOREIGN KEY (instructor_id) REFERENCES Instructors(instructor_id)
);

INSERT INTO Students (student_id, name) VALUES
(1, 'Ethann'),
(2, 'Julien'),
(3, 'Nathan');

INSERT INTO Instructors (instructor_id, name) VALUES
(1, 'Nicolas'),
(2, 'Julien');

INSERT INTO Courses (course_id, title) VALUES
(1, 'MAW');

INSERT INTO Students_Courses (student_id, course_id, instructor_id) VALUES
(1, 1, 1),
(2, 1, 1),
(3, 1, 1);