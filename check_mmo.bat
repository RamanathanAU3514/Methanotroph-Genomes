@echo off
if not exist hits mkdir hits
echo accession,pMMO_hits,sMMO_hits> mmo_results.csv
for /f %%a in (accessions.txt) do call :check %%a
echo Done
goto :eof

:check
set acc=%1
echo Checking %acc%
del tmp.zip 2>nul
rd /s /q tmp_ex 2>nul
datasets download genome accession %acc% --include protein --filename tmp.zip --no-progressbar >nul 2>&1
if not exist tmp.zip (
  >>mmo_results.csv echo %acc%,DOWNLOAD_FAILED,
  goto :eof
)
mkdir tmp_ex
tar -xf tmp.zip -C tmp_ex
set f=tmp_ex\ncbi_dataset\data\%acc%\protein.faa
if not exist %f% (
  >>mmo_results.csv echo %acc%,NO_PROTEIN_FILE,
  del tmp.zip
  goto :eof
)
findstr /i "monooxygenase" %f% > hits\%acc%.txt
set p=0
set s=0
for /f %%n in ('findstr /i /c:"ammonia monooxygenase" /c:"particulate methane" /c:"pmoA" /c:"pmoB" /c:"pmoC" hits\%acc%.txt ^| find /c /v ""') do set p=%%n
for /f %%n in ('findstr /i /c:"soluble methane" /c:"methane monooxygenase regulator" /c:"methane monooxygenase component" /c:"MmoB" /c:"MmoD" /c:"MmoX" /c:"MmoY" /c:"MmoZ" hits\%acc%.txt ^| find /c /v ""') do set s=%%n
>>mmo_results.csv echo %acc%,%p%,%s%
del tmp.zip
rd /s /q tmp_ex
goto :eof
