USE testing;

-- Product Analytics: Performance metrics, category sales, popularity rankings
TRUNCATE TABLE gold_product_analytics;

INSERT INTO gold_product_analytics
(
    product_id,
    source_system,
    product_name,
    product_category,
    total_quantity_sold,
    total_revenue,
    total_orders,
    average_unit_price,
    popularity_rank,
    first_sale_date,
    last_sale_date,
    days_since_last_sale
)
SELECT
    p.product_id,
    p.source_system,
    p.product_name,
    p.product_category,
    COALESCE(SUM(oi.quantity), 0) AS total_quantity_sold,
    COALESCE(SUM(oi.line_total), 0) AS total_revenue,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    CASE
        WHEN COALESCE(SUM(oi.quantity), 0) > 0
        THEN COALESCE(SUM(oi.line_total), 0) / SUM(oi.quantity)
        ELSE NULL
    END AS average_unit_price,
    NULL AS popularity_rank,
    MIN(o.order_ts) AS first_sale_date,
    MAX(o.order_ts) AS last_sale_date,
    DATEDIFF(CURDATE(), MAX(o.order_ts)) AS days_since_last_sale
FROM silver_products p
LEFT JOIN silver_order_items oi ON p.product_id = oi.product_id AND p.source_system = oi.source_system
LEFT JOIN silver_orders o ON oi.order_id = o.order_id AND oi.source_system = o.source_system
GROUP BY p.product_id, p.source_system, p.product_name, p.product_category;

-- Update popularity rank
UPDATE gold_product_analytics gpa
INNER JOIN (
    SELECT 
        product_id,
        source_system,
        ROW_NUMBER() OVER (PARTITION BY source_system ORDER BY total_revenue DESC) AS popularity_rank
    FROM gold_product_analytics
    ) ranked ON gpa.product_id = ranked.product_id AND gpa.source_system = ranked.source_system
SET gpa.popularity_rank = ranked.popularity_rank;

TRUNCATE TABLE gold_product_category_sales;

INSERT INTO gold_product_category_sales
(
    product_category,
    source_system,
    total_products,
    total_quantity_sold,
    total_revenue,
    average_product_price,
    category_rank
)
SELECT
    p.product_category,
    p.source_system,
    COUNT(DISTINCT p.product_id) AS total_products,
    COALESCE(SUM(oi.quantity), 0) AS total_quantity_sold,
    COALESCE(SUM(oi.line_total), 0) AS total_revenue,
    CASE
        WHEN COUNT(DISTINCT p.product_id) > 0
        THEN COALESCE(SUM(oi.line_total), 0) / COUNT(DISTINCT p.product_id)
        ELSE NULL
    END AS average_product_price,
    NULL AS category_rank
FROM silver_products p
LEFT JOIN silver_order_items oi ON p.product_id = oi.product_id AND p.source_system = oi.source_system
GROUP BY p.product_category, p.source_system;

-- Update category rank
UPDATE gold_product_category_sales gpcs
INNER JOIN (
    SELECT 
        product_category,
        source_system,
        ROW_NUMBER() OVER (PARTITION BY source_system ORDER BY total_revenue DESC) AS category_rank
    FROM gold_product_category_sales
    ) ranked ON gpcs.product_category = ranked.product_category AND gpcs.source_system = ranked.source_system
SET gpcs.category_rank = ranked.category_rank;
