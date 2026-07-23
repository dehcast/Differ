import SwiftUI
import DifferCore
import DifferServices
import DifferUI

@main
struct DifferApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            MainWindow()
                .environmentObject(appState)
                .frame(minWidth: 1200, minHeight: 800)
        }
        .commands {
            DifferCommands()
        }
        
        Settings {
            PreferencesView()
                .environmentObject(appState)
        }
    }
}
