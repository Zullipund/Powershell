<# Архивация изменений за день 
Копируем и архивируем ресурс, исключая файлы с маской excludelist63.txt  
Источник -> D:\Document >> E:\Document >> 7Zip >> E:\Archive >> "\\ServerDocument\Archive" + \\ServerBackUpAlternative\ 
\\ServerDocument\Archive - Ресурс хранения не более 30 дней 
\\ServerBackUpAlternative\ - Дополнительный ресурс длительного хранения с разбивкой по каталогам год\месяц\неделя\день 
#> 
Clear-Host 
# Создаем переменные по датам 
$Date = (Get-Date -uFormat "%d-%m-%y@%H-%M-%S") 
$Year = (Get-Date).Tostring("yyyy") 
$Month = (Get-Date).Tostring("MMMM") 
$Week = (GWMI -Class Win32_LocalTime).WeekInMonth 
$StrWeek = 'Неделя' 
Set-Variable -Name WeekRe -value $Week-$StrWeek 
$Day = (Get-Date).Tostring("dddd")+'-'+(Get-Date).Tostring("dd") 

# Выбираем куда попадает архив для не длительного хранения 
$TargetArchEx = "\\ServerDocument\Archive" 

# Создаем новый каталог по дате для долговременного хранения, какталоги для промежуточного хранения и архивации 
   NI \\ServerBackUpAlternative\$Year\$Month\$WeekRe\$Day -Type Directory 
      NI -Path E:\ -Name DocumentCopy -Type Directory 
         NI -Path E:\ -Name Archive -Type Directory 

# Вводим источник копирования 
$TargetRC = "D:\Document" 
# Копирование измененных за день файлов из $TargetRC во временный ресурс E:\DocumentCopy с учетом исключения C:\Script\7ZipPs\excludelist63.txt 
   ROBOCOPY $TargetRC E:\DocumentCopy /S /TS /LOG:C:\Log\DocumentDaily.txt /ZB /MAXAGE:1 /R:11 /W:3 /XF "C:\Script\7ZipPs\excludelist63.txt" 
   $Target = "E:\DocumentCopy\*.*"  
      $Archive = "E:\Archive\DocumentDaily.zip" 
         $Zip = "C:\Program Files\7-Zip\7z.exe" 
            [string]$Zip = "C:\Program Files\7-Zip\7z.exe" 
                       [array]$arguments = "a", "-r", "-tzip", "-xr@C:\Script\7ZipPs\excludelist63.txt", $Archive, $Target 
                          & $Zip $arguments 
       RNI -Path "E:\Archive\DocumentDaily.zip" -NewName "E:\Archive\DocumentDaily-$Date.zip" 
# Копирование результата архива во все ресурсы хранения 
          CP -Path "E:\Archive\*.*" -Destination $TargetArchEx -Force 
         CP -Path "E:\Archive\*.*" -Destination \\ServerBackUpAlternative\$Year\$Month\$WeekRe\$Day -Force 
# Удаление временных каталогов для архивации 
            RI -Path "E:\DocumentCopy" -Recurse -Force 
               RI -Path "E:\Archive" -Recurse -Force 