-- Compare store performance across regions
SELECT 
    s.region,
    s.store_name,
    s.city,
    COUNT(DISTINCT sa.sale_id) AS total_transactions,
    COUNT(DISTINCT sa.customer_id) AS unique_customers,
    SUM(sa.quantity) AS total_units_sold,
    ROUND(SUM(sa.quantity * p.unit_price * (1 - sa.discount_percent/100)), 2) AS total_revenue,
    ROUND(SUM((p.unit_price - p.cost) * sa.quantity * (1 - sa.discount_percent/100)), 2) AS total_profit,
    ROUND(AVG(sa.quantity * p.unit_price * (1 - sa.discount_percent/100)), 2) AS avg_transaction_value
FROM stores s
LEFT JOIN sales sa ON s.store_id = sa.store_id
LEFT JOIN products p ON sa.product_id = p.product_id
GROUP BY s.region, s.store_name, s.city
ORDER BY s.region, total_revenue DESC;