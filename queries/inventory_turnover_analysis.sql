-- Analyze product sales performance
SELECT 
    p.product_name,
    p.category,
    p.price,
    COUNT(o.order_id) AS times_ordered,
    SUM(o.quantity) AS total_units_sold,
    ROUND(SUM(o.order_total), 2) AS total_revenue,
    MAX(o.order_date) AS last_order_date,
    EXTRACT(DAY FROM CURRENT_DATE - MAX(o.order_date)) AS days_since_last_order
FROM products p
LEFT JOIN orders o ON p.product_id = o.product_id
GROUP BY p.product_id, p.product_name, p.category, p.price
ORDER BY total_units_sold DESC;
