@echo off

chcp 65001 >nul

REM ============================================================================
REM  Build Script
REM ============================================================================

echo.
echo ============================================
echo   Building Calculator
echo ============================================
echo.

REM Move to the root directory
pushd %~dp0..

REM Build and Restore Calculator project only
echo -Building...
dotnet build "ClassLib\src\Calculator.csproj" -c Release

if %ERRORLEVEL% neq 0 (
    echo.
    echo ============================================
    echo   Build FAILED!
    echo ============================================
    popd
    exit /b 1
)

echo.
echo ============================================
echo   Build Completed Successfully!
echo ============================================

popd
exit /b 0
