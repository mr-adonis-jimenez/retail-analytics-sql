-- Analyze customer behavior by segment
SELECT 
    c.customer_segment,
    COUNT(DISTINCT c.customer_id) AS customer_count,
    COUNT(sa.sale_id) AS total_orders,
    ROUND(AVG(order_value.order_total), 2) AS avg_order_value,
    ROUND(SUM(sa.quantity * p.unit_price * (1 - sa.discount_percent/100)), 2) AS total_revenue,
    ROUND(SUM(sa.quantity * p.unit_price * (1 - sa.discount_percent/100)) / 
          COUNT(DISTINCT c.customer_id), 2) AS avg_customer_value
FROM customers c
INNER JOIN sales sa ON c.customer_id = sa.customer_id
INNER JOIN products p ON sa.product_id = p.product_id
INNER JOIN (
    SELECT 
        sale_id,
        SUM(quantity * unit_price * (1 - discount_percent/100)) AS order_total
    FROM sales sa2
    INNER JOIN products p2 ON sa2.product_id = p2.product_id
    GROUP BY sale_id
) order_value ON sa.sale_id = order_value.sale_id
GROUP BY c.customer_segment
ORDER BY total_revenue DESC;