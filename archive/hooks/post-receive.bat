@echo off
setlocal enabledelayedexpansion

rem === Configuration ===
set REPO_DIR=C:\Users\Public\Documents\git\myproject.git
set WORK_TREE=C:\Users\Public\Documents\tmp\myproject
set DEST_DIR=C:\Users\Public\Documents\tmp\dags

rem === Read from stdin ===
for /F "tokens=1,2,3" %%a in ('more') do (
    set OLD=%%a
    set NEW=%%b
    set REF=%%c
)

rem === Only act on pushes to master ===
if /I "%REF%"=="refs/heads/master" (
    echo [INFO] Push to master detected. Updating working copy...

    rem Update the working tree with the latest code
    git --work-tree=%WORK_TREE% --git-dir=%REPO_DIR% checkout -f master

    rem Ensure destination exists
    powershell -Command "if (!(Test-Path -Path '%DEST_DIR%')) { New-Item -ItemType Directory -Path '%DEST_DIR%' | Out-Null }"

    rem Copy all .py files from src/dags to target
    powershell -Command "Get-ChildItem -Path '%WORK_TREE%\src\dags' -Filter *.py -Recurse | ForEach-Object { Copy-Item -Path $_.FullName -Destination '%DEST_DIR%' -Force }"

    echo [INFO] DAGs copied to %DEST_DIR%
) else (
    echo [INFO] Push to %REF% ignored.
)

endlocal
