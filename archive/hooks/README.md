# Git bare post-receive hook

The goal of this hook is to trigger a script after someone pushes to master in a bare repo.

This script will copy all .py files from src/dags (inside the pushed content) to C:\Utilisateurs\Public\Dags.

## post-receive Hook Script

As the git repo is inside a Windows server, so the logic of the hook must be a `.bat` file. The hook itself is only
a shell wrapper. Below is the minimum setup example

```text
myproject.git/
├── hooks/
│   ├── post-receive          # shell wrapper (no extension)
│   ├── post-receive.bat      # actual Windows batch logic
```
The `post-receive` file content

```bash
#!/bin/sh
exec "$(dirname "$0")/post-receive.bat"
```

The `post-receive.bat` file content

```powershell
@echo off
setlocal enabledelayedexpansion

rem === Configuration ===
set REPO_DIR=D:\git\myrepo.git
set WORK_TREE=D:\deploy\myrepo
set DEST_DIR=C:\Utilisateurs\Public\Dags

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

```

Copy this scripts to `D:\git\myrepo.git\hooks\post-receive` and make sure `the file has no extension and is executable`.