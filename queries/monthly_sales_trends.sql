-- Analyze monthly sales trends
SELECT 
    TO_CHAR(o.order_date, 'YYYY-MM') AS month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.quantity) AS units_sold,
    ROUND(SUM(o.order_total), 2) AS total_revenue,
    ROUND(AVG(o.order_total), 2) AS avg_transaction_value,
    COUNT(DISTINCT o.customer_id) AS unique_customers
FROM orders o
GROUP BY TO_CHAR(o.order_date, 'YYYY-MM')
ORDER BY month DESC;
