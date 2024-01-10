@echo off
set XXUnzipApp="%CD%\7z_x86.exe"
set XXBuildVersion=1.0.0

REM download jre and sonar-scanner
echo.
echo -download jre
curl -SL --output %USERPROFILE%\OpenJDK11U-jre_x64_windows_hotspot_11.0.17_8.zip https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.17+8/OpenJDK11U-jre_x64_windows_hotspot_11.0.17_8.zip
echo -download sonar-scanner
dotnet tool install --global dotnet-sonarscanner --version 5.15.0

REM extract zip
echo.
echo -extract jre
%XXUnzipApp% x -y -o"%USERPROFILE%\" "%USERPROFILE%\OpenJDK11U-jre_x64_windows_hotspot_11.0.17_8.zip"

REM add to PATH
echo.
echo -add jre file path into environment variable
set PATH=%PATH%;%USERPROFILE%\jdk-11.0.17+8-jre\bin

REM define New Code
rem master/main branch
if %CI_COMMIT_BRANCH% == %CI_DEFAULT_BRANCH% (
    set newcode=/v:sonar.projectVersion=%XXBuildVersion%
    goto sonar
)
rem release beanch
echo %CI_COMMIT_BRANCH%|findstr /r "^release_">nul
if %Errorlevel% EQU 0 ( 
	set newcode=/v:sonar.projectVersion=%XXBuildVersion%
	goto sonar
)
rem feature/bug branch
set newcode=/d:sonar.newCode.referenceBranch=%NewCodeRefBranch%
goto sonar

:sonar
REM start to scan begin
echo.
echo ==== SonarQube scan begin ====
pushd ..
dotnet sonarscanner begin /k:"test" /n:"test" /d:sonar.host.url=%SONAR_HOST_URL% /d:sonar.login=%SONAR_TOKEN% /s:%CI_PROJECT_DIR%/SonarQube.Analysis.xml %newcode%
popd

REM start to build
echo.
echo ==== SonarQube build ====
rem The begin, build and end steps need to be launched from the same folder
call build.bat

REM start to scan end
echo.
echo ==== SonarQube scan end ====
pushd ..
dotnet sonarscanner end /d:sonar.login=%SONAR_TOKEN%
popd

REM clean up
echo.
echo -clean up
del /q /f %USERPROFILE%\OpenJDK11U-jre_x64_windows_hotspot_11.0.17_8.zip
rd /q /s %USERPROFILE%\jdk-11.0.17+8-jre

REM check scan status
echo.
echo -check scan status
setlocal enabledelayedexpansion
for /f "tokens=*" %%i in ('findstr "ceTaskUrl" ..\.sonarqube\out\.sonar\report-task.txt') do set TASK_URL=%%i
set TASK_URL=!TASK_URL:~10!
curl -u %SONAR_TOKEN%: %TASK_URL% 2>&1 | findstr "SUCCESS" >nul
if %Errorlevel% EQU 0 (
    set STATUS=SUCCESS
    echo Scan Status : !STATUS!
) else (
    set STATUS=FAILED
    echo Scan Status : !STATUS!
    exit 1
)
