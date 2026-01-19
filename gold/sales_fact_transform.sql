USE testing;

-- Sales Fact Table: Denormalized fact table for reporting (orders + items + customers + products)
TRUNCATE TABLE gold_sales_fact;

INSERT INTO gold_sales_fact
(
    order_id,
    order_item_id,
    order_date,
    source_system,
    customer_id,
    customer_name,
    customer_segment,
    product_id,
    product_name,
    product_category,
    order_status,
    quantity,
    unit_price,
    line_total,
    order_total,
    year_and_month,
    year_and_quarter
)
SELECT
    o.order_id,
    oi.order_item_id,
    DATE(o.order_ts) AS order_date,
    o.source_system,
    o.customer_id,
    c.customer_name,
    CASE
        WHEN COALESCE(customer_totals.total_revenue, 0) >= 1000 THEN 'High Value'
        WHEN COALESCE(customer_totals.total_revenue, 0) >= 500 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment,
    oi.product_id,
    p.product_name,
    p.product_category,
    o.order_status,
    oi.quantity,
    oi.unit_price,
    oi.line_total,
    order_totals.order_total,
    DATE_FORMAT(o.order_ts, '%Y-%m') AS year_and_month,
    CONCAT(YEAR(o.order_ts), '-Q', QUARTER(o.order_ts)) AS year_and_quarter
FROM silver_order_items oi
INNER JOIN silver_orders o ON oi.order_id = o.order_id AND oi.source_system = o.source_system AND o.order_ts IS NOT NULL
INNER JOIN silver_customers c ON o.customer_id = c.customer_id AND o.source_system = c.source_system
INNER JOIN silver_products p ON oi.product_id = p.product_id AND oi.source_system = p.source_system
LEFT JOIN (
    SELECT o2.customer_id, o2.source_system, SUM(oi2.line_total) AS total_revenue
    FROM silver_order_items oi2
    INNER JOIN silver_orders o2 ON oi2.order_id = o2.order_id AND oi2.source_system = o2.source_system
    WHERE o2.order_ts IS NOT NULL
    GROUP BY o2.customer_id, o2.source_system
) customer_totals ON c.customer_id = customer_totals.customer_id AND c.source_system = customer_totals.source_system
LEFT JOIN (
    SELECT order_id, source_system, SUM(line_total) AS order_total
    FROM silver_order_items
    GROUP BY order_id, source_system
) order_totals ON o.order_id = order_totals.order_id AND o.source_system = order_totals.source_system;
