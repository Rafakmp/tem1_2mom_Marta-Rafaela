# Resultados del examen práctico

**Estudiante:** Rafaela Marta. **Fuente:** Sample Superstore. **Evidencia:** [salidas reales de Beeline para modelo, carga y las ocho preguntas](../evidencias/hive/), contrastadas con la [auditoría independiente del CSV](../evidencias/auditoria_csv.json). Entorno ejecutado: Apache Hive 4.0.1 sobre Docker Desktop.

## Pregunta 1. Diseño e implementación del modelo de datos

**Estrategia:** conservar el CSV original en una tabla cruda `STRING` con OpenCSVSerde y cargar una tabla ORC con tipos explícitos. El [diccionario](diccionario.md) documenta los 21 campos y restricciones. **Consulta:** [DDL](../sql/00_modelo.sql), [carga](../sql/01_carga.sql) y [verificación](../sql/preguntas/01_modelo.sql). **Evidencia y resultado:** Beeline confirmó [9.994 filas importadas](../evidencias/hive/01_carga.txt) y mostró [ambas tablas](../evidencias/hive/01_modelo.txt). **Interpretación:** la doble capa permite inspeccionar conversiones y mantener los valores originales. **Conclusión:** el modelo cubre todos los campos y la carga quedó validada en Hive.

## Pregunta 2. Auditoría de calidad e integridad

**Estrategia:** comparar conteos y valores vacíos de la tabla cruda, analizar fechas parseadas y restricciones numéricas. **Consulta:** [02_calidad.sql](../sql/preguntas/02_calidad.sql). **Evidencia y resultado:** [Beeline](../evidencias/hive/02_calidad.txt) confirmó 9.994 registros; 0 `Row ID` duplicados; 5.009 órdenes; 793 clientes; 0 valores vacíos en los 21 campos; 0 fechas inválidas, ventas no positivas, descuentos fuera de 0–1 o envíos anteriores al pedido. **Interpretación:** no aparecen anomalías según las reglas evaluadas. **Conclusión:** conservar todas las filas; ante futuras anomalías, separar filas inválidas para revisión, no imputar ventas ni ganancias sin respaldo, y excluir fechas inválidas de series temporales.

## Pregunta 3. Evolución comercial por región

**Estrategia:** agrupar por región y año; `LAG()` calcula ventas del año anterior y el margen es ganancia/ventas. **Consulta:** [03_regiones.sql](../sql/preguntas/03_regiones.sql). **Evidencia:** [Hive](../evidencias/hive/03_regiones.txt) y [auditoría local, `annual` y `regions`](../evidencias/auditoria_csv.json). **Resultado:** West: ventas 725.457,82 y ganancias 108.418,45; East: 678.781,24 y 91.522,78; South: 391.721,91 y 46.749,43; Central: 501.239,89 y 39.706,36. West lidera en ganancia y ventas acumuladas; Central tiene la menor ganancia y menor margen. En 2017 West alcanza ventas 250.128,37 y ganancia 43.808,96. **Interpretación:** el crecimiento de ventas no garantiza un margen alto: Central vende más que South y gana menos. **Conclusión:** priorizar la revisión de descuentos y mezcla de productos en Central.

## Pregunta 4. Segmentación RFM

**Estrategia:** referencia 2017-12-30; recencia en días desde última compra, frecuencia por órdenes distintas y monto por suma de ventas. `NTILE(5)` da valores altos a mejor recencia, frecuencia y monto. Alto valor: R,F,M ≥4; recurrente: F≥4 y R≥3; riesgo: R≤2 y F≥3 o M≥3; demás: otros. Las reglas se aplican en ese orden. **Consulta:** [04_rfm.sql](../sql/preguntas/04_rfm.sql). **Evidencia y resultado:** [Beeline](../evidencias/hive/04_rfm.txt): 104 alto valor, 131 recurrentes, 201 en riesgo y 357 otros. **Interpretación:** la frecuencia se mide por pedidos, evitando inflar el puntaje por pedidos con varias líneas. **Conclusión:** los clientes en riesgo son candidatos a acciones de retención; la etiqueta describe comportamiento histórico, no probabilidad calibrada de abandono.

## Pregunta 5. Ranking de productos según rentabilidad

**Estrategia:** agregar por `product_id`, calcular margen, `RANK()` y `DENSE_RANK()` por categoría, además de ganancia acumulada. Se muestran tanto ventas monetarias como unidades para cubrir ambas acepciones de volumen. **Consulta:** [05_productos.sql](../sql/preguntas/05_productos.sql). **Evidencia:** [Beeline](../evidencias/hive/05_productos.txt). **Resultado:** `TEC-CO-10004722` lidera ventas (61.599,82) y ganancias (25.199,93). El menos rentable es `TEC-MA-10000418` (−8.879,97). El mayor volumen en unidades es `TEC-AC-10003832`, con 75. La consulta muestra cinco líderes de cada categoría y cinco productos con menores ganancias. **Interpretación:** unidades y rentabilidad son medidas distintas; el mayor volumen no implica la mayor ganancia. **Conclusión:** revisar el precio y descuento de las impresoras 3D con pérdidas acumuladas.

## Pregunta 6. Impacto de los descuentos

**Estrategia:** clasificar 0, (0,0,2], (0,2,0,5] y más de 0,5; sumar ventas y ganancias, contar pérdidas y no rentables, y desglosar subcategorías. **Consulta:** [06_descuentos.sql](../sql/preguntas/06_descuentos.sql). **Evidencia:** [Beeline](../evidencias/hive/06_descuentos.txt). **Resultado:** sin descuento: 4.798 líneas, ganancia 320.987,60, 0,63 % no rentables; bajo: 3.803, ganancia 100.785,47, 14,33 %; medio: 537, pérdida neta 58.817,00, 94,04 %; alto: 856, pérdida neta 76.559,05, 100 % no rentables. Entre descuentos altos, Binders acumula la mayor pérdida: 38.510,50. **Interpretación:** existe asociación descriptiva fuerte entre descuentos elevados y operaciones sin ganancia, sin probar causalidad. **Conclusión:** revisar las reglas de descuento alto, especialmente en Binders y Machines.

## Pregunta 7. Tendencias temporales

**Estrategia:** agregar por mes, comparar con `LAG(1)` y `LAG(12)`, calcular media móvil de tres meses y ordenar extremos con `RANK()`. **Consulta:** [07_tendencias.sql](../sql/preguntas/07_tendencias.sql). **Evidencia:** [Beeline, 48 meses](../evidencias/hive/07_tendencias.txt). **Resultado:** mayor venta: noviembre 2017, 118.447,83; diciembre 2016, 96.999,04; septiembre 2017, 87.866,65. Menor venta: febrero 2014, 4.519,89; febrero 2015, 11.951,41; enero 2014, 14.236,90. **Interpretación:** las variaciones mensuales fluctúan y la comparación interanual ayuda a distinguir estacionalidad de crecimiento. **Conclusión:** usar media móvil y comparación anual antes de extrapolar un mes aislado.

## Pregunta 8. Pareto de ventas y rentabilidad

**Estrategia:** ordenar 1.862 productos por ventas y ganancias en dos ventanas independientes; encontrar el primer acumulado que alcanza 80 % del total. **Consulta:** [08_pareto.sql](../sql/preguntas/08_pareto.sql). **Evidencia:** [Beeline](../evidencias/hive/08_pareto.txt). **Resultado:** 414 productos (22,23 %) alcanzan 80 % de ventas; 164 productos (8,81 %) alcanzan 80 % de ganancia neta. **Interpretación:** la ganancia está más concentrada que las ventas y las pérdidas de otros productos reducen el total neto, por lo que el umbral de ganancia debe leerse con esa salvedad. **Conclusión:** cuidar productos clave de ganancia y examinar los que erosionan el beneficio.

## Conclusiones generales

El conjunto acumula ventas de 2.297.200,86 y ganancias de 286.397,02 entre 2014 y 2017. West aporta la mayor ganancia. Los descuentos de más de 50 % coinciden con pérdidas en todas sus líneas. La rentabilidad se concentra más que las ventas. Los resultados quedaron validados en Hive 4.0.1.
