DROP DATABASE IF EXISTS sql2Sce2;
CREATE DATABASE sql2Sce2;
USE sql2Sce2;
DROP TABLE IF EXISTS resultstudent;
CREATE TABLE resultstudent(
	id int NOT NULL AUTO_INCREMENT,
    test varchar(40),
	firstname varchar(20), 
	points int,
    grade decimal (5,1),
	PRIMARY KEY (id)
);
INSERT INTO resultstudent(firstname,points,grade) VALUES 
("Jean",10,5.5),
("Mike",12,6.0),
("Rudy",2,1.5),
("Karl",5,3.5);

DELIMITER //
CREATE PROCEDURE check_total_grade()
BEGIN
	IF (SELECT value FROM variabletable WHERE name = 'total_grade') IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The variable total_grade is empty';
	ELSE
       SELECT ROUND((SELECT value FROM variabletable WHERE name = 'total_grade') / (SELECT COUNT(DISTINCT firstname) FROM resultstudent), 1) AS average_grade;
    END IF; 
END //
DELIMITER ;

CREATE TABLE variabletable(
	name varchar(100) PRIMARY KEY,
	value VARCHAR(256)
);
INSERT INTO variabletable(name,value) VALUES ('total_grade', 100);

DELIMITER //
CREATE PROCEDURE update_variable(
    IN u_variable VARCHAR(64),
    IN u_value VARCHAR(256)
)
BEGIN
    UPDATE variabletable
    SET value = u_value
    WHERE name = u_variable;
END //
DELIMITER ;