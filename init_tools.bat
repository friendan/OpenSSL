@echo off
set "ROOT=%~dp0"
set "PERL_ROOT=%ROOT%tools\strawberry-perl-5.38.4.1-64bit-portable"
set "NASM_HOME=%ROOT%tools\nasm-3.01-win64"
if not exist "%PERL_ROOT%\perl\bin\perl.exe" (
    echo [ERROR] perl not found: %PERL_ROOT%\perl\bin\perl.exe
    exit /b 1
)
if not exist "%NASM_HOME%\nasm.exe" (
    echo [ERROR] nasm not found: %NASM_HOME%\nasm.exe
    exit /b 1
)
rem Prefer repo NASM over strawberry bundled copy
set "PATH=%NASM_HOME%;%PERL_ROOT%\perl\bin;%PERL_ROOT%\perl\site\bin;%PERL_ROOT%\c\bin;%PATH%"
rem Avoid Strawberry Perl crash on unsupported Chinese locale
set "LANG=C"
set "LC_ALL=C"
where perl >nul 2>nul || (echo [ERROR] perl not on PATH & exit /b 1)
where nasm >nul 2>nul || (echo [ERROR] nasm not on PATH & exit /b 1)
where nmake >nul 2>nul || (echo [ERROR] nmake not on PATH, call init_env.bat first & exit /b 1)
exit /b 0
