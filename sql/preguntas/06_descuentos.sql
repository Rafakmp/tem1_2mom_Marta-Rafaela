USE superstore_rafaela;
WITH b AS (
 SELECT category, sub_category, sales, profit, discount,
 CASE WHEN discount=0 THEN '0_sin_descuento'
 WHEN discount<=0.2 THEN '1_bajo' WHEN discount<=0.5 THEN '2_medio'
 ELSE '3_alto' END rango
 FROM superstore_ventas WHERE discount BETWEEN 0 AND 1
)
SELECT rango, COUNT(*) registros, ROUND(SUM(sales),2) ventas,
 ROUND(SUM(profit),2) ganancia,
 ROUND(100*SUM(profit)/NULLIF(SUM(sales),0),2) margen_pct,
 SUM(CASE WHEN profit<0 THEN 1 ELSE 0 END) registros_perdida,
 ROUND(100*SUM(CASE WHEN profit<=0 THEN 1 ELSE 0 END)/COUNT(*),2) no_rentables_pct,
 ROUND(AVG(discount),4) descuento_promedio
FROM b GROUP BY rango ORDER BY rango;

WITH b AS (
 SELECT category, sub_category, sales, profit, discount,
 CASE WHEN discount=0 THEN '0_sin_descuento' WHEN discount<=0.2 THEN '1_bajo'
 WHEN discount<=0.5 THEN '2_medio' ELSE '3_alto' END rango
 FROM superstore_ventas WHERE discount BETWEEN 0 AND 1
)
SELECT rango, category, sub_category, COUNT(*) registros,
 ROUND(SUM(profit),2) ganancia,
 ROUND(100*SUM(profit)/NULLIF(SUM(sales),0),2) margen_pct,
 ROUND(100*SUM(CASE WHEN profit<=0 THEN 1 ELSE 0 END)/COUNT(*),2) no_rentables_pct
FROM b GROUP BY rango, category, sub_category ORDER BY rango, ganancia ASC;
