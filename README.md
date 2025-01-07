# Throttlestop TPL Automation
This repository provides a batch script to automate the configuration of [ThrottleStop's](https://www.techpowerup.com/download/techpowerup-throttlestop/) TPL (Turbo Power Limits), including adjusting PL1, PL2, TTL (Turbo Time Limit),and other settings(in the future). It also integrates custom Windows power plans for enhanced CPU power management.

> [!WARNING]
> **Use this script at your own risk. Incorrect configuration may cause system instability or performance issues.**

## Features

- **Profile Automation**: Automatically switches ThrottleStop profiles based on user-defined arguments.
- **Advanced TPL Configuration**: Customizes PL1, PL2, and TTL for fine-tuned CPU power control.
- **Windows Power Plan Integration**: Applies matching Windows power plans to align with ThrottleStop profiles for optimal performance.
- **Backup**: Creates the backup of the `ThrottleStop.ini` with initial user's unchanged settings `backup-ThrottleStop.ini`.
- **Clamping**: Allows clamping of PL1 and PL2 values by appending "c" or "C" to the values.

## Requirements

1. Install [ThrottleStop](https://www.techpowerup.com/download/techpowerup-throttlestop/) and [Lenovo Legion Toolkit](https://github.com/BartoszCichecki/LenovoLegionToolkit) on your system.
   - Ensure you have the correct paths to `ThrottleStop.exe` and `ThrottleStop.ini`.
2. A basic understanding of your system's power and performance requirements.
3. **Enable Start Minimized**: For seamless starting/restarting of `ThrottleStop.exe`, ensure the **"Start Minimized"** option is checked in **ThrottleStop -> Options -> Miscellaneous -> Start Minimized**.

## Installation

1. Clone this repository to your local machine:
   ```sh
   git clone https://github.com/ZSungat/ThrottlestopTPLAutomation.git
   ```
2. Download batch file from [Releases](https://github.com/ZSungat/ThrottlestopTPLAutomation/releases)
3. Download from *<> Code -> Download Zip*


## Configuration!

 1. **Edit ThrottleStop paths:** Replace placeholders for `TS_EXE` and `TS_INI` with the actual paths
    to your ThrottleStop.exe and ThrottleStop.ini files.

     ```bat
     REM --- Paths to ThrottleStop executable and INI file ---
     set TS_EXE="C:\Program Files\ThrottleStop\ThrottleStop.exe"
     set TS_INI="C:\Program Files\ThrottleStop\ThrottleStop.ini"
     ```
 2. **Update Power Plan GUIDs:** Replace the power plan GUIDs with those corresponding to your system's power plans. You can find these by running `powercfg -l` in Command Prompt.
     ```bat
      REM --- Power Plan GUID Mapping (Customize these) ---
      set "Performance_GUID=52521609-efc9-4268-b9ba-67dea73f18b2"
      set "Balanced_GUID=85d583c5-cf2e-4197-80fd-3789a227a72c"
      set "Quiet_GUID=16edbccd-dee9-4ec4-ace5-2f0b5f2a8975"
      set "Battery_GUID=872d9e65-d1af-4f81-a23c-21326ff96305"
     ```
 3. **Edit Profile Names and GUIDs:** Map your desired ThrottleStop profiles to the appropriate power plan GUIDs.
     ```bat
      REM --- Profile Names (Customize these) ---
      set "PROFILE_NAMES=Performance Balanced Quiet Battery"
     ```
## Usage Instructions

* Open a [Lenovo Legion Toolkit](https://github.com/BartoszCichecki/LenovoLegionToolkit).
* Navigate to the Actions tab and add a new action triggered by a power mode change for each profile.

  ![image](https://github.com/user-attachments/assets/e643ab59-29f0-4db4-8e4d-f949d2311400)

* Select/Configure the Power Mode.
  
  ![image](https://github.com/user-attachments/assets/7467da46-b559-4712-b855-627ba77acba1)

* Add New Step "Run".
    - In the "Executable Path":
      - Write/Paste the full path of the downloaded TS_Profile_Automation.bat . Example:
         ```
         C:\Users\Example\Documents\ThrottlestopTPLAutomation.bat
         ```
    - In the "Arguments":
      - Write the arguments/options like this **{ProfileName} {PL1} {PL2} {TTL}**. Example:
         ```
            ThrottlestopTPLAutomation.bat <ProfileName> <PL1[c|C]> <PL2[c|C]> <TTL>
            Example 1: ThrottlestopTPLAutomation.bat Quiet 35 45 0.002
            Example 2: ThrottlestopTPLAutomation.bat 2 35 45 32
            Example 3: ThrottlestopTPLAutomation.bat Performance 35c 45 20
            Example 4: ThrottlestopTPLAutomation.bat 0 115C 135C 2560

            Profiles can be specified by name or number (0=Performance, 1=Balanced, etc.)
            PL1 and PL2 values can be followed by "c" or "C" to indicate that the corresponding value should be clamped.
         ```
    ![image](https://github.com/user-attachments/assets/b672e071-e978-418a-84ca-d1af34b24119)

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---
