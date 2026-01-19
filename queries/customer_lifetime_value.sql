-- Calculate customer lifetime value with segmentation
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.customer_segment,
    COUNT(DISTINCT sa.sale_id) AS total_orders,
    SUM(sa.quantity) AS total_items_purchased,
    ROUND(SUM(sa.quantity * p.unit_price * (1 - sa.discount_percent/100)), 2) AS lifetime_value,
    ROUND(AVG(sa.quantity * p.unit_price * (1 - sa.discount_percent/100)), 2) AS avg_order_value,
    MIN(sa.sale_date) AS first_purchase,
    MAX(sa.sale_date) AS last_purchase,
    DATEDIFF(MAX(sa.sale_date), MIN(sa.sale_date)) AS customer_tenure_days
FROM customers c
INNER JOIN sales sa ON c.customer_id = sa.customer_id
INNER JOIN products p ON sa.product_id = p.product_id
GROUP BY c.customer_id, customer_name, c.customer_segment
HAVING lifetime_value > 0
ORDER BY lifetime_value DESC;