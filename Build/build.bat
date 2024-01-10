@echo off
pushd ..

REM The begin, build and end steps need to be launched from the same folder
dotnet build "Src\ConsoleApp1\ConsoleApp1.sln" -c Release

popd