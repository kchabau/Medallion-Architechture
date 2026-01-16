-- BRONZE LAYER (RAW INGEST)
-- Data arrives as-is and must not be cleaned
-- REQUIREMENTS
-- no constraints except a surrogate key 
-- store timestamps as VARCHAR
-- include metadata for ingestion tracking
DROP TABLE IF EXISTS bronze_orders;

CREATE TABLE bronze_orders (
    bronze_id BIGINT AUTO_INCREMENT PRIMARY KEY, -- surrogate key
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_amount VARCHAR(50),
    order_status VARCHAR(50),
    order_ts VARCHAR(50),
    source_system VARCHAR(50),
    ingest_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ingest_batch_id VARCHAR(50) -- batch identifier
);

-- SILVER TABLE (CLEANED AND TRANSFORMED DATA)
-- silver_orders contains clean, typed, query ready orders from bronze_orders
DROP TABLE IF EXISTS silver_orders;

CREATE TABLE silver_orders (
    order_id VARCHAR(50) NOT NULL,
    customer_id VARCHAR(50) NOT NULL,
    order_amount DECIMAL(10, 2) NULL, -- NULL IF NOT PARSABLE
    order_status VARCHAR (30) NULL,
    order_ts DATETIME NULL, -- NULL IF NOT PARSABLE
    source_system VARCHAR(50) NOT NULL,
    ingest_batch_id VARCHAR(50) NOT NULL,
    bronze_id BIGINT NOT NULL, -- lineage back to bronze layer
    silver_ingest_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (order_id, source_system)
);

-- FOREIGN KEYS
-- INDEXES
CREATE INDEX idx_silver_orders_order_ts ON silver_orders(order_ts);
CREATE INDEX idx_silver_orders_customer_id ON silver_orders(customer_id);

-- REJECTS TABLE (FAILED INGESTION)
-- silver_orders_rejects table
DROP TABLE IF EXISTS silver_orders_rejects;

CREATE TABLE silver_orders_rejects (
    reject_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    bronze_id BIGINT NOT NULL,
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_amount VARCHAR(50),
    order_status VARCHAR(30),
    order_ts VARCHAR(50),
    source_system VARCHAR(50),
    ingest_batch_id VARCHAR(50),
    reject_reason VARCHAR(100) NOT NULL,
    reject_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_rejects_bronze_id ON silver_orders_rejects(bronze_id);
CREATE INDEX idx_rejects_reason ON silver_orders_rejects(reject_reason);