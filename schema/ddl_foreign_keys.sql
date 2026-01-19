-- FOREIGN KEYS
-- One-to-Many Relationship: One customer can have many orders
-- The foreign key goes on the "many" side (orders table)
-- Since silver_customers has a composite primary key (customer_id, source_system),
-- the foreign key must reference both columns

ALTER TABLE silver_orders
ADD CONSTRAINT fk_silver_orders_customer_id
FOREIGN KEY (customer_id, source_system)
REFERENCES silver_customers(customer_id, source_system);

ALTER TABLE silver_order_items
ADD CONSTRAINT fk_silver_order_items_order_id
FOREIGN KEY (order_id, source_system)
REFERENCES silver_orders(order_id, source_system);

ALTER TABLE silver_order_items
ADD CONSTRAINT fk_silver_order_items_product_id
FOREIGN KEY (product_id, source_system)
REFERENCES silver_products(product_id, source_system);
