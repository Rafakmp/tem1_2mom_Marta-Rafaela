USE superstore_rafaela;
WITH a AS (
 SELECT *, TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(order_date,'M/d/yyyy'))) pedido,
 TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(ship_date,'M/d/yyyy'))) envio
 FROM superstore_csv
)
SELECT COUNT(*) registros, COUNT(DISTINCT row_id) ids_fila,
 COUNT(*)-COUNT(DISTINCT row_id) filas_duplicadas,
 COUNT(DISTINCT order_id) ordenes_unicas, COUNT(DISTINCT customer_id) clientes_unicos,
 SUM(CASE WHEN pedido IS NULL OR envio IS NULL
   OR DATE_FORMAT(pedido,'M/d/yyyy')<>order_date
   OR DATE_FORMAT(envio,'M/d/yyyy')<>ship_date
   THEN 1 ELSE 0 END) fechas_invalidas,
 SUM(CASE WHEN CAST(sales AS DOUBLE)<=0 THEN 1 ELSE 0 END) ventas_no_positivas,
 SUM(CASE WHEN CAST(discount AS DOUBLE)<0 OR CAST(discount AS DOUBLE)>1 THEN 1 ELSE 0 END) descuentos_fuera_rango,
 SUM(CASE WHEN envio<pedido THEN 1 ELSE 0 END) envios_anteriores
FROM a;

SELECT 'row_id' campo, SUM(CASE WHEN row_id IS NULL OR TRIM(row_id)='' THEN 1 ELSE 0 END) nulos FROM superstore_csv
UNION ALL SELECT 'order_id', SUM(CASE WHEN order_id IS NULL OR TRIM(order_id)='' THEN 1 ELSE 0 END) FROM superstore_csv
UNION ALL SELECT 'order_date', SUM(CASE WHEN order_date IS NULL OR TRIM(order_date)='' THEN 1 ELSE 0 END) FROM superstore_csv
UNION ALL SELECT 'ship_date', SUM(CASE WHEN ship_date IS NULL OR TRIM(ship_date)='' THEN 1 ELSE 0 END) FROM superstore_csv
UNION ALL SELECT 'ship_mode', SUM(CASE WHEN ship_mode IS NULL OR TRIM(ship_mode)='' THEN 1 ELSE 0 END) FROM superstore_csv
UNION ALL SELECT 'customer_id', SUM(CASE WHEN customer_id IS NULL OR TRIM(customer_id)='' THEN 1 ELSE 0 END) FROM superstore_csv
UNION ALL SELECT 'customer_name', SUM(CASE WHEN customer_name IS NULL OR TRIM(customer_name)='' THEN 1 ELSE 0 END) FROM superstore_csv
UNION ALL SELECT 'segment', SUM(CASE WHEN segment IS NULL OR TRIM(segment)='' THEN 1 ELSE 0 END) FROM superstore_csv
UNION ALL SELECT 'country', SUM(CASE WHEN country IS NULL OR TRIM(country)='' THEN 1 ELSE 0 END) FROM superstore_csv
UNION ALL SELECT 'city', SUM(CASE WHEN city IS NULL OR TRIM(city)='' THEN 1 ELSE 0 END) FROM superstore_csv
UNION ALL SELECT 'state', SUM(CASE WHEN state IS NULL OR TRIM(state)='' THEN 1 ELSE 0 END) FROM superstore_csv
UNION ALL SELECT 'postal_code', SUM(CASE WHEN postal_code IS NULL OR TRIM(postal_code)='' THEN 1 ELSE 0 END) FROM superstore_csv
UNION ALL SELECT 'region', SUM(CASE WHEN region IS NULL OR TRIM(region)='' THEN 1 ELSE 0 END) FROM superstore_csv
UNION ALL SELECT 'product_id', SUM(CASE WHEN product_id IS NULL OR TRIM(product_id)='' THEN 1 ELSE 0 END) FROM superstore_csv
UNION ALL SELECT 'category', SUM(CASE WHEN category IS NULL OR TRIM(category)='' THEN 1 ELSE 0 END) FROM superstore_csv
UNION ALL SELECT 'sub_category', SUM(CASE WHEN sub_category IS NULL OR TRIM(sub_category)='' THEN 1 ELSE 0 END) FROM superstore_csv
UNION ALL SELECT 'product_name', SUM(CASE WHEN product_name IS NULL OR TRIM(product_name)='' THEN 1 ELSE 0 END) FROM superstore_csv
UNION ALL SELECT 'sales', SUM(CASE WHEN sales IS NULL OR TRIM(sales)='' THEN 1 ELSE 0 END) FROM superstore_csv
UNION ALL SELECT 'quantity', SUM(CASE WHEN quantity IS NULL OR TRIM(quantity)='' THEN 1 ELSE 0 END) FROM superstore_csv
UNION ALL SELECT 'discount', SUM(CASE WHEN discount IS NULL OR TRIM(discount)='' THEN 1 ELSE 0 END) FROM superstore_csv
UNION ALL SELECT 'profit', SUM(CASE WHEN profit IS NULL OR TRIM(profit)='' THEN 1 ELSE 0 END) FROM superstore_csv;
