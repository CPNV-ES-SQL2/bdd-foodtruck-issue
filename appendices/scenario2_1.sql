INSERT INTO resultstudent(firstname,points,grade) VALUES 
("Molly",7,4.0);

SET @total_grade  := (select sum(grade) from resultstudent);
CALL update_variable('total_grade', @total_grade)