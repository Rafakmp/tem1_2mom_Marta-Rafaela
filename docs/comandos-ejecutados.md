# Comandos ejecutados

Entorno: PowerShell en Windows, directorio del repositorio. Fecha: 11 de noviembre de 2026.

```powershell
rg --files -g '!**/.git/**'
git status --short
git log --oneline -5
git remote -v
Import-Csv -LiteralPath 'data\Sample - Superstore.csv'
Start-Process -FilePath 'C:\Program Files\Docker\Docker\Docker Desktop.exe' -WindowStyle Hidden
docker info --format '{{.ServerVersion}}'
Get-Service com.docker.service
Start-Service com.docker.service
$raw=[IO.File]::ReadAllText((Resolve-Path 'data\Sample - Superstore.csv'),[Text.Encoding]::GetEncoding(1252))
[IO.File]::WriteAllText((Join-Path (Get-Location) 'data\superstore_utf8.csv'),$raw,[Text.UTF8Encoding]::new($false))
& .\scripts\analizar_csv.ps1
& .\scripts\ejecutar_hive.ps1
```

En el intento inicial, `docker info` devolvió que no existía `//./pipe/docker_engine`; `Start-Service com.docker.service` devolvió acceso denegado. `docker compose ... up -d` falló y el script se detuvo. La ejecución posterior se documenta a continuación.

## Ejecución con Docker disponible

```powershell
docker info --format '{{.ServerVersion}}'
docker ps --format '{{.Names}} {{.Image}} {{.Status}}'
& .\scripts\ejecutar_hive.ps1
& .\scripts\ejecutar_hive.ps1 -Desde '02_calidad.sql'
& .\scripts\ejecutar_hive.ps1
& .\scripts\ejecutar_hive.ps1 -Desde '07_tendencias.sql'
& .\scripts\analizar_csv.ps1
rg -n 'Error:|ERROR :|FAILED:' evidencias\hive
```

Docker Engine respondió `29.7.2`. El primer intento Hive encontró el nombre de contenedor distinto del supuesto. Se cambió el script para obtener el ID con `docker compose ps -q hive-server`. La consulta de calidad original falló por `Too many counters: 121 max=120`; se reemplazaron 21 ramas `UNION ALL` por una sola lectura con `LATERAL VIEW STACK`. La primera consulta mensual agrupó en 1970-01-01 por el comportamiento de `TRUNC()` en este Hive; se corrigió a `DATE_FORMAT(order_date,'yyyy-MM-01')`.

La ejecución final guardó salidas de Beeline para DDL, carga y preguntas 1–8 en `evidencias/hive/`. La carga confirmó 9.994 filas, calidad confirmó 5.009 órdenes y 793 clientes sin anomalías, la serie mensual contiene 48 meses, y ninguna salida final contiene errores de Hive.
