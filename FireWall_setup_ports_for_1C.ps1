# Ru
# [Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("cp866")
# En
#[Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("utf-8")

# точка отсчёта времени работы скрипта
$elapsed = [System.Diagnostics.Stopwatch]::StartNew()
$started = Get-Date

################################################ Переменные и модули ###################################################################

# стандартный модуль win 8 - win2012
Import-Module NetSecurity
# список из 27 коммандлетов
# Get-Command -Noun "*Firewall*"

################################################### Исполняемый код  #########################################################

# открыть порты SQL отдельными правилами,в зависимости от используемых компонентов и возможностей
# для подключения к SQL Server с других компьютеров MSSQL_TCP_1433_accept
# чтобы другие компьютеры могли обнаруживать данный экземпляр SQL Server MSSQL_UDP_1434_accept
# Database Mirroring использует MSSQL_TCP_7022_accept , MSSQL_TCP_5022_accept , именнованые экземпляры MSSQL_TCP_5023_accept

New-NetFirewallRule -Name "MSSQL_TCP_1433_accept" -DisplayName "MSSQL_TCP_1433_accept" -Enabled True -Direction Inbound -Profile Domain, Private -Action Allow -LocalPort 1433 -Protocol TCP -RemotePort Any
New-NetFirewallRule -Name "MSSQL_UDP_1433_accept" -DisplayName "MSSQL_TCP_1433_accept" -Enabled True -Direction Inbound -Profile Domain, Private -Action Allow -LocalPort 1433 -Protocol UDP -RemotePort Any
New-NetFirewallRule -Name "MSSQL_TCP_1434_accept" -DisplayName "MSSQL_TCP_1434_accept" -Enabled True -Direction Inbound -Profile Domain, Private -Action Allow -LocalPort 1434 -Protocol TCP -RemotePort Any
New-NetFirewallRule -Name "MSSQL_UDP_1434_accept" -DisplayName "MSSQL_TCP_1434_accept" -Enabled True -Direction Inbound -Profile Domain, Private -Action Allow -LocalPort 1434 -Protocol UDP -RemotePort Any
New-NetFirewallRule -Name "MSSQL_TCP_5022_accept" -DisplayName "MSSQL_TCP_5022_accept" -Enabled True -Direction Inbound -Profile Domain, Private -Action Allow -LocalPort 5022 -Protocol TCP -RemotePort Any
New-NetFirewallRule -Name "MSSQL_TCP_5023_accept" -DisplayName "MSSQL_TCP_5023_accept" -Enabled True -Direction Inbound -Profile Domain, Private -Action Allow -LocalPort 5023 -Protocol TCP -RemotePort Any
New-NetFirewallRule -Name "MSSQL_TCP_7022_accept" -DisplayName "MSSQL_TCP_7022_accept" -Enabled True -Direction Inbound -Profile Domain, Private -Action Allow -LocalPort 7022 -Protocol TCP -RemotePort Any

# открыть сетевое обнаружение ICMPv4
Set-NetFirewallRule -DisplayName “File and Printer Sharing (Echo Request - ICMPv4-In)” -Enabled True -Profile Domain, Private -Action Allow
Set-NetFirewallRule -DisplayName "Virtual Machine Monitoring (Echo Request - ICMPv4-In)" -Enabled True -Profile Domain, Private -Action Allow

# Общее правило для NetBackup agent
# New-NetFirewallRule -Name "NetBackup_TCP" -DisplayName "NetBackup_TCP" -Enabled True -Direction Inbound -Profile Domain, Private, Public -Action Allow -LocalPort 1556, 1557, 13720, 13724, 13782, 13783 -Protocol TCP -RemotePort Any

# Стандартные порты 1С
# 1560-1591 - для рабочего процесса;
# 1541 - для менеджера кластера;
# 1540 - для агента сервера (не обязательно, если центральный сервер кластера один)
# Sentinel License Manager ?????? / открывают для программы ANY ports
New-NetFirewallRule -Name "1С_TCP_1541_accept" -DisplayName "1С_TCP_1541_accept" -Enabled True -Direction Inbound -Profile Domain, Private -Action Allow -LocalPort 1541 -Protocol TCP -RemotePort Any
New-NetFirewallRule -Name "1С_TCP_1560-1591_accept" -DisplayName "1С_TCP_1560-1591_accept" -Enabled True -Direction Inbound -Profile Domain, Private -Action Allow -LocalPort 1560-1591 -Protocol TCP -RemotePort Any
New-NetFirewallRule -Name "1С_TCP_1540_accept" -DisplayName "1С_TCP_1540_accept" -Enabled True -Direction Inbound -Profile Domain, Private -Action Allow -LocalPort 1540 -Protocol TCP -RemotePort Any


# Если политика безопасности не разрешают открывать порт для всех. А делается разрешение конкретным программам (в зависимости от версии) , нужным 1С.
# New-NetFirewallRule -Name "1С_8.3.10.2168_ragent_accept" -DisplayName "1С_8.3.10.2168_ragent_accept" -Enabled True -Direction Inbound -Program %ProgramFiles%\1Cv8\8.3.10.2168\bin\ragent.exe -Profile Domain, Private -Action Allow -LocalPort Any -Protocol TCP -RemotePort Any
# New-NetFirewallRule -Name "1С_8.3.10.2168_rmngr_accept" -DisplayName "1С_8.3.10.2168_rmngr_accept" -Enabled True -Direction Inbound -Program %ProgramFiles%\1Cv8\8.3.10.2168\bin\rmngr.exe -Profile Domain, Private -Action Allow -LocalPort Any -Protocol TCP -RemotePort Any
# New-NetFirewallRule -Name "1С_8.3.10.2168_rphost_accept" -DisplayName "1С_8.3.10.2168_rphost_accept" -Enabled True -Direction Inbound -Program %ProgramFiles%\1Cv8\8.3.10.2168\bin\rphost.exe -Profile Domain, Private -Action Allow -LocalPort Any -Protocol TCP -RemotePort Any

#####################################################################################################################################
# Время работы скрипта
$totaltime = ($elapsed.Elapsed.toString().Split(".")[0])
Write-Host -ForegroundColor Yellow -Verbose "FireWall_setup_ports started: $started"
Write-Host -ForegroundColor Green -Verbose "FireWall_setup_ports completed: $(Get-Date)"
Write-Host -ForegroundColor Cyan -Verbose "Total Elapsed time: $totaltime"