# Ru
# [Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("cp866")
# En
#[Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("utf-8")

# точка отсчёта времени работы скрипта
$elapsed = [System.Diagnostics.Stopwatch]::StartNew()
$started = Get-Date
#Модули
#импортируем модуль
Import-Module NTFSSecurity
#Переменные
#Директория назначения. Акаунт для применения к директории
#Определяем SID пользователя или группы безопасности
#[Security2.IdentityReference2]’IIS_IUSRS’
#[Security2.IdentityReference2]’USERS’
# Аккаунты можно указывать в следующем виде :
# 'localhost\Username','Username','Пользователь','SID'
# $account = 'S7-03-SDF9887\Everyone','Everyone','Все','S-1-1-0'
# $account = 'S-1-5-32-568','IIS_IUSRS'
# $account = 'S-1-5-32-545','USERS'
# $account = USR1CV8
$path1 = 'C:\inetpub\wwwroot','C:\Program Files\1cv8'
$path2 = 'C:\ProgramData\1C\','D:\srvinfo'
$path3 = 'C:\ProgramData\1C\licenses'
$account1 = 'IIS_IUSRS','USERS'
$account2 = 'USR1CV8'
$account3 = 'USERS'
# C:\inetpub\wwwroot | IIS_IUSRS , USERS | read & execute | ThisFolderSubfoldersAndFiles
# C:\Program Files\1cv8 | IIS_IUSRS , USERS | read & execute | ThisFolderSubfoldersAndFiles
# D:\srvinfo\ | USR1CV8 | FULL | ThisFolderSubfoldersAndFiles
# C:\ProgramData\1C\ | USR1CV8 | FULL | ThisFolderSubfoldersAndFiles
# C:\ProgramData\1C\licenses | USERS | MODIFY | ThisFolderSubfoldersAndFiles

# Исполняемый код
Add-NTFSAccess -Path $path1 -Account $account1 -AccessRights ReadAndExecute -AppliesTo ThisFolderSubfoldersAndFiles
Add-NTFSAccess -Path $path2 -Account $account2 -AccessRights FullControl -AppliesTo ThisFolderSubfoldersAndFiles
Add-NTFSAccess -Path $path3 -Account $account3 -AccessRights Modify -AppliesTo ThisFolderSubfoldersAndFiles

# Время работы скрипта
$totaltime = ($elapsed.Elapsed.toString().Split(".")[0])
Write-Host -ForegroundColor Yellow -Verbose "Add permissions started: $started"
Write-Host -ForegroundColor Green -Verbose "Add permissions completed: $(Get-Date)"
Write-Host -ForegroundColor Cyan -Verbose "Total Elapsed time: $totaltime"
