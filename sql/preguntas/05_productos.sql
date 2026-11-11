USE superstore_rafaela;
WITH p AS (
 SELECT category, product_id, MAX(product_name) product_name,
 SUM(sales) ventas, SUM(profit) ganancia, SUM(quantity) unidades
 FROM superstore_ventas GROUP BY category, product_id
), r AS (
 SELECT *, RANK() OVER(PARTITION BY category ORDER BY ganancia DESC) ranking_categoria,
 DENSE_RANK() OVER(PARTITION BY category ORDER BY ganancia DESC) dense_ranking_categoria,
 SUM(ganancia) OVER(PARTITION BY category ORDER BY ganancia DESC, product_id
 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) ganancia_acumulada FROM p
)
SELECT category, product_id, product_name, ROUND(ventas,2) ventas,
 ROUND(ganancia,2) ganancia, unidades,
 ROUND(100*ganancia/NULLIF(ventas,0),2) margen_pct,
 ranking_categoria, dense_ranking_categoria, ROUND(ganancia_acumulada,2) ganancia_acumulada
FROM r WHERE ranking_categoria<=5 ORDER BY category, ranking_categoria, product_id;

WITH p AS (SELECT product_id, MAX(product_name) product_name, SUM(sales) ventas,
 SUM(profit) ganancia, SUM(quantity) unidades FROM superstore_ventas GROUP BY product_id)
SELECT *, ROUND(100*ganancia/NULLIF(ventas,0),2) margen_pct
FROM p ORDER BY unidades DESC, product_id LIMIT 5;

WITH p AS (SELECT product_id, MAX(product_name) product_name, SUM(sales) ventas,
 SUM(profit) ganancia, SUM(quantity) unidades FROM superstore_ventas GROUP BY product_id)
SELECT *, ROUND(100*ganancia/NULLIF(ventas,0),2) margen_pct
FROM p ORDER BY ventas DESC, product_id LIMIT 5;

WITH p AS (SELECT product_id, MAX(product_name) product_name, SUM(sales) ventas,
 SUM(profit) ganancia FROM superstore_ventas GROUP BY product_id)
SELECT *, ROUND(100*ganancia/NULLIF(ventas,0),2) margen_pct
FROM p ORDER BY ganancia ASC, product_id LIMIT 5;
