SET @total_point := (select sum(points) from resultstudent);
SELECT @total_point