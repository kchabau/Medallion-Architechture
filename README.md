# Medallion Architecture - Orders Pipeline

A practical implementation of the Medallion Architecture pattern for data engineering, demonstrating how to structure and process data through bronze (raw), silver (cleaned), and reject layers using MySQL.

## Overview

This project showcases a real-world approach to implementing the Medallion Architecture pattern, commonly used in data engineering pipelines. The architecture separates data into distinct layers, each serving a specific purpose in the data transformation journey:

- **Bronze Layer**: Raw, unprocessed data ingested as-is from source systems
- **Silver Layer**: Cleaned, validated, and transformed data ready for analytics
- **Rejects Layer**: Records that fail validation rules, tracked for data quality monitoring

## Development Environment

### Database

- **MySQL Workbench** (8.0+)
- Database: `testing`

### IDE Setup

While MySQL Workbench is used for database management, development is done using:

- **VS Code** with the **SQL Connector Tool Extension**
- This setup allows connecting to the MySQL instance directly from VS Code without needing to keep MySQL Workbench open, making it easier to work on a single screen and improving development workflow

## Project Structure

```
Medallion Architecture/
├── schema/
│   └── ddl_orders_tables.sql          # Table definitions for all layers
├── bronze/
│   └── bronze_orders_load.sql         # Raw data ingestion
├── silver/
│   ├── silver_orders_transform.sql    # Data cleaning and transformation
│   └── silver_orders_rejects.sql      # Rejected records handling
└── README.md
```

## Architecture Layers

### Bronze Layer (`bronze_orders`)

- **Purpose**: Store raw, unprocessed data exactly as received from source systems
- **Characteristics**:
  - No data validation or cleaning
  - All fields stored as VARCHAR to preserve original format
  - Includes metadata: `ingest_ts`, `ingest_batch_id`, `bronze_id` (surrogate key)
  - Minimal constraints (only surrogate key)

### Silver Layer (`silver_orders`)

- **Purpose**: Clean, validated, and typed data ready for analytics
- **Characteristics**:
  - Data type conversion (amounts to DECIMAL, timestamps to DATETIME)
  - Data quality validation (required fields, format checks)
  - Deduplication logic (keeps most recent record per `order_id` + `source_system`)
  - Proper constraints and indexes for query performance
  - Lineage tracking back to bronze via `bronze_id`

### Rejects Layer (`silver_orders_rejects`)

- **Purpose**: Track records that fail validation rules
- **Characteristics**:
  - Captures all rejected records from bronze
  - Includes rejection reason for data quality monitoring
  - Maintains full record details for troubleshooting

## Execution Order

**Important**: Execute the SQL files in the following order to ensure proper setup and data flow:

### 1. Schema Setup

```sql
-- Run: schema/ddl_orders_tables.sql
```

- Creates the `testing` database (if needed)
- Creates all three tables: `bronze_orders`, `silver_orders`, and `silver_orders_rejects`
- Sets up indexes for optimal query performance

### 2. Bronze Layer - Data Ingestion

```sql
-- Run: bronze/bronze_orders_load.sql
```

- Loads raw order data into the bronze layer
- Includes sample data with various formats and edge cases
- Contains intentionally invalid data to demonstrate validation logic

### 3. Silver Layer - Data Transformation

```sql
-- Run: silver/silver_orders_transform.sql
```

- Transforms and cleans data from bronze to silver
- Applies data type conversions
- Validates required fields
- Handles deduplication using business logic (most recent record wins)
- Implements upsert logic for handling updates

### 4. Silver Layer - Rejects Processing

```sql
-- Run: silver/silver_orders_rejects.sql
```

- Identifies and moves invalid records to the rejects table
- Categorizes rejection reasons for monitoring
- Should be run after transformation to capture all validation failures

## Key Features Demonstrated

### Data Type Handling

- **Amounts**: Validates numeric format and converts to DECIMAL(10,2)
- **Timestamps**: Supports multiple formats:
  - ISO 8601: `2023-01-01T09:00:00Z`
  - Standard: `2023-01-01 09:00:00`
  - Slash format: `2023/01/01 10:00` or `2023/01/01 10:00:00`
  - Dash format: `01-15-2023 13:00:00` (MM-DD-YYYY)

### Deduplication Strategy

- Uses `ROW_NUMBER()` with partitioning by `(order_id, source_system)`
- Orders by:
  1. Business timestamp (`order_ts`) - most recent first
  2. Ingestion timestamp (`ingest_ts`) - fallback for tie-breaking
  3. Bronze ID (`bronze_id`) - deterministic final tie-breaker

### Upsert Logic

- Uses `ON DUPLICATE KEY UPDATE` to handle record updates
- Only updates if incoming record is newer (by timestamp or bronze_id)
- Preserves existing data when incoming data is older

### Validation Rules

Records are rejected if:

- Both `order_id` AND `source_system` are missing
- `order_id` is missing
- `source_system` is missing
- `customer_id` is missing

## Use Cases

This implementation demonstrates:

- **Data Quality**: How to handle dirty data and track quality issues
- **Data Lineage**: Tracking data from source through transformations
- **Incremental Processing**: Handling updates and deduplication
- **Error Handling**: Capturing and categorizing data quality issues
- **Production Patterns**: Real-world approaches used in data engineering roles

## Notes

- The `bronze_orders_load.sql` file includes test data with various edge cases
- Some records are intentionally invalid to demonstrate validation and rejection logic
- The last 10 records in the bronze load file are designed to test the upsert/update logic
- All timestamps in bronze are stored as VARCHAR to preserve original format

## Contributing

This is a learning project designed to showcase medallion architecture patterns. Feel free to use this as a reference or starting point for your own implementations.
