SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE silver_products;
SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO silver_products
(product_id, product_name, product_category, product_price, source_system, ingest_batch_id, bronze_id)
SELECT
  b.product_id,
  UPPER(b.product_name) AS product_name,
  CONCAT(UCASE(LEFT(b.product_category, 1)), LCASE(SUBSTRING(b.product_category, 2))) AS product_category,
  CASE
    WHEN b.product_price REGEXP '^-?[0-9]+(\.[0-9]+)?$'
      THEN CAST(b.product_price AS DECIMAL(10, 2))
    ELSE NULL
  END AS product_price,
  b.source_system,
  b.ingest_batch_id,
  b.bronze_id
FROM bronze_products b
WHERE b.product_id IS NOT NULL AND b.product_id <> ''
  AND b.product_name IS NOT NULL AND b.product_name <> ''
  AND b.product_category IS NOT NULL AND b.product_category <> ''
  AND b.product_price IS NOT NULL AND b.product_price <> ''
  AND b.source_system IS NOT NULL AND b.source_system <> '';