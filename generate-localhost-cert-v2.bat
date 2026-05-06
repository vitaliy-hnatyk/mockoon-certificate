@echo off
setlocal

REM Generate a self-signed HTTPS certificate for localhost, usable in Mockoon.
REM This version searches for OpenSSL in PATH, Git for Windows, and common OpenSSL folders.
REM Output files:
REM   localhost.crt
REM   localhost.key
REM   localhost.conf

set "SCRIPT_DIR=%~dp0"
set "CONF_FILE=%SCRIPT_DIR%localhost.conf"
set "CRT_FILE=%SCRIPT_DIR%localhost.crt"
set "KEY_FILE=%SCRIPT_DIR%localhost.key"
set "OPENSSL_EXE="

REM 1) Try OpenSSL from PATH
for /f "delims=" %%I in ('where openssl 2^>nul') do (
    if not defined OPENSSL_EXE set "OPENSSL_EXE=%%I"
)

REM 2) Try Git for Windows common locations
if not defined OPENSSL_EXE if exist "%ProgramFiles%\Git\usr\bin\openssl.exe" set "OPENSSL_EXE=%ProgramFiles%\Git\usr\bin\openssl.exe"
if not defined OPENSSL_EXE if exist "%ProgramFiles(x86)%\Git\usr\bin\openssl.exe" set "OPENSSL_EXE=%ProgramFiles(x86)%\Git\usr\bin\openssl.exe"
if not defined OPENSSL_EXE if exist "%LocalAppData%\Programs\Git\usr\bin\openssl.exe" set "OPENSSL_EXE=%LocalAppData%\Programs\Git\usr\bin\openssl.exe"

REM 3) Try common OpenSSL installer locations
if not defined OPENSSL_EXE if exist "%ProgramFiles%\OpenSSL-Win64\bin\openssl.exe" set "OPENSSL_EXE=%ProgramFiles%\OpenSSL-Win64\bin\openssl.exe"
if not defined OPENSSL_EXE if exist "%ProgramFiles(x86)%\OpenSSL-Win32\bin\openssl.exe" set "OPENSSL_EXE=%ProgramFiles(x86)%\OpenSSL-Win32\bin\openssl.exe"

if not defined OPENSSL_EXE (
    echo OpenSSL was not found.
    echo.
    echo Fix option 1:
    echo   Install Git for Windows, then run this file again.
    echo   This script will try to use:
    echo   C:\Program Files\Git\usr\bin\openssl.exe
    echo.
    echo Fix option 2:
    echo   Install OpenSSL for Windows and add it to PATH.
    echo.
    echo After installing, close this window and run this .bat again.
    echo.
    pause
    exit /b 1
)

echo Found OpenSSL:
echo "%OPENSSL_EXE%"
echo.

echo Creating OpenSSL config:
echo "%CONF_FILE%"

(
echo [req]
echo default_bits = 2048
echo prompt = no
echo default_md = sha256
echo distinguished_name = dn
echo x509_extensions = v3_req
echo.
echo [dn]
echo CN = localhost
echo.
echo [v3_req]
echo subjectAltName = @alt_names
echo.
echo [alt_names]
echo DNS.1 = localhost
echo IP.1 = 127.0.0.1
) > "%CONF_FILE%"

echo.
echo Generating certificate and private key...
"%OPENSSL_EXE%" req -x509 -nodes -days 365 -newkey rsa:2048 -keyout "%KEY_FILE%" -out "%CRT_FILE%" -config "%CONF_FILE%"

if errorlevel 1 (
    echo.
    echo Failed to generate certificate files.
    pause
    exit /b 1
)

echo.
echo Done!
echo Certificate:
echo "%CRT_FILE%"
echo.
echo Private key:
echo "%KEY_FILE%"
echo.
echo In Mockoon:
echo   1. Enable TLS
echo   2. Use localhost.crt as the certificate
echo   3. Use localhost.key as the private key
echo.
echo Then open:
echo   https://localhost:YOUR_PORT
echo.
pause
endlocal
