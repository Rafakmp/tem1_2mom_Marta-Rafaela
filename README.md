# Examen práctico individual: Sample Superstore

**Estudiante:** Rafaela Marta · Universidad del Valle · Segundo momento, noviembre de 2026.

Proyecto de ingesta, auditoría y analítica de 9.994 líneas de venta de Sample Superstore en Apache Hive. El enunciado desarrolla ocho preguntas aunque menciona «doce» en los requisitos de repositorio; se implementan las ocho preguntas descritas.

## Requisitos y ejecución

Docker Desktop, Docker Compose y el CSV `data/Sample - Superstore.csv`. Se reutiliza el entorno Hive de la práctica L17 en `D:\UNIVALLE\BIGDATA\docker-hadoop-hive-parquet`.

```powershell
& .\scripts\ejecutar_hive.ps1
```

El script inicia el stack, espera a HiveServer2, normaliza la codificación del CSV de Windows-1252 a UTF-8, ejecuta modelo, carga y preguntas en orden, y guarda la salida de Beeline en `evidencias/hive/`. La carga sobrescribe la tabla analítica. Fechas de origen: mes/día/año.

Para repetir desde una consulta sin volver a cargar datos: `& .\scripts\ejecutar_hive.ps1 -Desde '07_tendencias.sql'`.

## Estado verificado

La ejecución final se completó en Docker Engine 29.7.2 y Apache Hive 4.0.1. HiveServer2 quedó `healthy`; Beeline creó las dos tablas, cargó 9.994 registros y ejecutó las ocho preguntas. La auditoría encontró 5.009 órdenes, 793 clientes y ninguna anomalía en las reglas evaluadas. La serie temporal produjo 48 meses. Las diez salidas finales de Beeline no contienen errores Hive.

| Evidencia | Archivo |
|---|---|
| DDL y carga | [00_modelo.txt](evidencias/hive/00_modelo.txt), [01_carga.txt](evidencias/hive/01_carga.txt) |
| Modelo y preguntas 2–4 | [01_modelo.txt](evidencias/hive/01_modelo.txt), [02_calidad.txt](evidencias/hive/02_calidad.txt), [03_regiones.txt](evidencias/hive/03_regiones.txt), [04_rfm.txt](evidencias/hive/04_rfm.txt) |
| Preguntas 5–8 | [05_productos.txt](evidencias/hive/05_productos.txt), [06_descuentos.txt](evidencias/hive/06_descuentos.txt), [07_tendencias.txt](evidencias/hive/07_tendencias.txt), [08_pareto.txt](evidencias/hive/08_pareto.txt) |

## Entregables

[Diccionario](docs/diccionario.md) · [Consultas](sql/preguntas/) · [Resultados](docs/resultados.md) · [Optimización](docs/optimizacion.md) · [Evidencias](evidencias/) · [Comandos](docs/comandos-ejecutados.md).

Fuente: [Sample Superstore](https://www.kaggle.com/datasets/vivek468/superstore-dataset-final). La práctica LI17 se usó como referencia. Se declara apoyo de inteligencia artificial en scripts y documentación.
