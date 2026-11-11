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

SELECT campo, SUM(CASE WHEN valor IS NULL OR TRIM(valor)='' THEN 1 ELSE 0 END) nulos
FROM superstore_csv
LATERAL VIEW STACK(21,
 'row_id',row_id, 'order_id',order_id, 'order_date',order_date,
 'ship_date',ship_date, 'ship_mode',ship_mode, 'customer_id',customer_id,
 'customer_name',customer_name, 'segment',segment, 'country',country,
 'city',city, 'state',state, 'postal_code',postal_code, 'region',region,
 'product_id',product_id, 'category',category, 'sub_category',sub_category,
 'product_name',product_name, 'sales',sales, 'quantity',quantity,
 'discount',discount, 'profit',profit
) campos AS campo, valor
GROUP BY campo ORDER BY campo;
