-- Find products frequently purchased together by the same customers
SELECT 
    p1.product_name AS product_1,
    p2.product_name AS product_2,
    COUNT(*) AS times_purchased_together,
    ROUND(AVG(p1.price + p2.price), 2) AS avg_bundle_value
FROM orders o1
INNER JOIN orders o2 ON o1.customer_id = o2.customer_id 
    AND o1.product_id < o2.product_id
INNER JOIN products p1 ON o1.product_id = p1.product_id
INNER JOIN products p2 ON o2.product_id = p2.product_id
GROUP BY p1.product_name, p2.product_name
HAVING COUNT(*) > 1
ORDER BY times_purchased_together DESC
LIMIT 20;
