-- Insert Stores
INSERT INTO stores VALUES
(1, 'Downtown Flagship', 'New York', 'NY', 'Northeast', '2018-01-15'),
(2, 'Westside Mall', 'Los Angeles', 'CA', 'West', '2019-03-20'),
(3, 'River District', 'Chicago', 'IL', 'Midwest', '2017-06-10'),
(4, 'Tech Quarter', 'Austin', 'TX', 'South', '2020-02-01'),
(5, 'Harbor View', 'Seattle', 'WA', 'West', '2018-11-30');

-- Insert Products
INSERT INTO products VALUES
(101, 'Laptop Pro 15', 'Electronics', 'Computers', 1299.99, 850.00),
(102, 'Wireless Mouse', 'Electronics', 'Accessories', 29.99, 12.00),
(103, 'USB-C Cable', 'Electronics', 'Accessories', 19.99, 5.00),
(104, 'Desk Chair Ergonomic', 'Furniture', 'Office', 349.99, 180.00),
(105, 'Standing Desk', 'Furniture', 'Office', 599.99, 320.00),
(106, 'Monitor 27"', 'Electronics', 'Displays', 399.99, 220.00),
(107, 'Keyboard Mechanical', 'Electronics', 'Accessories', 149.99, 65.00),
(108, 'Desk Lamp LED', 'Furniture', 'Lighting', 79.99, 30.00),
(109, 'Webcam HD', 'Electronics', 'Accessories', 89.99, 40.00),
(110, 'Bookshelf', 'Furniture', 'Storage', 199.99, 95.00);

-- Insert Customers (sample)
INSERT INTO customers VALUES
(1001, 'Sarah', 'Johnson', 'sarah.j@email.com', 'New York', 'NY', '2020-01-15', 'Premium'),
(1002, 'Michael', 'Chen', 'mchen@email.com', 'Los Angeles', 'CA', '2020-03-22', 'Standard'),
(1003, 'Emily', 'Rodriguez', 'emily.r@email.com', 'Chicago', 'IL', '2019-11-10', 'Premium'),
(1004, 'James', 'Wilson', 'jwilson@email.com', 'Austin', 'TX', '2021-02-14', 'Standard'),
(1005, 'Lisa', 'Anderson', 'lisa.a@email.com', 'Seattle', 'WA', '2020-07-08', 'Premium'),
(1006, 'David', 'Martinez', 'dmartinez@email.com', 'New York', 'NY', '2021-01-20', 'Standard'),
(1007, 'Jennifer', 'Taylor', 'jtaylor@email.com', 'Los Angeles', 'CA', '2020-09-15', 'Budget'),
(1008, 'Robert', 'Brown', 'rbrown@email.com', 'Chicago', 'IL', '2019-12-03', 'Premium'),
(1009, 'Maria', 'Garcia', 'mgarcia@email.com', 'Austin', 'TX', '2021-03-10', 'Standard'),
(1010, 'William', 'Lee', 'wlee@email.com', 'Seattle', 'WA', '2020-05-25', 'Budget');

-- Insert Sales (sample - you'd generate more)
INSERT INTO sales VALUES
(5001, '2024-01-15', 1001, 1, 101, 1, 5.00),
(5002, '2024-01-15', 1002, 2, 102, 2, 0.00),
(5003, '2024-01-16', 1003, 3, 104, 1, 10.00),
(5004, '2024-01-16', 1001, 1, 106, 1, 0.00),
(5005, '2024-01-17', 1004, 4, 105, 1, 15.00),
(5006, '2024-01-17', 1005, 5, 107, 1, 0.00),
(5007, '2024-01-18', 1006, 1, 103, 3, 5.00),
(5008, '2024-01-18', 1007, 2, 108, 1, 20.00),
(5009, '2024-01-19', 1008, 3, 101, 1, 5.00),
(5010, '2024-01-19', 1009, 4, 109, 2, 10.00);

-- Insert Inventory
INSERT INTO inventory (store_id, product_id, stock_quantity, last_restock_date) VALUES
(1, 101, 15, '2024-01-01'),
(1, 102, 50, '2024-01-01'),
(1, 103, 100, '2024-01-01'),
(2, 101, 12, '2024-01-01'),
(2, 104, 8, '2024-01-01'),
(3, 105, 5, '2024-01-01'),
(4, 106, 20, '2024-01-01'),
(5, 107, 25, '2024-01-01');