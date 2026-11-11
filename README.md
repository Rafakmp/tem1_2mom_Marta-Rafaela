# Examen práctico individual: Sample Superstore

**Estudiante:** Rafaela Marta · Universidad del Valle · Segundo momento, noviembre de 2026.

Proyecto de ingesta, auditoría y analítica de 9.994 líneas de venta de Sample Superstore en Apache Hive. El enunciado desarrolla ocho preguntas aunque menciona «doce» en los requisitos de repositorio; se implementan las ocho preguntas descritas.

## Requisitos y ejecución

Docker Desktop, Docker Compose y el CSV `data/Sample - Superstore.csv`. Se reutiliza el entorno Hive de la práctica L17 en `D:\UNIVALLE\BIGDATA\docker-hadoop-hive-parquet`.

```powershell
& .\scripts\ejecutar_hive.ps1
```

El script inicia el stack, espera a HiveServer2, normaliza la codificación del CSV de Windows-1252 a UTF-8, ejecuta modelo, carga y preguntas en orden, y guarda la salida de Beeline en `evidencias/hive/`. La carga sobrescribe la tabla analítica. Fechas de origen: mes/día/año.

## Entregables

[Diccionario](docs/diccionario.md) · [Consultas](sql/preguntas/) · [Resultados](docs/resultados.md) · [Optimización](docs/optimizacion.md) · [Evidencias](evidencias/) · [Comandos](docs/comandos-ejecutados.md).

Fuente: [Sample Superstore](https://www.kaggle.com/datasets/vivek468/superstore-dataset-final). La práctica LI17 se usó como referencia. Se declara apoyo de inteligencia artificial en scripts y documentación.
