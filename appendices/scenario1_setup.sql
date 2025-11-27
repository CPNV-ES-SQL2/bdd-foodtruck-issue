USE SQL2;
DROP TABLE IF exists resultstudent;
CREATE TABLE resultstudent(
	id int NOT NULL AUTO_INCREMENT,
    test varchar(40),
	firstname varchar(20), 
	points int,
    grade decimal (1,1),
	PRIMARY KEY (id)
);
INSERT INTO resultstudent(firstname,points) values 
("Jean",10),
("Mike",12),
("Rudy",2),
("Karl",5),
("Molly",7);

