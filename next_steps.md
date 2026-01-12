# Future Enhancements - Normalized Schema

## Overview

This document outlines the planned enhancement to normalize the orders schema by introducing product and customer entities. This will create a more realistic e-commerce data model and enable richer analytics capabilities.

## Current State

Currently, the pipeline only handles order-level data:
- `bronze_orders` - Raw order data
- `silver_orders` - Cleaned order data
- `silver_orders_rejects` - Rejected orders

## Planned Enhancement: Option 2 - Normalized Schema

### Target Silver Layer Tables (4 Main Tables)

#### 1. `silver_orders`
**Purpose**: Order-level information (header data)
- `order_id` (PK)
- `customer_id` (FK to `silver_customers`)
- `source_system`
- `order_status`
- `order_ts` (DATETIME)
- `order_total` (DECIMAL) - Calculated from order_items
- `ingest_batch_id`
- `bronze_id` (lineage)
- `silver_ingest_ts`

#### 2. `silver_order_items`
**Purpose**: Product-level line items within orders
- `order_item_id` (PK, AUTO_INCREMENT)
- `order_id` (FK to `silver_orders`)
- `product_id` (FK to `silver_products`)
- `quantity` (INT)
- `unit_price` (DECIMAL)
- `line_total` (DECIMAL) - Calculated: quantity * unit_price
- `ingest_batch_id`
- `bronze_id` (lineage)
- `silver_ingest_ts`

**Indexes**:
- `idx_order_items_order_id` on `order_id`
- `idx_order_items_product_id` on `product_id`

#### 3. `silver_products`
**Purpose**: Product master data (dimension table)
- `product_id` (PK)
- `product_name` (VARCHAR)
- `product_category` (VARCHAR)
- `product_price` (DECIMAL) - Current/standard price
- `source_system` (VARCHAR) - Which system this product came from
- `is_active` (BOOLEAN)
- `ingest_batch_id`
- `bronze_id` (lineage)
- `silver_ingest_ts`

**Indexes**:
- `idx_products_category` on `product_category`
- `idx_products_source_system` on `source_system`

#### 4. `silver_customers`
**Purpose**: Customer master data (dimension table)
- `customer_id` (PK)
- `customer_name` (VARCHAR)
- `customer_email` (VARCHAR)
- `customer_phone` (VARCHAR)
- `customer_address` (VARCHAR)
- `source_system` (VARCHAR) - Which system this customer came from
- `ingest_batch_id`
- `bronze_id` (lineage)
- `silver_ingest_ts`

**Indexes**:
- `idx_customers_email` on `customer_email`
- `idx_customers_source_system` on `source_system`

## Bronze Layer Changes

### New Bronze Tables

#### `bronze_order_items`
- Raw line item data as received from source systems
- All fields as VARCHAR to preserve original format
- Includes `order_id` to link back to `bronze_orders`

#### `bronze_products`
- Raw product data as received from source systems
- All fields as VARCHAR

#### `bronze_customers`
- Raw customer data as received from source systems
- All fields as VARCHAR

## Silver Layer Transformation Logic

### Order Items Transformation
1. Parse `quantity` from VARCHAR to INT
2. Parse `unit_price` from VARCHAR to DECIMAL
3. Calculate `line_total` = quantity * unit_price
4. Validate foreign keys exist (order_id, product_id)
5. Reject items with invalid order_id or product_id references

### Products Transformation
1. Parse `product_price` from VARCHAR to DECIMAL
2. Parse `is_active` from VARCHAR to BOOLEAN
3. Handle product updates (upsert by product_id + source_system)
4. Track product price changes over time (if needed)

### Customers Transformation
1. Validate email format (basic regex)
2. Handle customer updates (upsert by customer_id + source_system)
3. Track customer data changes

### Orders Transformation Updates
1. Calculate `order_total` by summing `line_total` from `order_items`
2. Validate `customer_id` exists in `silver_customers`
3. Reject orders with invalid customer references

## Rejects Tables

### New Reject Tables
- `silver_order_items_rejects` - Invalid line items
- `silver_products_rejects` - Invalid product data
- `silver_customers_rejects` - Invalid customer data

### Rejection Reasons
- **Order Items**: Missing order_id, missing product_id, invalid quantity, invalid price, FK violations
- **Products**: Missing product_id, invalid price format, missing required fields
- **Customers**: Missing customer_id, invalid email format, missing required fields

## Gold Layer (Future)

Once the 4 main silver tables are developed and stable, we can create a Gold layer that includes:

### Potential Gold Tables
- **Analytics-ready aggregations**
- **Business metrics** (customer lifetime value, product performance, etc.)
- **Denormalized views** for reporting
- **Time-series aggregations** (daily/monthly sales, customer trends)

## Implementation Order

1. **Schema Creation**
   - Create bronze tables for order_items, products, customers
   - Create silver tables for order_items, products, customers
   - Create reject tables for each entity

2. **Bronze Load Scripts**
   - `bronze/bronze_order_items_load.sql`
   - `bronze/bronze_products_load.sql`
   - `bronze/bronze_customers_load.sql`

3. **Silver Transform Scripts**
   - `silver/silver_order_items_transform.sql`
   - `silver/silver_products_transform.sql`
   - `silver/silver_customers_transform.sql`
   - Update `silver/silver_orders_transform.sql` to calculate order_total

4. **Silver Reject Scripts**
   - `silver/silver_order_items_rejects.sql`
   - `silver/silver_products_rejects.sql`
   - `silver/silver_customers_rejects.sql`

5. **Gold Layer** (After silver is stable)
   - Create gold schema and transformation scripts

## Benefits of This Approach

1. **Normalized Design**: Follows database normalization best practices
2. **Scalability**: Can handle complex e-commerce scenarios
3. **Analytics Ready**: Enables product-level and customer-level analytics
4. **Data Quality**: Better validation at multiple levels
5. **Real-world Pattern**: Mirrors actual production data engineering patterns

## Considerations

- **Referential Integrity**: Need to handle FK validation carefully
- **Load Order**: Products and customers may need to load before order_items
- **Deduplication**: Products and customers may need deduplication logic
- **Data Lineage**: Maintain bronze_id tracking through all layers
- **Performance**: Indexes will be critical for FK lookups during transformation
