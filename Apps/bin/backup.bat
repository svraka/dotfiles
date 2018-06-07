@echo off
setlocal EnableDelayedExpansion

rem Halozati helyek belallitasa

set ngm_o_kut=\\gvvrcommon09\gvvrcommon09\LUN08\NGM_O_KUT
set ngm_fo_ana=\\gvvrcommon12\gvvrcommon12\LUN03\NGM_FO_ANA\O_AA
set ngm_sharepoint=\\docstore.central.internal.gov.hu@SSL\DavWWWRoot\ngm

rem Backup-meghajto belallitasa

set mydrive=F:

rem Sajat konyvtar

set myhome=C:\Users\SvrakaA

rem ############################################################################

chcp 65001

set rcopts_alap=/dst /ndl /mir /xj /xf "Thumbs.db" /xf "~$*"

if "%~1"=="" (
	set list=
) else (
	if "%~1"=="list" (
		set list=/l
		echo Csak listazom a szinkronizalando fajlokat!
		set rcopts_alap=%rcopts_alap% !list!
	) else (
		echo Ismeretlen parameter!
		exit /b 1
	)
)

set rcopts_net=!rcopts_alap! /mt
set rcopts_usb=!rcopts_alap! /fft

rem /tee /log+:"C:\Users\SvrakaA\tmp\backup.log"
set uzenet=--------------------------- Kiveheted a pendrive-ot! ---------------------------
set vonal=-------------------------------------------------------------------------------


if not exist %mydrive%\ (
	echo A %mydrive%\ meghajto nem talalhato!
	exit /b 1
)


: Config backup

set backupdir=ngm\misc\backup
set log=/log:%myhome%\tmp\backup.log

copy %myhome%\.bash_history %myhome%\%backupdir%\.bash_history /Y

robocopy "%myhome%\.abevjava" "%myhome%\%backupdir%\.abevjava" %rcopts_net% %log%
: robocopy "%myhome%\.babun\cygwin\home\SvrakaA" "%myhome%\%backupdir%\.babun\cygwin\home\svrakaa" %rcopts_net% %log% /xd ".oh-my-zsh"
robocopy "%myhome%\abevjava" "%myhome%\%backupdir%\abevjava" %rcopts_net% %log%
robocopy "%myhome%\AppData\Roaming\Microsoft\Signatures" "%myhome%\%backupdir%\AppData\Roaming\Microsoft\Signatures" %rcopts_net% %log%
robocopy "%myhome%\AppData\Roaming\Microsoft\Templates" "%myhome%\%backupdir%\AppData\Roaming\Microsoft\Templates" %rcopts_net% %log%
robocopy "%myhome%\AppData\Roaming\Microsoft\UProof" "%myhome%\%backupdir%\AppData\Roaming\Microsoft\UProof" %rcopts_net% %log%
robocopy "%myhome%\AppData\Roaming\RStudio" "%myhome%\%backupdir%\AppData\Roaming\RStudio" %rcopts_net% %log%
robocopy "%myhome%\AppData\Roaming\Microsoft\Windows\Start Menu" "%myhome%\%backupdir%\AppData\Roaming\Windows\Start Menu" %rcopts_net% %log%
robocopy "%myhome%\Apps\SublimeText\Data\Packages\User" "%myhome%\%backupdir%\Apps\SublimeText\Data\Packages\User" %rcopts_net% %log% /xd "Package Control.cache" /xf "Package Control.last-run"
robocopy "%myhome%\Apps\SublimeText\Data\Packages\Text Pastry" "%myhome%\%backupdir%\Apps\SublimeText\Data\Packages\Text Pastry" %rcopts_net% %log%
robocopy "%myhome%\Apps\SumatraPDF" "%myhome%\%backupdir%\Apps\SumatraPDF" %rcopts_net% %log% /xd "sumatrapdfcache" /xf "SumatraPDF.exe"
robocopy "%myhome%\Links" "%myhome%\%backupdir%\Links" %rcopts_net% %log%


@echo Halozati anyagok szinkronizalasa

robocopy "%ngm_o_kut%\Kutatási füzetek" "%myhome%\ngm\kutatas\Kutatási füzetek" %rcopts_net%
robocopy "%ngm_o_kut%\Szemle" "%myhome%\ngm\kutatas\Szemle" %rcopts_net%
robocopy "%ngm_fo_ana%\minta\Adatbázisok\KSH ADATOK\Munkaügyi táblák" "%myhome%\ngm\adatok\ksh\Munkaügyi táblák" %rcopts_net%
robocopy "%ngm_fo_ana%\minta\Adatbázisok\KSH ADATOK\Negyedéves munkaügyi adatok" "%myhome%\ngm\adatok\ksh\Negyedéves munkaügyi adatok" %rcopts_net%
robocopy "%ngm_o_kut%\női_részmunkaidő" "%myhome%\ngm\elemzesek\2017-09 – Munkerőtartalék" %rcopts_net%


@echo Backup

robocopy "%myhome%\Code" "%mydrive%\ngmcode" %rcopts_usb% /xf *.dta
robocopy "%myhome%\ngm" "%mydrive%\ngm" %rcopts_usb%
robocopy "E:\data" "%mydrive%\Data" %rcopts_usb%


@echo Halozati anyagok backupja

robocopy "%ngm_fo_ana%\minta" "%mydrive%\ngm_anaf" %rcopts_usb% /xf *.dta /xd "Adatbázisok" /max:33553332
robocopy "%ngm_sharepoint%\anafo\Megosztottdokumentumok" "%mydrive%\ngm_anaf_sharepoint" %rcopts_usb% /xd "Forms"
robocopy "%ngm_sharepoint%\adoszabhat\megosztottdokumentumok" "%mydrive%\ngm_adoszabhat_sharepoint" %rcopts_usb% /xd "Forms"


@echo %vonal%
@echo %uzenet%
@echo %vonal%
@echo Sajat anyagok szinkronizalasa a halozatra

robocopy "%myhome%\ngm\adatbazisok" "%ngm_o_kut%\Svraka András\adatbazisok" %rcopts_net%

@echo %vonal%
@echo %uzenet%
@echo %vonal%

robocopy "%myhome%\ngm\projektek" "%ngm_o_kut%\Svraka András\projektek" %rcopts_net%

@echo %vonal%
@echo %uzenet%
@echo %vonal%

robocopy "%myhome%\Code" "%ngm_o_kut%\Svraka András\Code" %rcopts_net% /xd "misc-misc" /xd ".git" /xf "*.dta"
