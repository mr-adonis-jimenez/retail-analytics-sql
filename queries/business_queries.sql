-- Which products generate the most revenue in each store?
SELECT 
    s.store_name,
    p.product_name,
    p.category,
    COUNT(sa.sale_id) AS total_sales,
    SUM(sa.quantity) AS units_sold,
    ROUND(SUM(sa.quantity * p.unit_price * (1 - sa.discount_percent/100)), 2) AS total_revenue,
    ROUND(AVG(p.unit_price * (1 - sa.discount_percent/100)), 2) AS avg_sale_price
FROM sales sa
INNER JOIN stores s ON sa.store_id = s.store_id
INNER JOIN products p ON sa.product_id = p.product_id
GROUP BY s.store_name, p.product_name, p.category
ORDER BY s.store_name, total_revenue DESC;