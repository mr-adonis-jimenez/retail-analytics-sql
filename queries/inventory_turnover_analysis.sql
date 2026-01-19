-- Calculate inventory turnover and identify slow-moving products
SELECT 
    s.store_name,
    p.product_name,
    p.category,
    i.stock_quantity AS current_stock,
    COALESCE(SUM(sa.quantity), 0) AS units_sold,
    i.last_restock_date,
    DATEDIFF(CURDATE(), i.last_restock_date) AS days_since_restock,
    CASE 
        WHEN COALESCE(SUM(sa.quantity), 0) = 0 THEN 'No Sales'
        WHEN i.stock_quantity / NULLIF(SUM(sa.quantity), 0) > 10 THEN 'Overstocked'
        WHEN i.stock_quantity / NULLIF(SUM(sa.quantity), 0) < 2 THEN 'Low Stock'
        ELSE 'Optimal'
    END AS stock_status
FROM inventory i
INNER JOIN stores s ON i.store_id = s.store_id
INNER JOIN products p ON i.product_id = p.product_id
LEFT JOIN sales sa ON i.product_id = sa.product_id 
    AND i.store_id = sa.store_id 
    AND sa.sale_date >= i.last_restock_date
GROUP BY s.store_name, p.product_name, p.category, i.stock_quantity, i.last_restock_date
ORDER BY s.store_name, stock_status;