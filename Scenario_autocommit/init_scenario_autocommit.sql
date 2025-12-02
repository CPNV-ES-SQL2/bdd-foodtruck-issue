DROP DATABASE IF EXISTS bank;
CREATE DATABASE bank;
USE bank;

-- Création des tables
CREATE TABLE customers (
    id   INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE cards (
    id           INT PRIMARY KEY,
    customer_id  INT NOT NULL,
    status       ENUM('active', 'blocked') NOT NULL,
    limit_amount INT NOT NULL,
    CONSTRAINT fk_cards_customer
       FOREIGN KEY (customer_id) REFERENCES customers(id)
) ENGINE=InnoDB;

-- 5 clients

INSERT INTO customers (id, name) VALUES
     (1, 'Alice'),
     (2, 'Bob'),
     (3, 'Charlie'),
     (4, 'David'),
     (5, 'Emma');

-- 5 cartes associées (1 carte par client)
INSERT INTO cards (id, customer_id, status, limit_amount) VALUES
    (1, 1, 'active', 2000),
    (2, 2, 'active', 1500),
    (3, 3, 'active', 3000),
    (4, 4, 'blocked', 1000);

SELECT id, name  FROM customers;
SELECT id, customer_id, status, limit_amount FROM cards;