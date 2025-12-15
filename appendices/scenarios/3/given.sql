CREATE TABLE Employees (
    employee_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE Projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(100)
);

CREATE TABLE Employees_Projects_Roles (
    employees_projects_roles_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT,
    project_id INT,
    role VARCHAR(100),
    UNIQUE (employee_id, project_id, role),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id),
    FOREIGN KEY (project_id) REFERENCES Projects(project_id)
);

INSERT INTO Employees (employee_id, name) VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie'),
(4, 'Diana'),
(5, 'Ethan'),
(6, 'Fiona'),
(7, 'George'),
(8, 'Hannah'),
(9, 'Ian'),
(10, 'Jane'),
(11, 'Kevin'),
(12, 'Laura'),
(13, 'Mike'),
(14, 'Nina'),
(15, 'Oscar'),
(16, 'Paula'),
(17, 'Quinn'),
(18, 'Rachel'),
(19, 'Steve'),
(20, 'Tina'),
(21, 'Uma'),
(22, 'Victor'),
(23, 'Wendy'),
(24, 'Xander'),
(25, 'Yara'),
(26, 'Zane'),
(27, 'Aaron'),
(28, 'Bianca'),
(29, 'Cameron'),
(30, 'Derek');

INSERT INTO Projects (project_id, project_name) VALUES
(1, 'Project Alpha'),
(2, 'Project Beta'),
(3, 'Project Gamma'),
(4, 'Project Delta'),
(5, 'Project Epsilon'),
(6, 'Project Zeta'),
(7, 'Project Eta'),
(8, 'Project Theta'),
(9, 'Project Iota'),
(10, 'Project Kappa');

INSERT INTO Employees_Projects_Roles (employee_id, project_id, role) VALUES
(1, 1, 'Developer'),
(1, 2, 'Tester'),
(2, 1, 'Manager'),
(2, 3, 'Developer'),
(3, 2, 'Developer'),
(3, 4, 'Tester'),
(4, 3, 'Manager'),
(4, 5, 'Developer'),
(5, 4, 'Developer'),
(5, 6, 'Tester'),
(6, 5, 'Manager'),
(6, 7, 'Developer'),
(7, 6, 'Developer'),
(7, 8, 'Tester'),
(8, 7, 'Manager'),
(8, 9, 'Developer'),
(9, 8, 'Developer'),
(9, 10, 'Tester'),
(10, 9, 'Manager'),
(10, 1, 'Developer');