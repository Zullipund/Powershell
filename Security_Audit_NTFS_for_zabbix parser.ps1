# Ru
# [Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("cp866")
# En
#[Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("utf-8")

# точка отсчёта времени работы скрипта
$elapsed = [System.Diagnostics.Stopwatch]::StartNew()
$started = Get-Date

################################################ Переменные и модули ###################################################################

# Install-Module -Name NTFSSecurity
# https://github.com/raandree/NTFSSecurity/releases
# Проверяем доступность модуля в общем списке
# Get-Module -ListAvailable
#Получть SID пользователя или группы безопасности S-1-1-0
#[Security2.IdentityReference2]’Все’

Import-Module NTFSSecurity

#Директория назначения. Аккаунт для применения к директории. может принимать значения "Все" or "Everyone" or "S-1-1-0" , DOMAIN\User1.
$path = 'C:\ProgramData\1C\','D:\srvinfo','C:\inetpub\wwwroot','C:\Program Files\1cv8'
$account = 'S-1-1-0'

################################################ Исполняемый код ###################################################################
# Правило № 1.
# Назначение прав аудита "Изменение" (изменение, чтение и выполнение, чтение содержимого папки,чтение,запись ) eventlog 4656
# для пользователя "все" (Everyone)
# Аудит отказа
# Применение к директории , поддиректориям , и файлам
# С наследованием (Inheritance enabled)

# Правило № 2.
# Назначение прав аудита "Смена разрешений" (change permissions ).eventlog 4670
# для пользователя "все" (Everyone)
# Аудит успеха
# Применение к директории , поддиректориям , и файлам .
# С наследованием (Inheritance enabled)

Add-NTFSAudit -Path $path -Account $account -AccessRights Modify -AuditFlags Failure -AppliesTo ThisFolderSubfoldersAndFiles
Add-NTFSAudit -Path $path -Account $account -AccessRights ChangePermissions -AuditFlags Success -AppliesTo ThisFolderSubfoldersAndFiles

# Audit
# Собрать список прав аудита без наследованием рекурсивно снизу
# dir $path -Recurse| Get-NTFSAudit –ExcludeInherited
# Собрать список прав аудита с наследованием рекурсивно снизу (Inheritance Enabled)
dir $path -Recurse| Get-NTFSAudit

# NTFS
# собрать список прав NTFS без наследования рекурсивно снизу (Inheritance Disabled)
# dir $path -Recurse| Get-NTFSAccess –ExcludeInherited
# Собрать список прав NTFS с наследованием рекурсивно снизу (Inheritance Enabled)
# dir $path -Recurse| Get-NTFSAccess

# Время работы скрипта
$totaltime = ($elapsed.Elapsed.toString().Split(".")[0])
Write-Host -ForegroundColor Yellow -Verbose "NTFS audit started: $started"
Write-Host -ForegroundColor Green -Verbose "NTFS audit completed: $(Get-Date)"
Write-Host -ForegroundColor Cyan -Verbose "Total Elapsed time: $totaltime"
