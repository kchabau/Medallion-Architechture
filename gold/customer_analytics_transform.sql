USE testing;

-- Customer Analytics: CLV, order history, segmentation, purchase frequency/recency
TRUNCATE TABLE gold_customer_analytics;

INSERT INTO gold_customer_analytics
(
    customer_id,
    source_system,
    customer_name,
    customer_email,
    total_orders,
    total_revenue,
    customer_lifetime_value,
    average_order_value,
    first_order_date,
    last_order_date,
    days_since_last_order,
    purchase_frequency,
    customer_segment
)
SELECT
    c.customer_id,
    c.source_system,
    c.customer_name,
    c.customer_email,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COALESCE(SUM(oi.line_total), 0) AS total_revenue,
    COALESCE(SUM(oi.line_total), 0) AS customer_lifetime_value,
    CASE 
        WHEN COUNT(DISTINCT o.order_id) > 0 
        THEN COALESCE(SUM(oi.line_total), 0) / COUNT(DISTINCT o.order_id)
        ELSE NULL 
    END AS average_order_value,
    MIN(o.order_ts) AS first_order_date,
    MAX(o.order_ts) AS last_order_date,
    DATEDIFF(CURDATE(), MAX(o.order_ts)) AS days_since_last_order,
    CASE
        WHEN DATEDIFF(MAX(o.order_ts), MIN(o.order_ts)) > 0
        THEN COUNT(DISTINCT o.order_id) / (DATEDIFF(MAX(o.order_ts), MIN(o.order_ts)) / 30.0)
        ELSE NULL
    END AS purchase_frequency,
    CASE
        WHEN COALESCE(SUM(oi.line_total), 0) >= 1000 THEN 'High Value'
        WHEN COALESCE(SUM(oi.line_total), 0) >= 500 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment
FROM silver_customers c
LEFT JOIN silver_orders o ON c.customer_id = o.customer_id AND c.source_system = o.source_system
LEFT JOIN silver_order_items oi ON o.order_id = oi.order_id AND o.source_system = oi.source_system
GROUP BY c.customer_id, c.source_system, c.customer_name, c.customer_email;
