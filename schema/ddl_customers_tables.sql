-- BRONZE LAYER (RAW INGEST) 
-- Data arrives as-is and must not be cleaned
-- REQUIREMENTS
-- no constraints except a surrogate key
-- store timestamps as VARCHAR
-- include metadata for ingestion tracking
DROP TABLE IF EXISTS bronze_customers;

CREATE TABLE bronze_customers (
    bronze_id BIGINT AUTO_INCREMENT PRIMARY KEY, -- surrogate key
    customer_id VARCHAR(50), 
    customer_name VARCHAR(50),
    customer_email VARCHAR(100),
    customer_phone VARCHAR (25),
    source_system VARCHAR(50),
    ingest_batch_id VARCHAR(50),
    ingest_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- SILVER TABLE (CLEANED AND TRANSFORMED DATA)
-- silver_customers contains clean, typed, query ready customers from bronze_customers
DROP TABLE IF EXISTS silver_customers;

CREATE TABLE silver_customers (
    customer_id VARCHAR(50) NOT NULL,
    customer_name VARCHAR(50) NOT NULL,
    customer_email VARCHAR(100) NULL,
    customer_phone VARCHAR (25) NULL,
    source_system VARCHAR(50) NOT NULL,
    ingest_batch_id VARCHAR(50) NOT NULL,
    bronze_id BIGINT NOT NULL, -- lineage back to bronze layer
    silver_ingest_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (customer_id, source_system)
);

CREATE INDEX idx_silver_customers_email ON silver_customers(customer_email);
CREATE INDEX idx_silver_customers_source_system ON silver_customers(source_system);

-- REJECTS TABLE (FAILED INGESTION)
-- silver_customers_rejects table
DROP TABLE IF EXISTS silver_customers_rejects;

CREATE TABLE silver_customers_rejects (
    reject_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    bronze_id BIGINT NOT NULL,
    customer_id VARCHAR(50),
    customer_name VARCHAR(50),
    customer_email VARCHAR(100),
    customer_phone VARCHAR (25),
    source_system VARCHAR(50),
    ingest_batch_id VARCHAR(50),
    reject_reason VARCHAR(100) NOT NULL,
    reject_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_rejects_bronze_id ON silver_customers_rejects(bronze_id);
CREATE INDEX idx_rejects_reason ON silver_customers_rejects(reject_reason);