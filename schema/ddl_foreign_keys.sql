USE testing;
-- FOREIGN KEYS
-- One-to-Many Relationship: One customer can have many orders
-- The foreign key goes on the "many" side (orders table)
-- Since silver_customers has a composite primary key (customer_id, source_system),
-- the foreign key must reference both columns

ALTER TABLE silver_orders
ADD CONSTRAINT fk_silver_orders_customer_id
FOREIGN KEY (customer_id, source_system)
REFERENCES silver_customers(customer_id, source_system);