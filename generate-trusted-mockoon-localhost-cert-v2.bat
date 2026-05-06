@echo off
setlocal

REM Creates a trusted localhost certificate for Mockoon on Windows.
REM No OpenSSL required.
REM
REM Output files in this same folder:
REM   localhost-mockoon.pfx
REM   localhost-mockoon.cer
REM
REM PFX password:
REM   mockoon

set "SCRIPT_DIR=%~dp0"
set "PS1_FILE=%TEMP%\create-mockoon-localhost-cert.ps1"

echo Creating temporary PowerShell script...
echo.

> "%PS1_FILE%" echo $ErrorActionPreference = 'Stop'
>> "%PS1_FILE%" echo $friendlyName = 'Mockoon Localhost Dev Cert'
>> "%PS1_FILE%" echo $scriptDir = '%SCRIPT_DIR:\=\\%'
>> "%PS1_FILE%" echo $pfxPath = Join-Path $scriptDir 'localhost-mockoon.pfx'
>> "%PS1_FILE%" echo $cerPath = Join-Path $scriptDir 'localhost-mockoon.cer'
>> "%PS1_FILE%" echo $passwordText = 'mockoon'
>> "%PS1_FILE%" echo $password = ConvertTo-SecureString $passwordText -AsPlainText -Force
>> "%PS1_FILE%" echo Write-Host 'Removing old Mockoon localhost certificates, if any...'
>> "%PS1_FILE%" echo Get-ChildItem Cert:\CurrentUser\My -ErrorAction SilentlyContinue ^| Where-Object { $_.FriendlyName -eq $friendlyName } ^| Remove-Item -Force -ErrorAction SilentlyContinue
>> "%PS1_FILE%" echo Get-ChildItem Cert:\CurrentUser\Root -ErrorAction SilentlyContinue ^| Where-Object { $_.FriendlyName -eq $friendlyName } ^| Remove-Item -Force -ErrorAction SilentlyContinue
>> "%PS1_FILE%" echo Write-Host 'Creating localhost certificate...'
>> "%PS1_FILE%" echo $cert = New-SelfSignedCertificate -Subject 'CN=localhost' -DnsName 'localhost' -CertStoreLocation 'Cert:\CurrentUser\My' -FriendlyName $friendlyName -KeyAlgorithm RSA -KeyLength 2048 -HashAlgorithm SHA256 -NotAfter (Get-Date).AddYears(1) -KeyExportPolicy Exportable
>> "%PS1_FILE%" echo Write-Host 'Exporting PFX for Mockoon...'
>> "%PS1_FILE%" echo Export-PfxCertificate -Cert $cert -FilePath $pfxPath -Password $password -Force ^| Out-Null
>> "%PS1_FILE%" echo Write-Host 'Exporting public certificate...'
>> "%PS1_FILE%" echo Export-Certificate -Cert $cert -FilePath $cerPath -Force ^| Out-Null
>> "%PS1_FILE%" echo Write-Host 'Trusting certificate for current Windows user...'
>> "%PS1_FILE%" echo Import-Certificate -FilePath $cerPath -CertStoreLocation Cert:\CurrentUser\Root ^| Out-Null
>> "%PS1_FILE%" echo Write-Host ''
>> "%PS1_FILE%" echo Write-Host 'Done!'
>> "%PS1_FILE%" echo Write-Host ('PFX file: ' + $pfxPath)
>> "%PS1_FILE%" echo Write-Host ('CER file: ' + $cerPath)
>> "%PS1_FILE%" echo Write-Host ('PFX password: ' + $passwordText)

powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1_FILE%"

if errorlevel 1 (
    echo.
    echo Failed.
    echo Try right-clicking this .bat file and choosing "Run as administrator".
    echo.
    pause
    exit /b 1
)

echo.
echo Next steps in Mockoon:
echo   1. Open your environment settings
echo   2. Enable TLS
echo   3. Select/use this PFX file:
echo      localhost-mockoon.pfx
echo   4. Set the passphrase/password to:
echo      mockoon
echo   5. Restart the Mockoon environment
echo.
echo Then open:
echo   https://localhost:YOUR_PORT
echo.
echo Important:
echo   Use localhost, not 127.0.0.1.
echo   Restart Chrome if it was already open.
echo.
pause
endlocal
