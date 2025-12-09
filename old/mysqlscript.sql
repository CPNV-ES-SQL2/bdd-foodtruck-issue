DROP TABLE IF EXISTS users_int;
DROP TABLE IF EXISTS users_varchar;
-- Table avec INTEGER
CREATE TABLE users_int (
    id INT NOT NULL,
    data VARCHAR(100),
    PRIMARY KEY (id)
) ENGINE = InnoDB;
-- Table avec VARCHAR représentant un entier
CREATE TABLE users_varchar (
    id VARCHAR(20) NOT NULL,
    data VARCHAR(100),
    PRIMARY KEY (id)
) ENGINE = InnoDB;
-- Insérer 100k de lignes dans les deux tables
DROP PROCEDURE IF EXISTS fill_tables;
DELIMITER //
CREATE PROCEDURE fill_tables() BEGIN
DECLARE i INT DEFAULT 1;
START TRANSACTION;
WHILE i <= 100000 DO
INSERT INTO users_int
VALUES (i, CONCAT('data-', i));
INSERT INTO users_varchar
VALUES (CAST(i AS CHAR), CONCAT('data-', i));
SET i = i + 1;
END WHILE;
COMMIT;
END //
DELIMITER ;
CALL fill_tables();
