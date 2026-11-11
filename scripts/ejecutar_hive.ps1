param(
  [string]$Stack = 'D:\UNIVALLE\BIGDATA\docker-hadoop-hive-parquet\docker-compose.yml'
)
$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $Stack)) { throw "No existe el Compose: $Stack" }
$root = Split-Path -Parent $PSScriptRoot
$evidencias = Join-Path $root 'evidencias\hive'
New-Item -ItemType Directory -Path $evidencias -Force | Out-Null
docker compose -f $Stack up -d postgres namenode datanode hive-metastore hive-server
if ($LASTEXITCODE -ne 0) { throw 'No se pudo iniciar el stack Hive.' }
$healthy = $false
for ($i=0; $i -lt 60; $i++) {
  $state = docker inspect --format '{{.State.Health.Status}}' hive-server 2>$null
  if ($state -eq 'healthy') { $healthy = $true; break }
  Start-Sleep -Seconds 5
}
if (-not $healthy) { throw 'HiveServer2 no llegó al estado healthy.' }
$rawPath = Join-Path $root 'data\Sample - Superstore.csv'
$utf8Path = Join-Path $root 'data\superstore_utf8.csv'
$raw = [IO.File]::ReadAllText($rawPath,[Text.Encoding]::GetEncoding(1252))
[IO.File]::WriteAllText($utf8Path,$raw,[Text.UTF8Encoding]::new($false))
docker cp $utf8Path hive-server:/tmp/superstore.csv
if ($LASTEXITCODE -ne 0) { throw 'No se pudo copiar el CSV.' }
$files = @(
  Join-Path $root 'sql\00_modelo.sql'
  Join-Path $root 'sql\01_carga.sql'
) + @(Get-ChildItem (Join-Path $root 'sql\preguntas\*.sql') | Sort-Object Name | Select-Object -ExpandProperty FullName)
foreach ($file in $files) {
  $name = Split-Path $file -Leaf
  docker cp $file "hive-server:/tmp/$name"
  if ($LASTEXITCODE -ne 0) { throw "No se pudo copiar $name" }
  $log = Join-Path $evidencias ($name -replace '\.sql$','.txt')
  docker exec hive-server beeline -u 'jdbc:hive2://localhost:10000/default' -n hive --showHeader=true -f "/tmp/$name" 2>&1 |
    Tee-Object -FilePath $log
  if ($LASTEXITCODE -ne 0) { throw "Falló $name. Revisar $log" }
}
