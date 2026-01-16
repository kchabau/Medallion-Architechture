TRUNCATE TABLE silver_customers_rejects;

INSERT INTO silver_customers_rejects
(
  bronze_id,
  customer_id,
  customer_name,
  customer_email,
  customer_phone,
  source_system,
  ingest_batch_id,
  reject_reason
)
SELECT
  b.bronze_id,
  b.customer_id,
  b.customer_name,
  b.customer_email,
  b.customer_phone,
  b.source_system,
  b.ingest_batch_id,
  CASE
    WHEN ((b.customer_id IS NULL OR b.customer_id = '') AND (b.source_system IS NULL OR b.source_system = ''))
      THEN 'missing_customer_id_and_source_system'
    WHEN (b.customer_id IS NULL OR b.customer_id = '')
      THEN 'missing_customer_id'
    WHEN (b.source_system IS NULL OR b.source_system = '')
      THEN 'missing_source_system'
    ELSE NULL
  END AS reject_reason
FROM bronze_customers b
WHERE
  ((b.customer_id IS NULL OR b.customer_id = '') AND (b.source_system IS NULL OR b.source_system = ''))
  OR (b.customer_id IS NULL OR b.customer_id = '')
  OR (b.source_system IS NULL OR b.source_system = '');