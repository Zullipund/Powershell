# Ru
# [Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("cp866")
# En
#[Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("utf-8")

# точка отсчёта времени работы скрипта
$elapsed = [System.Diagnostics.Stopwatch]::StartNew()
$started = Get-Date

################################################ Переменные и модули ###################################################################

# Export regpath to reg file networkshare
# Экспорт ветки реестра в сетевую директорию $NetworkShare .
# Название файла состоит из имени локального компьютера и расширения $srcComputerName.reg
# Export regpath to reg file networkshare
$srcComputerName = [System.Net.Dns]::GetHostByName("") | FL HostName | Out-String | %{ "{0}" -f $_.Split(':')[1].Trim() };

NI -Path \\TEST-VM-SOFT\BuckUP\TEST\ -Name $srcComputerName -Type Directory
NI -Path \\TEST-VM-SOFT\BuckUP\TEST\$srcComputerName\ -Name ODBC_INI -Type Directory
$NetworkShare = "\\TEST-VM-SOFT\BuckUP\TEST\$srcComputerName\"
$TargetPath = "HKLM\SOFTWARE\ODBC\ODBC.INI"

################################################### Исполняемый код  #########################################################
reg export $TargetPath "$NetworkShare\ODBC_INI\$srcComputerName.reg" /y


#####################################################  Восстановление reg ключа из бэкап директории  ######################################
################################################ Переменные и модули ###################################################################

# import reg file from networkshare
# импорт ветки реестра из сетевой директории
# $NetworkShare = "\\TEST-VM-SOFT\BuckUP\TEST\$srcComputerName\"
# reg import $NetworkShare\ODBC_INI\$srcComputerName.reg

#####################################################################################################################################
# Время работы скрипта
$totaltime = ($elapsed.Elapsed.toString().Split(".")[0])
Write-Host -ForegroundColor Yellow -Verbose "Archive REGkey started: $started"
Write-Host -ForegroundColor Green -Verbose "Archive REGkey completed: $(Get-Date)"
Write-Host -ForegroundColor Cyan -Verbose "Total Elapsed time: $totaltime"