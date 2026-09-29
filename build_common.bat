@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"

set "VER=%~1"
set "SRC_DIR=%~2"
set "CONFIG=%~3"
set "ACTION=%~4"

if "%VER%"=="" goto :usage
if "%SRC_DIR%"=="" goto :usage
if /i not "%CONFIG%"=="debug" if /i not "%CONFIG%"=="release" goto :usage
if /i not "%ACTION%"=="init" if /i not "%ACTION%"=="build" goto :usage
if not exist "%SRC_DIR%\Configure" (
    echo [ERROR] Configure not found: %SRC_DIR%\Configure
    exit /b 1
)

call "%~dp0init_env.bat"
if errorlevel 1 (
    echo [ERROR] init_env.bat failed
    exit /b 1
)
call "%~dp0init_tools.bat"
if errorlevel 1 (
    echo [ERROR] init_tools.bat failed
    exit /b 1
)

set "BUILD_DIR=build_%CONFIG%_%VER%"
set "BIN_DIR=bin\%VER%"
if /i "%CONFIG%"=="debug" (
    set "TARGET=debug-VC-WIN64A"
    set "CRT_FLAG=/MTd"
    set "LIB_SUFFIX=mtd"
) else (
    set "TARGET=VC-WIN64A"
    set "CRT_FLAG=/MT"
    set "LIB_SUFFIX=mt"
)

if /i "%ACTION%"=="init" goto :do_init
goto :do_build

:do_init
echo ==== INIT %VER% %CONFIG% ====
if exist "%BUILD_DIR%" (
    echo Removing old %BUILD_DIR% ...
    rmdir /s /q "%BUILD_DIR%"
)
mkdir "%BUILD_DIR%" || exit /b 1
pushd "%BUILD_DIR%"
echo Configure: perl "..\%SRC_DIR%\Configure" %TARGET% no-shared no-makedepend %CRT_FLAG%
perl "..\%SRC_DIR%\Configure" %TARGET% no-shared no-makedepend %CRT_FLAG%
if errorlevel 1 (
    echo [ERROR] Configure failed
    popd
    exit /b 1
)
echo nmake build_libs ...
nmake build_libs
if errorlevel 1 (
    echo [ERROR] nmake failed
    popd
    exit /b 1
)
popd
call :collect
if errorlevel 1 exit /b 1
echo ==== INIT DONE: %BIN_DIR% ====
exit /b 0

:do_build
echo ==== BUILD %VER% %CONFIG% ====
if not exist "%BUILD_DIR%\makefile" if not exist "%BUILD_DIR%\Makefile" (
    echo [ERROR] %BUILD_DIR% not configured. Choose menu 1 or 2 first.
    exit /b 1
)
pushd "%BUILD_DIR%"
nmake build_libs
if errorlevel 1 (
    echo [ERROR] nmake failed
    popd
    exit /b 1
)
popd
call :collect
if errorlevel 1 exit /b 1
echo ==== BUILD DONE: %BIN_DIR% ====
exit /b 0

:collect
if not exist "%BUILD_DIR%\libcrypto.lib" (
    echo [ERROR] missing %BUILD_DIR%\libcrypto.lib
    exit /b 1
)
if not exist "%BUILD_DIR%\libssl.lib" (
    echo [ERROR] missing %BUILD_DIR%\libssl.lib
    exit /b 1
)
if not exist "%BIN_DIR%" mkdir "%BIN_DIR%"
copy /Y "%BUILD_DIR%\libcrypto.lib" "%BIN_DIR%\libcrypto_!LIB_SUFFIX!.lib" >nul
if errorlevel 1 exit /b 1
copy /Y "%BUILD_DIR%\libssl.lib" "%BIN_DIR%\libssl_!LIB_SUFFIX!.lib" >nul
if errorlevel 1 exit /b 1

if exist "%BIN_DIR%\include" rmdir /s /q "%BIN_DIR%\include"
mkdir "%BIN_DIR%\include"
xcopy /E /I /Y /Q "%SRC_DIR%\include\*" "%BIN_DIR%\include\" >nul
if errorlevel 1 (
    echo [ERROR] copy source include failed
    exit /b 1
)
if exist "%BUILD_DIR%\include\" (
    xcopy /E /I /Y /Q "%BUILD_DIR%\include\*" "%BIN_DIR%\include\" >nul
)
echo Collected libs: libcrypto_!LIB_SUFFIX!.lib libssl_!LIB_SUFFIX!.lib
echo Collected headers: %BIN_DIR%\include\
exit /b 0

:usage
echo Usage: build_common.bat VER SRC_DIR debug^|release init^|build
exit /b 1
