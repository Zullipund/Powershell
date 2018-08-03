# Ru
# [Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("cp866")
# En
#[Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("utf-8")

# точка отсчёта времени работы скрипта
$elapsed = [System.Diagnostics.Stopwatch]::StartNew()
$started = Get-Date

################################################ Переменные и модули ###################################################################

Import-Module dbatools

# Миграция с сервера на сервер через сетевую папку несколькими командами.
# Выгрузить бэкап в локальную директорию, расшаренную в сеть.
# $LocalShare1 = $NetworkShare1
# Скопировать бэкап в локальную директорию нового сервера, расшаренную в сеть
# $LocalShare2 = $NetworkShare2
# Восстановить бэкап из сетевой папки . По идее сетевая директория может быть одна.
# Разделено на две независимые сетевые директории

# Databases - Список Баз, необходимых для переноса
# SRV_OLD -Сервер исходный, откуда идёт перенос или миграция
# SRV_NEW - Сервер назначения
# NetworkShare - Сетевая директория для обмена бэкапами между серверами
# BASEDstDataDir - новая директория для файлов базы данных 
# BASEDstLogDir - новая директория для логов базы данных

# $Databases = "BASE_AAA", "BASE_BBB", "BASE_CCC", "BASE_DDD"
$Databases = "BASE_AAA"
$SRV_OLD = "SRVsqlBASEPROD.group.local"
$SRV_NEW = "SRVsqlPROD.group.local"
$LocalShare1 = "E:\Backups\"
$LocalShare2 = "K:\MSSQL12.MSSQLSERVER\MSSQL\Backup"
$NetworkShare = "\\$SRV_OLD\Backups\"
$NetworkShare1 = "\\$SRV_NEW\Backup"
$BASEDstDataDir = "F:\MSSQL12.MSSQLSERVER\MSSQL\DATA"
$BASEDstLogDir = "D:\MSSQL12.MSSQLSERVER\MSSQL\Data"
#$cred = Get-Credential group.local\ADuser

################################################### Исполняемый код  #########################################################

# Выгрузить в локальную директорию, используя компрессию

$startBackupDbaDatabaseSplat = @{
    SqlInstance = $SRV_OLD
#	SqlCredential = $cred
    Database = $Databases
    Type = 'Full'
    CompressBackup = $true
    BackupDirectory = $LocalShare1
    Verbose = $true
    #OutputScriptOnly = $true
}
 Backup-DbaDatabase @startBackupDbaDatabaseSplat

# Backup-DbaDatabase -SqlInstance $SRV_OLD -SqlCredential $cred -Database $Databases -Type Full -CompressBackup -BackupDirectory $LocalShare1 -Verbose -OutputScriptOnly


# Копируем результат на сетевую директорию $NetworkShare1
$files = Get-ChildItem -path $NetworkShare -recurse -Force
foreach ($file in $files)
{
Move-Item $file.FullName -Destination $NetworkShare1 -Verbose
}

#####################################################  Восстановление DB из бэкап директории  ######################################
################################################ Переменные и модули ###################################################################
#$RestoreTime = Get-Date('07:30 07/06/2018')


################################################### Исполняемый код  #########################################################
# Восстановить из сетевой директории

#$startRestoreDbaDatabaseSplat = @{
#    SqlInstance = $SRV_NEW
#    Path = $LocalShare2 
#    DatabaseName = $Databases
#    MaintenanceSolutionBackup = $true
#    DestinationDataDirectory = $BASEDstDataDir
#    DestinationLogDirectory = $BASEDstLogDir
#    AllowContinue = $true
#    WithReplace = $true
#    Verbose = $true    
##    #RestoreTime = $RestoreTime
##    #TrustDbBackupHistory = $true

##   #OutputScriptOnly = $true
#}
#Restore-DbaDatabase @startRestoreDbaDatabaseSplat

# Назначить владельцем перечисленных баз пользователя  SQL "USERSERVICE" , либо доменного пользователя "DOMAIN\account"
# Set-DbaDatabaseOwner -SqlServer $SRV_NEW  -Databases $Databases -TargetLogin USERSERVICE

#####################################################################################################################################
# Время работы скрипта
$totaltime = ($elapsed.Elapsed.toString().Split(".")[0])
Write-Host -ForegroundColor Yellow -Verbose "BackupRestoreDB started: $started"
Write-Host -ForegroundColor Green -Verbose "BackupRestoreDB completed: $(Get-Date)"
Write-Host -ForegroundColor Cyan -Verbose "Total Elapsed time: $totaltime"