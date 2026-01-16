-- Temporarily disable foreign key checks to allow TRUNCATE
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE silver_orders;
SET FOREIGN_KEY_CHECKS = 1;

-- Insert only valid rows (not meeting the "reject" criteria) into silver_orders
INSERT INTO silver_orders
(order_id, source_system, customer_id, order_amount, order_status, order_ts, ingest_batch_id, bronze_id)
WITH parsed AS (
  SELECT
    b.bronze_id,
    b.order_id,
    b.source_system,
    b.customer_id,
    b.order_status,
    b.ingest_batch_id,
    b.ingest_ts,

    -- amount: keep only clean numeric (supports 123, 123.45)
    CASE
      WHEN b.order_amount REGEXP '^[0-9]+(\\.[0-9]{1,2})?$'
        THEN CAST(b.order_amount AS DECIMAL(10,2))
      ELSE NULL
    END AS order_amount_dec,

    -- timestamp parsing: try multiple formats (AVOID invalid STR_TO_DATE input)
    CASE
      -- 2023-01-01T09:00:00Z (ISO 8601) or 2023-01-01 09:00:00
      WHEN b.order_ts REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}[ T][0-9]{2}:[0-9]{2}:[0-9]{2}Z?$'
        THEN STR_TO_DATE(REPLACE(REPLACE(b.order_ts, 'T', ' '), 'Z', ''), '%Y-%m-%d %H:%i:%s')
      -- 2023/01/01 10:00 (slash format, only hour/minute, seconds missing: pad to :00)
      WHEN b.order_ts REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2} [0-9]{2}:[0-9]{2}$'
        THEN STR_TO_DATE(CONCAT(b.order_ts, ':00'), '%Y/%m/%d %H:%i:%s')
      -- 2023/01/01 10:00:00 (slash format, full to-seconds)
      WHEN b.order_ts REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$'
        THEN STR_TO_DATE(b.order_ts, '%Y/%m/%d %H:%i:%s')
      -- 01-01-2023 11:00:00 (dash, DD-MM-YYYY or MM-DD-YYYY - here we assume MM-DD-YYYY as input)
      WHEN b.order_ts REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4} [0-9]{2}:[0-9]{2}:[0-9]{2}$'
        THEN STR_TO_DATE(b.order_ts, '%m-%d-%Y %H:%i:%s')
      ELSE NULL
    END AS order_ts_dt
  FROM bronze_orders b
),
not_rejects AS (
  SELECT *
  FROM parsed
  WHERE NOT (
    -- Start rejection rules
    ((order_id IS NULL OR order_id = '') AND (source_system IS NULL OR source_system = ''))
    OR (order_id IS NULL OR order_id = '')
    OR (source_system IS NULL OR source_system = '')
    OR (customer_id IS NULL OR customer_id = '')
    -- End rejection rules
  )
),
ranked AS (
  SELECT
    nr.*,
    ROW_NUMBER() OVER (
      PARTITION BY nr.order_id, nr.source_system
      ORDER BY
        nr.order_ts_dt DESC,   -- business recency
        nr.ingest_ts DESC,     -- arrival time fallback
        nr.bronze_id DESC      -- deterministic tie-breaker
    ) AS rn
  FROM not_rejects nr
)
SELECT
  order_id,
  source_system,
  customer_id,
  order_amount_dec AS order_amount,
  order_status,
  order_ts_dt AS order_ts,
  ingest_batch_id,
  bronze_id
FROM ranked
WHERE rn = 1
ON DUPLICATE KEY UPDATE
  -- Update only if incoming is newer than existing
  customer_id = CASE
    WHEN (VALUES(order_ts) > silver_orders.order_ts)
      OR (silver_orders.order_ts IS NULL AND VALUES(order_ts) IS NOT NULL)
      OR (VALUES(order_ts) = silver_orders.order_ts AND VALUES(bronze_id) > silver_orders.bronze_id)
    THEN VALUES(customer_id) ELSE silver_orders.customer_id END,

  order_amount = CASE
    WHEN (VALUES(order_ts) > silver_orders.order_ts)
      OR (silver_orders.order_ts IS NULL AND VALUES(order_ts) IS NOT NULL)
      OR (VALUES(order_ts) = silver_orders.order_ts AND VALUES(bronze_id) > silver_orders.bronze_id)
    THEN VALUES(order_amount) ELSE silver_orders.order_amount END,

  order_status = CASE
    WHEN (VALUES(order_ts) > silver_orders.order_ts)
      OR (silver_orders.order_ts IS NULL AND VALUES(order_ts) IS NOT NULL)
      OR (VALUES(order_ts) = silver_orders.order_ts AND VALUES(bronze_id) > silver_orders.bronze_id)
    THEN VALUES(order_status) ELSE silver_orders.order_status END,

  order_ts = CASE
    WHEN (VALUES(order_ts) > silver_orders.order_ts)
      OR (silver_orders.order_ts IS NULL AND VALUES(order_ts) IS NOT NULL)
      OR (VALUES(order_ts) = silver_orders.order_ts AND VALUES(bronze_id) > silver_orders.bronze_id)
    THEN VALUES(order_ts) ELSE silver_orders.order_ts END,

  ingest_batch_id = CASE
    WHEN (VALUES(order_ts) > silver_orders.order_ts)
      OR (silver_orders.order_ts IS NULL AND VALUES(order_ts) IS NOT NULL)
      OR (VALUES(order_ts) = silver_orders.order_ts AND VALUES(bronze_id) > silver_orders.bronze_id)
    THEN VALUES(ingest_batch_id) ELSE silver_orders.ingest_batch_id END,

  bronze_id = CASE
    WHEN (VALUES(order_ts) > silver_orders.order_ts)
      OR (silver_orders.order_ts IS NULL AND VALUES(order_ts) IS NOT NULL)
      OR (VALUES(order_ts) = silver_orders.order_ts AND VALUES(bronze_id) > silver_orders.bronze_id)
    THEN VALUES(bronze_id) ELSE silver_orders.bronze_id END;
