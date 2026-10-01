@echo off
setlocal
where py >nul 2>nul
if not errorlevel 1 (
    py -3 "%~dp0tools\inventory_tool.py" apply-server
    goto finished
)
where python >nul 2>nul
if not errorlevel 1 (
    python "%~dp0tools\inventory_tool.py" apply-server
    goto finished
)
echo Python 3.10 or newer is required. Install Python, then run this file again.
:finished
echo.
pause
