USE testing;

-- Order Analytics: Status distribution, AOV, order metrics
TRUNCATE TABLE gold_order_status_distribution;

INSERT INTO gold_order_status_distribution
(
    order_status,
    source_system,
    order_count,
    total_revenue,
    percentage_of_total
)
SELECT
    o.order_status,
    o.source_system,
    COUNT(*) AS order_count,
    COALESCE(SUM(oi.line_total), 0) AS total_revenue,
    NULL AS percentage_of_total
FROM silver_orders o
LEFT JOIN silver_order_items oi ON o.order_id = oi.order_id AND o.source_system = oi.source_system
WHERE o.order_status IS NOT NULL
GROUP BY o.order_status, o.source_system;

-- Calculate percentage of total
UPDATE gold_order_status_distribution osd
INNER JOIN (
    SELECT 
        source_system,
        SUM(order_count) AS total_orders
    FROM gold_order_status_distribution
    GROUP BY source_system
) totals ON osd.source_system = totals.source_system
SET osd.percentage_of_total = (osd.order_count / totals.total_orders) * 100;

TRUNCATE TABLE gold_order_metrics;

INSERT INTO gold_order_metrics
(
    source_system,
    total_orders,
    total_revenue,
    average_order_value,
    min_order_value,
    max_order_value,
    median_order_value
)
SELECT
    o.source_system,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COALESCE(SUM(oi.line_total), 0) AS total_revenue,
    CASE
        WHEN COUNT(DISTINCT o.order_id) > 0
        THEN COALESCE(SUM(oi.line_total), 0) / COUNT(DISTINCT o.order_id)
        ELSE NULL
    END AS average_order_value,
    MIN(order_totals.order_total) AS min_order_value,
    MAX(order_totals.order_total) AS max_order_value,
    NULL AS median_order_value
FROM silver_orders o
LEFT JOIN silver_order_items oi ON o.order_id = oi.order_id AND o.source_system = oi.source_system
LEFT JOIN (
    SELECT order_id, source_system, SUM(line_total) AS order_total
    FROM silver_order_items
    GROUP BY order_id, source_system
) order_totals ON o.order_id = order_totals.order_id AND o.source_system = order_totals.source_system
GROUP BY o.source_system;
