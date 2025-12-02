DROP DATABASE IF EXISTS sql2Sce1;
CREATE DATABASE sql2Sce1;
USE sql2Sce1;
DROP TABLE IF EXISTS resultstudent;
CREATE TABLE resultstudent(
	id int NOT NULL AUTO_INCREMENT,
    test varchar(40),
	firstname varchar(20), 
	points int,
    grade decimal (1,1),
	PRIMARY KEY (id)
);
INSERT INTO resultstudent(firstname,points) VALUES 
("Jean",10),
("Mike",12),
("Rudy",2),
("Karl",5),
("Molly",7);

DELIMITER //
CREATE PROCEDURE check_total_point()
BEGIN
    IF @total_point IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The variable is empty';
    END IF;

    SELECT ROUND(@total_point / (SELECT COUNT(DISTINCT firstname) FROM resultstudent), 1) AS result;
END //
DELIMITER ;


