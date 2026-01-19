USE testing;

TRUNCATE TABLE bronze_products;

INSERT INTO bronze_products
(product_id, product_name, product_category, product_price, source_system, ingest_batch_id)
SELECT DISTINCT
  oi.product_id,

  -- messy names on purpose (some lower, some upper-ish)
  CASE
    WHEN MOD(CAST(REPLACE(oi.product_id, 'PROD-', '') AS UNSIGNED), 7) = 0
      THEN LOWER(CONCAT('product ', oi.product_id))
    WHEN MOD(CAST(REPLACE(oi.product_id, 'PROD-', '') AS UNSIGNED), 7) = 1
      THEN UPPER(CONCAT('PRODUCT ', oi.product_id))
    ELSE CONCAT('Product ', oi.product_id)
  END AS product_name,

  -- deterministic category buckets
  CASE MOD(CAST(REPLACE(oi.product_id, 'PROD-', '') AS UNSIGNED), 6)
    WHEN 0 THEN 'electronics'
    WHEN 1 THEN 'Home'
    WHEN 2 THEN 'beauty'
    WHEN 3 THEN 'Sports'
    WHEN 4 THEN 'toys'
    ELSE 'Grocery'
  END AS product_category,

  oi.unit_price AS product_price,        -- <-- GUARANTEED MATCH
  oi.source_system AS source_system,
  CONCAT('prod_from_', oi.ingest_batch_id) AS ingest_batch_id
FROM bronze_order_items oi
WHERE oi.product_id IS NOT NULL AND oi.product_id <> ''
  AND oi.source_system IS NOT NULL AND oi.source_system <> '';
