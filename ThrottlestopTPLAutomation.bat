@echo off
REM ============================================================================
REM                 Throttlestop TPL Automation
REM ============================================================================
REM This script automates the process of changing ThrottleStop profiles,
REM configuring TPL settings, and applying Windows power plans.
REM
REM IMPORTANT:
REM 1. Replace the placeholders for TS_EXE and TS_INI with the actual paths
REM    to your ThrottleStop.exe and ThrottleStop.ini files.
REM 2. Update the GUIDs for the power plans (Performance_GUID, Balanced_GUID,
REM    Quiet_GUID, Battery_GUID) with the GUIDs for your system's power plans.
REM    You can find these GUIDs by running the command "powercfg -l" in
REM    Command Prompt.
REM 3. Modify the PROFILE_NAMES and corresponding PROFILE_GUIDS below to match
REM    your desired profile names and their associated power plan GUIDs.
REM
REM Usage:
REM   ThrottlestopTPLAutomation.bat <ProfileName> <PL1[c|C]> <PL2[c|C]> <TTL>
REM   Example 1: ThrottlestopTPLAutomation.bat Quiet 35 45 0.002
REM   Example 2: ThrottlestopTPLAutomation.bat 2 35 45 32
REM   Example 3: ThrottlestopTPLAutomation.bat Performance 35c 45 20
REM   Example 4: ThrottlestopTPLAutomation.bat 0 115C 135C 2560
REM
REM   Profiles can be specified by name or number (0=Performance, 1=Balanced, etc.)
REM   PL1 and PL2 values can be followed by "c" or "C" to indicate that the 
REM   corresponding value should be clamped.
REM ============================================================================

setlocal EnableDelayedExpansion

REM --- Paths to ThrottleStop executable and INI file ---
set "TS_EXE=C:\Users\ZSungat\Desktop\ThrottleStop.exe"
set "TS_INI=C:\Users\ZSungat\Desktop\ThrottleStop.ini"

set "SCRIPT_DIR=%~dp0"
set "BACKUP_INI=%SCRIPT_DIR%backup-ThrottleStop.ini"

for /f "tokens=1-3 delims=/ " %%a in ('date /t') do set "mydate=%%c%%b%%a"
for /f "tokens=1-2 delims=: " %%a in ('time /t') do (
    set "mytime=%%a:%%b"
)
set "LOG_FILE=%SCRIPT_DIR%TTALogs.txt"

echo ========================================================================== >> "!LOG_FILE!"
echo		       ThrottleStop Profile Changer Session Started >> "!LOG_FILE!"
echo ========================================================================== >> "!LOG_FILE!"

for /f "tokens=2 delims==" %%a in ('wmic os get Caption /value') do (
    set "os_name=%%a"
    set "os_name=!os_name:Microsoft =!"
    set "os_name=!os_name:Windows =Win!"
)
for /f "tokens=2 delims==" %%a in ('wmic os get BuildNumber /value') do set "build=%%a"
echo [%mydate% %mytime%] Operating System: !os_name! Build !build! >> "!LOG_FILE!"

echo [%mydate% %mytime%] ThrottleStop Executable Path: !TS_EXE! >> "!LOG_FILE!"
echo [%mydate% %mytime%] ThrottleStop INI Path: !TS_INI! >> "!LOG_FILE!"

if not exist "!BACKUP_INI!" (
    echo [%mydate% %mytime%] Creating backup of ThrottleStop.ini... >> "!LOG_FILE!"
    copy "!TS_INI!" "!BACKUP_INI!" >nul
    if errorlevel 1 (
        echo [%mydate% %mytime%] Error: Failed to create backup >> "!LOG_FILE!"
        exit /b 1
    )
    echo [%mydate% %mytime%] Backup created successfully at !BACKUP_INI! >> "!LOG_FILE!"
)

set "PROFILE_NAME="
set "PL1="
set "PL2="
set "TTL="
set "PL1_CLAMPED=false"
set "PL2_CLAMPED=false"

REM --- Power Plan GUID Mapping (Customize these) ---
set "Performance_GUID=52521609-efc9-4268-b9ba-67dea73f18b2"
set "Balanced_GUID=85d583c5-cf2e-4197-80fd-3789a227a72c"
set "Quiet_GUID=16edbccd-dee9-4ec4-ace5-2f0b5f2a8975"
set "Battery_GUID=872d9e65-d1af-4f81-a23c-21326ff96305"


REM --- Profile Names (Customize these) ---
set "PROFILE_NAMES=Performance Balanced Quiet Battery"

echo [%mydate% %mytime%] Arguments passed: %* >> "!LOG_FILE!"

if "%~1"=="" (
    echo [%mydate% %mytime%] Usage: %~nx0 profile pl1 pl2 ttl >> "!LOG_FILE!"
    echo [%mydate% %mytime%] Example: %~nx0 Performance 35 45 0.002 >> "!LOG_FILE!"
    echo [%mydate% %mytime%] Available profiles: %PROFILE_NAMES% or numeric mappings 0, 1, 2, 3 >> "!LOG_FILE!"
    exit /b 1
)

set "PROFILE_NAME=%~1"
set "PL1=%~2"
set "PL2=%~3"
set "TTL=%~4"

echo [%mydate% %mytime%] Profile Change Request >> "!LOG_FILE!"
echo [%mydate% %mytime%] Requested Profile: !PROFILE_NAME! >> "!LOG_FILE!"

if "%PL1:~-1%"=="C" (
    set "PL1=%PL1:~0,-1%"
    set "PL1_CLAMPED=true"
)
if "%PL1:~-1%"=="c" (
    set "PL1=%PL1:~0,-1%"
    set "PL1_CLAMPED=true"
)

if "%PL2:~-1%"=="C" (
    set "PL2=%PL2:~0,-1%"
    set "PL2_CLAMPED=true"
)
if "%PL2:~-1%"=="c" (
    set "PL2=%PL2:~0,-1%"
    set "PL2_CLAMPED=true"
)

echo [%mydate% %mytime%] PL1 Value: !PL1! >> "!LOG_FILE!"
echo [%mydate% %mytime%] PL2 Value: !PL2! >> "!LOG_FILE!"
echo [%mydate% %mytime%] TTL Value: !TTL! >> "!LOG_FILE!"
echo [%mydate% %mytime%] PL1 Clamped: !PL1_CLAMPED! >> "!LOG_FILE!"
echo [%mydate% %mytime%] PL2 Clamped: !PL2_CLAMPED! >> "!LOG_FILE!"

set "NUMERIC_PROFILE="
if "!PROFILE_NAME!"=="0" set "PROFILE_NAME=Performance"
if "!PROFILE_NAME!"=="1" set "PROFILE_NAME=Balanced"
if "!PROFILE_NAME!"=="2" set "PROFILE_NAME=Quiet"
if "!PROFILE_NAME!"=="3" set "PROFILE_NAME=Battery"

set "PROFILE_NUM="
for %%a in (%PROFILE_NAMES%) do (
    set /a PROFILE_NUM+=1
    if /i "!PROFILE_NAME!"=="%%a" (
        set "POWER_PLAN_GUID=!%%a_GUID!"
        goto found_profile
    )
)
:found_profile

if not "!PROFILE_NUM!"=="" set /a "NUMERIC_PROFILE=!PROFILE_NUM!-1"

if "!PL1!"=="" (
    echo [%mydate% %mytime%] Error: Missing PL1 value >> "!LOG_FILE!"
    exit /b 1
)
if "!PL2!"=="" (
    echo [%mydate% %mytime%] Error: Missing PL2 value >> "!LOG_FILE!"
    exit /b 1
)

echo !PL1!|findstr /r "^[0-9][0-9]*$" >nul || (
    echo [%mydate% %mytime%] Error: PL1 must be a positive number >> "!LOG_FILE!"
    exit /b 1
)
echo !PL2!|findstr /r "^[0-9][0-9]*$" >nul || (
    echo [%mydate% %mytime%] Error: PL2 must be a positive number >> "!LOG_FILE!"
    exit /b 1
)

set /A PL1_HEX=(!PL1!*8)
set /A PL2_HEX=(!PL2!*8)

for /f "tokens=*" %%a in ('powershell -NoProfile -Command "[Convert]::ToString(!PL1_HEX!, 16).PadLeft(3, '0').ToUpper()"') do set "PL1_HEX_PADDED=%%a"
for /f "tokens=*" %%a in ('powershell -NoProfile -Command "[Convert]::ToString(!PL2_HEX!, 16).PadLeft(3, '0').ToUpper()"') do set "PL2_HEX_PADDED=%%a"

if "!PL1_CLAMPED!"=="true" (
    set "TTL_HEX_MAP=0.0010:01;0.0012:41;0.0015:81;0.0017:C1;0.0020:03;0.0024:43;0.0029:83;0.0034:C3;0.0039:05;0.0049:45;0.0059:85;0.0068:C5;0.0078:07;0.0098:47;0.0117:87;0.0137:C7;0.0156:09;0.0195:49;0.0234:89;0.0273:C9;0.0313:0B;0.0391:4B;0.0469:8B;0.0547:CB;0.0625:0D;0.0781:4D;0.0938:8D;0.1094:CD;0.1250:0F;0.1563:4F;0.1875:8F;0.2180:CF;0.2500:11;0.3125:51;0.3750:91;0.4375:D1;0.5000:13;0.6250:53;0.7500:93;0.8750:D3;1.00:15;1.25:55;1.50:95;1.75:D5;2.00:17;2.50:57;3.00:97;3.50:D7;4:19;5:59;6:99;7:D9;8:1B;10:5B;12:9B;14:DB;16:1D;20:5D;24:9D;28:DD;32:1F;40:5F;48:9F;56:DF;64:21;80:61;96:A1;112:E1;128:23;160:63;192:A3;224:E3;256:25;320:65;384:A5;448:E5;512:27;640:67;768:A7;896:E7;1024:29;1280:69;1536:A9;1792:E9;2048:2B;2560:6B;3072:AB;3584:EB;4096:2D;5120:6D;6144:AD;7168:ED;8196:2F;10240:6F;12288:AF;14336:EF;16384:31;20480:71;24576:B1;28672:F1;32768:33;40960:73;49152:B3;57344:F3;65536:35;81920:75;98304:B5;114688:F5;131072:37;163840:77;196608:B7;229376:F7;262144:39;327680:79;393216:B9;458752:F9;524288:3B;655360:7B;786432:BB;917504:FB;1048576:3D;1310720:7D;1572864:BD;1835008:FD;2097152:3F;2621440:7F;3145728:BF;3670016:FF;"
) else (
    set "TTL_HEX_MAP=0.0010:00;0.0012:40;0.0015:80;0.0017:C0;0.0020:02;0.0024:42;0.0029:82;0.0034:C2;0.0039:04;0.0049:44;0.0059:84;0.0068:C4;0.0078:06;0.0098:46;0.0117:86;0.0137:C6;0.0156:08;0.0195:48;0.0234:88;0.0273:C8;0.0313:0A;0.0391:4A;0.0469:8A;0.0547:CA;0.0625:0C;0.0781:4C;0.0938:8C;0.1094:CC;0.1250:0E;0.1563:4E;0.1875:8E;0.2180:CE;0.2500:10;0.3125:50;0.3750:90;0.4375:D0;0.5000:12;0.6250:52;0.7500:92;0.8750:D2;1.00:14;1.25:54;1.50:94;1.75:D4;2.00:16;2.50:56;3.00:96;3.50:D6;4:18;5:58;6:98;7:D8;8:1A;10:5A;12:9A;14:DA;16:1C;20:5C;24:9C;28:DC;32:1E;40:5E;48:9E;56:DE;64:20;80:60;96:A0;112:E0;128:22;160:62;192:A2;224:E2;256:24;320:64;384:A4;448:E4;512:26;640:66;768:A6;896:E6;1024:28;1280:68;1536:A8;1792:E8;2048:2A;2560:6A;3072:AA;3584:EA;4096:2C;5120:6C;6144:AC;7168:EC;8196:2E;10240:6E;12288:AE;14336:EE;16384:30;20480:70;24576:B0;28672:F0;32768:32;40960:72;49152:B2;57344:F2;65536:34;81920:74;98304:B4;114688:F4;131072:36;163840:76;196608:B6;229376:F6;262144:38;327680:78;393216:B8;458752:F8;524288:3A;655360:7A;786432:BA;917504:FA;1048576:3C;1310720:7C;1572864:BC;1835008:FC;2097152:3E;2621440:7E;3145728:BE;3670016:FE;"
)

for %%a in (!TTL_HEX_MAP!) do (
    for /f "tokens=1,2 delims=:" %%b in ("%%a") do (
        if "%%b"=="!TTL!" set "TTL_HEX=%%c"
    )
)

if not defined TTL_HEX (
    echo [%mydate% %mytime%] Error: No mapping found for TTL value !TTL! >> "!LOG_FILE!"
    exit /b 1
)

echo [%mydate% %mytime%] TTL_HEX=!TTL_HEX! >> "!LOG_FILE!"

set "POWERLIMITEAX=0x00!TTL_HEX!8!PL1_HEX_PADDED!"
if "!PL2_CLAMPED!"=="true" (
    set "POWERLIMITEDX=0x00438!PL2_HEX_PADDED!"
) else (
    set "POWERLIMITEDX=0x00428!PL2_HEX_PADDED!"
)

echo. >> "!LOG_FILE!"
echo [%mydate% %mytime%] Final Configuration Values: >> "!LOG_FILE!"
echo [%mydate% %mytime%] Profile=!NUMERIC_PROFILE! >> "!LOG_FILE!"
echo [%mydate% %mytime%] POWERLIMITEAX=!POWERLIMITEAX! >> "!LOG_FILE!"
echo [%mydate% %mytime%] POWERLIMITEDX=!POWERLIMITEDX! >> "!LOG_FILE!"

if not exist "!TS_EXE!" (
    echo [%mydate% %mytime%] Error: ThrottleStop executable not found at !TS_EXE! >> "!LOG_FILE!"
    exit /b 1
)

if not exist "!TS_INI!" (
    echo [%mydate% %mytime%] Error: ThrottleStop.ini not found at !TS_INI! >> "!LOG_FILE!"
    exit /b 1
)

tasklist /FI "IMAGENAME eq ThrottleStop.exe" 2>NUL | find /I "ThrottleStop.exe">NUL
if !ERRORLEVEL!==0 (
    echo [%mydate% %mytime%] ThrottleStop is running. Terminating it... >> "!LOG_FILE!"
    taskkill /F /IM ThrottleStop.exe
    timeout /t 2 /nobreak > NUL
)

echo [%mydate% %mytime%] Changing ThrottleStop profile to !PROFILE_NAME! (Profile=!NUMERIC_PROFILE!)... >> "!LOG_FILE!"

for /f "tokens=1,* delims==" %%a in ('findstr /b "PP0POWERLIMITEAX" "!TS_INI!"') do (
    set "PP0POWERLIMITEAX=%%b"
)

if defined NUMERIC_PROFILE (
    powershell -Command "(Get-Content '!TS_INI!') -replace 'Profile=\d+', 'Profile=!NUMERIC_PROFILE!' | Set-Content '!TS_INI!'"
    echo [%mydate% %mytime%] Updated Profile number to !NUMERIC_PROFILE! >> "!LOG_FILE!"
) else (
    echo [%mydate% %mytime%] Warning: Could not determine numeric profile value >> "!LOG_FILE!"
)

powershell -Command "(Get-Content '!TS_INI!') -replace 'POWERLIMITEAX=.*', 'POWERLIMITEAX=!POWERLIMITEAX!' | Set-Content '!TS_INI!'"
powershell -Command "(Get-Content '!TS_INI!') -replace 'POWERLIMITEDX=.*', 'POWERLIMITEDX=!POWERLIMITEDX!' | Set-Content '!TS_INI!'"
powershell -Command "(Get-Content '!TS_INI!') -replace 'PP0POWERLIMITEAX=.*', 'PP0POWERLIMITEAX=!PP0POWERLIMITEAX!' | Set-Content '!TS_INI!'"

if defined POWER_PLAN_GUID (
    echo [%mydate% %mytime%] Applying Power Plan >> "!LOG_FILE!"
    echo [%mydate% %mytime%] Power Plan GUID: !POWER_PLAN_GUID! >> "!LOG_FILE!"
    powercfg /setactive !POWER_PLAN_GUID!
    if !ERRORLEVEL!==0 (
        echo [%mydate% %mytime%] Power plan applied successfully >> "!LOG_FILE!"
    ) else (
        echo [%mydate% %mytime%] Warning: Failed to apply power plan >> "!LOG_FILE!"
    )
)

echo [%mydate% %mytime%] Starting ThrottleStop with the !PROFILE_NAME! profile... >> "!LOG_FILE!"
start "" /min "!TS_EXE!"
if !ERRORLEVEL!==0 (
    echo [%mydate% %mytime%] ThrottleStop started successfully >> "!LOG_FILE!"
) else (
    echo [%mydate% %mytime%] Error: Failed to start ThrottleStop >> "!LOG_FILE!"
    exit /b 1
)

echo. >> "!LOG_FILE!"
echo [%mydate% %mytime%] Profile change completed successfully >> "!LOG_FILE!"
echo [%mydate% %mytime%] Session completed >> "!LOG_FILE!"
echo ========================================================================== >> "!LOG_FILE!"
echo. >> "!LOG_FILE!"
echo. >> "!LOG_FILE!"
echo. >> "!LOG_FILE!"

endlocal
exit /b 0