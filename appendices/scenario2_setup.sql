DROP DATABASE IF EXISTS sql2Sce2;
CREATE DATABASE sql2Sce2;
USE sql2Sce2;
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
("Rudy",2,1.5),
("Karl",5,3.5);

DELIMITER //
CREATE PROCEDURE get_average_grade()
BEGIN
	IF (SELECT value FROM config WHERE name = 'total_grade') IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The variable total_grade is empty';
	ELSE
       SELECT ROUND((SELECT value FROM config WHERE name = 'total_grade') / (SELECT COUNT(DISTINCT firstname) FROM resultstudent), 1) AS average_grade;
    END IF; 
END //
DELIMITER ;

CREATE TABLE config(
	name varchar(50) PRIMARY KEY,
	value VARCHAR(100)
);
INSERT INTO config(name) VALUES ('total_grade');

DELIMITER //
CREATE PROCEDURE update_variable(
    IN u_variable VARCHAR(50),
    IN u_value VARCHAR(100)
)
BEGIN
    UPDATE config
    SET value = u_value
    WHERE name = u_variable;
END //
DELIMITER ;