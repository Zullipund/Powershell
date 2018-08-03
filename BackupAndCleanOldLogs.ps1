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

#DATA = "%y-%m-%d
#TIME = %H-%M-%S"
#$ToDay = (Get-Date -uFormat "%y-%m-%d@%H-%M-%S")
$ToDay = (Get-Date -uFormat "%y_%m")
$now = Get-Date
# устанавливаем дату для нахождения элементов, старше 1 месяца
#$OlderThenMonths = "-1"
#$OldDate = $now.AddMonths($OlderThenMonths)

# устанавливаем дату для нахождения элементов, старше 31 дней
$OlderThenDays = "-30"
$OldDate = $now.AddDays($OlderThenDays)

# Директория источник старых файлов
$TargetFolder = "D:\logs\"
$TargetFolder2 = "D:\partitions\logs\"
# Директория временного хранилища файлов на локальной машине
$LocalDir = "D:\Backup\BackupTemp"
$LocalDir2 = "D:\Backup\BackupTemp2"
# Сетевая директория для сохранения
#$ShareFolder = "\\TEST-VM-SOFT\BuckUP\TEST\"
$ShareFolder = "\\TEST-VM-SOFT\BuckUP\LOGS\"
# Создаем новый каталог по дате для долговременного хранения, каталоги для промежуточного хранения и архивации 
#   NI $ShareFolder\$Year\$Month\$Week\$Day -Type Directory 
      NI -Path D:\Backup -Name BackupTemp -Type Directory
         NI -Path D:\Backup -Name BackupTemp2 -Type Directory

# программа архивации
$Progzip = "$env:ProgramFiles\7-Zip\7z"
# Имя файла с текущей датой
$FileName = "Integrator_LOGS_$ToDay.7z"
$FileName2 = "Partition1_LOGS_$ToDay.7z"

################################################### Исполняемый код  #########################################################

# Перемещаем файлы, старее $OlderThenDays дня в локальную директорию ,заданную в переменной $LocalDir
$files = Get-ChildItem -path $TargetFolder -recurse -Force | Where {$_.LastWriteTime -lt "$OldDate"}
foreach ($file in $files)
{
Move-Item $file.FullName -Destination $LocalDir
}

# Создание архива всех файлов в $LocalDir , перемещение архива на сетевую шару $ShareFolder , -sdel , с именем $FileName . 
&$Progzip a -ssw -mx9 -y $ShareFolder$FileName $LocalDir\*

# Перемещаем файлы, старее $OlderThenDays дня в локальную директорию ,заданную в переменной $LocalDir2
$files = Get-ChildItem -path $TargetFolder2 -recurse -Force | Where {$_.LastWriteTime -lt "$OldDate"}
foreach ($file in $files)
{
Move-Item $file.FullName -Destination $LocalDir2
}

# Создание архива всех файлов в $LocalDir2 , перемещение архива на сетевую шару $ShareFolder , -sdel , с именем $FileName2 . 
&$Progzip a -ssw -mx9 -y $ShareFolder$FileName2 $LocalDir2\*


# Описание ключей 7z
# a = Добавление файлов в архив. Если архивного файла не существует, создает его.
# -tzip в формате zip . без этого ключа по умолчанию 7z
# -ssw = Включить файл в архив, даже если он в данный момент используется. Для резервного копирования очень полезный ключ.
# -mx7 = Уровень компрессии. 0 - без компрессии (быстро), 9 - самая большая компрессия (медленно).
# -sdel = 	Удалить файлы после создания архива.
# -x@exclusions.txt = это файл-списк исключений, которые не будем архивировать.Каждая строка файла — новое исключение. Можно использовать маски типа *.ext и т.п. 
# -x!*.trn = Если исключение не много, то можно обойтись и без файла, в таком случае ключ примет следующий вид: -x!*.trn
# -r0 = (это ноль, а не буква О) исключения, которые будут прописаны дальше обрабатываются только в рабочем каталоге;
# -y = Утвердительно ответить на все вопросы, которые может запросить система.
#####################################################################################################################################
# Время работы скрипта
$totaltime = ($elapsed.Elapsed.toString().Split(".")[0])
Write-Host -ForegroundColor Yellow -Verbose "Archive old logs started: $started"
Write-Host -ForegroundColor Green -Verbose "Archive old logs completed: $(Get-Date)"
Write-Host -ForegroundColor Cyan -Verbose "Total Elapsed time: $totaltime"