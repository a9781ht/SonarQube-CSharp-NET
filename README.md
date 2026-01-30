# SonarQube Windows C# .NET 專案導入示範

此為示範專案，教導如何將 Windows 平台的 .NET 專案導入到 SonarQube。

---

## 使用版本

| 工具 | 版本 |
|------|------|
| SonarQube | Developer Edition v10.6 |
| SonarScanner | 9.0.2 (for .NET Global Tool) |

---

## 前置作業

1. 透過個人 GitLab 帳號的 **Personal Access Token** 將該 .NET 專案加入到 SonarQube

2. 選擇 **Previous Version** 當作 New Code 的 baseline

3. 將 SonarQube 的 URL 儲存在 GitLab 的**全域變數**裡，取名為 `SONAR_HOST_URL`

4. 將該 .NET 專案在 SonarQube 產生出來的 **Project Key** 儲存到 GitLab 的 **Settings → CI/CD → Variables** 裡，取名為 `SONARQUBE_PROJECT_KEY`

5. 將該 .NET 專案在 SonarQube 產生出來的 **Token** 儲存到 GitLab 的 **Settings → CI/CD → Variables** 裡，取名為 `SONAR_TOKEN`

---

## 專案修改

1. 修改 `.gitlab-ci.yml` 裡的 `image`，選一個可以編譯你軟體的環境，並且該環境也需要擁有 `git` 與 `7z` 等工具

2. 修改 `.gitlab-ci.yml` 裡的 `tag`，選一個 GitLab 有提供的 Windows 環境去啟動 image

3. 修改 `SQAnalysis.bat` 裡的 `version` 軟體版本

4. 修改 `SQAnalysis.bat` 裡的 `release` 分支前綴

---

## 開始分析

| 分支類型 | New Code 區分方式 |
|----------|-------------------|
| `master` | 使用 `SQAnalysis.bat` 裡的 `Version` 變數 |
| `release` | 使用 `SQAnalysis.bat` 裡的 `Version` 變數 |
| `feature` / `bug` | 使用 `.gitlab-ci.yml` 裡的 `NewCodeRefBranch` 變數 |

---

## 備註

<details>
  <summary>專案格式</summary>
  .NET 6 僅支援 **SDK style**。
</details>

<details>
  <summary>套件管理方式</summary>
  SDK style（新格式）僅支援一種套件管理方式：**PackageReference**，並不支援 **packages.config**
</details>

<details>
  <summary>套件還原方式</summary>
  使用 PackageReference 時，可以在命令列透過 dotnet build 的 `--restore` 選項自動還原套件，不過預設就會，所以可以不用加。
</details>

<details>
  <summary>其他</summary>

  > dotnet test
  1. 因為在 .NET 專案下，使用 dotnet test 的整合度更優於 vstest.console.exe (前者為跨平台並且透過 .NET SDK 安裝；後者僅支援 Windows 並且透過 Visual Studio 或 Microsoft.TestPlatform NuGet 安裝)。除此之外，從 [官網](https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-test?tabs=dotnet-test-with-vstest) 可以發現到其實 dotnet test 背後是透過兩種 test driver 來實現：[VSTest](https://learn.microsoft.com/zh-tw/dotnet/core/testing/microsoft-testing-platform-vs-vstest) 或 [Microsoft Testing Platform](https://www.nuget.org/packages/Microsoft.Testing.Platform)。預設為前者，即 vstest.console.exe (這也就是為何兩者的參數格式很像，因為是同一個測試引擎)；後者為新推出之更快更輕量的解決方案
  2. 由於 vstest.console.exe 執行一次只能捕獲一種測試覆蓋率的格式，為了兼容 SonarQube 和 GitLab 的情境，可以先產生一種格式，再用工具轉換成另一種格式。不過官方的 CodeCoverage.exe 工具已不再維護，目前只建議使用 [dotnet-coverage](https://learn.microsoft.com/en-us/dotnet/core/additional-tools/dotnet-coverage) 或 [Microsoft.CodeCoverage.Console](https://learn.microsoft.com/en-us/visualstudio/test/microsoft-code-coverage-console-tool?view=visualstudio) 工具，其實兩者底層都是同一個引擎，只是不同的包裝而已。前者為獨立的工具，不依賴 VSTest，可以包裝任何命令收集覆蓋率，不只限定測試專案，只是不支援 C++ 與 IIS/ASP.NET 安全功能；而後者的原型是 [Microsoft.CodeCoverage](https://github.com/microsoft/codecoverage/blob/main/README.md) 其原本僅作為 dotnet test 的 VSTest Data Collector 運作，被 Microsoft.NET.Test.Sdk 套件自動引用，只能在測試執行期間收集覆蓋率，即透過 --collect "Code Coverage" 參數啟用，但爾後發展出了他的 CLI 工具，也就是 Microsoft.CodeCoverage.Console，功能更加強大，可視為 dotnet-coverage 的擴展版，並且支援 C++ 與 IIS/ASP.NET 安全功能
  3. 但是 Microsoft.CodeCoverage.Console 目前只能透過安裝 Visual Studio 取得 (在 Visual Studio 2022 及以前只整合進 Enterprise 版本，Visual Studio 2025 以後才下放到所有版本)，而 [Nuget](https://www.nuget.org/packages/Microsoft.CodeCoverage) 上提供的只是 Microsoft.CodeCoverage，並非 Console 版本的 CLI 工具。綜合以上，以 C# .NET 的情境來說，可以改使用第三方工具 ReportGenerator，比較單純易用且支援更多格式轉換
  4. 因此架構會變成：vstest.console.exe 產生 GitLab 需要的 Cobertura 格式，ReportGenerator 再將其轉換成 Visual Studio XML 格式或是直接轉成 SonarQube 格式，甚至也可以多轉出一份易閱讀的 HTML 格式
  
  > SonarQube
  1. 以 SonarQube v10.6 版本為例，對於 C# 來說，test report 報表支援 Trx、Nunit、XUnit 與 SonarQube 格式；code coverage 報表支援 OpenCover、dotCover、Coverlet、dotnet-coverage、Visual Studio XML 與 SonarQube 格式
  2. 說到產生的方式 test report 報表的方式，如果用 Nunit 格式也可以，不過就需要搭配第三方工具 NunitXml.TestLogger
  3. 說到產生的方式 code coverage 報表的方式，OpenCover 已停止維護、dotCover 需要付費、dotnet-coverage 為 Microsoft 官方工具 (可透過 dotnet tool install 安裝) 支援跨平台、Coverlet 為開源社群的工具 (可透過 NuGet 安裝) 支援跨平台。後兩者主要差異在於，前者可透過 [dotnet-coverage collect](https://github.com/microsoft/codecoverage/blob/main/README.md)，輸出 Visual Studio Binary 格式，即 *.coverage；而後者有被 Microsoft 整合到 [dotnet test --collect "XPlat Code Coverage"](https://github.com/coverlet-coverage/coverlet/blob/master/README.md) 裡了，只是目前還不能輸出 Visual Studio Binary 格式，也就是若要顯示在 Visual Studio 上可能還需要額外的插件
  4. 若透過 ReportGenerator 轉出 Visual Studio XML 格式會有很多份，每個測試案例就是獨立一份，所以 sonar.cs.vscoveragexml.reportsPaths 欄位支援 wildcard；而轉出 SonarQube 格式只會有一份，預設叫做 SonarQube.xml，所以 sonar.coverageReportPaths 欄位不支援 wildcard
  
  > GitLab
  1. GitLab 顯示 code coverage 的地方會在 Merge Request 裡面，如果想在 Jobs 頁面上顯示 code coverage 的百分比，需要使用 coverage 關鍵字 (透過 ReportGenerator 產生 TeamCitySummary 格式，並從 console output 中提取覆蓋率百分比)，其中 CodeCoverageS 代表 Statement Coverage 語句覆蓋率
</details>