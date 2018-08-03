# Ru
# [Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("cp866")
# En
#[Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("utf-8")

# точка отсчёта времени работы скрипта
$elapsed = [System.Diagnostics.Stopwatch]::StartNew()
$started = Get-Date

################################################ Переменные и модули ###################################################################

# Создать бэкап заданий планировщика Windows
# Директория цель резервного копирования
$TargetFolder = "C:\Windows\System32\Tasks\GBZ_prod"
# Сетевая директория для сохранения
$srcComputerName = [System.Net.Dns]::GetHostByName("") | FL HostName | Out-String | %{ "{0}" -f $_.Split(':')[1].Trim() };
NI -Path \\TEST-VM-SOFT\BuckUP\TEST\ -Name $srcComputerName -Type Directory
$NetworkShare = "\\TEST-VM-SOFT\BuckUP\TEST\$srcComputerName"
# Создаем новый каталог долговременного хранения
NI -Path $NetworkShare -Name ShedullerTASKS -Type Directory

################################################### Исполняемый код  #########################################################

# Копируем локальную директорию $LocalDir
CP -Path $TargetFolder -Destination $NetworkShare\ShedullerTASKS -Force -recurse

#
#####################################################  Восстановление заданий из бэкап директории  ######################################
################################################ Переменные и модули ###################################################################
# Сетевая директория для сохранения
#$NetworkShare = "\\TEST-VM-SOFT\BuckUP\TEST\$srcComputerName"
#$BackupTaskFolder = "$NetworkShare\ShedullerTASKS"
# $TaskUser = read-host " Введите имя пользователя в формате Domain\User или LocalPCName\User"
# $TaskUserPassword = read-host "Введите пароль пользователя $TaskUser"
#$TaskUser = "group.local\SQLAgent-DB11"
#$TaskUserPassword = "Jz%$f4XKt4tty6ol8jt"
#$principal = New-ScheduledTaskPrincipal -UserID $TaskUser -LogonType S4U

# либо вариант такой
#$principal = New-ScheduledTaskPrincipal -UserId "$($env:USERDOMAIN)\$($env:USERNAME)" -LogonType ServiceAccount
#$principal = New-ScheduledTaskPrincipal -UserId "$($env:USERDOMAIN)\$($env:USERNAME)" -LogonType S4U

################################################### Исполняемый код  #########################################################

# Добавление в планировщик заданий из $BackupTaskFolder по имени файла . Запус от имени пользователя $TaskUser
#$Files = Get-Childitem $BackupTaskFolder -Recurse
#foreach ($File in $Files)
#{
#$principal = New-ScheduledTaskPrincipal -UserID $TaskUser -LogonType S4U
#Register-ScheduledTask -Xml (get-content $File.FullName | out-string) -TaskName "GBZ_prod\WORK_Task\$File" -user $TaskUser -password $TaskUserPassword –Force
#}

#

#####################################################################################################################################
# Время работы скрипта
$totaltime = ($elapsed.Elapsed.toString().Split(".")[0])
Write-Host -ForegroundColor Yellow -Verbose "Archive ShedullerTASKS started: $started"
Write-Host -ForegroundColor Green -Verbose "Archive ShedullerTASKS completed: $(Get-Date)"
Write-Host -ForegroundColor Cyan -Verbose "Total Elapsed time: $totaltime"