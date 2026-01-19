-- Find products frequently purchased together
SELECT 
    p1.product_name AS product_1,
    p2.product_name AS product_2,
    COUNT(*) AS times_purchased_together,
    ROUND(AVG(p1.unit_price + p2.unit_price), 2) AS avg_bundle_value
FROM sales s1
INNER JOIN sales s2 ON s1.customer_id = s2.customer_id 
    AND s1.sale_date = s2.sale_date 
    AND s1.product_id < s2.product_id
INNER JOIN products p1 ON s1.product_id = p1.product_id
INNER JOIN products p2 ON s2.product_id = p2.product_id
GROUP BY p1.product_name, p2.product_name
HAVING times_purchased_together > 1
ORDER BY times_purchased_together DESC;