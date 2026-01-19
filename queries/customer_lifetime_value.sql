-- Calculate customer lifetime value
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.acquisition_channel,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.quantity) AS total_items_purchased,
    ROUND(SUM(o.order_total), 2) AS lifetime_value,
    ROUND(AVG(o.order_total), 2) AS avg_order_value,
    MIN(o.order_date) AS first_purchase,
    MAX(o.order_date) AS last_purchase,
    MAX(o.order_date) - MIN(o.order_date) AS customer_tenure_days
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, customer_name, c.acquisition_channel
ORDER BY lifetime_value DESC
LIMIT 50;
