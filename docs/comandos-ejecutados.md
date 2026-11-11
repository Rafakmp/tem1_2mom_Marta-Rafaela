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

`docker info` devolvió que no existe `//./pipe/docker_engine`; `Start-Service com.docker.service` devolvió acceso denegado y el servicio siguió detenido. El script ejecutó `docker compose ... up -d`, que falló por el mismo motivo y se detuvo correctamente. Por ello no se ejecutaron `docker cp`, `docker exec` ni Beeline. No hay evidencia de ejecución Hive que se pueda atribuir a este equipo. Para continuar, iniciar Docker Desktop con permisos de servicio y ejecutar los comandos del README.
