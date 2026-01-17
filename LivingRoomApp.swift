import Cocoa
import Foundation
import ServiceManagement

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBar: NSStatusBar!
    var statusItem: NSStatusItem!
    var deviceName: String = "Living Room"
    let configDir = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".config/LivingRoom")
    let configFile = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".config/LivingRoom/config.json")

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Check for accessibility permissions
        checkAccessibilityPermissions()

        // Load configuration
        loadConfig()

        // Register for screen unlock notifications
        registerForScreenUnlockNotifications()

        print("LivingRoom app started. Device name: \(deviceName)")
    }

    func checkAccessibilityPermissions() {
        let accessEnabled = AXIsProcessTrusted()

        if !accessEnabled {
            print("Accessibility permissions not granted. Prompting user...")
            let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: true]
            AXIsProcessTrustedWithOptions(options)
        }
    }

    func registerForScreenUnlockNotifications() {
        let dnc = DistributedNotificationCenter.default()
        dnc.addObserver(
            self,
            selector: #selector(screenUnlocked),
            name: NSNotification.Name("com.apple.screenIsUnlocked"),
            object: nil
        )
    }

    @objc func screenUnlocked() {
        print("Screen unlocked, running AirPlay script...")
        runScript()
    }

    @objc func runScript() {
        let scriptPath = Bundle.main.path(forResource: "AirPlay", ofType: "scpt")

        guard let path = scriptPath else {
            showAlert(message: "AirPlay.scpt not found in bundle")
            return
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = [path, deviceName]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        do {
            try process.run()
            process.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""

            if !output.isEmpty {
                print("Script output: \(output)")
            }

            if process.terminationStatus != 0 {
                let errorMessage = output.isEmpty ? "Script failed with status \(process.terminationStatus)" : "Script failed with status \(process.terminationStatus):\n\n\(output)"
                showAlert(message: errorMessage)
            }
        } catch {
            showAlert(message: "Failed to run script: \(error.localizedDescription)")
        }
    }

    @objc func openSettings() {
        let alert = NSAlert()
        alert.informativeText = "Enter the AirPlay device name:"
        alert.addButton(withTitle: "Save")
        alert.addButton(withTitle: "Cancel")

        let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        textField.stringValue = deviceName
        alert.accessoryView = textField

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            deviceName = textField.stringValue
            saveConfig()
            print("Device name updated to: \(deviceName)")
        }
    }

    func loadConfig() {
        guard FileManager.default.fileExists(atPath: configFile.path) else {
            return
        }

        do {
            let data = try Data(contentsOf: configFile)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: String],
               let name = json["deviceName"] {
                deviceName = name
            }
        } catch {
            print("Failed to load config: \(error)")
        }
    }

    func saveConfig() {
        do {
            // Create config directory if it doesn't exist
            if !FileManager.default.fileExists(atPath: configDir.path) {
                try FileManager.default.createDirectory(at: configDir, withIntermediateDirectories: true)
            }

            let json = ["deviceName": deviceName]
            let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            try data.write(to: configFile)
            print("Config saved to: \(configFile.path)")
        } catch {
            showAlert(message: "Failed to save config: \(error.localizedDescription)")
        }
    }

    func showAlert(message: String) {
        let alert = NSAlert()
        alert.messageText = "LivingRoom"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }

    @objc func toggleLaunchAtLogin(_ sender: NSMenuItem) {
        if #available(macOS 13.0, *) {
            let service = SMAppService.mainApp
            let isEnabled = service.status == .enabled

            do {
                if isEnabled {
                    try service.unregister()
                    sender.state = .off
                } else {
                    try service.register()
                    sender.state = .on
                }
            } catch {
                showAlert(message: "Failed to toggle launch at login: \(error.localizedDescription)")
            }
        } else {
            // Fallback for older macOS versions
            showAlert(message: "Launch at login requires macOS 13.0 or later")
        }
    }

    func isLaunchAtLoginEnabled() -> Bool {
        if #available(macOS 13.0, *) {
            return SMAppService.mainApp.status == .enabled
        }
        return false
    }
}

// Main entry point
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

// Create main menu bar
let mainMenu = NSMenu()

// Application menu
let appMenuItem = NSMenuItem()
mainMenu.addItem(appMenuItem)

let appMenu = NSMenu()
let appName = "LivingRoom"

appMenu.addItem(NSMenuItem(title: "About \(appName)", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: ""))

appMenu.addItem(NSMenuItem.separator())
let settingsMenuItem = NSMenuItem(title: "Set Device Name...", action: #selector(AppDelegate.openSettings), keyEquivalent: ",")
settingsMenuItem.target = delegate
appMenu.addItem(settingsMenuItem)

appMenu.addItem(NSMenuItem.separator())
let launchAtLoginMenuItem = NSMenuItem(title: "Launch at Login", action: #selector(AppDelegate.toggleLaunchAtLogin(_:)), keyEquivalent: "")
launchAtLoginMenuItem.target = delegate
let isEnabled = delegate.isLaunchAtLoginEnabled()
launchAtLoginMenuItem.state = isEnabled ? .on : .off
launchAtLoginMenuItem.image = NSImage(systemSymbolName: "power", accessibilityDescription: "Launch at Login")
appMenu.addItem(launchAtLoginMenuItem)

appMenu.addItem(NSMenuItem.separator())
let runMenuItem = NSMenuItem(title: "Run Now", action: #selector(AppDelegate.runScript), keyEquivalent: "r")
runMenuItem.target = delegate
runMenuItem.image = NSImage(systemSymbolName: "play.fill", accessibilityDescription: "Run")
appMenu.addItem(runMenuItem)

appMenu.addItem(NSMenuItem.separator())
appMenu.addItem(NSMenuItem(title: "Quit \(appName)", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

appMenuItem.submenu = appMenu

app.mainMenu = mainMenu

app.run()
