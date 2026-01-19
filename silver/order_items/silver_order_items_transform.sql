SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE silver_order_items;
SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO silver_order_items
(order_item_id, order_id, product_id, quantity, unit_price, line_total, source_system, ingest_batch_id, bronze_id)
SELECT
  b.order_item_id,
  b.order_id,
  b.product_id,
  -- Only cast quantity if it is a valid integer, else set to NULL
  CASE 
    WHEN b.quantity REGEXP '^-?[0-9]+$'
      THEN CAST(b.quantity AS SIGNED)
    ELSE NULL
  END AS quantity,
  -- Only cast unit_price if it is a valid decimal, else set to NULL
  CASE
    WHEN b.unit_price REGEXP '^-?[0-9]+(\\.[0-9]+)?$'
      THEN CAST(b.unit_price AS DECIMAL(10,2))
    ELSE NULL
  END AS unit_price,
  -- Only calculate line_total if both are valid, else NULL
  CASE
    WHEN b.quantity REGEXP '^-?[0-9]+$' AND b.unit_price REGEXP '^-?[0-9]+(\\.[0-9]+)?$'
      THEN CAST(b.quantity AS SIGNED) * CAST(b.unit_price AS DECIMAL(10,2))
    ELSE NULL
  END AS line_total,
  b.source_system,
  b.ingest_batch_id,
  b.bronze_id
FROM bronze_order_items b
-- Validate foreign key to silver_orders: ensure order exists
INNER JOIN silver_orders so 
  ON b.order_id = so.order_id 
  AND b.source_system = so.source_system
-- Validate foreign key to silver_products: ensure product exists
INNER JOIN silver_products sp 
  ON b.product_id = sp.product_id 
  AND b.source_system = sp.source_system
WHERE b.order_item_id IS NOT NULL AND b.order_item_id <> ''
  AND b.order_id IS NOT NULL AND b.order_id <> ''
  AND b.product_id IS NOT NULL AND b.product_id <> ''
  AND b.source_system IS NOT NULL AND b.source_system <> '';