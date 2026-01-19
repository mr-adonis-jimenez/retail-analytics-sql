-- Create Database
CREATE DATABASE retail_analytics;
USE retail_analytics;

-- 1. Stores Table
CREATE TABLE stores (
    store_id INT PRIMARY KEY,
    store_name VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(2),
    region VARCHAR(20),
    opened_date DATE
);

-- 2. Products Table
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    subcategory VARCHAR(50),
    unit_price DECIMAL(10, 2),
    cost DECIMAL(10, 2)
);

-- 3. Customers Table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(2),
    join_date DATE,
    customer_segment VARCHAR(20)
);

-- 4. Sales Table
CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    sale_date DATE,
    customer_id INT,
    store_id INT,
    product_id INT,
    quantity INT,
    discount_percent DECIMAL(5, 2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (store_id) REFERENCES stores(store_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 5. Inventory Table
CREATE TABLE inventory (
    inventory_id INT PRIMARY KEY AUTO_INCREMENT,
    store_id INT,
    product_id INT,
    stock_quantity INT,
    last_restock_date DATE,
    FOREIGN KEY (store_id) REFERENCES stores(store_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Drop for clean rebuild
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    signup_date DATE NOT NULL,
    acquisition_channel VARCHAR(50) NOT NULL
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price NUMERIC(10,2) NOT NULL CHECK (price > 0)
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    order_date DATE NOT NULL,
    order_total NUMERIC(10,2) NOT NULL CHECK (order_total >= 0),

    CONSTRAINT fk_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON DELETE RESTRICT
);
