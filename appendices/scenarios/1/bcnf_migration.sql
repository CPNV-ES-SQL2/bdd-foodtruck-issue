CREATE TABLE Courses_Instructors (
  course_id INT NOT NULL,
  instructor_id INT NOT NULL,
  PRIMARY KEY (course_id, instructor_id),
  FOREIGN KEY (course_id) REFERENCES Courses(course_id),
  FOREIGN KEY (instructor_id) REFERENCES Instructors(instructor_id)
);

INSERT INTO Courses_Instructors (course_id, instructor_id)
SELECT DISTINCT course_id, instructor_id
FROM Students_Courses;

ALTER TABLE Students_Courses
  DROP FOREIGN KEY Students_Courses_ibfk_3;
ALTER TABLE Students_Courses
  DROP COLUMN instructor_id;
