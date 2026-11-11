# Análisis de optimización

La tabla cruda usa `OpenCSVSerde` para respetar campos entrecomillados, incluidos nombres de producto con comas. La tabla analítica usa ORC con Snappy y tipos `DATE`, `INT` y `DECIMAL`; evita convertir cadenas en cada consulta y reduce lectura de columnas. El dataset de 9.994 filas es pequeño, por lo que particionar por año o región generaría archivos pequeños y sobrecosto de metadatos. Tampoco se justifica bucketing. Para volúmenes mayores, convendría particionar por año de pedido y compactar archivos, después de medir con `EXPLAIN` y tiempos reales.

Las consultas agregan por producto, cliente o mes antes de aplicar ventanas. Pareto hace dos órdenes independientes, uno por ventas y otro por ganancia, con desempate por `product_id`. Se usa `NULLIF` en divisiones para evitar error o valores indefinidos cuando el denominador es cero. `COUNT(DISTINCT order_id)` evita contar líneas de una misma orden como compras independientes.

En la ejecución real, 21 ramas `UNION ALL` para contar valores vacíos superaron el máximo de 120 contadores de Tez. La auditoría final usa `LATERAL VIEW STACK` para desplegar las 21 columnas por fila y agrupar en una lectura. También se sustituyó `TRUNC(date,'MM')`, que Hive 4.0.1 evaluó como 1970-01-01, por `DATE_FORMAT(date,'yyyy-MM-01')`; se verificaron 48 meses distintos.
