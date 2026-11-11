USE superstore_rafaela;
WITH p AS (
 SELECT product_id, MAX(product_name) product_name, SUM(sales) ventas, SUM(profit) ganancia
 FROM superstore_ventas GROUP BY product_id
), o AS (
 SELECT *, SUM(ventas) OVER() total_ventas, SUM(ganancia) OVER() total_ganancia,
 SUM(ventas) OVER(ORDER BY ventas DESC, product_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) ventas_acum,
 SUM(ganancia) OVER(ORDER BY ganancia DESC, product_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) ganancia_acum,
 ROW_NUMBER() OVER(ORDER BY ventas DESC, product_id) pos_ventas,
 ROW_NUMBER() OVER(ORDER BY ganancia DESC, product_id) pos_ganancia FROM p
), c AS (
 SELECT MIN(CASE WHEN ventas_acum>=0.8*total_ventas THEN pos_ventas END) n_ventas_80,
 MIN(CASE WHEN ganancia_acum>=0.8*total_ganancia THEN pos_ganancia END) n_ganancia_80,
 COUNT(*) n_productos FROM o
)
SELECT n_productos, n_ventas_80, ROUND(100*n_ventas_80/n_productos,2) pct_productos_ventas,
 n_ganancia_80, ROUND(100*n_ganancia_80/n_productos,2) pct_productos_ganancia FROM c;

WITH p AS (SELECT product_id, MAX(product_name) product_name,
 SUM(sales) ventas, SUM(profit) ganancia FROM superstore_ventas GROUP BY product_id),
r AS (SELECT *, 100*ventas/SUM(ventas) OVER() pct_ventas,
 100*ganancia/SUM(ganancia) OVER() pct_ganancia,
 100*SUM(ventas) OVER(ORDER BY ventas DESC, product_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)/SUM(ventas) OVER() pct_ventas_acum,
 100*SUM(ganancia) OVER(ORDER BY ganancia DESC, product_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)/SUM(ganancia) OVER() pct_ganancia_acum,
 ROW_NUMBER() OVER(ORDER BY ventas DESC, product_id) pos_ventas,
 ROW_NUMBER() OVER(ORDER BY ganancia DESC, product_id) pos_ganancia FROM p)
SELECT product_id, product_name, ROUND(ventas,2) ventas, ROUND(ganancia,2) ganancia,
 ROUND(pct_ventas,2) pct_ventas, ROUND(pct_ganancia,2) pct_ganancia,
 ROUND(pct_ventas_acum,2) pct_ventas_acum, ROUND(pct_ganancia_acum,2) pct_ganancia_acum,
 pos_ventas, pos_ganancia FROM r WHERE pos_ventas<=10 OR pos_ganancia<=10
ORDER BY pos_ventas;
