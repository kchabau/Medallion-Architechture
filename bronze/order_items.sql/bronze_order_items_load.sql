TRUNCATE TABLE bronze_order_items;

INSERT INTO bronze_order_items
(order_item_id, order_id, product_id, quantity, unit_price, source_system, ingest_ts, ingest_batch_id)
SELECT
  CONCAT('OI-', LPAD(b.bronze_id, 6, '0'))                                  AS order_item_id,
  b.order_id                                                                AS order_id,
  CONCAT('PROD-', LPAD((MOD(b.bronze_id, 200) + 1), 3, '0'))                AS product_id,
  '1'                                                                       AS quantity,
  b.order_amount                                                            AS unit_price,
  b.source_system                                                           AS source_system,
  CURRENT_TIMESTAMP                                                         AS ingest_ts,
  CONCAT('items_', COALESCE(b.ingest_batch_id, 'default_batch'))            AS ingest_batch_id
FROM bronze_orders b
WHERE (b.order_id IS NOT NULL AND TRIM(b.order_id) <> '')
  AND (b.source_system IS NOT NULL AND TRIM(b.source_system) <> '');
