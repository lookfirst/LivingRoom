<img src="logo.png" alt="LivingRoom Logo" width="50%">

# LivingRoom

A trivial macOS application that automatically reconnects your AirPlay (HomePods) audio devices after sleep/wake.

100% vibe-coded with Claude. Logo/Icon by ChatGPT. I've never written Swift, and it has been years since I've written AppleScript. The fact that I can create this in a couple of hours by promting AI is amazing.

## The Problem

When a Mac goes to sleep, the connection to AirPlay (HomePods) devices is dropped. This is particularly annoying with Mac minis connected to TVs using HomePods as speakers - every time the mini wakes up, you have to manually re-select the HomePods as the audio output.

## The Solution

This app automatically re-selects your AirPlay (HomePods) device whenever your Mac wakes from sleep. Hook it up to run at login, and the problem disappears.

## Features

- Automatically checks and prompts for accessibility permissions
- Runs automatically when screen is unlocked
- Configurable device name
- Launch at login (macOS 13.0+)
- Stores settings in `~/.config/LivingRoom/config.json`
- App with minimal UI, intentionally sits in the Dock so that it can be easily run with command-r

## Getting Started

Clone the repository:

```bash
git clone https://github.com/lookfirst/LivingRoom.git
cd LivingRoom
```

## Building

```bash
./build.sh
```

## Running

```bash
open build/LivingRoom.app
```

## Installing

```bash
cp -r build/LivingRoom.app /Applications/
```

## Usage

1. Launch the app - it will appear in the dock as "LivingRoom"
2. Open up System Preferences, "Accessibility" preference pane, enable "LivingRoom"
3. Click the app title and select "Set Device Name..." (command-,)
4. Enter your AirPlay device name (e.g., "Living Room")
5. Enable "Launch at Login" to start the app automatically when your Mac boots
6. The app will now run the AirPlay script whenever your machine wakes up
7. You can also manually trigger it via "Run Now" (command-r) in the menu

Note, if you replace the app with a new version, you might have to do the Accessibility dance again by removing the app first and then adding it back in again.

## Requirements

- macOS 13.0+
- Accessibility permissions for System Events control

## License

MIT
