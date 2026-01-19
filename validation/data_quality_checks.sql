-- =========================
-- Data Quality Checks
-- Retail Analytics Database
-- =========================

-- Run these queries regularly to ensure data integrity

-- =========================
-- 1. REFERENTIAL INTEGRITY CHECKS
-- =========================

-- Check for orphaned orders (customer doesn't exist)
SELECT 
    'Orphaned Orders - Invalid Customer' AS check_name,
    COUNT(*) AS issue_count,
    ARRAY_AGG(o.order_id) AS problematic_records
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL
GROUP BY check_name
HAVING COUNT(*) > 0;

-- Check for orphaned orders (product doesn't exist)
SELECT 
    'Orphaned Orders - Invalid Product' AS check_name,
    COUNT(*) AS issue_count,
    ARRAY_AGG(o.order_id) AS problematic_records
FROM orders o
LEFT JOIN products p ON o.product_id = p.product_id
WHERE p.product_id IS NULL
GROUP BY check_name
HAVING COUNT(*) > 0;

-- =========================
-- 2. DATA VALIDATION CHECKS
-- =========================

-- Check for negative or zero quantities
SELECT 
    'Invalid Quantity' AS check_name,
    COUNT(*) AS issue_count,
    ARRAY_AGG(order_id) AS problematic_records
FROM orders
WHERE quantity <= 0
GROUP BY check_name
HAVING COUNT(*) > 0;

-- Check for negative or zero prices
SELECT 
    'Invalid Product Price' AS check_name,
    COUNT(*) AS issue_count,
    ARRAY_AGG(product_id) AS problematic_records
FROM products
WHERE price <= 0
GROUP BY check_name
HAVING COUNT(*) > 0;

-- Check for negative order totals
SELECT 
    'Negative Order Total' AS check_name,
    COUNT(*) AS issue_count,
    ARRAY_AGG(order_id) AS problematic_records
FROM orders
WHERE order_total < 0
GROUP BY check_name
HAVING COUNT(*) > 0;

-- =========================
-- 3. BUSINESS LOGIC CHECKS
-- =========================

-- Check for order_total mismatch (should equal quantity * price)
SELECT 
    'Order Total Mismatch' AS check_name,
    COUNT(*) AS issue_count,
    ARRAY_AGG(o.order_id) AS problematic_records
FROM orders o
JOIN products p ON o.product_id = p.product_id
WHERE ABS(o.order_total - (o.quantity * p.price)) > 0.01
GROUP BY check_name
HAVING COUNT(*) > 0;

-- Check for orders before customer signup date
SELECT 
    'Order Before Customer Signup' AS check_name,
    COUNT(*) AS issue_count,
    ARRAY_AGG(o.order_id) AS problematic_records
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_date < c.signup_date
GROUP BY check_name
HAVING COUNT(*) > 0;

-- Check for future dates
SELECT 
    'Future Order Dates' AS check_name,
    COUNT(*) AS issue_count,
    ARRAY_AGG(order_id) AS problematic_records
FROM orders
WHERE order_date > CURRENT_DATE
GROUP BY check_name
HAVING COUNT(*) > 0;

-- Check for future customer signup dates
SELECT 
    'Future Signup Dates' AS check_name,
    COUNT(*) AS issue_count,
    ARRAY_AGG(customer_id) AS problematic_records
FROM customers
WHERE signup_date > CURRENT_DATE
GROUP BY check_name
HAVING COUNT(*) > 0;

-- =========================
-- 4. DUPLICATE CHECKS
-- =========================

-- Check for duplicate customer emails
SELECT 
    'Duplicate Customer Emails' AS check_name,
    COUNT(*) AS issue_count,
    ARRAY_AGG(email) AS problematic_records
FROM (
    SELECT email
    FROM customers
    GROUP BY email
    HAVING COUNT(*) > 1
) duplicates
GROUP BY check_name
HAVING COUNT(*) > 0;

-- Check for duplicate product names in same category
SELECT 
    'Duplicate Products in Category' AS check_name,
    COUNT(*) AS issue_count,
    ARRAY_AGG(category || ': ' || product_name) AS problematic_records
FROM (
    SELECT category, product_name
    FROM products
    GROUP BY category, product_name
    HAVING COUNT(*) > 1
) duplicates
GROUP BY check_name
HAVING COUNT(*) > 0;

-- =========================
-- 5. DATA COMPLETENESS CHECKS
-- =========================

-- Check for NULL values in required fields
SELECT 
    'NULL Values in Customers' AS check_name,
    COUNT(*) AS issue_count
FROM customers
WHERE first_name IS NULL 
   OR last_name IS NULL 
   OR email IS NULL 
   OR signup_date IS NULL 
   OR acquisition_channel IS NULL
GROUP BY check_name
HAVING COUNT(*) > 0;

SELECT 
    'NULL Values in Products' AS check_name,
    COUNT(*) AS issue_count
FROM products
WHERE product_name IS NULL 
   OR category IS NULL 
   OR price IS NULL
GROUP BY check_name
HAVING COUNT(*) > 0;

-- =========================
-- 6. STATISTICAL ANOMALY CHECKS
-- =========================

-- Check for unusually large orders (>3 standard deviations from mean)
WITH order_stats AS (
    SELECT 
        AVG(order_total) AS mean_total,
        STDDEV(order_total) AS stddev_total
    FROM orders
)
SELECT 
    'Abnormally Large Orders' AS check_name,
    COUNT(*) AS issue_count,
    ARRAY_AGG(order_id) AS problematic_records
FROM orders o
CROSS JOIN order_stats
WHERE o.order_total > (order_stats.mean_total + 3 * order_stats.stddev_total)
GROUP BY check_name
HAVING COUNT(*) > 0;

-- Check for customers with suspicious order patterns (>50 orders in one day)
SELECT 
    'Suspicious Order Volume' AS check_name,
    COUNT(*) AS issue_count,
    ARRAY_AGG(customer_id || ' on ' || order_date) AS problematic_records
FROM (
    SELECT customer_id, order_date, COUNT(*) as order_count
    FROM orders
    GROUP BY customer_id, order_date
    HAVING COUNT(*) > 50
) suspicious
GROUP BY check_name
HAVING COUNT(*) > 0;

-- =========================
-- 7. SUMMARY REPORT
-- =========================

-- Overall data quality summary
SELECT 
    'Total Customers' AS metric,
    COUNT(*) AS count
FROM customers

UNION ALL

SELECT 
    'Total Products',
    COUNT(*)
FROM products

UNION ALL

SELECT 
    'Total Orders',
    COUNT(*)
FROM orders

UNION ALL

SELECT 
    'Date Range (Orders)',
    CONCAT(MIN(order_date)::TEXT, ' to ', MAX(order_date)::TEXT)
FROM orders

UNION ALL

SELECT 
    'Total Revenue',
    ROUND(SUM(order_total), 2)::TEXT
FROM orders;
