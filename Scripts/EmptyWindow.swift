#!/usr/bin/swift

import Cocoa
import SwiftUI

// MARK: SwiftUI

struct ContentView: View {
    
    var body: some View {
        EmptyView()
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
