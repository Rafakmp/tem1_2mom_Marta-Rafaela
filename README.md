# Momento Evaluativo 2: Análisis Superstore Sales Dataset

**Estudiante:** Rafaela Kiara Marta Puente

## 1. Descripción

Proyecto de ingesta, auditoría y análisis de 9.994 registros de ventas del conjunto de datos *Sample Superstore*, utilizando Apache Hive y Beeline. Se implementan ocho consultas analíticas.

## 2. Objetivos

- Cargar los datos de ventas en Apache Hive.
- Revisar la calidad e integridad de los registros.
- Analizar ventas, clientes, regiones y productos.
- Identificar tendencias y patrones comerciales mediante consultas HiveQL.

## 3. Requisitos

- Windows 10/11.
- Docker Desktop en ejecución.
- Docker Compose.
- PowerShell.
- Archivo CSV: `data/Sample - Superstore.csv`.
- Entorno Hive de la práctica anterior ubicado en `D:\docker-hadoop-hive-parquet`.

## 4. Procedimiento de ejecución

1. Abrir Docker Desktop y esperar a que esté iniciado.
2. Abrir PowerShell en la carpeta principal del proyecto.
3. Ejecutar el siguiente comando para iniciar Hive y ejecutar todas las consultas:

```powershell
& .\scripts\ejecutar_hive.ps1
```

4. El script inicia los contenedores, prepara el archivo CSV, crea las tablas, carga los datos y ejecuta las consultas en orden.
5. Los resultados de Beeline se guardan automáticamente en:

```text
evidencias/hive/
```

### Ejecutar desde una consulta específica

Para continuar desde una consulta sin repetir la creación del modelo y la carga de datos:

```powershell
& .\scripts\ejecutar_hive.ps1 -Desde '07_tendencias.sql'
```

Cambiar el nombre del archivo por la consulta desde la que se desea comenzar.

### Ejecución manual de consultas

También es posible conectarse a Hive mediante Beeline:

```powershell
docker compose -f "D:\docker-hadoop-hive-parquet\docker-compose.yml" exec hive-server beeline -u jdbc:hive2://localhost:10000/default
```

Una vez conectado, ejecutar las consultas:

```sql
SHOW DATABASES;
USE db_superstore_rafaela;
SHOW TABLES;
```

Para ejecutar un archivo SQL desde Beeline:

```sql
!run /tmp/07_tendencias.sql
```

Las consultas están disponibles en la carpeta `sql/preguntas/`.
