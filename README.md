# Medallion Architecture - E-Commerce Data Pipeline

A practical implementation of the Medallion Architecture pattern for data engineering, demonstrating how to structure and process data through bronze (raw), silver (cleaned), and reject layers using MySQL.

## Overview

This project showcases a real-world approach to implementing the Medallion Architecture pattern, commonly used in data engineering pipelines. The architecture separates data into distinct layers, each serving a specific purpose in the data transformation journey:

- **Bronze Layer**: Raw, unprocessed data ingested as-is from source systems
- **Silver Layer**: Cleaned, validated, and transformed data ready for analytics
- **Rejects Layer**: Records that fail validation rules, tracked for data quality monitoring

### Current Implementation Status

**Completed (2 of 4 planned tables):**

- ✅ **Orders**: Complete with transformation, validation, and rejection handling
- ✅ **Customers**: Complete with data cleaning, validation, and rejection handling
- ✅ **Foreign Keys**: Relationship between orders and customers established

**Planned:**

- ⏳ **Products**: Product master data table
- ⏳ **Order Items**: Line items linking orders to products

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
│   ├── database_creation.sql           # Database setup
│   ├── ddl_orders_tables.sql          # Orders table definitions (bronze, silver, rejects)
│   ├── ddl_customers_table.sql        # Customers table definitions (bronze, silver, rejects)
│   └── ddl_foreign_keys.sql           # Foreign key constraints
├── bronze/
│   ├── orders/
│   │   └── bronze_orders_load.sql     # Raw orders data ingestion
│   └── customers/
│       └── bronze_customers_load.sql   # Raw customers data ingestion
├── silver/
│   ├── orders/
│   │   ├── silver_orders_transform.sql    # Orders data cleaning and transformation
│   │   └── silver_orders_rejects.sql       # Rejected orders handling
│   └── customers/
│       ├── silver_customers_transform.sql  # Customers data cleaning and transformation
│       └── silver_customers_rejects.sql    # Rejected customers handling
├── next_steps.md                      # Implementation roadmap and progress
└── README.md
```

## Architecture Layers

### Bronze Layer

**Tables**: `bronze_orders`, `bronze_customers`

- **Purpose**: Store raw, unprocessed data exactly as received from source systems
- **Characteristics**:
  - No data validation or cleaning
  - All fields stored as VARCHAR to preserve original format
  - Includes metadata: `ingest_ts`, `ingest_batch_id`, `bronze_id` (surrogate key)
  - Minimal constraints (only surrogate key)
  - Supports multiple source systems (shopify, amazon, web)

### Silver Layer

**Tables**: `silver_orders`, `silver_customers`

- **Purpose**: Clean, validated, and typed data ready for analytics
- **Characteristics**:
  - Data type conversion (amounts to DECIMAL, timestamps to DATETIME)
  - Data quality validation (required fields, format checks)
  - Data cleaning (name formatting, phone formatting, email validation)
  - Deduplication logic (keeps most recent record per composite key)
  - Proper constraints and indexes for query performance
  - Foreign key relationships for referential integrity
  - Lineage tracking back to bronze via `bronze_id`
  - Composite primary keys: `(order_id, source_system)`, `(customer_id, source_system)`

### Rejects Layer

**Tables**: `silver_orders_rejects`, `silver_customers_rejects`

- **Purpose**: Track records that fail validation rules
- **Characteristics**:
  - Captures all rejected records from bronze
  - Includes rejection reason for data quality monitoring
  - Maintains full record details for troubleshooting
  - Indexed for efficient querying and reporting

## Execution Order

**Important**: Execute the SQL files in the following order to ensure proper setup and data flow. The order matters because of foreign key dependencies (orders reference customers).

### 1. Database Setup

```sql
-- Run: schema/database_creation.sql
```

- Creates the `testing` database
- Sets the active database context

### 2. Schema Setup - Tables

```sql
-- Run: schema/ddl_customers_table.sql
-- Run: schema/ddl_orders_tables.sql
-- Run: schema/ddl_foreign_keys.sql
```

**Order matters**: Customers must be created before orders due to foreign key dependency.

- Creates all bronze, silver, and reject tables
- Sets up indexes for optimal query performance
- Establishes foreign key relationships

### 3. Bronze Layer - Data Ingestion

**Execute in this order:**

```sql
-- Step 3a: Load customers first
-- Run: bronze/customers/bronze_customers_load.sql

-- Step 3b: Load orders second (depends on customers for FK validation)
-- Run: bronze/orders/bronze_orders_load.sql
```

- Loads raw data into bronze layer
- Includes sample data with various formats and edge cases
- Contains intentionally invalid data to demonstrate validation logic
- Customers must load before orders due to foreign key constraint

### 4. Silver Layer - Data Transformation

**Execute in this order:**

```sql
-- Step 4a: Transform customers first
-- Run: silver/customers/silver_customers_transform.sql

-- Step 4b: Transform orders second (requires customers to exist)
-- Run: silver/orders/silver_orders_transform.sql
```

**Customers Transformation:**

- Transforms and cleans customer data from bronze to silver
- Applies name title-casing (first and last name)
- Validates email format with regex
- Formats phone numbers (xxx-xxx-xxxx)
- Validates required fields (customer_id, customer_name, source_system)
- Handles deduplication using business logic

**Orders Transformation:**

- Transforms and cleans order data from bronze to silver
- Applies data type conversions (amounts to DECIMAL, timestamps to DATETIME)
- Multi-format timestamp parsing (ISO 8601, slash format, dash format)
- Validates required fields
- Validates foreign key to customers
- Handles deduplication using business logic (most recent record wins)
- Implements upsert logic for handling updates

### 5. Silver Layer - Rejects Processing

**Execute in this order:**

```sql
-- Step 5a: Process customer rejects
-- Run: silver/customers/silver_customers_rejects.sql

-- Step 5b: Process order rejects
-- Run: silver/orders/silver_orders_rejects.sql
```

- Identifies and moves invalid records to the rejects tables
- Categorizes rejection reasons for monitoring
- Should be run after transformation to capture all validation failures

## Key Features Demonstrated

### Data Type Handling

**Orders:**

- **Amounts**: Validates numeric format and converts to DECIMAL(10,2)
- **Timestamps**: Supports multiple formats:
  - ISO 8601: `2023-01-01T09:00:00Z`
  - Standard: `2023-01-01 09:00:00`
  - Slash format: `2023/01/01 10:00` or `2023/01/01 10:00:00`
  - Dash format: `01-15-2023 13:00:00` (MM-DD-YYYY)

**Customers:**

- **Names**: Title-cases first and last names (e.g., "JOHN DOE" → "John Doe")
- **Emails**: Validates format using regex pattern
- **Phones**: Formats to standard xxx-xxx-xxxx format, rejects invalid formats

### Deduplication Strategy

- Uses `ROW_NUMBER()` with partitioning by composite keys:
  - Orders: `(order_id, source_system)`
  - Customers: `(customer_id, source_system)`
- Orders by:
  1. Business timestamp (most recent first)
  2. Ingestion timestamp (fallback for tie-breaking)
  3. Bronze ID (deterministic final tie-breaker)

### Upsert Logic

- Uses `ON DUPLICATE KEY UPDATE` to handle record updates
- Only updates if incoming record is newer (by timestamp or bronze_id)
- Preserves existing data when incoming data is older

### Foreign Key Relationships

- **One-to-Many**: One customer can have many orders
- Foreign key on `silver_orders` references `silver_customers`
- Composite foreign key: `(customer_id, source_system)` → `(customer_id, source_system)`
- Ensures referential integrity between orders and customers

### Validation Rules

**Orders are rejected if:**

- Both `order_id` AND `source_system` are missing
- `order_id` is missing
- `source_system` is missing
- `customer_id` is missing

**Customers are rejected if:**

- `customer_id` is missing
- `customer_name` is missing
- `source_system` is missing
- Combinations of missing required fields

## Use Cases

This implementation demonstrates:

- **Data Quality**: How to handle dirty data and track quality issues
- **Data Lineage**: Tracking data from source through transformations
- **Incremental Processing**: Handling updates and deduplication
- **Error Handling**: Capturing and categorizing data quality issues
- **Referential Integrity**: Foreign key relationships and validation
- **Data Cleaning**: Name formatting, phone formatting, email validation
- **Production Patterns**: Real-world approaches used in data engineering roles

## Notes

- **Load Order**: Always load customers before orders due to foreign key dependency
- **Foreign Key Checks**: The transformation scripts temporarily disable foreign key checks (`SET FOREIGN_KEY_CHECKS = 0`) to allow `TRUNCATE` operations. This is acceptable in this full reload scenario where we're completely refreshing the silver layer. **For incremental loads in production, use `DELETE` with proper ordering instead of `TRUNCATE` to maintain referential integrity without disabling constraints.**
- **Test Data**: Bronze load files include test data with various edge cases
- **Invalid Records**: Some records are intentionally invalid to demonstrate validation and rejection logic
- **Upsert Testing**: Bronze load files include duplicate records to test the upsert/update logic
- **Data Preservation**: All timestamps in bronze are stored as VARCHAR to preserve original format
- **Multi-Source**: Supports multiple source systems (shopify, amazon, web) with composite keys

## Future Enhancements

See `next_steps.md` for the roadmap. Planned additions include:

- Products table (product master data)
- Order Items table (line items linking orders to products)
- Gold layer (analytics-ready aggregations)

## Contributing

This is a learning project designed to showcase medallion architecture patterns. Feel free to use this as a reference or starting point for your own implementations.
