CREATE TABLE Students_Phonenumbers (
    student_phonenumber_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    phonenumber VARCHAR(15),
    UNIQUE(student_id, phonenumber),
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
);

INSERT INTO Students_Phonenumbers (student_id, phonenumber)
SELECT student_id, phonenumber FROM Students WHERE phonenumber IS NOT NULL;

ALTER TABLE Students DROP COLUMN phonenumber;