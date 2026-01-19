USE testing;

-- Gold Layer: Analytics-ready tables for business intelligence and reporting

-- Customer Analytics: CLV, order history, segmentation, purchase frequency
DROP TABLE IF EXISTS gold_customer_analytics;

CREATE TABLE gold_customer_analytics (
    customer_id VARCHAR(50) NOT NULL,
    source_system VARCHAR(50) NOT NULL,
    customer_name VARCHAR(50),
    customer_email VARCHAR(100),
    total_orders INT NOT NULL DEFAULT 0,
    total_revenue DECIMAL(12, 2) NOT NULL DEFAULT 0,
    customer_lifetime_value DECIMAL(12, 2) NOT NULL DEFAULT 0,
    average_order_value DECIMAL(10, 2) NULL,
    first_order_date DATETIME NULL,
    last_order_date DATETIME NULL,
    days_since_last_order INT NULL,
    purchase_frequency DECIMAL(10, 2) NULL,
    customer_segment VARCHAR(50) NULL,
    last_updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    PRIMARY KEY (customer_id, source_system)
);

CREATE INDEX idx_gold_customer_clv ON gold_customer_analytics(customer_lifetime_value);
CREATE INDEX idx_gold_customer_segment ON gold_customer_analytics(customer_segment);
CREATE INDEX idx_gold_customer_source ON gold_customer_analytics(source_system);

-- Product Analytics: Performance metrics, category sales, popularity rankings
DROP TABLE IF EXISTS gold_product_analytics;

CREATE TABLE gold_product_analytics (
    product_id VARCHAR(50) NOT NULL,
    source_system VARCHAR(50) NOT NULL,
    product_name VARCHAR(50),
    product_category VARCHAR(50),
    total_quantity_sold INT NOT NULL DEFAULT 0,
    total_revenue DECIMAL(12, 2) NOT NULL DEFAULT 0,
    total_orders INT NOT NULL DEFAULT 0,
    average_unit_price DECIMAL(10, 2) NULL,
    popularity_rank INT NULL,
    first_sale_date DATETIME NULL,
    last_sale_date DATETIME NULL,
    days_since_last_sale INT NULL,
    last_updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    PRIMARY KEY (product_id, source_system)
);

CREATE INDEX idx_gold_product_revenue ON gold_product_analytics(total_revenue);
CREATE INDEX idx_gold_product_category ON gold_product_analytics(product_category);
CREATE INDEX idx_gold_product_rank ON gold_product_analytics(popularity_rank);

DROP TABLE IF EXISTS gold_product_category_sales;

CREATE TABLE gold_product_category_sales (
    product_category VARCHAR(50) NOT NULL,
    source_system VARCHAR(50) NOT NULL,
    total_products INT NOT NULL DEFAULT 0,
    total_quantity_sold INT NOT NULL DEFAULT 0,
    total_revenue DECIMAL(12, 2) NOT NULL DEFAULT 0,
    average_product_price DECIMAL(10, 2) NULL,
    category_rank INT NULL,
    last_updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    PRIMARY KEY (product_category, source_system)
);

CREATE INDEX idx_gold_category_revenue ON gold_product_category_sales(total_revenue);

-- Order Analytics: Status distribution, AOV, order metrics
DROP TABLE IF EXISTS gold_order_status_distribution;

CREATE TABLE gold_order_status_distribution (
    order_status VARCHAR(30) NOT NULL,
    source_system VARCHAR(50) NOT NULL,
    order_count INT NOT NULL DEFAULT 0,
    total_revenue DECIMAL(12, 2) NOT NULL DEFAULT 0,
    percentage_of_total DECIMAL(5, 2) NULL,
    last_updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    PRIMARY KEY (order_status, source_system)
);

DROP TABLE IF EXISTS gold_order_metrics;

CREATE TABLE gold_order_metrics (
    source_system VARCHAR(50) NOT NULL,
    total_orders INT NOT NULL DEFAULT 0,
    total_revenue DECIMAL(12, 2) NOT NULL DEFAULT 0,
    average_order_value DECIMAL(10, 2) NULL,
    min_order_value DECIMAL(10, 2) NULL,
    max_order_value DECIMAL(10, 2) NULL,
    median_order_value DECIMAL(10, 2) NULL,
    last_updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    PRIMARY KEY (source_system)
);

-- Time-Series Analytics: Daily, monthly, quarterly aggregations
DROP TABLE IF EXISTS gold_daily_sales;

CREATE TABLE gold_daily_sales (
    sale_date DATE NOT NULL,
    source_system VARCHAR(50) NOT NULL,
    order_count INT NOT NULL DEFAULT 0,
    total_revenue DECIMAL(12, 2) NOT NULL DEFAULT 0,
    average_order_value DECIMAL(10, 2) NULL,
    total_items_sold INT NOT NULL DEFAULT 0,
    unique_customers INT NOT NULL DEFAULT 0,
    last_updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    PRIMARY KEY (sale_date, source_system)
);

CREATE INDEX idx_gold_daily_date ON gold_daily_sales(sale_date);
CREATE INDEX idx_gold_daily_revenue ON gold_daily_sales(total_revenue);

DROP TABLE IF EXISTS gold_monthly_revenue;

CREATE TABLE gold_monthly_revenue (
    year_and_month VARCHAR(7) NOT NULL,
    source_system VARCHAR(50) NOT NULL,
    order_count INT NOT NULL DEFAULT 0,
    total_revenue DECIMAL(12, 2) NOT NULL DEFAULT 0,
    average_order_value DECIMAL(10, 2) NULL,
    total_items_sold INT NOT NULL DEFAULT 0,
    unique_customers INT NOT NULL DEFAULT 0,
    revenue_growth DECIMAL(10, 2) NULL,
    last_updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    PRIMARY KEY (year_and_month, source_system)
);

CREATE INDEX idx_gold_monthly_ym ON gold_monthly_revenue(year_and_month);

DROP TABLE IF EXISTS gold_quarterly_metrics;

CREATE TABLE gold_quarterly_metrics (
    `year_quarter` VARCHAR(7) NOT NULL,
    source_system VARCHAR(50) NOT NULL,
    order_count INT NOT NULL DEFAULT 0,
    total_revenue DECIMAL(12, 2) NOT NULL DEFAULT 0,
    average_order_value DECIMAL(10, 2) NULL,
    total_items_sold INT NOT NULL DEFAULT 0,
    unique_customers INT NOT NULL DEFAULT 0,
    revenue_growth DECIMAL(10, 2) NULL,
    last_updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    PRIMARY KEY (`year_quarter`, source_system)
);

-- Sales Fact Table: Denormalized fact table for reporting
DROP TABLE IF EXISTS gold_sales_fact;

CREATE TABLE gold_sales_fact (
    fact_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(50) NOT NULL,
    order_item_id VARCHAR(50) NOT NULL,
    order_date DATE NOT NULL,
    source_system VARCHAR(50) NOT NULL,
    customer_id VARCHAR(50),
    customer_name VARCHAR(50),
    customer_segment VARCHAR(50),
    product_id VARCHAR(50),
    product_name VARCHAR(50),
    product_category VARCHAR(50),
    order_status VARCHAR(30),
    quantity INT,
    unit_price DECIMAL(10, 2),
    line_total DECIMAL(10, 2),
    order_total DECIMAL(10, 2),
    year_and_month VARCHAR(7),
    year_and_quarter VARCHAR(7),
    last_updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE INDEX idx_gold_fact_date ON gold_sales_fact(order_date);
CREATE INDEX idx_gold_fact_customer ON gold_sales_fact(customer_id, source_system);
CREATE INDEX idx_gold_fact_product ON gold_sales_fact(product_id, source_system);
CREATE INDEX idx_gold_fact_category ON gold_sales_fact(product_category);
CREATE INDEX idx_gold_fact_source ON gold_sales_fact(source_system);
CREATE INDEX idx_gold_fact_ym ON gold_sales_fact(year_and_month);
