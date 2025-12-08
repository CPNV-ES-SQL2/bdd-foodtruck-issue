CREATE DATABASE IF NOT EXISTS shop2;
USE shop2;

CREATE TABLE sales (
    id INT AUTO_INCREMENT PRIMARY KEY,
    shop VARCHAR(100) NOT NULL DEFAULT 'shop2',
    price DECIMAL(10,2) NOT NULL
)
ENGINE=Federated
CONNECTION='mysql://avnadmin:PASSWORD@mysql-db2-diogof648.f.aivencloud.com:23668/datawarehouse/sales';