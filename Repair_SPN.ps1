# Ru
# [Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("cp866")
# En
#[Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("utf-8")

# точка отсчёта времени работы скрипта
$elapsed = [System.Diagnostics.Stopwatch]::StartNew()
$started = Get-Date

################################################ Переменные и модули ###################################################################

Import-Module dbatools

$ToDay_Time = (Get-Date -uFormat "%y-%m-%d@%H-%M-%S")
$ADDC = "DC16MD1.group.local" # контроллер домена для поиска
$cred = Get-Credential GROUPLOCAL\AdmWinSrv # Windows авторизация
$sqlcred = Get-Credential sa # SQL авторизация
#$ADadmin = Get-Credential GROUPLOCAL\adadmin # AD пользователь с правами для внесения изменений AD("Read servicePrincipalName" и "Write servicePrincipalName")
$LocalDir = "C:\temp"

############################################## Получить список серверов AD  #################################################################

#Найти все компьютеры, на которых стоит серверная операционная система.
# Отфильтровать по уникальным именам

$ADServerComputers = Get-ADComputer -Filter "OperatingSystem -like '*Server*'" -properties OperatingSystem,OperatingSystemServicePack | Select Name,Op
$ADServerComputers_unique_name = @($ADServerComputers.Name) | Sort-Object -Property @{Expression={$_.Trim()}} -Unique
#$ADServerComputers_unique_name | Format-Table # отобразить
$ADServerComputers_unique_name >> $LocalDir\ADServerComputers_unique_name_$ToDay_Time.txt # Выгрузить в файл

#Список операционных систем в домене:
#Get-ADComputer -Filter * -Properties OperatingSystem | Select OperatingSystem -unique | Sort OperatingSystem
#Найти все компьютеры, на которых стоит серверная операционная система:
#Get-ADComputer -Filter "OperatingSystem -like '*Server*'" -properties OperatingSystem,OperatingSystemServicePack | Select Name,Op* | format-list
############################################ Отфильтровать на наличие SQL ###################################################################
# Найти SQL сервера
# Только из AD , используя контроллер домена -DomainController
# Выгрузить список в переменную и файл
# отсортировать список (с удалением дубликатов) на уникальность
# Используя учётную запись Windows $cred
# Используя учётную запись SQL $sqlcred

$SQLsrv = @($ADServerComputers_unique_name) | Find-DbaInstance -DomainController $ADDC -Credential $cred -SqlCredential $sqlcred -ScanType All -Verbose
$SQLsrv_unique_name = @($SQLsrv).ComputerName | Sort-Object -Property @{Expression={$_.Trim()}} -Unique -Verbose
$SQLsrv_unique_name >> $LocalDir\SQLsrv_unique_name_$ToDay_Time.txt

# Просканировать все компьютеры AD на наличие SQL :
# $SQLsrv = Find-DbaInstance -DiscoveryType Domain -DomainController $ADDC -Credential $cred -SqlCredential $sqlcred -ScanType All  -Verbose

############################################ запустить проверку заданного списка серверов #################################################
# Используя учётную запись Windows $cred
# Заданный список серверов
# Используя компьютеры домена без фильтрации по sql:
#$TESTDBASPN = Test-DbaSpn -ComputerName $ADServerComputers_unique_name -Credential $cred -Verbose

# Используя конкретные компьютеры домена:
# $SQLsrv_unique_name = "SRVappcustom.group.local","srv2SQLDB.group.local","srv1SQLDB.group.local"

$TESTDBASPN = Test-DbaSpn -ComputerName $SQLsrv_unique_name -Credential $cred -Verbose

# Удовлетворяет следующим условиям
# Запущено под локальный аккаунт NT Service\MSSQLSERVER + InstanceServiceAccount = DOMAIN\HOSTNAME ( пример group.local\srv2SQLDB$ ) + SPN на учётную запись КОМПЬЮТЕРА прописаны в AD
# Запущено под доменный аккаунт пользователя + SPN на учётную запись ПОЛЬЗОВАТЕЛЯ прописаны в AD
# локальный аккаунт NT Service\MSSQLSERVER
# 
$TESTDBASPN1 = @($TESTDBASPN | where-object {$_.IsSet -eq $true , $_.error -eq 'None' , $_.Warning -eq 'None' } ).ComputerName | Sort-Object -Property @{Expression={$_.Trim()}} -Unique | Format-Table
$TESTDBASPN1 >> $LocalDir\Unique_Servers_Name_SPN_all_good_$ToDay_Time.txt #список серверов без наличия проблем
$TESTDBASPN | where-object {$_.IsSet -eq $true , $_.error -eq 'None' , $_.Warning -eq 'None' } >> $LocalDir\extendedINFO_SPN_all_good_servers_$ToDay_Time.txt #список серверов без наличия проблем расширенная информация

#  Удовлетворяет следующим условиям
# Запущено под доменный аккаунт пользователя + SPN на учётную запись ПОЛЬЗОВАТЕЛЯ НЕ прописаны в AD

$TESTDBASPN2 = @($TESTDBASPN| where-object {$_.IsSet -eq $False -and $_.error -eq 'SPN missing'-and $_.InstanceServiceAccount -like "GROUPLOCAL\*" }).ComputerName | Sort-Object -Property @{Expression={$_.Trim()}} -Unique | Format-Table
$TESTDBASPN2 >> $LocalDir\Unique_Servers_Name_for_AD_user_SPN_missing_$ToDay_Time.txt #список серверов с проблемой
$TESTDBASPN | where-object {$_.IsSet -eq $False -and $_.error -eq 'SPN missing'-and $_.InstanceServiceAccount -like "GROUPLOCAL\*" } >> $LocalDir\extendedINFO_for_AD_user_SPN_missing_$ToDay_Time.txt #список серверов с проблемой расширенная информация

############ Исправить #################
# Добавить доменной учётной записи ПОЛЬЗОВАТЕЛЯ нужные SPN
# Не добавлять делегирование

#TESTDBASPN | where-object {$_.IsSet -eq $False -and $_.error -eq 'SPN missing'-and $_.InstanceServiceAccount -like "GROUPLOCAL\*" } | Set-DbaSpn -Credential $ADadmin -NoDelegation

########################################

#Удовлетворяет следующим условиям
# 
# Запущено под локальный аккаунт NT Service\MSSQLSERVER + InstanceServiceAccount = DOMAIN\HOSTNAME ( пример group.local\srv2SQLDB$ ) + SPN на учётную запись КОМПЬЮТЕРА НЕ прописаны в AD
# Запущено под локальный аккаунт пользователя Системы + InstanceServiceAccount = DOMAIN\HOSTNAME ( пример group.local\srv2SQLDB$ ) + SPN на учётную запись КОМПЬЮТЕРА НЕ прописаны в AD
#
#
$TESTDBASPN3 = @($TESTDBASPN| where-object {$_.IsSet -eq $False -and $_.error -eq 'SPN missing'-and $_.InstanceServiceAccount -like "group.local\*" }).ComputerName | Sort-Object -Property @{Expression={$_.Trim()}} -Unique | Format-Table
$TESTDBASPN3 >> $LocalDir\Unique_Servers_Name_for_AD_computers_SPN_missing_$ToDay_Time.txt #список серверов с проблемой
$TESTDBASPN | where-object {$_.IsSet -eq $False -and $_.error -eq 'SPN missing'-and $_.InstanceServiceAccount -like "group.local\*" } >> $LocalDir\extendedINFO_for_AD_computers_SPN_missing_$ToDay_Time.txt #список серверов с проблемой расширенная информация
############ Исправить #################
# Добавить доменной учётной записи КОМПЬЮТЕРА нужные SPN
# Не добавлять делегирование

#$TESTDBASPN | where-object {$_.IsSet -eq $False -and $_.error -eq 'SPN missing'-and $_.InstanceServiceAccount -like "group.local\*" } | Set-DbaSpn -Credential $ADadmin -NoDelegation


# Время работы скрипта
$totaltime = ($elapsed.Elapsed.toString().Split(".")[0])
Write-Host -ForegroundColor Yellow -Verbose "Test SPN missing started: $started"
Write-Host -ForegroundColor Green -Verbose "Test SPN missing completed: $(Get-Date)"
Write-Host -ForegroundColor Cyan -Verbose "Total Elapsed time: $totaltime"