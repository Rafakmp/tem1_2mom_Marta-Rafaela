$ErrorActionPreference = 'Stop'
$culture = [Globalization.CultureInfo]::InvariantCulture
$source = Join-Path $PSScriptRoot '..\data\Sample - Superstore.csv'
$out = Join-Path $PSScriptRoot '..\evidencias\auditoria_csv.json'
$rows = @(Import-Csv -LiteralPath $source -Encoding Default)
$items = foreach ($r in $rows) {
  [pscustomobject]@{
    id = $r.'Row ID'; order = $r.'Order ID'; customer = $r.'Customer ID'
    date = [datetime]::ParseExact($r.'Order Date', 'M/d/yyyy', $culture)
    ship = [datetime]::ParseExact($r.'Ship Date', 'M/d/yyyy', $culture)
    region = $r.Region; category = $r.Category; subcategory = $r.'Sub-Category'
    product = $r.'Product ID'; product_name = $r.'Product Name'
    sales = [decimal]::Parse($r.Sales,$culture)
    profit = [decimal]::Parse($r.Profit,$culture)
    discount = [decimal]::Parse($r.Discount,$culture)
    quantity = [int]$r.Quantity
  }
}
function SumField($group, $field) {
  $sum = [decimal]0
  foreach ($x in $group) { $sum += $x.$field }
  return [math]::Round($sum,2)
}
$nulls = [ordered]@{}
foreach ($name in $rows[0].PSObject.Properties.Name) {
  $nulls[$name] = @($rows | Where-Object { [string]::IsNullOrWhiteSpace($_.$name) }).Count
}
$regions = @($items | Group-Object region | ForEach-Object {
  [pscustomobject]@{region=$_.Name; sales=SumField $_.Group 'sales'; profit=SumField $_.Group 'profit'}
} | Sort-Object profit -Descending)
$annual = @($items | Group-Object { "$($_.region)|$($_.date.Year)" } | ForEach-Object {
  [pscustomobject]@{region=$_.Group[0].region; year=$_.Group[0].date.Year; sales=SumField $_.Group 'sales'; profit=SumField $_.Group 'profit'}
} | Sort-Object region,year)
$discounts = @($items | Group-Object {
  if ($_.discount -eq 0) {'0_sin_descuento'} elseif ($_.discount -le .2) {'1_bajo'} elseif ($_.discount -le .5) {'2_medio'} else {'3_alto'}
} | ForEach-Object {
  $loss = @($_.Group | Where-Object profit -LT 0).Count
  $nonprofit = @($_.Group | Where-Object profit -LE 0).Count
  [pscustomobject]@{range=$_.Name; count=$_.Count; sales=SumField $_.Group 'sales'; profit=SumField $_.Group 'profit'; losses=$loss; unprofitable=$nonprofit; unprofitable_pct=[math]::Round(100*$nonprofit/$_.Count,2)}
} | Sort-Object range)
$months = @($items | Group-Object { $_.date.ToString('yyyy-MM') } | ForEach-Object {
  [pscustomobject]@{month=$_.Name; sales=SumField $_.Group 'sales'; profit=SumField $_.Group 'profit'}
} | Sort-Object month)
$products = @($items | Group-Object product | ForEach-Object {
  [pscustomobject]@{id=$_.Name; name=$_.Group[0].product_name; category=$_.Group[0].category; sales=SumField $_.Group 'sales'; profit=SumField $_.Group 'profit'; quantity=($_.Group | Measure-Object quantity -Sum).Sum}
})
$maxDate = ($items | Sort-Object date | Select-Object -Last 1).date
$rfm = @($items | Group-Object customer | ForEach-Object {
  $last = ($_.Group | Sort-Object date | Select-Object -Last 1).date
  [pscustomobject]@{customer=$_.Name; recency=($maxDate-$last).Days;
    frequency=@($_.Group | Select-Object -ExpandProperty order -Unique).Count;
    monetary=SumField $_.Group 'sales'; r=0; f=0; m=0}
})
$n = $rfm.Count
$small = [math]::Floor($n/5); $largeCount = $n % 5; $large = $small+1
function Bucket($index) {
  if ($index -lt $largeCount*$large) { return [int]([math]::Floor($index/$large)+1) }
  return [int]($largeCount+[math]::Floor(($index-$largeCount*$large)/$small)+1)
}
$ranking = @($rfm | Sort-Object @{Expression='recency';Descending=$true},customer)
for ($i=0;$i -lt $n;$i++) { $ranking[$i].r = Bucket $i }
$ranking = @($rfm | Sort-Object frequency,customer)
for ($i=0;$i -lt $n;$i++) { $ranking[$i].f = Bucket $i }
$ranking = @($rfm | Sort-Object monetary,customer)
for ($i=0;$i -lt $n;$i++) { $ranking[$i].m = Bucket $i }
$segments = @($rfm | Group-Object {
  if ($_.r -ge 4 -and $_.f -ge 4 -and $_.m -ge 4) {'alto_valor'}
  elseif ($_.f -ge 4 -and $_.r -ge 3) {'recurrente'}
  elseif ($_.r -le 2 -and ($_.f -ge 3 -or $_.m -ge 3)) {'en_riesgo'}
  else {'otros'}
} | ForEach-Object { [pscustomobject]@{segment=$_.Name; count=$_.Count} })
$discountImpact = @($items | Where-Object discount -GT .5 | Group-Object subcategory | ForEach-Object {
  [pscustomobject]@{subcategory=$_.Name; count=$_.Count; profit=SumField $_.Group 'profit'}
} | Sort-Object profit | Select-Object -First 5)
$totalSales = SumField $items 'sales'; $totalProfit = SumField $items 'profit'
$salesOrder = @($products | Sort-Object sales -Descending)
$profitOrder = @($products | Sort-Object profit -Descending)
$cumulative = [decimal]0; $sales80 = 0
foreach ($p in $salesOrder) { $cumulative += $p.sales; $sales80++; if ($cumulative -ge .8*$totalSales) {break} }
$cumulative = [decimal]0; $profit80 = 0
foreach ($p in $profitOrder) { $cumulative += $p.profit; $profit80++; if ($cumulative -ge .8*$totalProfit) {break} }
$report = [ordered]@{
 source='Sample - Superstore.csv'; row_count=$rows.Count; columns=$rows[0].PSObject.Properties.Name
 null_or_empty=$nulls; duplicate_row_ids=$rows.Count-@($rows | Select-Object -ExpandProperty 'Row ID' -Unique).Count
 unique_orders=@($rows | Select-Object -ExpandProperty 'Order ID' -Unique).Count
 unique_customers=@($rows | Select-Object -ExpandProperty 'Customer ID' -Unique).Count
 unique_products=$products.Count; min_date=($items | Sort-Object date | Select-Object -First 1).date.ToString('yyyy-MM-dd')
 max_date=($items | Sort-Object date | Select-Object -Last 1).date.ToString('yyyy-MM-dd')
 invalid_dates=0; nonpositive_sales=@($items | Where-Object sales -LE 0).Count
 invalid_discounts=@($items | Where-Object { $_.discount -lt 0 -or $_.discount -gt 1 }).Count
 ship_before_order=@($items | Where-Object { $_.ship -lt $_.date }).Count
 total_sales=$totalSales; total_profit=$totalProfit; regions=$regions; annual=$annual
 discounts=$discounts; top_months=@($months | Sort-Object sales -Descending | Select-Object -First 3)
 bottom_months=@($months | Sort-Object sales | Select-Object -First 3)
 top_products_profit=@($products | Sort-Object profit -Descending | Select-Object -First 5)
 bottom_products_profit=@($products | Sort-Object profit | Select-Object -First 5)
 top_products_quantity=@($products | Sort-Object quantity -Descending | Select-Object -First 5)
 top_products_sales=@($products | Sort-Object sales -Descending | Select-Object -First 5)
 category_top_profit=@($products | Group-Object category | ForEach-Object {
   $_.Group | Sort-Object profit -Descending | Select-Object -First 5
 })
 rfm_segments=$segments; rfm_top=@($rfm | Sort-Object monetary -Descending | Select-Object -First 5)
 high_discount_worst_subcategories=$discountImpact
 pareto=@{products=$products.Count; sales80=$sales80; profit80=$profit80}
}
New-Item -ItemType Directory -Path (Split-Path $out) -Force | Out-Null
$report | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $out -Encoding utf8
Write-Output "Guardado: $out"
