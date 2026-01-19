-- Analyze sales trends over time
SELECT 
    DATE_FORMAT(sa.sale_date, '%Y-%m') AS month,
    COUNT(DISTINCT sa.sale_id) AS transactions,
    SUM(sa.quantity) AS units_sold,
    ROUND(SUM(sa.quantity * p.unit_price * (1 - sa.discount_percent/100)), 2) AS revenue,
    ROUND(AVG(sa.quantity * p.unit_price * (1 - sa.discount_percent/100)), 2) AS avg_transaction,
    COUNT(DISTINCT sa.customer_id) AS unique_customers,
    LAG(SUM(sa.quantity * p.unit_price * (1 - sa.discount_percent/100))) 
        OVER (ORDER BY DATE_FORMAT(sa.sale_date, '%Y-%m')) AS prev_month_revenue,
    ROUND(
        ((SUM(sa.quantity * p.unit_price * (1 - sa.discount_percent/100)) - 
          LAG(SUM(sa.quantity * p.unit_price * (1 - sa.discount_percent/100))) 
              OVER (ORDER BY DATE_FORMAT(sa.sale_date, '%Y-%m'))) /
         NULLIF(LAG(SUM(sa.quantity * p.unit_price * (1 - sa.discount_percent/100))) 
              OVER (ORDER BY DATE_FORMAT(sa.sale_date, '%Y-%m')), 0)) * 100, 
    2) AS revenue_growth_percent
FROM sales sa
INNER JOIN products p ON sa.product_id = p.product_id
GROUP BY month
ORDER BY month;