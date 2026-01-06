INSERT INTO resultstudent(firstname,points,grade) VALUES 
("Molly",3,2.0);

SET @total_grade  := (select sum(grade) from resultstudent);
SET @total_point := (select sum(points) from resultstudent);