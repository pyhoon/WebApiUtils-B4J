@echo off
setlocal

if "%~1"=="" (
    echo Usage:
    echo    create_excluded.bat file1.bas file2.bas
    pause
    exit /b
)

:nextfile

if "%~1"=="" goto done

set "INPUT=%~1"
set "OUTPUT=%~dpn1.b4x_excluded"

echo.
echo Processing:
echo    %INPUT%
echo Output:
echo    %OUTPUT%

powershell -NoProfile -ExecutionPolicy Bypass -Command "$found=$false; Get-Content '%INPUT%' | ForEach-Object { if($found){ $_ } elseif($_ -match '@EndOfDesignText@'){ $found=$true } } | Set-Content '%OUTPUT%'"

shift
goto nextfile

:done

echo.
echo Finished.
pause