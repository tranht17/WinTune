@ECHO OFF

:: Edit the path here. Just edit "WinTunePath1"
SET WinTunePath1=WinTune.exe
SET WinTunePath2=..\WinTune.exe
SET WinTunePath3=WinTune32.exe
SET WinTunePath4=..\WinTune32.exe

setlocal enabledelayedexpansion
FOR /l %%n IN (1,1,4) DO (
	IF EXIST !WinTunePath%%n! (
		START !WinTunePath%%n! /script %1
		goto :EOF
	)
)
:DE
ECHO "WinTune.exe" path doesn't exist.
ECHO Just copy "WinTune.exe" or "WinTune32.exe" to the same folder as this file
ECHO or edit the path in bat file.
pause



