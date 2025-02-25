@echo off
setlocal EnableDelayedExpansion

:: 设置Chrome路径和配置文件存储位置
set "CHROME_PATH=C:\Program Files\Google\Chrome\Application\chrome.exe"
set "PROFILES_DIR=E:\chromeduokai\ChromeProfiles"
set "DESKTOP_DIR=%USERPROFILE%\Desktop"

:: 检查Chrome是否存在
if not exist "%CHROME_PATH%" (
    echo Chrome not found at default location. Please edit the script to set correct path.
    pause
    exit /b 1
)

:menu
cls
echo Chrome Profile Manager
echo ====================
echo 1. Create new Chrome profile
echo 2. Batch Create Chrome profile
echo 3. Launch existing profile
echo 4. List all profiles
echo 5. Open All Chrome profile
echo 6. Delete profile
echo 7. Delete all profiles
echo 8. Close all Chrome profiles
echo 9. Exit
echo.

set /p choice="Enter your choice (1-8): "

if "%choice%"=="1" goto create_profile
if "%choice%"=="2" goto batch_create_profile
if "%choice%"=="3" goto launch_profile
if "%choice%"=="4" goto list_profiles
if "%choice%"=="5" goto open_all_profiles
if "%choice%"=="6" goto delete_profile
if "%choice%"=="7" goto delete_all_profiles
if "%choice%"=="8" goto close_all_profiles
if "%choice%"=="9" exit /b 0
goto menu

:close_all_profiles
echo Closing all Chrome instances...
taskkill /F /IM chrome.exe
echo All Chrome instances closed.
pause
goto menu


:batch_create_profile
echo.
set /p num_profiles="Enter the number of profiles to create: "
set /p base_name="Enter the base name for profiles: "

echo Number of profiles: %num_profiles%
echo Base name for profiles: %base_name%

for /l %%i in (1,1,%num_profiles%) do (
    set "profile_name=!base_name!%%i"
    call :create_profile_b "!profile_name!"
    echo "%profile_name%"
) 

echo Batch creation completed
pause
goto menu

:create_profile_b
set "profile_path=%PROFILES_DIR%\%1"
echo Attempting to create profile at: "%profile_path%\Default"
if not exist "%profile_path%\Default" (
    mkdir "%profile_path%\Default"
    echo Created profile directory: "%profile_path%\Default"
) else (
    echo Profile directory already exists: "%profile_path%"
)
goto :eof


:delete_all_profiles
echo.
set /p confirm="Are you sure you want to delete all profiles? (Y/N): "
if /i "%confirm%"=="Y" (
    rmdir /s /q "%PROFILES_DIR%"
    echo All profiles deleted successfully.
) else (
    echo Delete cancelled.
)
pause
goto menu

:open_all_profiles
echo.
echo Opening all created Chrome profiles...
for /d %%p in ("%PROFILES_DIR%\*") do (
    start "" "%CHROME_PATH%" --user-data-dir="%%p" --title="Profile %%p" --no-first-run --no-default-browser-check
)
echo All profiles opened.
pause
goto menu

:create_profile
echo.
set /p profile_name="Enter profile name: "

:: 创建配置文件目录
if not exist "%PROFILES_DIR%\%profile_name%\Default" (
    mkdir "%PROFILES_DIR%\%profile_name%\Default"
) 



:: 创建Local State文件
echo { > "%PROFILES_DIR%\%profile_name%\Local State"
echo   "browser": { >> "%PROFILES_DIR%\%profile_name%\Local State"
echo     "enabled_labs_experiments": [], >> "%PROFILES_DIR%\%profile_name%\Local State"
echo     "last_redirect_origin": "" >> "%PROFILES_DIR%\%profile_name%\Local State"
echo   } >> "%PROFILES_DIR%\%profile_name%\Local State"
echo } >> "%PROFILES_DIR%\%profile_name%\Local State"

:: 创建启动快捷方式
echo @echo off > "%DESKTOP_DIR%\Chrome-%profile_name%.bat"
echo set "CHROME_PATH=%CHROME_PATH%" >> "%DESKTOP_DIR%\Chrome-%profile_name%.bat"
echo set "PROFILE_PATH=%PROFILES_DIR%\%profile_name%" >> "%DESKTOP_DIR%\Chrome-%profile_name%.bat"

if not "%proxy%"=="" (
    echo start "" "%%CHROME_PATH%%" --user-data-dir="%%PROFILE_PATH%%" --proxy-server="%proxy%" --no-first-run --no-default-browser-check >> "%DESKTOP_DIR%\Chrome-%profile_name%.bat"
) else (
    echo start "" "%%CHROME_PATH%%" --user-data-dir="%%PROFILE_PATH%%"  --no-first-run --no-default-browser-check >> "%DESKTOP_DIR%\Chrome-%profile_name%.bat"
)

echo Created profile: %profile_name%
if not "%proxy%"=="" echo Proxy set to: %proxy%
echo Shortcut created on desktop: Chrome-%profile_name%.bat
pause
goto menu

:launch_profile
echo.
echo Available profiles:
echo ------------------
dir /b "%PROFILES_DIR%" 2>nul
echo.
set /p profile_name="Enter profile name to launch: "

if not exist "%PROFILES_DIR%\%profile_name%" (
    echo Profile does not exist!
    pause
    goto menu
)

start "" "%CHROME_PATH%" --user-data-dir="%PROFILES_DIR%\%profile_name%" --title="Profile %profile_name%" --no-first-run --no-default-browser-check
goto menu

:list_profiles
echo.
echo Available Chrome profiles:
echo ------------------------
dir /b "%PROFILES_DIR%" 2>nul
echo.
pause
goto menu

:delete_profile
echo.
echo Available profiles:
echo ------------------
dir /b "%PROFILES_DIR%" 2>nul
echo.
set /p profile_name="Enter profile name to delete: "

if not exist "%PROFILES_DIR%\%profile_name%" (
    echo Profile does not exist!
    pause
    goto menu
)

set /p confirm="Are you sure you want to delete %profile_name%? (Y/N): "
if /i "%confirm%"=="Y" (
    rmdir /s /q "%PROFILES_DIR%\%profile_name%"
    del "%DESKTOP_DIR%\Chrome-%profile_name%.bat" 2>nul
    echo Profile deleted successfully.
) else (
    echo Delete cancelled.
)
pause
goto menu
