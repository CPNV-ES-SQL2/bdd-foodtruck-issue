-- Delete database if it exists
DROP DATABASE IF EXISTS demo_db;

-- Create database
CREATE DATABASE demo_db;
USE demo_db;

-- Table: users
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(150) UNIQUE
);

-- Table: products
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) UNIQUE,
    price DECIMAL(10,2)
);

-- Table: orders (junction table)
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT DEFAULT 1,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Insert dummy users
INSERT INTO users (first_name, last_name, email) VALUES
('Alice', 'Johnson', 'alice@example.com'),
('Bob', 'Smith', 'bob@example.com'),
('Charlie', 'Lee', 'charlie@example.com');

-- Insert products
INSERT INTO products (name, price) VALUES
('Laptop', 1200.00),
('Mouse', 25.50),
('Keyboard', 45.00),
('Monitor', 300.00);

-- Insert orders
INSERT INTO orders (user_id, product_id, quantity) VALUES
(1, 3, 2),   -- Alice buys 2 Keyboards
(2, 1, 1),   -- Bob buys 1 Laptop
(2, 4, 3),   -- Bob buys 3 Monitors
(3, 2, 4),   -- Charlie buys 4 Mice
(3, 1, 1),   -- Charlie buys 1 Laptop
(1, 4, 2);   -- Alice buys 2 Monitors
