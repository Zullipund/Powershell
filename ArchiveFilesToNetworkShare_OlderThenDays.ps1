# Ru
# [Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("cp866")
# En
#[Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("utf-8")

# точка отсчёта времени работы скрипта
$elapsed = [System.Diagnostics.Stopwatch]::StartNew()
$started = Get-Date

################################################ Переменные и модули ###################################################################

# Для распределённой структуры на сетевой шаре с делением по директориям (вот такая структура \$Month\$Week\$Day\)

# Вычисляем неделю
# Function Get-WeekOfMonth
#{
#param ([datetime]$date = (Get-Date))
#$beginningOfMonth = New-Object DateTime($date.Year,$date.Month,1)
#while ($date.Date.AddDays(1).DayOfWeek -ne (Get-Culture).DateTimeFormat.FirstDayOfWeek)
#{
#$date = $date.AddDays(1)
#}
#[int]([Math]::Truncate($date.Subtract($beginningOfMonth).TotalDays / 7) + 1)
#}
#$Week = Get-WeekOfMonth
#$Year = (Get-Date).ToString("yyyy")
#$Month = (Get-Date).ToString("MMMM")
#$Day = (Get-Date).ToString("dddd")
# Сетевая директория для сохранения. 
# $ShareFolder = "\\TEST-VM-SOFT\BuckUP\$Month\$Week\$Day\"
# $ShareFolder = "F:\Temp\backup\$Year.$Month.$Day"

#$ToDay = (Get-Date -uFormat "%y-%m-%d@%H-%M-%S")
$StartDay = (Get-Date).Date
$ToDay = (Get-Date -uFormat "%y_%m_%d")
$ToMonth = (Get-Date -uFormat "%y_%m")
$now = Get-Date
$OlderThenDays = "-2"
$OldDate = $now.AddDays($OlderThenDays)

# Директория цель резервного копирования
$TargetFolder = "D:\Integrator"
$TargetFolder1 = "D:\Partition1"

# Директория временного хранилища файлов на локальной машине
$LocalDir = "D:\Backup\BackupTemp"
$LocalDir1 = "D:\Backup\BackupTemp2"
$LocalZIPDir = "D:\Backup\BackupTemp3"

# Сетевая директория для сохранения
$srcComputerName = [System.Net.Dns]::GetHostByName("") | FL HostName | Out-String | %{ "{0}" -f $_.Split(':')[1].Trim() };
NI -Path \\TEST-VM-SOFT\BuckUP\TEST\ -Name $srcComputerName -Type Directory
$NetworkShare = "\\TEST-VM-SOFT\BuckUP\TEST\$srcComputerName"

# Удаление временных каталогов для архивации. Очистка старой копии директорий
RI -Path "D:\Backup\BackupTemp" -Recurse -Force
RI -Path "D:\Backup\BackupTemp2" -Recurse -Force

# Создаем новый каталог (по дате для долговременного хранения), каталоги для промежуточного хранения и архивации 
#   NI $ShareFolder\$Year\$Month\$Week\$Day -Type Directory
NI -Path D:\Backup -Name BackupTemp -Type Directory
NI -Path D:\Backup -Name BackupTemp2 -Type Directory
NI -Path D:\Backup -Name BackupTemp3 -Type Directory
# программа архивации
$Progzip = "$env:ProgramFiles\7-Zip\7z"

# Имя файла с текущей датой месяца
$FileName = "Integrator_LOGS_$ToDay.7z"
$FileName2 = "Partition1_LOGS_$ToDay.7z"

################################################### Исполняемый код  #########################################################

# Скопировать в локальную директорию файлов и папок сервере
# Запуск архиватора со складированием месячного архива локально с быстрым (-mx1) сжатием  и добавление изменений в месячный архив
# Запуск копирования архива из временного ресурса в сетевую директорию
# Удаление файлов на $LocalZIPDir

# Копируем локальную директорию $LocalDir
CP -Path $TargetFolder -Destination $LocalDir -Force -recurse
CP -Path $TargetFolder1 -Destination $LocalDir1 -Force -recurse

# Создание архива всех файлов $LocalDir , перемещение архива на локальную дирекорию временного хранения архивов $LocalZIPDir, с именем $FileName . 
&$Progzip a -ssw -mx1 -y $LocalZIPDir\$FileName $LocalDir\*
# Создание архива всех файлов $LocalDir1 , перемещение архива на локальную дирекорию временного хранения архивов $LocalZIPDir, с именем $FileName1 . 
&$Progzip a -ssw -mx1 -y $LocalZIPDir\$FileName1 $LocalDir1\*


# Копируем файлы за сегодня на сетевую директорию $NetworkShare .
# (Get-Date).Date  - дата начала дня 00:00:00 часов .-gt больше чем эта дата , подходит под условие
$files = Get-ChildItem -path $LocalZIPDir -recurse -Force | Where {$_.LastWriteTime -gt "$StartDay"}
foreach ($file in $files)
{
Copy-Item $file.FullName -Destination $NetworkShare
}

# Удалить файлы архивы, старее $OlderThenDays
$files = Get-ChildItem -path $LocalZIPDir -recurse -Force | Where {$_.LastWriteTime -le "$OldDate"}
foreach ($file in $files)
{
Remove-Item $file.FullName -Force -Recurse
}

# Удаление временных каталогов с архивами
# RI -Path "D:\Backup\BackupTemp3" -Recurse -Force
# RI -Path "D:\Backup\BackupTemp2" -Recurse -Force
# RI -Path "D:\Backup\BackupTemp" -Recurse -Force

#####################################################################################################################################
# Время работы скрипта
$totaltime = ($elapsed.Elapsed.toString().Split(".")[0])
Write-Host -ForegroundColor Yellow -Verbose "Archive Files started: $started"
Write-Host -ForegroundColor Green -Verbose "Archive Files completed: $(Get-Date)"
Write-Host -ForegroundColor Cyan -Verbose "Total Elapsed time: $totaltime"