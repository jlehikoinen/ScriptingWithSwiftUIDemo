#!/usr/bin/swift

import Cocoa
import SwiftUI

// MARK: SwiftUI main view

struct ContentView: View {
    
    // App data
    @State var apps = [
        AppProperties(name: AppFriendlyName.appleMail,
                      path: AppPath.appleMail,
                      bundleId: UTIHandler.appleMailId,
                      utiHandlers: UTIHandler.macosAppsHandlers, defaultApp: true),
        AppProperties(name: AppFriendlyName.microsoftOutlook,
                      path: AppPath.microsoftOutlook,
                      bundleId: UTIHandler.microsoftOutlookId,
                      utiHandlers: UTIHandler.microsoftOutlookHandlers, defaultApp: false)
    ]
    
    // Animation
    @State var iconHighlightAnimating: Bool = false
    
    var body: some View {
        VStack {
            
            Text("Choose default email app")
                .font(.largeTitle)
                // .font(.system(size: 36))
            
            List {
                ForEach(apps) { app in
                    HStack {

                        Spacer()

                        ZStack {
                            // Selected app icon background highlight
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .frame(width: 90.0, height: 90.0)
                                .foregroundColor(.indigo)
                                .opacity(app.defaultApp ? 1 : 0)
                                // Animations
                                // .animation(.default, value: iconHighlightAnimating)
                                .animation(.easeInOut(duration: 1), value: iconHighlightAnimating)
                            // Icon
                            Image(nsImage: app.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80.0, height: 80.0)
                        }
                        .frame(width: 140, height: 80)

                        Spacer()

                        Button(action: {
                            defaultAppOrNot(app)
                            iconHighlightAnimating.toggle()
                        }) {
                            Text(app.wrappedName)
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        // Custom button styles
                        .buttonStyle(CustomButtonStyleGray())
                        // .buttonStyle(CustomButtonStyleColorful())

                        Spacer()
                    }
                    .padding(.vertical, 12)
                }
            }
        }
        .padding(.vertical, 20)
    }
    
    // MARK: Launch Services helper methods
    
    // Demo switcher
    func defaultAppOrNot(_ app: AppProperties) {
        
        print("\(app.wrappedName) selected")
                            
        for index in 0..<apps.count {
            if apps[index].id == app.id {
                apps[index].defaultApp = true
            } else {
                apps[index].defaultApp = false
            }
        }
    }
}

// MARK: Custom styles

struct CustomButtonStyleGray: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            // Static button size
            .frame(width: 120, height: 50)
            .background(.gray)
                .opacity(configuration.isPressed ? 0.5 : 1)
            .foregroundColor(.primary)
                .opacity(configuration.isPressed ? 0.5 : 1)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(.white, lineWidth: 1)
            )
    }
}

struct CustomButtonStyleColorful: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            // Static button size
            .frame(width: 120, height: 50)
            .background(LinearGradient(colors: [.pink, .purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                .opacity(configuration.isPressed ? 0.5 : 1)
            .foregroundColor(.primary)
                .opacity(configuration.isPressed ? 0.5 : 1)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.8 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: Helper struct for app properties

struct AppProperties: Identifiable {
    
    let id = UUID()
    let name: AppFriendlyName
    let path: AppPath
    let bundleId: String
    let utiHandlers: [String: String]
    var defaultApp: Bool = false
    
    var wrappedName: String {
        name.rawValue
    }
    
    var wrappedPath: String {
        path.rawValue
    }
    
    var icon: NSImage {

        var image = NSImage()
        // https://stackoverflow.com/questions/62525921/how-to-get-a-high-resolution-app-icon-for-any-application-on-a-mac
        if let representation = NSWorkspace.shared.icon(forFile: wrappedPath)
            .bestRepresentation(for: NSRect(x: 0, y: 0, width: 128, height: 128), context: nil, hints: nil) {
            image = NSImage(size: representation.size)
            image.addRepresentation(representation)
        }
        return image
    }
}

// MARK: Enums

enum AppFriendlyName: String {
    
    case appleMail = "macOS Mail"
    case microsoftOutlook = "Outlook"
}

enum AppPath: String {
    
    case appleMail = "/System/Applications/Mail.app"
    case microsoftOutlook = "/Applications/Microsoft Outlook.app"
}

enum UrlScheme {
    
    static let mailTo = "mailto"
}

enum UTIHandler {
    
    static let appleMailId = "com.apple.mail"
    static let microsoftOutlookId = "com.microsoft.outlook"
    
    static let macosAppsHandlers = [
        "com.apple.mail.email": Self.appleMailId,
        "public.vcard": "com.apple.AddressBook",
        "com.apple.ical.ics": "com.apple.CalendarFileHandler",
    ]
    
    static let microsoftOutlookHandlers = [
        "com.apple.mail.email": Self.microsoftOutlookId,
        "public.vcard": Self.microsoftOutlookId,
        "com.apple.ical.ics": Self.microsoftOutlookId,
        "com.microsoft.outlook16.email-message": Self.microsoftOutlookId,
        "com.microsoft.outlook16.icalendar": Self.microsoftOutlookId
    ]
}



// MARK: App and window setup

class AppDelegate: NSObject, NSApplicationDelegate {
    
    let appName = "Demo App"
    
    // Resizable window
    let window = NSWindow(contentRect: NSMakeRect(0, 0, .zero, .zero),
                          styleMask: [.titled, .closable, .miniaturizable, .resizable],
                          backing: .buffered,
                          defer: true)
    
    // Methods
    func setupUI() {
        
        // Window properties
        window.center()
        window.title = appName
        
        // "Normal" window presence (activation & exit)
        window.makeKeyAndOrderFront(nil)
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        
        // Setup window's SwiftUI content view with min. width and height
        window.contentView = NSHostingView(
            rootView: ContentView()
                .frame(minWidth: 600,
                       maxWidth: .infinity,
                       minHeight: 340,
                       maxHeight: .infinity)
        )
        
        // Dock icon
        setupDockIcon(path: "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/ToolbarCustomizeIcon.icns")
    }
    
    func setupDockIcon(path: String) {
        
        let icon = NSImage(byReferencingFile: path)!
        icon.size = CGSize(width: 128, height: 128)
        NSApp.applicationIconImage = icon
    }
    
    // Required app delegate method
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupUI()
    }
    
    // Close app when window's red button is pushed
    func applicationShouldTerminateAfterLastWindowClosed(_ app: NSApplication) -> Bool {
        return true
    }
}

// MARK: Run the app

// Setup app delegate and run the app
let thisApp = NSApplication.shared
let appDelegate = AppDelegate()
thisApp.delegate = appDelegate
thisApp.run()
