-- Segment customers based on purchase behavior
SELECT 
    c.acquisition_channel AS segment,
    COUNT(DISTINCT c.customer_id) AS customer_count,
    COUNT(o.order_id) AS total_orders,
    ROUND(AVG(o.order_total), 2) AS avg_order_value,
    ROUND(SUM(o.order_total), 2) AS total_revenue,
    ROUND(SUM(o.order_total) / COUNT(DISTINCT c.customer_id), 2) AS avg_customer_value
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.acquisition_channel
ORDER BY total_revenue DESC;
