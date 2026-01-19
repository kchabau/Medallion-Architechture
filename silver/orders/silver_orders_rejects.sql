TRUNCATE TABLE silver_orders_rejects;

INSERT INTO silver_orders_rejects
(
  bronze_id,
  order_id,
  customer_id,
  order_amount,
  order_status,
  order_ts,
  source_system,
  ingest_batch_id,
  reject_reason
)
SELECT
  b.bronze_id,
  b.order_id,
  b.customer_id,
  b.order_amount,
  b.order_status,
  b.order_ts,
  b.source_system,
  b.ingest_batch_id,
  CASE
    WHEN ((b.order_id IS NULL OR b.order_id = '') AND (b.source_system IS NULL OR b.source_system = ''))
      THEN 'missing_order_id_and_source_system' 
    WHEN (b.order_id IS NULL OR b.order_id = '')
      THEN 'missing_order_id'
    WHEN (b.source_system IS NULL OR b.source_system = '')
      THEN 'missing_source_system'
    WHEN (b.customer_id IS NULL OR b.customer_id = '')
      THEN 'missing_customer_id'
    ELSE NULL
  END AS reject_reason
FROM bronze_orders b
WHERE
  ((b.order_id IS NULL OR b.order_id = '') AND (b.source_system IS NULL OR b.source_system = ''))
  OR (b.order_id IS NULL OR b.order_id = '')
  OR (b.source_system IS NULL OR b.source_system = '')
  OR (b.customer_id IS NULL OR b.customer_id = '');
