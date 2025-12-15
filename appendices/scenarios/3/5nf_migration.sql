CREATE TABLE Projects_Employees (
    project_employee_id INT AUTO_INCREMENT PRIMARY KEY,
    project_id INT,
    employee_id INT,
    UNIQUE (project_id, employee_id),
    FOREIGN KEY (project_id) REFERENCES Projects(project_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

CREATE TABLE Projects_Roles (
    project_role_id INT AUTO_INCREMENT PRIMARY KEY,
    project_id INT,
    role VARCHAR(100),
    UNIQUE (project_id, role),
    FOREIGN KEY (project_id) REFERENCES Projects(project_id)
);

CREATE TABLE Employees_Roles (
    employee_role_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT,
    project_role_id INT,
    UNIQUE (employee_id, project_role_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id),
    FOREIGN KEY (project_role_id) REFERENCES Projects_Roles(project_role_id)
);

INSERT INTO Projects_Employees (project_id, employee_id) SELECT DISTINCT project_id, employee_id FROM Employees_Projects_Roles;
INSERT INTO Projects_Roles (project_id, role) SELECT DISTINCT project_id, role FROM Employees_Projects_Roles;
INSERT INTO Employees_Roles (employee_id, project_role_id)
SELECT epr.employee_id, pr.project_role_id
FROM Employees_Projects_Roles epr
JOIN Projects_Roles pr ON epr.project_id = pr.project_id AND epr.role = pr.role;

DROP TABLE Employees_Projects_Roles;