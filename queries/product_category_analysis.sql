-- Rank products within categories by performance
SELECT 
    p.category,
    p.product_name,
    COUNT(o.order_id) AS sales_count,
    SUM(o.quantity) AS units_sold,
    ROUND(SUM(o.order_total), 2) AS revenue,
    RANK() OVER (PARTITION BY p.category ORDER BY SUM(o.order_total) DESC) AS revenue_rank,
    ROUND(AVG(p.price), 2) AS avg_price
FROM products p
INNER JOIN orders o ON p.product_id = o.product_id
GROUP BY p.category, p.product_name, p.price
ORDER BY p.category, revenue_rank;
