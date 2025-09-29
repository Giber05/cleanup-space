@echo off
setlocal enabledelayedexpansion

:: Flutter/Gradle Space Cleanup Script for Windows
:: This script safely removes cache files and build artifacts to free up disk space

echo.
echo [INFO] Starting Flutter/Gradle cleanup process...
echo.

:: Function to safely remove directory
:safe_remove_dir
if exist "%~1" (
    echo [INFO] Removing %~1
    rmdir /s /q "%~1" 2>nul
    if not exist "%~1" (
        echo [SUCCESS] Removed %~1
    ) else (
        echo [WARNING] Failed to remove %~1
    )
) else (
    echo [WARNING] Directory %~1 does not exist, skipping
)
goto :eof

:: Function to safely remove file
:safe_remove_file
if exist "%~1" (
    echo [INFO] Removing %~1
    del /f /q "%~1" 2>nul
    if not exist "%~1" (
        echo [SUCCESS] Removed %~1
    ) else (
        echo [WARNING] Failed to remove %~1
    )
) else (
    echo [WARNING] File %~1 does not exist, skipping
)
goto :eof

:: Function to ask for confirmation
:ask_confirmation
echo [QUESTION] %~1 [y/N]
set /p response=
if /i "%response%"=="y" goto :confirm_yes
if /i "%response%"=="yes" goto :confirm_yes
echo [INFO] Skipped
goto :confirm_no
:confirm_yes
exit /b 0
:confirm_no
exit /b 1

:: Store initial directory for reference
set "PROJECT_DIR=%CD%"
echo [INFO] Cleaning project: %PROJECT_DIR%
echo.

:: 1. Clean Flutter build cache
echo [INFO] Cleaning Flutter build cache...
call :safe_remove_dir "build"

:: 2. Clean Android Gradle cache and build files
echo [INFO] Cleaning Android Gradle cache...
call :safe_remove_dir "android\.gradle"
call :safe_remove_dir "android\app\build"
call :safe_remove_dir "android\build"

:: 3. Clean iOS build files (if on Windows with iOS development setup)
echo [INFO] Cleaning iOS build files...
call :safe_remove_dir "ios\build"
call :safe_remove_dir "ios\Pods"
call :safe_remove_dir "ios\.symlinks"
call :safe_remove_dir "ios\Flutter\Flutter.framework"
call :safe_remove_file "ios\Flutter\Flutter.podspec"
call :safe_remove_file "ios\Podfile.lock"

:: 4. Clean macOS build files
echo [INFO] Cleaning macOS build files...
call :safe_remove_dir "macos\build"
call :safe_remove_dir "macos\Pods"
call :safe_remove_file "macos\Podfile.lock"

:: 5. Clean Windows build files
echo [INFO] Cleaning Windows build files...
call :safe_remove_dir "windows\build"

:: 6. Clean Linux build files
echo [INFO] Cleaning Linux build files...
call :safe_remove_dir "linux\build"

:: 7. Clean Web build files
echo [INFO] Cleaning Web build files...
call :safe_remove_dir "web\build"

:: 8. Clean Flutter ephemeral files
echo [INFO] Cleaning Flutter ephemeral files...
call :safe_remove_dir ".dart_tool"
call :safe_remove_file ".packages"

:: 9. Clean test coverage
echo [INFO] Cleaning test coverage files...
call :safe_remove_dir "coverage"

:: 10. Clean temporary files
echo [INFO] Cleaning temporary files...
for /r . %%f in (*.tmp) do (
    if exist "%%f" (
        del /f /q "%%f" 2>nul
        echo [SUCCESS] Removed %%f
    )
)

for /r . %%f in (*.log) do (
    if exist "%%f" (
        del /f /q "%%f" 2>nul
        echo [SUCCESS] Removed %%f
    )
)

echo.
echo [INFO] Running Flutter commands to clean cache...

:: 11. Flutter clean
where flutter >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [INFO] Running flutter clean...
    flutter clean
    echo [SUCCESS] Flutter clean completed
    
    :: 12. Flutter pub cache repair (optional - uncomment if needed)
    :: echo [INFO] Running flutter pub cache repair...
    :: flutter pub cache repair
    :: echo [SUCCESS] Flutter pub cache repair completed
) else (
    echo [WARNING] Flutter command not found, skipping flutter clean
)

echo.
echo [INFO] AGGRESSIVE CLEANUP OPTIONS (with confirmation)
echo [WARNING] The following cleanups can affect other projects on your system!
echo.

:: Global Flutter cache cleanup
if exist "%USERPROFILE%\.pub-cache" (
    call :ask_confirmation "Clean global Flutter pub cache? This affects ALL Flutter projects!"
    if %ERRORLEVEL% EQU 0 (
        echo [INFO] Cleaning global pub cache...
        where flutter >nul 2>nul
        if %ERRORLEVEL% EQU 0 (
            flutter pub cache clean
            echo [SUCCESS] Global pub cache cleaned
        ) else (
            rmdir /s /q "%USERPROFILE%\.pub-cache" 2>nul
            echo [SUCCESS] Global pub cache removed
        )
    )
) else (
    echo [WARNING] Global pub cache not found
)

echo.

:: Global Gradle cache cleanup
if exist "%USERPROFILE%\.gradle" (
    call :ask_confirmation "Clean global Gradle cache? This affects ALL Gradle projects!"
    if %ERRORLEVEL% EQU 0 (
        echo [INFO] Cleaning global Gradle cache...
        rmdir /s /q "%USERPROFILE%\.gradle\caches" 2>nul
        rmdir /s /q "%USERPROFILE%\.gradle\wrapper" 2>nul
        rmdir /s /q "%USERPROFILE%\.gradle\daemon" 2>nul
        echo [SUCCESS] Global Gradle cache cleaned
    )
) else (
    echo [WARNING] Global Gradle cache not found
)

echo.

:: Android build tools cache
if exist "%USERPROFILE%\.android\build-cache" (
    call :ask_confirmation "Clean Android build cache?"
    if %ERRORLEVEL% EQU 0 (
        rmdir /s /q "%USERPROFILE%\.android\build-cache" 2>nul
        echo [SUCCESS] Android build cache cleaned
    )
) else (
    echo [WARNING] Android build cache not found
)

echo.

:: Android NDK cleanup
echo [INFO] Android NDK cleanup...

:: Function to find Android SDK directory
:find_android_sdk
set "android_sdk="

:: Check common Android SDK locations on Windows
if defined ANDROID_HOME (
    if exist "!ANDROID_HOME!" (
        set "android_sdk=!ANDROID_HOME!"
    )
) else if defined ANDROID_SDK_ROOT (
    if exist "!ANDROID_SDK_ROOT!" (
        set "android_sdk=!ANDROID_SDK_ROOT!"
    )
) else if exist "%USERPROFILE%\AppData\Local\Android\Sdk" (
    set "android_sdk=%USERPROFILE%\AppData\Local\Android\Sdk"
) else if exist "%USERPROFILE%\Android\Sdk" (
    set "android_sdk=%USERPROFILE%\Android\Sdk"
) else if exist "C:\Android\Sdk" (
    set "android_sdk=C:\Android\Sdk"
) else if exist "C:\Program Files\Android\Sdk" (
    set "android_sdk=C:\Program Files\Android\Sdk"
)

goto :eof

:: Find Android SDK directory
call :find_android_sdk

if defined android_sdk (
    if exist "!android_sdk!" (
        set "ndk_dir=!android_sdk!\ndk"
        echo [INFO] Found Android SDK: !android_sdk!
        
        if exist "!ndk_dir!" (
            echo [INFO] Found NDK directory: !ndk_dir!
            echo [INFO] Available NDK versions:
            
            set "version_count=0"
            for /d %%d in ("!ndk_dir!\*") do (
                if exist "%%d" (
                    set /a version_count+=1
                    for %%f in ("%%d") do set "version_name=%%~nxf"
                    echo [INFO]   - !version_name!
                )
            )
            
            if !version_count! GTR 0 (
                call :ask_confirmation "Do you want to remove NDK versions? (You'll be prompted for each)"
                if %ERRORLEVEL% EQU 0 (
                    echo [INFO] Listing versions for removal...
                    for /d %%d in ("!ndk_dir!\*") do (
                        if exist "%%d" (
                            for %%f in ("%%d") do set "version_name=%%~nxf"
                            call :ask_confirmation "Remove NDK version !version_name!?"
                            if %ERRORLEVEL% EQU 0 (
                                rmdir /s /q "%%d" 2>nul
                                echo [SUCCESS] Removed NDK version !version_name!
                            ) else (
                                echo [INFO] Skipped NDK version !version_name!
                            )
                        )
                    )
                ) else (
                    echo [INFO] Skipped NDK cleanup
                )
            ) else (
                echo [WARNING] No NDK versions found in !ndk_dir!
            )
        ) else (
            echo [WARNING] NDK directory not found at !ndk_dir!
        )
    ) else (
        echo [WARNING] Android SDK directory not found
    )
) else (
    echo [WARNING] Android SDK not found
    echo [INFO] Checked locations:
    echo [INFO]   - ANDROID_HOME environment variable
    echo [INFO]   - ANDROID_SDK_ROOT environment variable
    echo [INFO]   - %USERPROFILE%\AppData\Local\Android\Sdk
    echo [INFO]   - %USERPROFILE%\Android\Sdk
    echo [INFO]   - C:\Android\Sdk
    echo [INFO]   - C:\Program Files\Android\Sdk
)

echo.

:: Node modules in project
if exist "node_modules" (
    call :ask_confirmation "Remove node_modules directory?"
    if %ERRORLEVEL% EQU 0 (
        rmdir /s /q "node_modules" 2>nul
        echo [SUCCESS] node_modules removed
        echo [INFO] Run 'npm install' or 'yarn install' to restore
    )
) else (
    echo [WARNING] No node_modules directory found
)

echo.

:: Yarn cache
if exist "%USERPROFILE%\AppData\Local\Yarn\Cache" (
    call :ask_confirmation "Clean Yarn cache? Packages will be re-downloaded when needed"
    if %ERRORLEVEL% EQU 0 (
        where yarn >nul 2>nul
        if %ERRORLEVEL% EQU 0 (
            echo [INFO] Cleaning Yarn cache using yarn command...
            yarn cache clean
            echo [SUCCESS] Yarn cache cleaned
        ) else (
            rmdir /s /q "%USERPROFILE%\AppData\Local\Yarn\Cache" 2>nul
            echo [SUCCESS] Yarn cache removed
        )
    )
) else (
    echo [WARNING] Yarn cache not found
)

:: NPM cache
if exist "%USERPROFILE%\AppData\Roaming\npm-cache" (
    call :ask_confirmation "Clean NPM cache? Packages will be re-downloaded when needed"
    if %ERRORLEVEL% EQU 0 (
        where npm >nul 2>nul
        if %ERRORLEVEL% EQU 0 (
            echo [INFO] Cleaning NPM cache using npm command...
            npm cache clean --force
            echo [SUCCESS] NPM cache cleaned
        ) else (
            rmdir /s /q "%USERPROFILE%\AppData\Roaming\npm-cache" 2>nul
            echo [SUCCESS] NPM cache removed
        )
    )
) else (
    echo [WARNING] NPM cache not found
)

echo.

:: Browser cache cleanup
echo [INFO] Browser cache cleanup options:

:: Chrome cache
if exist "%USERPROFILE%\AppData\Local\Google\Chrome\User Data\Default\Cache" (
    call :ask_confirmation "Clean Chrome cache?"
    if %ERRORLEVEL% EQU 0 (
        rmdir /s /q "%USERPROFILE%\AppData\Local\Google\Chrome\User Data\Default\Cache" 2>nul
        echo [SUCCESS] Chrome cache cleaned
    )
)

:: Edge cache
if exist "%USERPROFILE%\AppData\Local\Microsoft\Edge\User Data\Default\Cache" (
    call :ask_confirmation "Clean Edge cache?"
    if %ERRORLEVEL% EQU 0 (
        rmdir /s /q "%USERPROFILE%\AppData\Local\Microsoft\Edge\User Data\Default\Cache" 2>nul
        echo [SUCCESS] Edge cache cleaned
    )
)

echo.

:: System temp cleanup
echo [INFO] System cleanup options:

call :ask_confirmation "Clean Windows temp files?"
if %ERRORLEVEL% EQU 0 (
    echo [INFO] Cleaning Windows temp files...
    del /f /s /q "%TEMP%\*" 2>nul
    del /f /s /q "C:\Windows\Temp\*" 2>nul
    echo [SUCCESS] Windows temp files cleaned
)

echo.

:: FVM versions cleanup
echo [INFO] FVM versions cleanup...

:: Function to find FVM cache directory
:find_fvm_cache
set "fvm_cache="
set "fvm_cache_dir="

:: Check common FVM cache locations on Windows
if exist "%USERPROFILE%\.fvm\versions" (
    set "fvm_cache=%USERPROFILE%\.fvm\versions"
) else if exist "%USERPROFILE%\AppData\Local\fvm\versions" (
    set "fvm_cache=%USERPROFILE%\AppData\Local\fvm\versions"
) else if exist "%USERPROFILE%\AppData\Roaming\fvm\versions" (
    set "fvm_cache=%USERPROFILE%\AppData\Roaming\fvm\versions"
) else (
    :: Try to get cache directory from fvm command
    where fvm >nul 2>nul
    if %ERRORLEVEL% EQU 0 (
        for /f "tokens=*" %%i in ('fvm config --cache-path 2^>nul') do set "fvm_cache=%%i"
        if defined fvm_cache (
            if exist "!fvm_cache!" (
                set "fvm_cache=!fvm_cache!\versions"
            ) else (
                set "fvm_cache="
            )
        )
    )
)

if defined fvm_cache (
    set "fvm_cache_dir=!fvm_cache!"
)

goto :eof

:: Get current project FVM version
set "current_version=unknown"
if exist ".fvm\version" (
    set /p current_version=<.fvm\version
)

:: Find FVM cache directory
call :find_fvm_cache

if defined fvm_cache_dir (
    if exist "!fvm_cache_dir!" (
        echo [INFO] Found FVM cache directory: !fvm_cache_dir!
        echo [INFO] Current project FVM version: !current_version!
        
        call :ask_confirmation "Show FVM versions for manual cleanup?"
        if %ERRORLEVEL% EQU 0 (
            where fvm >nul 2>nul
            if %ERRORLEVEL% EQU 0 (
                echo [INFO] Available FVM versions:
                fvm list
                echo.
                call :ask_confirmation "Do you want to remove unused FVM versions? (You'll be prompted for each)"
                if %ERRORLEVEL% EQU 0 (
                    echo [INFO] Listing versions for removal...
                    for /d %%d in ("!fvm_cache_dir!\*") do (
                        if exist "%%d" (
                            for %%f in ("%%d") do set "version_name=%%~nxf"
                            if not "!version_name!"=="!current_version!" (
                                call :ask_confirmation "Remove FVM version !version_name!?"
                                if %ERRORLEVEL% EQU 0 (
                                    where fvm >nul 2>nul
                                    if %ERRORLEVEL% EQU 0 (
                                        fvm remove !version_name!
                                    ) else (
                                        rmdir /s /q "%%d" 2>nul
                                        echo [SUCCESS] Removed FVM version !version_name!
                                    )
                                ) else (
                                    echo [INFO] Skipped FVM version !version_name!
                                )
                            )
                        )
                    )
                )
            ) else (
                echo [WARNING] FVM command not found, manual cleanup required
                echo [INFO] Available versions in cache:
                dir "!fvm_cache_dir!" 2>nul || echo [WARNING] Cannot list versions
            )
        ) else (
            echo [INFO] Skipped FVM versions cleanup
        )
    ) else (
        echo [WARNING] FVM cache directory not found
        echo [INFO] Checked locations:
        echo [INFO]   - %USERPROFILE%\.fvm\versions
        echo [INFO]   - %USERPROFILE%\AppData\Local\fvm\versions
        echo [INFO]   - %USERPROFILE%\AppData\Roaming\fvm\versions
        where fvm >nul 2>nul
        if %ERRORLEVEL% EQU 0 (
            echo [INFO]   - FVM config cache path
        )
    )
) else (
    echo [WARNING] FVM cache directory not found
    echo [INFO] Checked locations:
    echo [INFO]   - %USERPROFILE%\.fvm\versions
    echo [INFO]   - %USERPROFILE%\AppData\Local\fvm\versions
    echo [INFO]   - %USERPROFILE%\AppData\Roaming\fvm\versions
    where fvm >nul 2>nul
    if %ERRORLEVEL% EQU 0 (
        echo [INFO]   - FVM config cache path
    )
)

:: Also check for local FVM versions (project-specific)
if exist ".fvm\versions" (
    call :ask_confirmation "Clean local FVM versions? (This only affects this project)"
    if %ERRORLEVEL% EQU 0 (
        rmdir /s /q ".fvm\versions" 2>nul
        echo [SUCCESS] Local FVM versions cleaned
    ) else (
        echo [INFO] Skipped local FVM versions cleanup
    )
)

echo.
echo [SUCCESS] Cleanup completed successfully!
echo [INFO] You can now run 'flutter pub get' to restore dependencies
echo [INFO] For iOS: run 'cd ios && pod install' to restore pods (if on macOS)
echo [INFO] For macOS: run 'cd macos && pod install' to restore pods (if on macOS)

echo.
echo [INFO] Recommended next steps:
echo 1. flutter pub get
echo 2. cd ios ^&^& pod install (if developing for iOS on macOS)
echo 3. cd macos ^&^& pod install (if developing for macOS)
echo 4. flutter build ^<platform^> (to rebuild for your target platform)

echo.
pause 