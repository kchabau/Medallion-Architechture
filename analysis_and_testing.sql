-- inspecting for duplicates
WITH duplicates AS (
    SELECT
        order_id,
        COUNT(*) AS duplicate_count
    FROM testing.bronze_orders
    GROUP BY order_id
    HAVING duplicate_count > 1
)

SELECT
    order_id,
    duplicate_count,
    SUM(duplicate_count) OVER () AS total_duplicates
FROM duplicates;

