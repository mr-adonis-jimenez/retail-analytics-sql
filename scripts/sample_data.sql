-- =========================
-- Sample Data for Retail Analytics
-- Matches schema/schema.sql (customers, products, orders)
-- =========================

-- Insert Customers
INSERT INTO customers (customer_id, first_name, last_name, email, signup_date, acquisition_channel) VALUES
(1, 'Sarah', 'Johnson', 'sarah.j@email.com', '2020-01-15', 'Organic'),
(2, 'Michael', 'Chen', 'mchen@email.com', '2020-03-22', 'Paid Search'),
(3, 'Emily', 'Rodriguez', 'emily.r@email.com', '2019-11-10', 'Referral'),
(4, 'James', 'Wilson', 'jwilson@email.com', '2021-02-14', 'Email'),
(5, 'Lisa', 'Anderson', 'lisa.a@email.com', '2020-07-08', 'Social Media'),
(6, 'David', 'Martinez', 'dmartinez@email.com', '2021-01-20', 'Direct'),
(7, 'Jennifer', 'Taylor', 'jtaylor@email.com', '2020-09-15', 'Organic'),
(8, 'Robert', 'Brown', 'rbrown@email.com', '2019-12-03', 'Paid Search'),
(9, 'Maria', 'Garcia', 'mgarcia@email.com', '2021-03-10', 'Referral'),
(10, 'William', 'Lee', 'wlee@email.com', '2020-05-25', 'Email');

-- Insert Products
INSERT INTO products (product_id, product_name, category, price) VALUES
(1, 'Laptop Pro 15', 'Electronics', 1299.99),
(2, 'Wireless Mouse', 'Electronics', 29.99),
(3, 'USB-C Cable', 'Electronics', 19.99),
(4, 'Desk Chair Ergonomic', 'Furniture', 349.99),
(5, 'Standing Desk', 'Furniture', 599.99),
(6, 'Monitor 27"', 'Electronics', 399.99),
(7, 'Keyboard Mechanical', 'Electronics', 149.99),
(8, 'Desk Lamp LED', 'Furniture', 79.99),
(9, 'Webcam HD', 'Electronics', 89.99),
(10, 'Bookshelf', 'Furniture', 199.99);

-- Insert Orders
INSERT INTO orders (order_id, customer_id, product_id, quantity, order_date, order_total) VALUES
(1, 1, 1, 1, '2024-01-15', 1299.99),
(2, 2, 2, 2, '2024-01-15', 59.98),
(3, 3, 4, 1, '2024-01-16', 349.99),
(4, 1, 6, 1, '2024-01-16', 399.99),
(5, 4, 5, 1, '2024-01-17', 599.99),
(6, 5, 7, 1, '2024-01-17', 149.99),
(7, 6, 3, 3, '2024-01-18', 59.97),
(8, 7, 8, 1, '2024-01-18', 79.99),
(9, 8, 1, 1, '2024-01-19', 1299.99),
(10, 9, 9, 2, '2024-01-19', 179.98);
