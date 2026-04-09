@echo off
REM ReactOS Build Script (Batch version)
REM This script configures and builds ReactOS using CMake

setlocal enabledelayedexpansion

REM Parse arguments
set ARCH=i386
set BUILD_TYPE=Debug
set GENERATOR=Ninja
set CLEAN=0
set CONFIG_ONLY=0

:parse_args
if "%1"=="" goto end_parse
if /i "%1"=="--arch" (
    set ARCH=%2
    shift & shift
    goto parse_args
)
if /i "%1"=="--build-type" (
    set BUILD_TYPE=%2
    shift & shift
    goto parse_args
)
if /i "%1"=="--generator" (
    set GENERATOR=%2
    shift & shift
    goto parse_args
)
if /i "%1"=="--clean" (
    set CLEAN=1
    shift
    goto parse_args
)
if /i "%1"=="--config-only" (
    set CONFIG_ONLY=1
    shift
    goto parse_args
)
shift
goto parse_args

:end_parse
REM Validate architecture
if /i not "%ARCH%"=="i386" (
    if /i not "%ARCH%"=="amd64" (
        if /i not "%ARCH%"=="arm" (
            if /i not "%ARCH%"=="arm64" (
                echo Error: Invalid architecture "%ARCH%"
                echo Valid options: i386, amd64, arm, arm64
                exit /b 1
            )
        )
    )
)

REM Set paths
set SCRIPT_DIR=%~dp0
set BUILD_DIR=%SCRIPT_DIR%build_%ARCH%_%BUILD_TYPE%
set SOURCE_DIR=%SCRIPT_DIR%

REM Create/clean build directory
if exist "%BUILD_DIR%" (
    if %CLEAN% equ 1 (
        echo Cleaning build directory: %BUILD_DIR%
        rmdir /s /q "%BUILD_DIR%"
    )
)

if not exist "%BUILD_DIR%" (
    echo Creating build directory: %BUILD_DIR%
    mkdir "%BUILD_DIR%"
)

REM Change to build directory
cd /d "%BUILD_DIR%"

REM Run CMake configuration
echo.
echo Configuring ReactOS build...
echo   Architecture: %ARCH%
echo   Build Type: %BUILD_TYPE%
echo   Generator: %GENERATOR%
echo   Source: %SOURCE_DIR%
echo   Build Dir: %BUILD_DIR%
echo.

cmake -G "%GENERATOR%" -DARCH=%ARCH% -DCMAKE_BUILD_TYPE=%BUILD_TYPE% "%SOURCE_DIR%"

if %errorlevel% neq 0 (
    echo Error: CMake configuration failed!
    exit /b 1
)

if %CONFIG_ONLY% equ 1 (
    echo Configuration complete. Build directory: %BUILD_DIR%
    exit /b 0
)

REM Build the project
echo.
echo Building ReactOS...
echo.

if /i "%GENERATOR%"=="Ninja" (
    ninja
) else (
    cmake --build . --config %BUILD_TYPE%
)

if %errorlevel% neq 0 (
    echo Error: Build failed!
    exit /b 1
)

echo.
echo Build completed successfully!
echo Build output: %BUILD_DIR%
endlocal
