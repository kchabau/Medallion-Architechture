# Medallion Architecture - Normalized Schema

## Overview

This document outlines the normalized schema implementation for a medallion architecture (Bronze → Silver → Gold) with a realistic e-commerce data model. The architecture includes orders, customers, products, and order items entities.

## Progress Status

### ✅ Completed (2 of 4 Main Tables)

#### 1. **Orders** - COMPLETE
- ✅ `bronze_orders` table (DDL)
- ✅ `silver_orders` table (DDL)
- ✅ `silver_orders_rejects` table (DDL)
- ✅ `bronze/orders/bronze_orders_load.sql` - Data load script
- ✅ `silver/orders/silver_orders_transform.sql` - Transformation with parsing logic
- ✅ `silver/orders/silver_orders_rejects.sql` - Reject handling
- ✅ Foreign key constraint to `silver_customers`

**Features Implemented:**
- Multi-format timestamp parsing (ISO 8601, slash format, dash format)
- Decimal amount parsing with validation
- Rejection logic for missing required fields
- Upsert logic with recency-based updates
- Composite primary key (order_id, source_system)

#### 2. **Customers** - COMPLETE
- ✅ `bronze_customers` table (DDL)
- ✅ `silver_customers` table (DDL)
- ✅ `silver_customers_rejects` table (DDL)
- ✅ `bronze/customers/bronze_customers_load.sql` - Data load script with test cases
- ✅ `silver/customers/silver_customers_transform.sql` - Transformation with data cleaning
- ✅ `silver/customers/silver_customers_rejects.sql` - Reject handling
- ✅ Foreign key from `silver_orders` to `silver_customers`

**Features Implemented:**
- Name title-casing (first and last name)
- Email validation with regex
- Phone number formatting (xxx-xxx-xxxx)
- Rejection logic for missing customer_id, customer_name, or source_system
- Composite primary key (customer_id, source_system)
- Test data includes missing field scenarios

### 🚧 Remaining (2 of 4 Main Tables)

#### 3. **Order Items** - TODO
- ⏳ `bronze_order_items` table (DDL)
- ⏳ `silver_order_items` table (DDL)
- ⏳ `silver_order_items_rejects` table (DDL)
- ⏳ `bronze/order_items/bronze_order_items_load.sql`
- ⏳ `silver/order_items/silver_order_items_transform.sql`
- ⏳ `silver/order_items/silver_order_items_rejects.sql`
- ⏳ Foreign keys to `silver_orders` and `silver_products`

#### 4. **Products** - TODO
- ⏳ `bronze_products` table (DDL)
- ⏳ `silver_products` table (DDL)
- ⏳ `silver_products_rejects` table (DDL)
- ⏳ `bronze/products/bronze_products_load.sql`
- ⏳ `silver/products/silver_products_transform.sql`
- ⏳ `silver/products/silver_products_rejects.sql`

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

### Customers Transformation ✅ IMPLEMENTED
1. ✅ Validate email format (basic regex)
2. ✅ Handle customer updates (upsert by customer_id + source_system)
3. ✅ Title-case customer names (first and last)
4. ✅ Format phone numbers (xxx-xxx-xxxx)
5. ✅ Reject rows with missing customer_id, customer_name, or source_system

### Orders Transformation ✅ IMPLEMENTED
1. ✅ Multi-format timestamp parsing (ISO 8601, slash, dash formats)
2. ✅ Decimal amount parsing with validation
3. ✅ Validate `customer_id` exists in `silver_customers` (via FK constraint)
4. ✅ Reject orders with missing required fields
5. ✅ Upsert logic with recency-based updates
6. ⏳ **TODO**: Calculate `order_total` by summing `line_total` from `order_items` (after order_items table is created)

## Rejects Tables

### New Reject Tables
- `silver_order_items_rejects` - Invalid line items
- `silver_products_rejects` - Invalid product data
- `silver_customers_rejects` - Invalid customer data

### Rejection Reasons

#### ✅ Orders - IMPLEMENTED
- Missing order_id
- Missing source_system
- Missing customer_id
- Both order_id and source_system missing

#### ✅ Customers - IMPLEMENTED
- Missing customer_id
- Missing customer_name
- Missing source_system
- Combinations of missing required fields

#### ⏳ Order Items - TODO
- Missing order_id
- Missing product_id
- Invalid quantity
- Invalid price
- FK violations (order_id or product_id not found)

#### ⏳ Products - TODO
- Missing product_id
- Invalid price format
- Missing required fields

## Gold Layer (Future)

Once the 4 main silver tables are developed and stable, we can create a Gold layer that includes:

### Potential Gold Tables
- **Analytics-ready aggregations**
- **Business metrics** (customer lifetime value, product performance, etc.)
- **Denormalized views** for reporting
- **Time-series aggregations** (daily/monthly sales, customer trends)

## Implementation Order

### ✅ Phase 1: Orders & Customers (COMPLETE)
1. ✅ **Schema Creation**
   - ✅ Created bronze tables for orders and customers
   - ✅ Created silver tables for orders and customers
   - ✅ Created reject tables for orders and customers
   - ✅ Created foreign key constraints

2. ✅ **Bronze Load Scripts**
   - ✅ `bronze/orders/bronze_orders_load.sql`
   - ✅ `bronze/customers/bronze_customers_load.sql` (includes test data with missing fields)

3. ✅ **Silver Transform Scripts**
   - ✅ `silver/orders/silver_orders_transform.sql`
   - ✅ `silver/customers/silver_customers_transform.sql`

4. ✅ **Silver Reject Scripts**
   - ✅ `silver/orders/silver_orders_rejects.sql`
   - ✅ `silver/customers/silver_customers_rejects.sql`

### 🚧 Phase 2: Products & Order Items (NEXT)

1. **Schema Creation**
   - Create `bronze_products` table (DDL)
   - Create `silver_products` table (DDL)
   - Create `silver_products_rejects` table (DDL)
   - Create `bronze_order_items` table (DDL)
   - Create `silver_order_items` table (DDL)
   - Create `silver_order_items_rejects` table (DDL)
   - Create foreign key constraints:
     - `silver_order_items.order_id` → `silver_orders.order_id`
     - `silver_order_items.product_id` → `silver_products.product_id`

2. **Bronze Load Scripts**
   - `bronze/products/bronze_products_load.sql`
   - `bronze/order_items/bronze_order_items_load.sql`

3. **Silver Transform Scripts**
   - `silver/products/silver_products_transform.sql`
   - `silver/order_items/silver_order_items_transform.sql`
   - Update `silver/orders/silver_orders_transform.sql` to calculate `order_total` from order_items

4. **Silver Reject Scripts**
   - `silver/products/silver_products_rejects.sql`
   - `silver/order_items/silver_order_items_rejects.sql`

### 📋 Phase 3: Gold Layer (Future)
- Create gold schema and transformation scripts
- Analytics-ready aggregations
- Business metrics calculations

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
