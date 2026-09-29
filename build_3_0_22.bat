@echo off
setlocal EnableExtensions
cd /d "%~dp0"
set "VER=3_0_22"
set "SRC_DIR=openssl-src\openssl-openssl-3.0.22"
title OpenSSL %VER%
set "BATCH_MODE=0"

rem CLI: 1|2|3|4  OR  init/build debug|release  OR  debug|release init/build
if "%~1"=="" goto menu

set "BATCH_MODE=1"
set "A1=%~1"
set "A2=%~2"

if /i "%A1%"=="1" goto opt1
if /i "%A1%"=="2" goto opt2
if /i "%A1%"=="3" goto opt3
if /i "%A1%"=="4" goto opt4

if /i "%A1%"=="init" if /i "%A2%"=="debug" goto opt1
if /i "%A1%"=="init" if /i "%A2%"=="release" goto opt2
if /i "%A1%"=="build" if /i "%A2%"=="debug" goto opt3
if /i "%A1%"=="build" if /i "%A2%"=="release" goto opt4

if /i "%A1%"=="debug" if /i "%A2%"=="init" goto opt1
if /i "%A1%"=="release" if /i "%A2%"=="init" goto opt2
if /i "%A1%"=="debug" if /i "%A2%"=="build" goto opt3
if /i "%A1%"=="release" if /i "%A2%"=="build" goto opt4

echo [ERROR] bad args: %*
echo Usage:
echo   %~nx0
echo   %~nx0 1^|2^|3^|4
echo   %~nx0 init debug^|release
echo   %~nx0 build debug^|release
echo 1/2=Configure+全量编库  3/4=增量编库
exit /b 1

:menu
cls
echo ========================================
echo   OpenSSL %VER%
echo ========================================
echo   1 - 初始化 Debug   (Configure + 全量编库)
echo   2 - 初始化 Release (Configure + 全量编库)
echo   3 - 增量编译 Debug (需先做过 1)
echo   4 - 增量编译 Release (需先做过 2)
echo   0 - 退出
echo ========================================
echo 也可: %~nx0 2  或  %~nx0 init release
echo ========================================
set "CHOICE="
set /p CHOICE=请选择:

if "%CHOICE%"=="1" goto opt1
if "%CHOICE%"=="2" goto opt2
if "%CHOICE%"=="3" goto opt3
if "%CHOICE%"=="4" goto opt4
if "%CHOICE%"=="0" goto bye
echo 无效输入
pause
goto menu

:opt1
call "%~dp0build_common.bat" %VER% "%SRC_DIR%" debug init
goto after
:opt2
call "%~dp0build_common.bat" %VER% "%SRC_DIR%" release init
goto after
:opt3
call "%~dp0build_common.bat" %VER% "%SRC_DIR%" debug build
goto after
:opt4
call "%~dp0build_common.bat" %VER% "%SRC_DIR%" release build
goto after

:after
if errorlevel 1 goto fail
if "%BATCH_MODE%"=="1" exit /b 0
echo.
pause
goto menu

:fail
if "%BATCH_MODE%"=="1" exit /b 1
echo.
echo [FAILED]
pause
goto menu

:bye
exit /b 0
