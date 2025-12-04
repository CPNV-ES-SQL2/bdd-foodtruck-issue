DROP DATABASE IF EXISTS demo_db;

CREATE DATABASE demo_db;
USE demo_db;

CREATE TABLE users (
    id INT PRIMARY KEY,
    name VARCHAR(50),
    created_at DATETIME
);

CREATE TABLE products (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    price DECIMAL(10,2),
    category_id INT
);

CREATE TABLE orders (
    id INT PRIMARY KEY,
    user_id INT,
    created_at DATETIME,
    total_amount DECIMAL(10,2),
    INDEX(user_id),
    INDEX(created_at)
);

CREATE TABLE order_items (
    id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    INDEX(order_id),
    INDEX(product_id)
);

INSERT INTO users
SELECT
    n,
    CONCAT('User ', n),
    NOW() - INTERVAL (RAND()*365) DAY
FROM (
    SELECT @row:=@row+1 AS n
    FROM
        (SELECT 0 FROM information_schema.columns LIMIT 1000) t1,
        (SELECT 0 FROM information_schema.columns LIMIT 1000) t2,
        (SELECT @row:=0) t0
    LIMIT 1000000
) t;

INSERT INTO products
SELECT
    n,
    CONCAT('Product ', n),
    ROUND(RAND()*200, 2),
    FLOOR(1 + RAND()*20)
FROM (
    SELECT @row:=@row+1 AS n
    FROM
        (SELECT 0 FROM information_schema.columns LIMIT 1000) t1,
        (SELECT 0 FROM information_schema.columns LIMIT 1000) t2,
        (SELECT @row:=0) t0
    LIMIT 500000
) t;

INSERT INTO orders
SELECT
    n,
    FLOOR(1 + RAND()*10000),
    NOW() - INTERVAL (RAND()*365) DAY,
    ROUND(RAND()*500, 2)
FROM (
    SELECT @row:=@row+1 AS n
    FROM
        (SELECT 0 FROM information_schema.columns LIMIT 1000) t1,
        (SELECT 0 FROM information_schema.columns LIMIT 1000) t2,
        (SELECT @row:=0) t0
    LIMIT 500000
) t;

INSERT INTO order_items
SELECT
    n,
    FLOOR(1 + RAND()*50000),
    FLOOR(1 + RAND()*5000),
    FLOOR(1 + RAND()*5),
    ROUND(RAND()*200, 2)
FROM (
    SELECT @row:=@row+1 AS n
    FROM
        (SELECT 0 FROM information_schema.columns LIMIT 1000) t1,
        (SELECT 0 FROM information_schema.columns LIMIT 1000) t2,
        (SELECT @row:=0) t0
    LIMIT 2000000
) t;
