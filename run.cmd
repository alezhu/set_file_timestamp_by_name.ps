@echo off
SETLOCAL

REM --- Script to set file timestamp by it's name ---
REM
REM Usage:
REM   run.cmd <path> [pattern]
REM
REM Parameters (can be in any order):
REM   <path>: The path to file or directory.
REM   [pattern] (optional): regex pattern with named groups to extract YMDHms.
REM                         Default: (?<year>\d{4})\D*(?<month>\d{2})\D*(?<day>\d{2})\D*(?<hour>\d{2})\D*(?<minute>\d{2})\D*(?<second>\d{2})

SET "INPUT_PATH=%1"
SET "PATTERN=%2"

REM If no path argument was found, show usage
IF NOT DEFINED INPUT_PATH (
    ECHO Usage: run.cmd ^<path^> [pattern]
    GOTO end
)

ECHO Processing path: %INPUT_PATH%
IF DEFINED PATTERN (
    ECHO Pattern: %PATTERN%
) ELSE (
    ECHO Pattern: (default)
)

REM If the path ends with a backslash, remove it to prevent issues with PowerShell argument parsing
IF "%INPUT_PATH:~-1%"=="\" SET "INPUT_PATH=%INPUT_PATH:~0,-1%"

IF DEFINED PATTERN (
    powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%~dp0\_main.ps1" -InputPath "%INPUT_PATH%" -Pattern "%PATTERN%"
) ELSE (
    powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%~dp0\_main.ps1" -InputPath "%INPUT_PATH%"
)

GOTO end

:end
ENDLOCAL
