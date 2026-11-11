USE superstore_rafaela;
WITH m AS (
 SELECT TRUNC(order_date,'MM') periodo, SUM(sales) ventas, SUM(profit) ganancia
 FROM superstore_ventas GROUP BY TRUNC(order_date,'MM')
), t AS (
 SELECT *, LAG(ventas) OVER(ORDER BY periodo) ventas_previas,
 LAG(ventas,12) OVER(ORDER BY periodo) ventas_anio_previo,
 AVG(ventas) OVER(ORDER BY periodo ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) promedio_movil_3,
 RANK() OVER(ORDER BY ventas DESC) rango_mayor,
 RANK() OVER(ORDER BY ventas ASC) rango_menor FROM m
)
SELECT periodo, ROUND(ventas,2) ventas, ROUND(ganancia,2) ganancia,
 ROUND(100*(ventas-ventas_previas)/NULLIF(ventas_previas,0),2) variacion_mensual_pct,
 ROUND(100*(ventas-ventas_anio_previo)/NULLIF(ventas_anio_previo,0),2) variacion_interanual_pct,
 ROUND(promedio_movil_3,2) promedio_movil_3, rango_mayor, rango_menor
FROM t ORDER BY periodo;

WITH m AS (SELECT TRUNC(order_date,'MM') periodo, SUM(sales) ventas
 FROM superstore_ventas GROUP BY TRUNC(order_date,'MM')),
r AS (SELECT *, RANK() OVER(ORDER BY ventas DESC) mayor,
 RANK() OVER(ORDER BY ventas ASC) menor FROM m)
SELECT periodo, ROUND(ventas,2) ventas, mayor, menor FROM r
WHERE mayor<=3 OR menor<=3 ORDER BY ventas DESC;
