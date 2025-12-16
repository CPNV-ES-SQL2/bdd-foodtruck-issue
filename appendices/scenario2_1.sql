SET @total_grade := call sum_grade();
CALL update_variable('total_grade', @total_grade)