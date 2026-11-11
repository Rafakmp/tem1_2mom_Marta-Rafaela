# Examen práctico individual: Sample Superstore

**Estudiante:** Rafaela Marta · Universidad del Valle · Segundo momento, noviembre de 2026.

Proyecto de ingesta, auditoría y analítica de 9.994 líneas de venta de Sample Superstore en Apache Hive. El enunciado desarrolla ocho preguntas aunque menciona «doce» en los requisitos de repositorio; se implementan las ocho preguntas descritas.

## Requisitos y ejecución

Docker Desktop, Docker Compose y el CSV `data/Sample - Superstore.csv`. Se reutiliza el entorno Hive de la práctica L17 en `D:\UNIVALLE\BIGDATA\docker-hadoop-hive-parquet`.

```powershell
$stack = 'D:\UNIVALLE\BIGDATA\docker-hadoop-hive-parquet\docker-compose.yml'
docker compose -f $stack up -d postgres namenode datanode hive-metastore hive-server
$raw = [IO.File]::ReadAllText((Resolve-Path 'data\Sample - Superstore.csv'), [Text.Encoding]::GetEncoding(1252))
[IO.File]::WriteAllText((Join-Path (Get-Location) 'data\superstore_utf8.csv'), $raw, [Text.UTF8Encoding]::new($false))
docker cp 'data\superstore_utf8.csv' hive-server:/tmp/superstore.csv
Get-ChildItem sql\*.sql,sql\preguntas\*.sql | ForEach-Object {
  docker cp $_.FullName "hive-server:/tmp/$($_.Name)"
  docker exec hive-server beeline -u 'jdbc:hive2://localhost:10000/default' -n hive -f "/tmp/$($_.Name)"
}
```

Ejecutar primero `00_modelo.sql`, después `01_carga.sql` y finalmente las preguntas en orden. La carga sobrescribe la tabla analítica. Fechas de origen: mes/día/año.

## Entregables

[Diccionario](docs/diccionario.md) · [Consultas](sql/preguntas/) · [Resultados](docs/resultados.md) · [Optimización](docs/optimizacion.md) · [Evidencias](evidencias/) · [Comandos](docs/comandos-ejecutados.md).

Fuente: [Sample Superstore](https://www.kaggle.com/datasets/vivek468/superstore-dataset-final). La práctica LI17 se usó como referencia. Se declara apoyo de inteligencia artificial en scripts y documentación.
