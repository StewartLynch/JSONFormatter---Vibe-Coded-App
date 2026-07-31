# JSONFormatter
> Note:  This is the app created for the tutorial on [Vibe Coding a macOS App in Xcode 27 | Build a JSON Formatter from Scratch]()
> 
JSONFormatter is a native macOS SwiftUI app for validating, formatting, and exporting JSON.

## Download Installer
Get the [latest Release](https://github.com/StewartLynch/JSONFormatter---Vibe-Coded-App/releases/latest/download/JSONFormatter.dmg)

The app provides a two-pane workspace: paste or load source JSON on the left, then review the pretty-printed result or parser error details on the right.

## Features

- Live JSON validation while typing or pasting
- Pretty-printed output with sorted keys and unescaped slashes
- Clear invalid JSON state with parser message, line/column when available, and source context
- Open `.json` files with the native file picker
- Drag and drop JSON files into the source pane
- Export formatted JSON through the native save panel
- Smart quote sanitization for pasted text
- Native macOS Light Mode and Dark Mode styling

## Requirements

- macOS 26 or later
- Xcode 26 or later

## Project Structure

```text
JSONFormatter.xcodeproj
JSONFormatter/
  Commands/      App menu command definitions
  Models/        Formatting result and file document models
  Services/      JSON formatting, sanitizing, and file loading
  ViewModels/    Observable app state and validation workflow
  Views/         SwiftUI panes, headers, empty states, and errors
```

## Getting Started

1. Open `JSONFormatter.xcodeproj` in Xcode.
2. Select the `JSONFormatter` scheme.
3. Build and run the app.

## Usage

- Paste JSON into the source pane to format it automatically.
- Choose **File > Open...** or press `Command-O` to load a JSON file.
- Drag a `.json` file into the source pane to load it.
- Choose **File > Export Formatted JSON...** or press `Shift-Command-S` to save the formatted output.

Export is available only when the current source JSON is valid.

## Implementation Notes

The formatter uses Foundation's `JSONSerialization` with `.prettyPrinted`, `.sortedKeys`, and `.withoutEscapingSlashes`. Validation is debounced in the view model and runs formatting work off the main actor so the editor stays responsive.

## License

Copyright (c) 2026 CreaTECH Solutions (Stewart Lynch). All rights reserved.
