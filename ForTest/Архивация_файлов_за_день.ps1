Function Get-WeekOfMonth
{
param ([datetime]$date = (Get-Date))
$beginningOfMonth = New-Object DateTime($date.Year,$date.Month,1)
while ($date.Date.AddDays(1).DayOfWeek -ne (Get-Culture).DateTimeFormat.FirstDayOfWeek)
{
$date = $date.AddDays(1)
}
[int]([Math]::Truncate($date.Subtract($beginningOfMonth).TotalDays / 7) + 1)
}

$Year = (Get-Date).ToString("yyyy")
$Month = (Get-Date).ToString("MMMM")
$Day = (Get-Date).ToString("dddd")
$Week = Get-WeekOfMonth

$zip = "$env:ProgramFiles\7-Zip\7z"
# Создаёт архив на локальной машине
$FilesArh = "c:\Test\Test.zip"
# После создания отправляет архив по сети
$ShareFolder = "\\AVTOZ-VM-SOFT\BuckUPPowershell\$Month\$Week\$Day\"
# $ShareFolder = "F:\Temp\backup\$Year.$Month.$Day"

# Путь, что именно подвергается архиввации
$Dir = «C:\base»
# $Dir = "\\Srv\dfs\folder"

$DirCopy=$Dir+»Copy»

cp $Dir $DirCopy -Recurse -Filter *.mdb

&$zip a «$FilesArh» $DirCopy

rm $DirCopy -Recurse -Force

if ($LastExitCode -eq 0)
{
if ( -not (Test-Path $ShareFolder))
{
md $ShareFolder | Out-Null
}
Copy-Item $FilesArh -Destination $ShareFolder
}
else
{
Write-Host "Архивирование завершилось неудачей."
}

