-- Temporarily disable foreign key checks to allow TRUNCATE
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE silver_customers;
SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO silver_customers 
(customer_id, customer_name, customer_email, customer_phone, source_system, ingest_batch_id, bronze_id)
SELECT
    b.customer_id,
    -- Title-case customer_name (first and last)
    CONCAT(
        UPPER(LEFT(TRIM(SUBSTRING_INDEX(TRIM(b.customer_name), ' ', 1)), 1)),
        LOWER(SUBSTRING(TRIM(SUBSTRING_INDEX(TRIM(b.customer_name), ' ', 1)), 2)),
        ' ',
        UPPER(LEFT(TRIM(SUBSTRING_INDEX(TRIM(b.customer_name), ' ', -1)), 1)),
        LOWER(SUBSTRING(TRIM(SUBSTRING_INDEX(TRIM(b.customer_name), ' ', -1)), 2))
    ) AS customer_name,
    -- Email validation: basic regex
    CASE
        WHEN b.customer_email REGEXP '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
            THEN b.customer_email
        ELSE NULL
    END AS customer_email,
    -- Phone: Accept all lengths, format digits to xxx-xxx-xxxx if possible; if not 12 chars after formatting, then NULL
    CASE
        WHEN LENGTH(
            CONCAT(
                SUBSTR(REGEXP_REPLACE(b.customer_phone, '[^0-9]', ''), 1, 3), '-',
                SUBSTR(REGEXP_REPLACE(b.customer_phone, '[^0-9]', ''), 4, 3), '-',
                SUBSTR(REGEXP_REPLACE(b.customer_phone, '[^0-9]', ''), 7, 4)
            )
        ) = 12
        THEN
            CONCAT(
                SUBSTR(REGEXP_REPLACE(b.customer_phone, '[^0-9]', ''), 1, 3), '-',
                SUBSTR(REGEXP_REPLACE(b.customer_phone, '[^0-9]', ''), 4, 3), '-',
                SUBSTR(REGEXP_REPLACE(b.customer_phone, '[^0-9]', ''), 7, 4)
            )
        ELSE NULL
    END AS customer_phone,
    b.source_system,
    b.ingest_batch_id,
    b.bronze_id
FROM bronze_customers b
WHERE
    b.customer_id IS NOT NULL AND b.customer_id != ''
    AND b.customer_name IS NOT NULL AND b.customer_name != ''
    AND b.source_system IS NOT NULL AND b.source_system != '';
