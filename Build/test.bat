@echo off

chcp 65001 >nul

REM ============================================================================
REM  Test Script (NUnit)
REM ============================================================================

echo.
echo ============================================
echo   Building and Running NUnit Tests
echo ============================================
echo.

REM Move to the root directory
pushd %~dp0..

REM Build and run tests together using dotnet test (dotnet test will auto-build Calculator via ProjectReference)
echo -Building and running tests...
dotnet test "ClassLib\test\TestCalculator.csproj" -c Debug --logger "trx;LogFileName=TestResults.trx"

if %ERRORLEVEL% neq 0 (
    echo.
    echo ============================================
    echo   Some Tests FAILED!
    echo ============================================
    popd
    exit /b 1
)

echo.
echo ============================================
echo   All Tests PASSED!
echo ============================================

popd
exit /b 0
