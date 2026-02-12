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
            tell process "ControlCenter"
                -- Find and click Sound menu bar item
                set soundItem to first menu bar item of menu bar 1 whose description contains "sound"
                click soundItem
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
