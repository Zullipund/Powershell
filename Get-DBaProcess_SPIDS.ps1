# Ru
# [Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("cp866")
# En
#[Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("utf-8")

# точка отсчёта времени работы скрипта
$elapsed = [System.Diagnostics.Stopwatch]::StartNew()
$started = Get-Date
$ToDay_Time = (Get-Date -uFormat "%y-%m-%d@%H-%M-%S")

################################################ Переменные и модули ###################################################################

Import-Module dbatools
$SRV_NEW = "SRVsqlPROD.group.local"
$Spids = "59","94"
$cred = Get-Credential group.local\ADuser
$LocalDir = "C:\temp"
################################################ Исполняемый код ###################################################################
$DBAProcess_LOG = Get-DbaProcess -SqlServer $SRV_NEW -SqlCredential $cred -Spid $Spids -
$DBAProcess_LOG >> $LocalDir\DBAProcess_LOG_$ToDay_Time.txt

# Время работы скрипта
$totaltime = ($elapsed.Elapsed.toString().Split(".")[0])
Write-Host -ForegroundColor Yellow -Verbose "Test SPN missing started: $started"
Write-Host -ForegroundColor Green -Verbose "Test SPN missing completed: $(Get-Date)"
Write-Host -ForegroundColor Cyan -Verbose "Total Elapsed time: $totaltime"