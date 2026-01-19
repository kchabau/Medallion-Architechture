-- BRONZE LAYER (RAW INGEST)
-- Data arrives as-is and must not be cleaned
-- REQUIREMENTS
-- no constraints except a surrogate key 
-- store timestamps as VARCHAR
-- include metadata for ingestion tracking
DROP TABLE IF EXISTS bronze_products;

CREATE TABLE bronze_products (
    bronze_id BIGINT AUTO_INCREMENT PRIMARY KEY, -- surrogate key
    product_id VARCHAR(50),
    product_name VARCHAR(50),
    product_category VARCHAR(50),
    product_price VARCHAR(50),
    source_system VARCHAR(50),
    ingest_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ingest_batch_id VARCHAR(50) -- batch identifier
);

-- SILVER TABLE (CLEANED AND TRANSFORMED DATA)
-- silver_products contains clean, typed, query ready products from bronze_products
DROP TABLE IF EXISTS silver_products;

CREATE TABLE silver_products (
    product_id VARCHAR(50) NOT NULL,
    product_name VARCHAR(50) NOT NULL,
    product_category VARCHAR(50) NOT NULL,
    product_price DECIMAL(10, 2) NULL,
    source_system VARCHAR(50) NOT NULL,
    ingest_batch_id VARCHAR(50) NOT NULL,
    bronze_id BIGINT NOT NULL, -- lineage back to bronze layer
    silver_ingest_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (product_id, source_system)
);

-- INDEXES
CREATE INDEX idx_silver_products_category ON silver_products(product_category);
CREATE INDEX idx_silver_products_source_system ON silver_products(source_system);