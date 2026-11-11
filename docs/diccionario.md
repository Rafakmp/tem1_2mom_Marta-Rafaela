# Diccionario de datos

Fuente: `data/Sample - Superstore.csv`, 21 columnas. El CSV conserva todos los campos como `STRING` en `superstore_csv`; `superstore_ventas` usa los tipos de la tabla siguiente. Los identificadores, códigos postales y nombres son texto, incluso cuando contienen dígitos. Fechas originales `M/d/yyyy`; números con punto decimal.

| Campo CSV | Campo Hive | Tipo | Significado y restricción esperada |
|---|---|---|---|
| Row ID | row_id | INT | Identificador único de línea, positivo, no nulo. |
| Order ID | order_id | STRING | Orden; puede repetirse por producto, no vacío. |
| Order Date | order_date | DATE | Fecha de pedido válida. |
| Ship Date | ship_date | DATE | Fecha de envío válida, igual o posterior al pedido. |
| Ship Mode | ship_mode | STRING | Modalidad de envío, no vacía. |
| Customer ID | customer_id | STRING | Identificador de cliente, no vacío. |
| Customer Name | customer_name | STRING | Nombre del cliente, no vacío. |
| Segment | segment | STRING | Segmento comercial, no vacío. |
| Country | country | STRING | País, no vacío. |
| City | city | STRING | Ciudad, no vacía. |
| State | state | STRING | Estado, no vacío. |
| Postal Code | postal_code | STRING | Código postal; texto para preservar ceros iniciales. Puede faltar. |
| Region | region | STRING | Región comercial, no vacía. |
| Product ID | product_id | STRING | Identificador de producto, no vacío. Puede repetirse por venta. |
| Category | category | STRING | Categoría, no vacía. |
| Sub-Category | sub_category | STRING | Subcategoría, no vacía. |
| Product Name | product_name | STRING | Nombre del producto, no vacío. |
| Sales | sales | DECIMAL(18,4) | Importe de venta, esperado mayor que cero. |
| Quantity | quantity | INT | Unidades vendidas, esperadas mayores que cero. |
| Discount | discount | DECIMAL(6,4) | Proporción de descuento, intervalo 0 a 1. |
| Profit | profit | DECIMAL(18,4) | Ganancia o pérdida; puede ser negativa. |

Hive no impone estas restricciones en la tabla; se auditan en la pregunta 2. Las conversiones fallidas producirían `NULL`, por eso se preserva la capa cruda para revisión.
