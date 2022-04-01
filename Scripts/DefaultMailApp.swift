#!/usr/bin/swift

import Cocoa
import SwiftUI

// MARK: SwiftUI main view

struct ContentView: View {
    
    // App data (Mail & Outlook properties)
    @State var apps = [
        AppProperties(name: AppFriendlyName.appleMail,
                      path: AppPath.appleMail,
                      bundleId: UTIHandler.appleMailId,
                      utiHandlers: UTIHandler.macosAppsHandlers),
        AppProperties(name: AppFriendlyName.microsoftOutlook,
                      path: AppPath.microsoftOutlook,
                      bundleId: UTIHandler.microsoftOutlookId,
                      utiHandlers: UTIHandler.microsoftOutlookHandlers)
    ]
    
    // Animation
    @State var iconHighlightAnimating: Bool = false
    
    // View body
    var body: some View {
        VStack {
            
            // Header
            Text("Choose default email app")
                .font(.largeTitle)
                // .font(.system(size: 36))
            
            // Iterate through the list of apps
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
                            setDefaultApp(app)
                            getDefaultApp()
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
        
        .onAppear {
            getDefaultApp()
        }
    }
    
    // MARK: Launch Services helper methods
    
    func getDefaultApp() {
        
        if let appURL = LaunchServicesHelper.getDefaultScheme(for: UrlScheme.mailTo) {
            print("Default email app path (\(UrlScheme.mailTo) handler): \(appURL.path)")
            // Use current mailto handler (=path) for finding out default app
            defaultAppOrNot(path: appURL.path)
        } else {
            print("No default app found for \(UrlScheme.mailTo) scheme")
        }
        
        // List UTI handlers
        print("Current handlers:")
        // Loop through Microsoft UTIs because there are few extras compared to macOS UTIs
        for (contentType, _) in UTIHandler.microsoftOutlookHandlers {
            print(LaunchServicesHelper.getDefaultHandler(for: contentType))
        }
    }
    
    func defaultAppOrNot(path: String) {
        
        for index in 0..<apps.count {
            if apps[index].wrappedPath == path {
                apps[index].defaultApp = true
            } else {
                apps[index].defaultApp = false
            }
        }
    }
    
    func setDefaultApp(_ app: AppProperties) {
        
        print("\(app.wrappedName) selected")
        
        // Handlers for content types (UTIs)
        for (contentType, lsHandler) in app.utiHandlers {
            LaunchServicesHelper.setDefaultHandlerForContentType(handler: lsHandler, for: contentType)
        }
        
        // Handler for scheme
        LaunchServicesHelper.setDefaultHandlerForScheme(handler: app.bundleId, for: UrlScheme.mailTo)
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

// MARK: Main Launch Services helper

struct LaunchServicesHelper {
    
    static func getDefaultHandler(for contentType: String) -> String {
        
        if let appHandler = LSCopyDefaultRoleHandlerForContentType(contentType as CFString, LSRolesMask.editor) {
            let bundleId = appHandler.takeRetainedValue()
            return "\(contentType): \(bundleId)"
        }
        return "\(contentType): n/a"
    }
    
    static func getDefaultScheme(for scheme: String) -> URL? {
        
        guard let url = URL(string: "\(scheme):") else { return nil }
        if let result = LSCopyDefaultApplicationURLForURL(url as CFURL, .all, nil) {
            let appURL = result.takeRetainedValue() as URL
            return appURL
        }
        return nil
    }
    
    static func setDefaultHandlerForContentType(handler: String, for contentType: String) {
        LSSetDefaultRoleHandlerForContentType(contentType as CFString, LSRolesMask.editor, handler as CFString)
    }
    
    static func setDefaultHandlerForScheme(handler: String, for scheme: String) {
        LSSetDefaultHandlerForURLScheme(scheme as CFString, handler as CFString)
    }
}




// MARK: App and window setup

class AppDelegate: NSObject, NSApplicationDelegate {
    
    let appName = "Demo App"
    
    // Static window size
    let window = NSWindow(contentRect: NSMakeRect(0, 0, 600, 340),
                          styleMask: [.titled, .closable, .miniaturizable],
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
        
        // Setup window's SwiftUI content view
        window.contentView = NSHostingView(rootView: ContentView())
        
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
