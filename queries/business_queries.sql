-- Which products generate the most revenue?
SELECT 
    p.product_name,
    p.category,
    COUNT(o.order_id) AS total_orders,
    SUM(o.quantity) AS units_sold,
    SUM(o.order_total) AS total_revenue,
    ROUND(AVG(o.order_total), 2) AS avg_order_value
FROM orders o
INNER JOIN products p ON o.product_id = p.product_id
GROUP BY p.product_name, p.category
ORDER BY total_revenue DESC
LIMIT 10;
