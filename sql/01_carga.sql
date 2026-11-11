USE superstore_rafaela;
LOAD DATA LOCAL INPATH '/tmp/superstore.csv' OVERWRITE INTO TABLE superstore_csv;
INSERT OVERWRITE TABLE superstore_ventas
SELECT CAST(row_id AS INT), order_id,
 TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(order_date,'M/d/yyyy'))),
 TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(ship_date,'M/d/yyyy'))),
 ship_mode, customer_id, customer_name, segment, country, city, state,
 postal_code, region, product_id, category, sub_category, product_name,
 CAST(sales AS DECIMAL(18,4)), CAST(quantity AS INT),
 CAST(discount AS DECIMAL(6,4)), CAST(profit AS DECIMAL(18,4))
FROM superstore_csv;
SELECT COUNT(*) AS filas_importadas FROM superstore_ventas;
SELECT * FROM superstore_ventas LIMIT 5;
