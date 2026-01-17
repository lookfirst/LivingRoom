#!/usr/bin/osascript

on run argv
    if (count of argv) is 0 then
        set deviceName to "Living Room"
    else
        set deviceName to item 1 of argv
    end if

    tell application "System Events"
        tell process "ControlCenter"
            -- Find and click Sound menu bar item
            set soundItem to first menu bar item of menu bar 1 whose description contains "sound"
            click soundItem
            delay 0.8

            -- Look for the window that appears
            if exists window 1 then
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
            end if
        end tell
    end tell
end run
