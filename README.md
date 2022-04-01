# Scripting with SwiftUI Demo

"Scripting with SwiftUI" demo for FinMacAdmin meetup 13.04.2022. 

This is a sequel for 2019 FinMacAdmin [Scripting in Swift](https://github.com/jlehikoinen/ScriptingInSwiftDemo) presentation.

The demo script `DefaultMailApp.swift` can be used for setting up default email application (macOS Mail or MS Outlook). Try `DefaultMailAppOnlyUI.swift` if you want test the UI only.

## Requirements

* Xcode 13 or Xcode Command Line Tools installed

## Setup

Install Xcode or Xcode Command Line Tools.

> Tip: Install Xcode Command Line Tools by running `swift` in Terminal app.

Download or `git clone` this repo.

## Usage

GUI example (button functionality disabled):

`$ ./DefaultMailAppOnlyUI.swift`

Choose default email app example:

`$ ./DefaultMailApp.swift`

Empty window example:

`$ ./EmptyWindow.swift`

## Default email app

**TODO: Add screenshot**

## Default email app configuration

`DefaultMailApp.swift` struct `DefaultApp` uses Launch Services API for changing default email application. See details below.

Apple documentation: https://developer.apple.com/documentation/coreservices/launch_services

macOS Mail Launch Services handlers:

```
com.apple.mail.email:   com.apple.mail
public.vcard:           com.apple.AddressBook
com.apple.ical.ics:     com.apple.CalendarFileHandler
```

MS Outlook Launch Services handlers:

```
com.apple.mail.email:                   com.microsoft.outlook
com.microsoft.outlook16.email-message:  com.microsoft.outlook
public.vcard:                           com.microsoft.outlook
com.apple.ical.ics:                     com.microsoft.outlook
com.microsoft.outlook16.icalendar:      com.microsoft.outlook
```

macOS Mail URL Scheme:

```
mailto: com.apple.mail
```

MS Outlook URL Scheme:

```
mailto: com.microsoft.outlook
```

## Additional information

* Menu bar displays the active app name as "swift-frontend" in GUI scripts
* Scripts have been tested only on macOS 12
* Animations can output `CVCGDisplayLink` warning messages to console

## Todo

* How to implement [CommandMenu](https://developer.apple.com/documentation/swiftui/commandmenu) in SwiftUI scripts?