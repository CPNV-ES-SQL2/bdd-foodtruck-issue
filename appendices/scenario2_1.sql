INSERT INTO resultstudent(firstname,points,grade) VALUES 
("Molly",3,2.0);

INSERT INTO variabletable(name,value) VALUES ('total_point',(select sum(points) from resultstudent));
UPDATE variabletable set value = (select sum(grade) from resultstudent) where name = 'total_grade';