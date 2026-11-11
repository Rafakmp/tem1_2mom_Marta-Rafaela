USE superstore_rafaela;
WITH anual AS (
 SELECT region, YEAR(order_date) anio, SUM(sales) ventas, SUM(profit) ganancia
 FROM superstore_ventas GROUP BY region, YEAR(order_date)
), c AS (SELECT *, LAG(ventas) OVER(PARTITION BY region ORDER BY anio) ventas_previas FROM anual)
SELECT region, anio, ROUND(ventas,2) ventas, ROUND(ganancia,2) ganancia,
 ROUND(100*ganancia/NULLIF(ventas,0),2) margen_pct,
 ROUND(100*(ventas-ventas_previas)/NULLIF(ventas_previas,0),2) variacion_pct
FROM c ORDER BY region, anio;
SELECT region, ROUND(SUM(sales),2) ventas, ROUND(SUM(profit),2) ganancia,
 ROUND(100*SUM(profit)/NULLIF(SUM(sales),0),2) margen_pct
FROM superstore_ventas GROUP BY region ORDER BY ganancia DESC;
