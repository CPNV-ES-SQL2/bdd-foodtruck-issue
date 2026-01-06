DROP DATABASE IF EXISTS sql2Sce1;
CREATE DATABASE sql2Sce1;
USE sql2Sce1;
DROP TABLE IF EXISTS resultstudent;
CREATE TABLE resultstudent(
	id int NOT NULL AUTO_INCREMENT,
    test varchar(40),
	firstname varchar(20), 
	points int,
    grade decimal (2,1),
	PRIMARY KEY (id)
);
INSERT INTO resultstudent(firstname,points,grade) VALUES 
("Jean",10,5.5),
("Mike",12,6.0),
("Rudy",4,2.5),
("Karl",5,3.5);

DELIMITER //
CREATE PROCEDURE check_total_point()
BEGIN
    IF @total_point IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The variable @total_point is empty';
	ELSE
        SELECT ROUND(@total_point / (SELECT COUNT(DISTINCT firstname) FROM resultstudent), 1) AS average_point;
    END IF;
END //
CREATE PROCEDURE check_total_grade()
BEGIN
	IF @total_grade IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The variable @total_grade is empty';
	ELSE
        SELECT ROUND(@total_grade / (SELECT COUNT(DISTINCT firstname) FROM resultstudent), 1) AS average_grade;
    END IF; 
END //
DELIMITER ;
SET @total_grade  := (select sum(grade) from resultstudent);