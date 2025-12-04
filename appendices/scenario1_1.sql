SET @total_grade  := (select sum(grade) from resultstudent);
SET @total_point := (select sum(points) from resultstudent);