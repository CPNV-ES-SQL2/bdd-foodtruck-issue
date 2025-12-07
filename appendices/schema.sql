-- MySQL Schema for Index Performance Demonstration
-- This schema creates a table to demonstrate the performance benefits of indexes
-- Drop the database if it exists
DROP DATABASE IF EXISTS index_demo;
-- Create the database
CREATE DATABASE index_demo;
-- Use the database
USE index_demo;
-- Create personas table with multiple columns for testing indexes
CREATE TABLE personas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(150),
    phone VARCHAR(20),
    address VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(50),
    zip_code VARCHAR(10),
    country VARCHAR(50),
    date_of_birth DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- Table will initially have NO indexes (except the primary key)
-- We will test different index configurations