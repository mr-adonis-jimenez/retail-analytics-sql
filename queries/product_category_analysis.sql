-- Rank products within categories by performance
SELECT 
    p.category,
    p.product_name,
    COUNT(sa.sale_id) AS sales_count,
    SUM(sa.quantity) AS units_sold,
    ROUND(SUM(sa.quantity * p.unit_price * (1 - sa.discount_percent/100)), 2) AS revenue,
    RANK() OVER (PARTITION BY p.category ORDER BY SUM(sa.quantity * p.unit_price * (1 - sa.discount_percent/100)) DESC) AS revenue_rank,
    ROUND(AVG(p.unit_price), 2) AS avg_price
FROM products p
INNER JOIN sales sa ON p.product_id = sa.product_id
GROUP BY p.category, p.product_name
ORDER BY p.category, revenue_rank;