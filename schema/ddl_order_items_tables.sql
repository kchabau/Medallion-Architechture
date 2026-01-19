-- BRONZE LAYER (RAW INGEST)
-- Data arrives as-is and must not be cleaned
-- REQUIREMENTS
-- no constraints except a surrogate key 
-- store timestamps as VARCHAR
-- include metadata for ingestion tracking
DROP TABLE IF EXISTS bronze_order_items;

CREATE TABLE bronze_order_items (
    bronze_id BIGINT AUTO_INCREMENT PRIMARY KEY, -- surrogate key
    order_item_id VARCHAR(50),
    order_id VARCHAR(50),
    product_id VARCHAR(50),
    quantity VARCHAR(50),
    unit_price VARCHAR(50),
    source_system VARCHAR(50),
    ingest_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ingest_batch_id VARCHAR(50) -- batch identifier
);

-- SILVER TABLE (CLEANED AND TRANSFORMED DATA)
-- silver_order_items contains clean, typed, query ready order items from bronze_order_items
DROP TABLE IF EXISTS silver_order_items;

CREATE TABLE silver_order_items (
    order_item_id VARCHAR(50) NOT NULL,
    order_id VARCHAR(50) NOT NULL,
    product_id VARCHAR(50) NOT NULL,
    quantity INT NULL, 
    unit_price DECIMAL(10, 2) NULL,
    line_total DECIMAL(10, 2) NULL,
    source_system VARCHAR(50) NOT NULL,
    ingest_batch_id VARCHAR(50) NOT NULL,
    bronze_id BIGINT NOT NULL, -- lineage back to bronze layer
    silver_ingest_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (order_item_id, source_system)
);

CREATE INDEX idx_silver_order_items_order_id ON silver_order_items(order_id);
CREATE INDEX idx_silver_order_items_product_id ON silver_order_items(product_id);
