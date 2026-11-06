#!/usr/bin/osascript

on run argv
    if (count of argv) is 0 then
        set deviceName to "Living Room"
    else
        set deviceName to item 1 of argv
    end if

    set maxAttempts to 3
    repeat with attempt from 1 to maxAttempts
        try
            return my setOutputToDevice(deviceName)
        on error errMsg number errNum
            if attempt is maxAttempts then
                error errMsg number errNum
            end if
            delay 0.5
        end try
    end repeat
end run

on setOutputToDevice(deviceName)
    with timeout of 8 seconds
        tell application "System Events"
            if not (exists process "ControlCenter") then
                error "ControlCenter process not found"
            end if
            -- Menu bar controls and their popups need not belong to the same process.
            set soundItem to missing value
            repeat with ownerName in {"MenuBarAgent", "ControlCenter", "SystemUIServer"}
                if exists process (contents of ownerName) then
                    tell process (contents of ownerName)
                        repeat with menuBar in (get every menu bar)
                            -- Newer macOS nests items in groups and omits their descriptions.
                            repeat with menuItem in (get entire contents of menuBar)
                                if class of menuItem is menu bar item then
                                    set isSound to false
                                    try
                                        set isSound to (value of attribute "AXIdentifier" of menuItem is "com.apple.menuextra.sound")
                                    end try
                                    if not isSound then
                                        try
                                            set isSound to (description of menuItem contains "sound")
                                        end try
                                    end if
                                    if isSound then
                                        set soundItem to contents of menuItem
                                        exit repeat
                                    end if
                                end if
                            end repeat
                            if soundItem is not missing value then exit repeat
                        end repeat
                    end tell
                end if
                if soundItem is not missing value then exit repeat
            end repeat
            if soundItem is missing value then
                error "Sound control not found. Set Sound to always show in the macOS menu bar."
            end if
            click soundItem

            tell process "ControlCenter"
                delay 0.6

                -- Look for the window that appears
                repeat 20 times
                    if exists window 1 then exit repeat
                    delay 0.1
                end repeat
                if not (exists window 1) then
                    key code 53 -- Escape key
                    error "Sound output window did not appear"
                end if

                tell window 1
                    tell group 1
                        tell scroll area 1
                            -- Find checkbox by AXIdentifier attribute
                            set allCheckboxes to every checkbox
                            set foundDevice to false
                            repeat with cb in allCheckboxes
                                try
                                    set cbIdentifier to value of attribute "AXIdentifier" of cb
                                    if cbIdentifier contains "sound-device-" & deviceName then
                                        click cb
                                        set foundDevice to true
                                        exit repeat
                                    end if
                                end try
                            end repeat

                            key code 53 -- Escape key

                            if foundDevice then
                                return "Successfully set output to " & deviceName
                            else
                                error "Device '" & deviceName & "' not found"
                            end if

                        end tell
                    end tell
                end tell
            end tell
        end tell
    end timeout
end setOutputToDevice
