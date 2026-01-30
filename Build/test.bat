@echo off

chcp 65001 >nul

REM ============================================================================
REM  Test Script (NUnit)
REM ============================================================================

echo.
echo ============================================
echo   Building NUnit Tests
echo ============================================
echo.

REM Move to the root directory
pushd %~dp0..

REM Set NuGet package versions (align with TestCalculator.csproj version)
set ReportGeneratorVer=5.4.18

REM Set nuget packages tool paths (PackageReference uses global cache)
set PackagesDir=%userprofile%\.nuget\packages
set ReportGeneratorPath=%PackagesDir%\reportgenerator\%ReportGeneratorVer%\tools\net8.0

REM Build and Restore test project only (dotnet build will auto-build Calculator via ProjectReference)
echo -Building TestCalculator with dependencies...
dotnet build "ClassLib\test\TestCalculator.csproj" -c Debug

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
echo   Running NUnit Tests via dotnet test
echo ============================================
echo.

REM Set test result and test coverage directory
set TestResultsDir=%CD%\ClassLib\test\TestResults
if exist "%TestResultsDir%" (rmdir /S /Q "%TestResultsDir%")
mkdir "%TestResultsDir%"

REM Run tests with:
REM   - JUnit format test results (for GitLab)
REM   - TRX format test results (for SonarQube)
REM   - Cobertura format code coverage (for GitLab)
echo -Running tests with Code Coverage...
dotnet test "ClassLib\test\TestCalculator.csproj" -c Debug --no-build ^
    --logger "junit;LogFileName=junit_test_results.xml;MethodFormat=Class;FailureBodyFormat=Verbose" ^
    --logger "trx;LogFileName=trx_test_results.trx" ^
    --collect "Code Coverage;Format=cobertura" ^
    --results-directory "%TestResultsDir%"

set TEST_EXIT_CODE=%ERRORLEVEL%

REM Convert format
REM   - using ReportGenerator to convert cobertura format code coverage to SonarQube Generic Format (for SonarQube)
REM   - using ReportGenerator to convert cobertura format code coverage to TeamCitySummary format (for GitLab)
echo -Converting code coverage to SonarQube format...
dotnet exec "%ReportGeneratorPath%\ReportGenerator.dll" ^
    "-reports:%TestResultsDir%\*-*-*-*-*\*.cobertura.xml" ^
    "-targetdir:%TestResultsDir%" ^
    "-reporttypes:SonarQube;TeamCitySummary" ^
    "-sourcedirs:%CD%" ^
    "-filefilters:+%CD%\**;-*nunit*" ^
    "-verbosity:Warning"
echo   Done.

if %TEST_EXIT_CODE% neq 0 (
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
