USE testing;

-- Time-Series Analytics: Daily, monthly, quarterly aggregations with growth metrics
TRUNCATE TABLE gold_daily_sales;
TRUNCATE TABLE gold_monthly_revenue;
TRUNCATE TABLE gold_quarterly_metrics;

INSERT INTO gold_daily_sales
(
    sale_date,
    source_system,
    order_count,
    total_revenue,
    average_order_value,
    total_items_sold,
    unique_customers
)
SELECT
    DATE(o.order_ts) AS sale_date,
    o.source_system,
    COUNT(DISTINCT o.order_id) AS order_count,
    COALESCE(SUM(oi.line_total), 0) AS total_revenue,
    CASE
        WHEN COUNT(DISTINCT o.order_id) > 0
        THEN COALESCE(SUM(oi.line_total), 0) / COUNT(DISTINCT o.order_id)
        ELSE NULL
    END AS average_order_value,
    COALESCE(SUM(oi.quantity), 0) AS total_items_sold,
    COUNT(DISTINCT o.customer_id) AS unique_customers
FROM silver_orders o
LEFT JOIN silver_order_items oi ON o.order_id = oi.order_id AND o.source_system = oi.source_system
WHERE o.order_ts IS NOT NULL
GROUP BY DATE(o.order_ts), o.source_system;

INSERT INTO gold_monthly_revenue
(
    year_and_month,
    source_system,
    order_count,
    total_revenue,
    average_order_value,
    total_items_sold,
    unique_customers,
    revenue_growth
)
SELECT
    DATE_FORMAT(o.order_ts, '%Y-%m') AS year_and_month,
    o.source_system,
    COUNT(DISTINCT o.order_id) AS order_count,
    COALESCE(SUM(oi.line_total), 0) AS total_revenue,
    CASE
        WHEN COUNT(DISTINCT o.order_id) > 0
        THEN COALESCE(SUM(oi.line_total), 0) / COUNT(DISTINCT o.order_id)
        ELSE NULL
    END AS average_order_value,
    COALESCE(SUM(oi.quantity), 0) AS total_items_sold,
    COUNT(DISTINCT o.customer_id) AS unique_customers,
    NULL AS revenue_growth
FROM silver_orders o
LEFT JOIN silver_order_items oi ON o.order_id = oi.order_id AND o.source_system = oi.source_system
WHERE o.order_ts IS NOT NULL
GROUP BY DATE_FORMAT(o.order_ts, '%Y-%m'), o.source_system;

-- Calculate month-over-month revenue growth
UPDATE gold_monthly_revenue current_month
JOIN gold_monthly_revenue previous_month
  ON current_month.source_system = previous_month.source_system
 AND current_month.year_and_month = DATE_FORMAT(
       DATE_ADD(
         STR_TO_DATE(CONCAT(previous_month.year_and_month, '-01'), '%Y-%m-%d'),
         INTERVAL 1 MONTH
       ),
       '%Y-%m'
     )
SET current_month.revenue_growth = CASE
    WHEN previous_month.total_revenue > 0
    THEN ((current_month.total_revenue - previous_month.total_revenue) / previous_month.total_revenue) * 100
    ELSE NULL
END;

INSERT INTO gold_quarterly_metrics
(
    year_quarter,
    source_system,
    order_count,
    total_revenue,
    average_order_value,
    total_items_sold,
    unique_customers,
    revenue_growth
)
SELECT
    CONCAT(YEAR(o.order_ts), '-Q', QUARTER(o.order_ts)) AS year_quarter,
    o.source_system,
    COUNT(DISTINCT o.order_id) AS order_count,
    COALESCE(SUM(oi.line_total), 0) AS total_revenue,
    CASE
        WHEN COUNT(DISTINCT o.order_id) > 0
        THEN COALESCE(SUM(oi.line_total), 0) / COUNT(DISTINCT o.order_id)
        ELSE NULL
    END AS average_order_value,
    COALESCE(SUM(oi.quantity), 0) AS total_items_sold,
    COUNT(DISTINCT o.customer_id) AS unique_customers,
    NULL AS revenue_growth
FROM silver_orders o
LEFT JOIN silver_order_items oi ON o.order_id = oi.order_id AND o.source_system = oi.source_system
WHERE o.order_ts IS NOT NULL
GROUP BY CONCAT(YEAR(o.order_ts), '-Q', QUARTER(o.order_ts)), o.source_system;
