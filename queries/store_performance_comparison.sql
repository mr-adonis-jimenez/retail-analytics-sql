-- Compare performance across customer acquisition channels
SELECT 
    c.acquisition_channel,
    COUNT(DISTINCT o.order_id) AS total_transactions,
    COUNT(DISTINCT c.customer_id) AS unique_customers,
    SUM(o.quantity) AS total_units_sold,
    ROUND(SUM(o.order_total), 2) AS total_revenue,
    ROUND(AVG(o.order_total), 2) AS avg_transaction_value,
    ROUND(SUM(o.order_total) / COUNT(DISTINCT c.customer_id), 2) AS revenue_per_customer
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.acquisition_channel
ORDER BY total_revenue DESC;
