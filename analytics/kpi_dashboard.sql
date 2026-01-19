-- =========================
-- KPI Dashboard
-- Business Intelligence Metrics
-- =========================

-- =========================
-- 1. MONTHLY PERFORMANCE METRICS
-- =========================

WITH monthly_metrics AS (
    SELECT 
        TO_CHAR(order_date, 'YYYY-MM') AS month,
        COUNT(DISTINCT customer_id) AS active_customers,
        COUNT(DISTINCT order_id) AS total_orders,
        SUM(order_total) AS revenue,
        AVG(order_total) AS avg_order_value,
        SUM(quantity) AS total_units_sold
    FROM orders
    WHERE order_date >= CURRENT_DATE - INTERVAL '12 months'
    GROUP BY month
)
SELECT 
    month,
    active_customers,
    total_orders,
    ROUND(revenue::NUMERIC, 2) AS revenue,
    ROUND(avg_order_value::NUMERIC, 2) AS avg_order_value,
    ROUND((revenue / active_customers)::NUMERIC, 2) AS revenue_per_customer,
    total_units_sold,
    ROUND((total_units_sold::NUMERIC / total_orders), 2) AS units_per_order,
    ROUND(
        ((revenue - LAG(revenue) OVER (ORDER BY month)) / 
        NULLIF(LAG(revenue) OVER (ORDER BY month), 0) * 100)::NUMERIC, 
        2
    ) AS mom_revenue_growth_pct,
    ROUND(
        ((active_customers - LAG(active_customers) OVER (ORDER BY month))::NUMERIC / 
        NULLIF(LAG(active_customers) OVER (ORDER BY month), 0) * 100), 
        2
    ) AS mom_customer_growth_pct
FROM monthly_metrics
ORDER BY month DESC;

-- =========================
-- 2. CUSTOMER COHORT ANALYSIS
-- =========================

-- Customer acquisition by channel with lifetime value
SELECT 
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(AVG(customer_orders.order_count)::NUMERIC, 2) AS avg_orders_per_customer,
    ROUND(SUM(o.order_total)::NUMERIC, 2) AS total_revenue,
    ROUND(AVG(customer_revenue.lifetime_value)::NUMERIC, 2) AS avg_customer_ltv,
    ROUND((SUM(o.order_total) / NULLIF(COUNT(DISTINCT c.customer_id), 0))::NUMERIC, 2) AS revenue_per_customer
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN (
    SELECT customer_id, COUNT(*) as order_count
    FROM orders
    GROUP BY customer_id
) customer_orders ON c.customer_id = customer_orders.customer_id
LEFT JOIN (
    SELECT customer_id, SUM(order_total) as lifetime_value
    FROM orders
    GROUP BY customer_id
) customer_revenue ON c.customer_id = customer_revenue.customer_id
GROUP BY c.acquisition_channel
ORDER BY total_revenue DESC;

-- =========================
-- 3. PRODUCT PERFORMANCE
-- =========================

-- Top performing products by revenue
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    COUNT(DISTINCT o.order_id) AS times_ordered,
    SUM(o.quantity) AS total_units_sold,
    ROUND(SUM(o.order_total)::NUMERIC, 2) AS total_revenue,
    ROUND(AVG(o.order_total)::NUMERIC, 2) AS avg_order_value,
    ROUND((SUM(o.order_total) / SUM(SUM(o.order_total)) OVER () * 100)::NUMERIC, 2) AS revenue_share_pct,
    RANK() OVER (ORDER BY SUM(o.order_total) DESC) AS revenue_rank
FROM products p
INNER JOIN orders o ON p.product_id = o.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_revenue DESC
LIMIT 20;

-- Category performance comparison
SELECT 
    p.category,
    COUNT(DISTINCT p.product_id) AS product_count,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.quantity) AS total_units_sold,
    ROUND(SUM(o.order_total)::NUMERIC, 2) AS total_revenue,
    ROUND(AVG(o.order_total)::NUMERIC, 2) AS avg_order_value,
    ROUND((SUM(o.order_total) / COUNT(DISTINCT o.order_id))::NUMERIC, 2) AS revenue_per_order,
    ROUND((SUM(o.order_total) / SUM(SUM(o.order_total)) OVER () * 100)::NUMERIC, 2) AS revenue_share_pct
FROM products p
INNER JOIN orders o ON p.product_id = o.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;

-- =========================
-- 4. CUSTOMER SEGMENTATION
-- =========================

-- RFM Analysis (Recency, Frequency, Monetary)
WITH customer_rfm AS (
    SELECT 
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        c.email,
        c.acquisition_channel,
        CURRENT_DATE - MAX(o.order_date) AS recency_days,
        COUNT(DISTINCT o.order_id) AS frequency,
        ROUND(SUM(o.order_total)::NUMERIC, 2) AS monetary_value
    FROM customers c
    INNER JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name, c.email, c.acquisition_channel
),
rfm_scores AS (
    SELECT 
        *,
        NTILE(5) OVER (ORDER BY recency_days) AS r_score,
        NTILE(5) OVER (ORDER BY frequency DESC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary_value DESC) AS m_score
    FROM customer_rfm
)
SELECT 
    customer_id,
    customer_name,
    email,
    acquisition_channel,
    recency_days,
    frequency,
    monetary_value,
    r_score,
    f_score,
    m_score,
    (r_score + f_score + m_score) AS rfm_total_score,
    CASE 
        WHEN (r_score + f_score + m_score) >= 13 THEN 'Champions'
        WHEN (r_score + f_score + m_score) >= 10 THEN 'Loyal Customers'
        WHEN (r_score + f_score + m_score) >= 7 THEN 'Potential Loyalists'
        WHEN (r_score + f_score + m_score) >= 5 THEN 'At Risk'
        ELSE 'Lost'
    END AS customer_segment
FROM rfm_scores
ORDER BY rfm_total_score DESC, monetary_value DESC;

-- Customer segment distribution
WITH rfm_segments AS (
    SELECT 
        c.customer_id,
        CURRENT_DATE - MAX(o.order_date) AS recency_days,
        COUNT(DISTINCT o.order_id) AS frequency,
        SUM(o.order_total) AS monetary_value,
        NTILE(5) OVER (ORDER BY CURRENT_DATE - MAX(o.order_date)) AS r_score,
        NTILE(5) OVER (ORDER BY COUNT(DISTINCT o.order_id) DESC) AS f_score,
        NTILE(5) OVER (ORDER BY SUM(o.order_total) DESC) AS m_score
    FROM customers c
    INNER JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id
)
SELECT 
    CASE 
        WHEN (r_score + f_score + m_score) >= 13 THEN 'Champions'
        WHEN (r_score + f_score + m_score) >= 10 THEN 'Loyal Customers'
        WHEN (r_score + f_score + m_score) >= 7 THEN 'Potential Loyalists'
        WHEN (r_score + f_score + m_score) >= 5 THEN 'At Risk'
        ELSE 'Lost'
    END AS segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(monetary_value)::NUMERIC, 2) AS avg_lifetime_value,
    ROUND(SUM(monetary_value)::NUMERIC, 2) AS total_revenue,
    ROUND((COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER () * 100), 2) AS pct_of_customers
FROM rfm_segments
GROUP BY segment
ORDER BY total_revenue DESC;

-- =========================
-- 5. BUSINESS HEALTH METRICS
-- =========================

-- Overall business summary
SELECT 
    'Total Revenue' AS metric,
    TO_CHAR(ROUND(SUM(order_total)::NUMERIC, 2), 'FM$999,999,999.00') AS value
FROM orders

UNION ALL

SELECT 
    'Total Orders',
    TO_CHAR(COUNT(DISTINCT order_id), 'FM999,999,999')
FROM orders

UNION ALL

SELECT 
    'Total Customers',
    TO_CHAR(COUNT(DISTINCT customer_id), 'FM999,999,999')
FROM customers

UNION ALL

SELECT 
    'Average Order Value',
    TO_CHAR(ROUND(AVG(order_total)::NUMERIC, 2), 'FM$999,999,999.00')
FROM orders

UNION ALL

SELECT 
    'Average Customer LTV',
    TO_CHAR(
        ROUND((SUM(o.order_total) / COUNT(DISTINCT o.customer_id))::NUMERIC, 2), 
        'FM$999,999,999.00'
    )
FROM orders o

UNION ALL

SELECT 
    'Repeat Customer Rate',
    TO_CHAR(
        ROUND(
            (COUNT(DISTINCT CASE WHEN order_count > 1 THEN customer_id END)::NUMERIC / 
            NULLIF(COUNT(DISTINCT customer_id), 0) * 100), 
            2
        ), 
        'FM990.00'
    ) || '%'
FROM (
    SELECT customer_id, COUNT(*) as order_count
    FROM orders
    GROUP BY customer_id
) customer_orders

UNION ALL

SELECT 
    'Total Products',
    TO_CHAR(COUNT(*), 'FM999,999,999')
FROM products;
