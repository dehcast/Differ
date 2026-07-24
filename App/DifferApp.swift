import SwiftUI
import AppKit
import DifferCore
import DifferServices
import DifferUI

@main
struct DifferApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            MainWindow(
                imageComparisonService: appState.imageComparisonService,
                currentTestRun: $appState.currentTestRun
            )
            .frame(minWidth: 1200, minHeight: 800)
            .alert(
                "Something Went Wrong",
                isPresented: Binding(
                    get: { appState.errorMessage != nil },
                    set: { if !$0 { appState.errorMessage = nil } }
                ),
                presenting: appState.errorMessage
            ) { _ in
                Button("OK", role: .cancel) {}
            } message: { message in
                Text(message)
            }
        }
        .commands {
            DifferCommands()
        }
        
        Settings {
            PreferencesView()
        }
    }
}

/// App delegate to handle window activation
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Ensure app activates properly and comes to foreground
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // When clicking the dock icon, bring app to foreground
        if !flag {
            // No visible windows, create one
            return true
        } else {
            // Has visible windows, activate them
            NSApp.activate(ignoringOtherApps: true)
            return false
        }
    }
}
