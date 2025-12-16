@echo off

set Version=輸入你的軟體版本
set ScannerVersion=9.0.2

REM download scanner
echo.
echo -download scanner
dotnet tool install --global dotnet-sonarscanner --version %ScannerVersion%

REM define New Code
rem master/main branch
if %CI_COMMIT_BRANCH% == %CI_DEFAULT_BRANCH% (
    set newcode=/v:sonar.projectVersion=%Version%
    goto sonar
)
rem release beanch
echo %CI_COMMIT_BRANCH%|findstr /r "^輸入你的release分支前綴_">nul
if %Errorlevel% EQU 0 (
    set newcode=/v:sonar.projectVersion=%Version%
    goto sonar
)
rem feature branch
set newcode=/d:sonar.newCode.referenceBranch=%NewCodeRefBranch%
goto sonar

:sonar
REM start to scan begin
echo.
echo ==== SonarQube scan begin ====
pushd ..
dotnet sonarscanner begin /k:%SONARQUBE_PROJECT_KEY% /d:sonar.host.url=%SONAR_HOST_URL% /d:sonar.token=%SONAR_TOKEN% /s:%CI_PROJECT_DIR%/SonarQube.Analysis.xml %newcode%
popd

REM start to build
echo.
echo ==== SonarQube build ====
REM The begin, build and end steps need to be launched from the same folder.
pushd ..
call BUILD/build.bat
popd

REM start to scan end
echo.
echo ==== SonarQube scan end ====
pushd ..
dotnet sonarscanner end /d:sonar.token=%SONAR_TOKEN%
if %Errorlevel% NEQ 0 exit 1
popd

REM check upload status (avoid scanning quality gate successfully but upload to server failed)
echo.
echo -check upload status
setlocal enabledelayedexpansion
for /f "tokens=*" %%i in ('findstr "ceTaskUrl" ..\.sonarqube\out\.sonar\report-task.txt') do set TASK_URL=%%i
set TASK_URL=!TASK_URL:~10!
curl -u %SONAR_TOKEN%: %TASK_URL% 2>&1 | findstr "SUCCESS" >nul
if %Errorlevel% EQU 0 (
	set STATUS=SUCCESS
	echo Upload Status : !STATUS!
) else (
	set STATUS=FAILED
	echo Upload Status : !STATUS!
	exit 1
)

